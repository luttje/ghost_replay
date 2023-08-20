local function queueFrameForReplay(ply, recording, frameIndex, delay)
    if (not recording) then
        GhostReplay.Notify(ply, "No recording found", GhostReplay.NotifyTypes.ERROR)
        return
    end

    if (not frameIndex) then
        GhostReplay.Notify(ply, "No frame found", GhostReplay.NotifyTypes.ERROR)
        return
    end

    local frame = recording[frameIndex]
    frame.frameIndex = frameIndex

    ply.GhostReplayReplaying.frameToReplay = frame
    ply.GhostReplayReplaying.frameDelay = delay
end

local function showFrame(ghost, frameToReplay)
    local appearance = frameToReplay.appearance

    if (appearance) then
        ghost:SetModel(appearance.model)
        ghost:SetSkin(appearance.skin)
        ghost:SetBodyGroups(appearance.bodygroups)
        ghost:SetColor(appearance.color)
        ghost:SetMaterial(appearance.material)
        ghost:SetSequence(appearance.sequence)
    end

    local movement = frameToReplay.movement

    ghost:SetPos(movement.pos)
    ghost:SetAngles(movement.ang)
    ghost:SetVelocity(movement.vel)
end

function GhostReplay.Record.Replay(ply, recording)
    if (not recording) then
        GhostReplay.Notify(ply, "No recording found", GhostReplay.NotifyTypes.ERROR)
        return
    end

    local ghostEntity = ents.Create("ghost_replay_ghost")
    ghostEntity:SetPos(ply:GetPos())
    ghostEntity:Spawn()

    ply.GhostReplayReplaying = {
        recording = recording,
        startTime = CurTime(),
        ghost = ghostEntity,
        pause = true,

        weaponsBeforeReplay = {},
        posBeforeReplay = ply:GetPos(),
        angBeforeReplay = ply:EyeAngles()
    }

    for _, weapon in ipairs(ply:GetWeapons()) do
        table.insert(ply.GhostReplayReplaying.weaponsBeforeReplay, weapon:GetClass())
    end

    ply:Spectate(OBS_MODE_CHASE)
    ply:SpectateEntity(ghostEntity)
    ply:StripWeapons()

    queueFrameForReplay(ply, recording, 1, 0)
    showFrame(ghostEntity, recording[1])

    net.Start("GhostReplay.OpenScrubber")
    net.WriteUInt(#recording, 32)
    net.Send(ply)

    GhostReplay.Notify(ply, "Replaying recording", GhostReplay.NotifyTypes.SUCCESS)
end

function GhostReplay.Record.Pause(ply)
    if (not ply.GhostReplayReplaying) then
        return
    end

    local recording = ply.GhostReplayReplaying.recording

    if (not recording) then
        return
    end

    ply.GhostReplayReplaying.pause = true
end

function GhostReplay.Record.SetFrame(ply, frameIndex)
    if (not ply.GhostReplayReplaying) then
        return
    end

    local recording = ply.GhostReplayReplaying.recording

    if (not recording) then
        return
    end

    queueFrameForReplay(ply, recording, frameIndex, 0)
    showFrame(ply.GhostReplayReplaying.ghost, recording[frameIndex])
end

function GhostReplay.Record.Stop(ply)
    if (not IsValid(ply)) then return end

    if (not ply.GhostReplayReplaying) then
        return
    end

    if (IsValid(ply.GhostReplayReplaying.ghost)) then
        ply.GhostReplayReplaying.ghost:Remove()
    end

    for _, weaponClass in ipairs(ply.GhostReplayReplaying.weaponsBeforeReplay) do
        ply:Give(weaponClass)
    end

    ply:UnSpectate()
    ply:Spawn()
    ply:SetPos(ply.GhostReplayReplaying.posBeforeReplay)
    ply:SetEyeAngles(ply.GhostReplayReplaying.angBeforeReplay)
    ply.GhostReplayReplaying = nil

    GhostReplay.Notify(ply, "Stopped replaying recording", GhostReplay.NotifyTypes.SUCCESS)
end

hook.Add("Think", "GhostReplay.Record.ReplayThink", function()
    for _, ply in ipairs(player.GetAll()) do
        if (ply.GhostReplayReplaying and not ply.GhostReplayReplaying.pause) then
            local replaying = ply.GhostReplayReplaying
            local frameToReplay = replaying.frameToReplay
            local frameDelay = replaying.frameDelay
            local ghost = replaying.ghost

            if (not frameToReplay) then
                GhostReplay.Record.Stop(ply)
                return
            end

            local timeSinceStart = CurTime() - replaying.startTime

            if (timeSinceStart >= frameToReplay.time + frameDelay) then
                local nextFrame = replaying.recording[frameToReplay.frameIndex + 1]

                if (nextFrame) then
                    queueFrameForReplay(ply, replaying.recording, frameToReplay.frameIndex + 1, frameDelay)
                else
                    GhostReplay.Record.Stop(ply)
                end
            end

            if (timeSinceStart >= frameToReplay.time) then
                showFrame(ghost, frameToReplay)
            end
        end
    end
end)

concommand.Add("ghost_replay_play", function(ply, cmd, args)
    if (not ply:IsSuperAdmin()) then return end

    local recordingIndex = tonumber(args[1])

    if (not recordingIndex) then
        GhostReplay.Notify(ply, "Invalid recording index", GhostReplay.NotifyTypes.ERROR)
        return
    end

    local recording = GhostReplay.Record.Recordings[recordingIndex]

    GhostReplay.Record.Replay(ply, recording)
end)

concommand.Add("ghost_replay_stop", function(ply, cmd, args)
    if (not ply:IsSuperAdmin()) then return end

    GhostReplay.Record.Stop(ply)
end)
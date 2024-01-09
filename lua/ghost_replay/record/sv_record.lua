local STRESS_TEST_ENABLED = false
local fakePlayers = {}

local function fakePlayer(index)
    if (fakePlayers[index]) then
        return fakePlayers[index]
    end

    fakePlayers[index] = {
        index = index,

        IsValid = function() return true end,
        IsPlayer = function() return true end,
        GetModel = function() return "models/player/group01/male_04.mdl" end,
        GetSkin = function() return 0 end,
        GetBodyGroups = function() return {} end,
        GetColor = function() return Color(255, 255, 255, 255) end,
        GetMaterial = function() return "" end,
        GetSequence = function() return 0 end,
        GetPos = function() return player.GetByID(1):GetPos() end,
        GetAngles = function() return player.GetByID(1):GetAngles() end,
        GetVelocity = function() return Vector(0, 0, 0) end,
    }

    return fakePlayers[index]
end


local function getMovement(ply)
    return {
        pos = ply:GetPos(),
        ang = ply:GetAngles(),
        vel = ply:GetVelocity(),
    }
end

local function getAppearance(ply)
    return {
        model = ply:GetModel(),
        skin = ply:GetSkin(),
        bodygroups = ply:GetBodyGroups(),
        color = ply:GetColor(),
        material = ply:GetMaterial(),
        sequence = ply:GetSequence(),
    }
end

local function makeNewFrame(ply)
    local newFrame = {
        time = CurTime(),
        appearance = getAppearance(ply),
        movement = getMovement(ply)
    }

    ply.GhostReplayRecording[#ply.GhostReplayRecording + 1] = newFrame

    return newFrame
end

local function getLastRecordedFrameOrNew(ply)
    local lastFrame = ply.GhostReplayRecording[#ply.GhostReplayRecording]

    if (not lastFrame) then
        lastFrame = makeNewFrame(ply)
    end

    return lastFrame
end

local function startRecording(ply)
    if (not IsValid(ply)) then
        return false, "Invalid player"
    end

    if (ply.GhostReplayRecording) then
        return false, "Already recording"
    end

    ply.GhostReplayRecording = {}

    local lastFrame = getLastRecordedFrameOrNew(ply)
    lastFrame.appearance = getAppearance(ply)
    lastFrame.movement = getMovement(ply)

    return true
end

local function stopRecording(ply)
    if (not IsValid(ply)) then
        return false, "Invalid player"
    end

    if (not istable(ply.GhostReplayRecording)) then
        return false, "Not recording"
    end

    local recording = ply.GhostReplayRecording
    ply.GhostReplayRecording = nil

    -- Normalize the time on the recording so each frame is relative to the previous, frame 1 is 0
    local firstFrame = recording[1]
    local firstFrameTime = firstFrame.time

    for i = 1, #recording do
        local frame = recording[i]
        frame.time = frame.time - firstFrameTime
    end

    GhostReplay.Record.Recordings[#GhostReplay.Record.Recordings + 1] = recording

    return true
end

concommand.Add("ghost_replay_record", function(ply, cmd, args)
    if (not ply:IsSuperAdmin()) then return end

    local success, err = startRecording(ply)

    if (not success) then
        GhostReplay.Notify(ply, err, GhostReplay.NotifyTypes.ERROR)
        return
    end

    GhostReplay.Notify(ply, "Recording started")

    if (STRESS_TEST_ENABLED) then
        for i = 1, 64 do
            startRecording(fakePlayer(i))
        end
    end
end)

concommand.Add("ghost_replay_stop_recording", function(ply, cmd, args)
    if (not ply:IsSuperAdmin()) then return end

    local success, err = stopRecording(ply)

    if (not success) then
        GhostReplay.Notify(ply, err, GhostReplay.NotifyTypes.ERROR)
        return
    end

    GhostReplay.Notify(ply, "Recording stopped")

    if (STRESS_TEST_ENABLED) then
        for i = 1, 64 do
            stopRecording(fakePlayer(i))
        end
    end
end)

concommand.Add("ghost_replay_list_recordings", function(ply, cmd, args)
    if (not ply:IsSuperAdmin()) then return end

    for i, recording in ipairs(GhostReplay.Record.Recordings) do
        print("id: ", i, "frame count: ", #recording)
    end
end)

hook.Add("PlayerTick", "GhostReplay.Record.PlayerTick", function(ply, moveData)
    if (not ply.GhostReplayRecording) then return end

    local newFrame = makeNewFrame(ply)
    newFrame.movement = getMovement(ply)

    if (STRESS_TEST_ENABLED) then
        for i = 1, 64 do
            local newFrame = makeNewFrame(fakePlayer(i))
            newFrame.movement = getMovement(ply)
        end
    end
end)
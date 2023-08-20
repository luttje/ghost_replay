include("record/sv_init.lua")

util.AddNetworkString("GhostReplay.Notify")

function GhostReplay.Notify(ply, message, type, duration)
    net.Start("GhostReplay.Notify")
    net.WriteString(message)
    net.WriteUInt(type or GhostReplay.NotifyTypes.INFO, 3)
    net.WriteUInt(duration or 5, 5)
    net.Send(ply)
end

-- Used for testing
concommand.Add("ghost_replay_activate_surf", function(ply, cmd, args)
    if (not ply:IsSuperAdmin()) then return end

    RunConsoleCommand("sv_accelerate", "10")
    RunConsoleCommand("sv_airaccelerate", "1400")
    RunConsoleCommand("sv_gravity", "800.0")
    RunConsoleCommand("sv_maxvelocity", "7200.0")

    hook.Add("GetFallDamage", "GhostReplay.DisableFallDamage", function(ply, speed)
        return 0
    end)
end)

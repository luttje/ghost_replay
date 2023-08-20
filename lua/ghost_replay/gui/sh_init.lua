AddCSLuaFile("cl_scrubber.lua")

if (SERVER) then
    util.AddNetworkString("GhostReplay.TogglePlayRecording")
    util.AddNetworkString("GhostReplay.CloseScrubber")
    util.AddNetworkString("GhostReplay.OpenScrubber")
    util.AddNetworkString("GhostReplay.SetFrame")
    util.AddNetworkString("GhostReplay.ScrubTo")
    util.AddNetworkString("GhostReplay.End")

    net.Receive("GhostReplay.TogglePlayRecording", function(len, ply)
        GhostReplay.Record.SetPaused(ply, ply.GhostReplayReplaying and not ply.GhostReplayReplaying.isPaused or false)
    end)

    net.Receive("GhostReplay.ScrubTo", function(len, ply)
        local frame = net.ReadUInt(32)

        GhostReplay.Record.SetFrame(ply, frame)
        GhostReplay.Record.SetPaused(ply, true)
    end)

    net.Receive("GhostReplay.End", function(len, ply)
        GhostReplay.Record.Stop(ply)
        net.Start("GhostReplay.CloseScrubber")
        net.Send(ply)
    end)
else
    include("cl_scrubber.lua")
end
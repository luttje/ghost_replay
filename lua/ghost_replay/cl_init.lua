--

net.Receive("GhostReplay.Notify", function()
    local message = net.ReadString()
    local type = net.ReadUInt(3)
    local duration = net.ReadUInt(5)

    if (type == GhostReplay.NotifyTypes.ERROR) then
        notification.AddLegacy(message, NOTIFY_ERROR, duration)
        surface.PlaySound("buttons/button10.wav")
    elseif (type == GhostReplay.NotifyTypes.SUCCESS) then
        notification.AddLegacy(message, NOTIFY_GENERIC, duration)
        surface.PlaySound("buttons/button9.wav")
    elseif (type == GhostReplay.NotifyTypes.INFO) then
        notification.AddLegacy(message, NOTIFY_HINT, duration)
        surface.PlaySound("buttons/button15.wav")
    end
end)
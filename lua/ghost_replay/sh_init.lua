GhostReplay = GhostReplay or {}

GhostReplay.NotifyTypes = {
    ERROR = 1,
    SUCCESS = 2,
    INFO = 3
}

if (SERVER) then
    AddCSLuaFile("cl_init.lua")
    include("sv_init.lua")

    AddCSLuaFile("gui/sh_init.lua")
else
    include("cl_init.lua")
end

include("gui/sh_init.lua")
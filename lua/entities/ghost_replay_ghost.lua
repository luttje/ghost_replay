AddCSLuaFile()

DEFINE_BASECLASS("base_anim")

ENT.Type = "anim"
ENT.PrintName = "Ghost Replay Ghost"
ENT.Author = "Luttje"
ENT.Information = "Ghost for replayed movement"
ENT.Category = "Fun + Games"

ENT.Spawnable = false
ENT.AdminOnly = true

function ENT:Initialize()
    self:SetMoveType(MOVETYPE_NONE)
end
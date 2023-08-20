-- GMOD scrubber panel that shows the current time and allows the user to scrub through the replay.
local PANEL = {}

function PANEL:Init()
    local width = math.min(ScrW() * .9, 800)
    self:SetSize(width, 128)
    self:SetPos(ScrW() / 2 - width / 2, ScrH() - self:GetTall() - 32)

    self.slider = vgui.Create("DNumSlider", self)
    self.slider:Dock(FILL)
    self.slider:SetDecimals(0)
    self.slider:SetMin(1)
    self.slider:SetMax(1)
    self.slider:SetValue(1)
    self.slider:SetEnabled(false)
    self.slider:DockMargin(0, 8, 0, 0)

    self.slider.OnValueChanged = function(slider, value)
        net.Start("GhostReplay.ScrubTo")
        net.WriteUInt(value, 32)
        net.SendToServer()
    end

    self.closeButton = vgui.Create("DButton", self)
    self.closeButton:SetText("Close")
    self.closeButton:Dock(BOTTOM)
    self.closeButton:DockMargin(0, 8, 0, 0)
    self.closeButton:SetTall(32)
    self.closeButton.DoClick = function()
        net.Start("GhostReplay.End")
        net.SendToServer()
    end
end

function PANEL:SetNumFrames(numFrames)
    self.numFrames = numFrames

    self.slider:SetMax(numFrames)
    self.slider:SetEnabled(true)
end

function PANEL:Paint(w, h)
    draw.RoundedBox(4, 0, 0, w, h, Color(0, 0, 0, 128))
    draw.SimpleText("Ghost Replay", "DermaLarge", 8, 8, Color(255, 255, 255, 255))
end

vgui.Register("GhostReplay.Scrubber", PANEL, "EditablePanel")

net.Receive("GhostReplay.OpenScrubber", function()
    local numFrames = net.ReadUInt(32)

    if (IsValid(GhostReplay.Gui)) then
        GhostReplay.Gui:Remove()
    end

    local panel = vgui.Create("GhostReplay.Scrubber")
    panel:SetNumFrames(numFrames)
    panel:MakePopup()
    GhostReplay.Gui = panel
end)


net.Receive("GhostReplay.CloseScrubber", function()
    if (IsValid(GhostReplay.Gui)) then
        GhostReplay.Gui:Remove()
    end

    GhostReplay.Gui = nil
end)
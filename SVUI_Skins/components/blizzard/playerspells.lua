--[[
##############################################################################
S V U I   By: Vorka
##############################################################################
--]]
--[[ GLOBALS ]]--
local _G = _G;
local unpack  	= unpack;
local select  	= _G.select;
local ipairs  	= _G.ipairs;
local pairs   	= _G.pairs;
local type 		= _G.type;
--[[ ADDON ]]--
local SV = _G['SVUI'];
local L = SV.L;
local MOD = SV.Skins;
local Schema = MOD.Schema;
--[[
##########################################################
LOCAL VARIABLES
##########################################################
]]--
local IconCoords = _G.SVUI_ICON_COORDS
local IconRoles = [[Interface\AddOns\SVUI_UnitFrames\assets\UNIT-ROLES]];
local RoleIconData = {
	[Enum.LFGRole.Tank] = {0,0.5,0,0.5, 0.5,0.75,0.51,0.75},
	[Enum.LFGRole.Healer] = {0,0.5,0.5,1, 0.5,0.75,0.76,1},
	[Enum.LFGRole.Damage] = {0.5,1,0,0.5, 0.76,1,0.51,0.75}
}
--[[
##########################################################
HELPERS
##########################################################
]]--

local function _hook_SpecFrame_Update(self)
    if self.skinned then return end
    
    local role, coords

    for specContentFrame in self.SpecContentFramePool:EnumerateActive() do 
        -- if not specContentFrame.skinned then
            for btn in specContentFrame.SpellButtonPool:EnumerateActive() do
                btn.Ring:Die()
                btn.Icon:SetTexture(btn.Icon:GetTexture())
                btn.Icon:SetTexCoord(unpack(IconCoords))
            end

            specContentFrame.SpecImageBorderOn:Die()
            specContentFrame.SpecImageBorderOff:Die()
            --RoleIcon 5171843
            role = GetSpecializationRoleEnum(specContentFrame.specIndex, false, false)
            coords = RoleIconData[role]
            specContentFrame.RoleIcon:SetTexture(IconRoles)
            if specContentFrame.RoleIcon:GetHeight() <= 13 then
                specContentFrame.RoleIcon:SetTexCoord(coords[5], coords[6], coords[7], coords[8])
            else
                specContentFrame.RoleIcon:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
            end

            SV.API:Set("Button", specContentFrame.ActivateButton)
            -- specContentFrame.skinned = true
        -- end
    end

    self.skinned = true
end

local function _hook_HeroFrame_OnShow(self)
    if self.skinned then return end

    local noop = function() end

    for specContentFrame in self.SpecContentFramePool:EnumerateActive() do 
        SV.API:Set("Button", specContentFrame.ActivateButton)
        specContentFrame.SpecImageBorder:Die()
        specContentFrame.SpecImageBorder.Show = noop
        specContentFrame.SpecImageBorderSelected:Die()
        specContentFrame.SpecImageBorderSelected.Show = noop
        -- specContentFrame.SpecImageMask:Die()
    end

    self.skinned = true
end

--[[
##########################################################
PROFESSION MODR
##########################################################
]]--
local function PlayerSpellsStyle()
    if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.playerspells ~= true then return end

    local holder = PlayerSpellsFrame

    holder.TitleContainer.TitleText:SetFontObject(SVUI_Font_Header)
    holder:RemoveTextures(true)
    holder.NineSlice:Hide()
    holder:SetStyle("Frame", "Window")

    holder:SetMovable(true)
    holder:EnableMouse(true)
    holder:RegisterForDrag("LeftButton")
    holder:SetScript("OnDragStart", holder.StartMoving)
    holder:SetScript("OnDragStop", holder.StopMovingOrSizing)

    SV.API:Set("CloseButton", holder.CloseButton)

    holder.PortraitContainer:RemoveTextures(true)

    local specFrame = holder.SpecFrame

    specFrame:RemoveTextures(true)
    specFrame:SetStyle("!_Frame", "Window2")
    specFrame:SetPanelColor("darkest")

    local talentFrame = holder.TalentsFrame
    talentFrame:RemoveTextures(true)
    talentFrame:SetStyle("!_Frame", "Window2")
    talentFrame:SetPanelColor("darkest")
    SV.API:Set("Button", talentFrame.ApplyButton)
    
    local heroContainer = talentFrame.HeroTalentsContainer
    
    heroContainer.HeroSpecButton.Border:Die()
    heroContainer.HeroSpecButton.Border.SetShown = function() end

    --ExpandedContainer
    heroContainer.ExpandedContainer:RemoveTextures(true)
    --CollapsedContainer
    heroContainer.CollapsedContainer:RemoveTextures(true)
    --PreviewContainer
    heroContainer.PreviewContainer:RemoveTextures(true)


    local heroFrame = talentFrame.HeroTalentsContainer.specSelectionDialog
    heroFrame.TitleContainer.TitleText:SetFontObject(SVUI_Font_Header)
    heroFrame:RemoveTextures(true)
    heroFrame.NineSlice:Hide()
    heroFrame:SetStyle("Frame", "Window")
    --DevTool:AddData(heroFrame, "specSelectionDialog")

    --SpecOptionsContainer
    hooksecurefunc(specFrame, "UpdateSpecFrame", _hook_SpecFrame_Update)
    hooksecurefunc(heroFrame, "UpdateActiveHeroSpec", _hook_HeroFrame_OnShow)
    -- heroFrame:HookScript("OnShow", _hook_HeroFrame_OnShow)

end

--[[
##########################################################
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle("Blizzard_PlayerSpells", PlayerSpellsStyle)
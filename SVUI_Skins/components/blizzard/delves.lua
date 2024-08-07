--[[
##############################################################################
S V U I   By: Failcoder
##############################################################################
--]]
--[[ GLOBALS ]]--
local _G = _G;
local unpack  = _G.unpack;
local select  = _G.select;
--[[ ADDON ]]--
local SV = _G['SVUI'];
local L = SV.L;
local MOD = SV.Skins;
local Schema = MOD.Schema;

--[[ 
########################################################## 
CHALLENGES UI MODR
##########################################################
]]--
local function DelvesStyle()

    if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.lfg ~= true then return end

    local frame = DelvesDashboardFrame
    local ButtonPanel = frame.ButtonPanelLayoutFrame
    ButtonPanel.CompanionConfigButtonPanel.ButtonPanelBackground:Die()
    ButtonPanel.CompanionConfigButtonPanel.CompanionConfigButton:SetStyle("Button")
    ButtonPanel.GreatVaultButtonPanel.ButtonPanelBackground:Die()

    --DelvesCompanionConfigurationFrame
    frame = DelvesCompanionConfigurationFrame
    frame:RemoveTextures(true)
    frame.NineSlice:Hide()
    frame:SetStyle("Frame", "Window")

    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    SV.API:Set("CloseButton", frame.CloseButton)

    local portrait = frame.CompanionPortraitFrame
    portrait.Border:Die()
    --portrait.Icon

    --DelvesDifficultyPickerFrame
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle("Blizzard_DelvesDashboardUI", DelvesStyle)
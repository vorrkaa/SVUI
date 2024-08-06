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

--[[
##########################################################
HELPERS
##########################################################
]]--
local function __hook_UpdateOverlay(self)
    if self.Overlay.skinned then return end

    local overlay = self.Overlay
    --overlay.Title
    --overlay.Text
    overlay:RemoveTextures(true)
    overlay.NineSlice:Hide()
    overlay:SetStyle("!_Frame", "Window2")
    overlay:SetPanelColor("darkest")

    self.Overlay.skinned = true
end
--[[
##########################################################
PROFESSION MODR
##########################################################
]]--
local function WeeklyRewardsStyle()
    if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.weeklyrewards ~= true then return end

    local holder = WeeklyRewardsFrame
    holder:RemoveTextures(true)
    holder:SetStyle("Frame", "Window")

    holder.BorderContainer:RemoveTextures(true)
    holder.Divider1:Die()
    holder.Divider2:Die()
    holder.Blackout:Die()

    holder.HeaderFrame.HeaderDivider:Die()

    holder:SetMovable(true)
    holder:EnableMouse(true)
    holder:RegisterForDrag("LeftButton")
    holder:SetScript("OnDragStart", holder.StartMoving)
    holder:SetScript("OnDragStop", holder.StopMovingOrSizing)

    SV.API:Set("CloseButton", holder.CloseButton)

    hooksecurefunc(holder, "UpdateOverlay", __hook_UpdateOverlay)

    local concession = holder.ConcessionFrame
    concession:RemoveTextures(true)
    concession:SetStyle("!_Frame", "Window2")
    concession:SetPanelColor("darkest")

    local RewardTypeFrame = {
        "MythicFrame",
        "PVPFrame",
        "RaidFrame",
        "WorldFrame"
    }
    local rtf
    for i =1, 4 do
        rtf = holder[RewardTypeFrame[i]]
        rtf.Name:SetFontObject(SVUI_Font_Header)
    end

    local activities = C_WeeklyRewards.GetActivities();
	for i, activityInfo in ipairs(activities) do
        local frame = holder:GetActivityFrame(activityInfo.type, activityInfo.index);
		if frame then
            -- frame:RemoveTextures(true)
            frame.Background:Die()
            frame.Border:Die()
            frame:SetStyle("!_Frame", "Transparent")
            frame.Progress:SetFontObject(SVUI_Font_Number)
        end
    end

end

--[[
##########################################################
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle("Blizzard_WeeklyRewards", WeeklyRewardsStyle)
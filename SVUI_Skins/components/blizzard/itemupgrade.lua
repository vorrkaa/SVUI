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
ITEMUPGRADE UI MODR
##########################################################
]]--
local function ItemUpgradeStyle()
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.itemUpgrade ~= true then
		 return 
	end 

	local frame = ItemUpgradeFrame

	SV.API:Set("Window", frame, true)
	frame.TitleContainer.TitleText:SetFontObject(SVUI_Font_Header)

	SV.API:Set("CloseButton", frame.CloseButton)
	frame.UpgradeButton:SetStyle("Button")

	frame.PortraitContainer.CircleMask:Hide()
	frame.PortraitContainer.portrait:InsetPoints()
	frame.PortraitContainer.portrait:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))

	--ItemUpgradeFrameUpgradeButton:RemoveTextures()
	--ItemUpgradeFrameUpgradeButton:SetStyle("Button")
	frame.UpgradeItemButton:RemoveTextures()
	frame.UpgradeItemButton:SetStyle("ActionSlot")
	frame.UpgradeItemButton.icon:InsetPoints()
	hooksecurefunc(frame, "UpdateUpgradeItemInfo", function()
		if C_ItemUpgrade.GetItemUpgradeItemInfo() then
			frame.UpgradeItemButton.icon:SetAlpha(1)
			frame.UpgradeItemButton.icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
		else
			frame.UpgradeItemButton.icon:SetAlpha(0)
		end 
	end)
	frame.UpgradeCostFrame:RemoveTextures()
	frame.PlayerCurrenciesBorder:RemoveTextures()
	--ItemUpgradeFrame.FinishedGlow:Die()
	--ItemUpgradeFrame.ButtonFrame:DisableDrawLayer('BORDER')
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle("Blizzard_ItemUpgradeUI",ItemUpgradeStyle)
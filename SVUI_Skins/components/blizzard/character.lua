--[[
##############################################################################
S V U I   By: Failcoder
##############################################################################
--]]
--[[ GLOBALS ]]--
local _G = _G;
local unpack  = _G.unpack;
local select  = _G.select;
local ipairs  = _G.ipairs;
local pairs   = _G.pairs;
--[[ WOW API ]]--
local GetItemQualityColor	= C_Item.GetItemQualityColor
local GetItemInfo			= C_Item.GetItemInfo
--[[ ADDON ]]--
local SV = _G['SVUI'];
local L = SV.L;
local MOD = SV.Skins;
local Schema = MOD.Schema;
--[[
##########################################################
HELPERS
##########################################################
]]--
local color --for StatsPane
local SlotListener = CreateFrame("Frame")

local CharacterSlotNames = {
	"HeadSlot",
	"NeckSlot",
	"ShoulderSlot",
	"BackSlot",
	"ChestSlot",
	"ShirtSlot",
	"TabardSlot",
	"WristSlot",
	"HandsSlot",
	"WaistSlot",
	"LegsSlot",
	"FeetSlot",
	"Finger0Slot",
	"Finger1Slot",
	"Trinket0Slot",
	"Trinket1Slot",
	"MainHandSlot",
	"SecondaryHandSlot"
};

local CharFrameList = {
	"CharacterFrame",
	"CharacterModelFrame",
	"CharacterFrameInset",
	"CharacterStatsPane",
	"CharacterFrameInsetRight",
	"PaperDollFrame",
	"PaperDollSidebarTabs",
	--"PaperDollEquipmentManagerPane"
};

local CharacterStatsSubFrames = {
	"ItemLevelCategory",
	"AttributesCategory",
	"EnhancementsCategory"
};

local function SetItemFrame(frame, point)
	point = point or frame
	local noscalemult = 2 * UIParent:GetScale()
	if point.bordertop then return end
	point.backdrop = frame:CreateTexture(nil, "BORDER")
	point.backdrop:SetDrawLayer("BORDER", -4)
	point.backdrop:SetAllPoints(point)
	point.backdrop:SetTexture(SV.media.statusbar.default)
	point.backdrop:SetVertexColor(unpack(SV.media.color.default))
	point.bordertop = frame:CreateTexture(nil, "BORDER")
	point.bordertop:SetPoint("TOPLEFT", point, "TOPLEFT", -noscalemult, noscalemult)
	point.bordertop:SetPoint("TOPRIGHT", point, "TOPRIGHT", noscalemult, noscalemult)
	point.bordertop:SetHeight(noscalemult)
	point.bordertop:SetColorTexture(0,0,0)
	point.bordertop:SetDrawLayer("BORDER", 1)
	point.borderbottom = frame:CreateTexture(nil, "BORDER")
	point.borderbottom:SetPoint("BOTTOMLEFT", point, "BOTTOMLEFT", -noscalemult, -noscalemult)
	point.borderbottom:SetPoint("BOTTOMRIGHT", point, "BOTTOMRIGHT", noscalemult, -noscalemult)
	point.borderbottom:SetHeight(noscalemult)
	point.borderbottom:SetColorTexture(0,0,0)
	point.borderbottom:SetDrawLayer("BORDER", 1)
	point.borderleft = frame:CreateTexture(nil, "BORDER")
	point.borderleft:SetPoint("TOPLEFT", point, "TOPLEFT", -noscalemult, noscalemult)
	point.borderleft:SetPoint("BOTTOMLEFT", point, "BOTTOMLEFT", noscalemult, -noscalemult)
	point.borderleft:SetWidth(noscalemult)
	point.borderleft:SetColorTexture(0,0,0)
	point.borderleft:SetDrawLayer("BORDER", 1)
	point.borderright = frame:CreateTexture(nil, "BORDER")
	point.borderright:SetPoint("TOPRIGHT", point, "TOPRIGHT", noscalemult, noscalemult)
	point.borderright:SetPoint("BOTTOMRIGHT", point, "BOTTOMRIGHT", -noscalemult, -noscalemult)
	point.borderright:SetWidth(noscalemult)
	point.borderright:SetColorTexture(0,0,0)
	point.borderright:SetDrawLayer("BORDER", 1)
end

local function StyleCharacterSlots()
	for _,slotName in pairs(CharacterSlotNames) do
		local globalName = ("Character%s"):format(slotName)
		local charSlot = _G[globalName]
		if(charSlot) then
			if(not charSlot.Panel) then
				charSlot:RemoveTextures()
				charSlot.ignoreTexture:SetTexture([[Interface\PaperDollInfoFrame\UI-GearManager-LeaveItem-Transparent]])
				charSlot:SetStyle("!_ActionSlot", 1, 0, 0)

				local iconTex = _G[globalName.."IconTexture"] or charSlot.icon;
				if(iconTex) then
					iconTex:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
					iconTex:InsetPoints(charSlot)
					--iconTex:SetParent(charSlot.Panel)
				end
				if(charSlot.IconBorder) then
					charSlot.IconBorder:Die()
				end
			end

			local slotID,_ = GetInventorySlotInfo(slotName)
			local r, g, b = 0, 0, 0;
			if(slotID) then
				local itemLink = GetInventoryItemLink("player", slotID)
				if(itemLink) then
					local key, _, quality, _, _, _, _, _, equipSlot = GetItemInfo(itemLink);
					if(quality and quality > 1) then
						r,g,b = GetItemQualityColor(quality)
					end
				end
				charSlot:SetBackdropColor(r,g,b,0.6)
				charSlot:SetBackdropBorderColor(r,g,b,1)
			end
		end
	end

	for i = 1, #PAPERDOLL_SIDEBARS do
		local tab = _G["PaperDollSidebarTab"..i]
		if(tab) then
			if(not tab.Panel) then
				tab.Highlight:SetColorTexture(1, 1, 1, 0.3)
				tab.Highlight:SetPoint("TOPLEFT", 3, -4)
				tab.Highlight:SetPoint("BOTTOMRIGHT", -1, 0)
				tab.Hider:SetColorTexture(0.4, 0.4, 0.4, 0.4)
				tab.Hider:SetPoint("TOPLEFT", 3, -4)
				tab.Hider:SetPoint("BOTTOMRIGHT", -1, 0)
				tab.TabBg:Die()
				if i == 1 then
					for x = 1, tab:GetNumRegions()do
						local texture = select(x, tab:GetRegions())
						texture:SetTexCoord(0.16, 0.86, 0.16, 0.86)
					end
				end
				tab:SetStyle("Frame", "Default", true, 2)
				tab.Panel:SetPoint("TOPLEFT", 2, -3)
				tab.Panel:SetPoint("BOTTOMRIGHT", 0, -2)
			end
			if(i == 1) then
				tab:ClearAllPoints()
				tab:SetPoint("BOTTOM", CharacterFrameInsetRight, "TOP", -30, 4)
			else
				tab:ClearAllPoints()
				tab:SetPoint("LEFT",  _G["PaperDollSidebarTab"..i-1], "RIGHT", 4, 0)
			end
		end
	end
end

local function StyleFlyoutButton(button, texture)
	button:SetStyle("Button")
	texture:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
	button:GetNormalTexture():SetTexture("")
	texture:InsetPoints()
	button:SetFrameLevel(button:GetFrameLevel() + 2)
	if not button.Panel then
		button:SetStyle("Frame", "Default")
		button.Panel:SetAllPoints()
	end
end

local function EquipmentFlyout_OnShow()
	EquipmentFlyoutFrameButtons:RemoveTextures()
	EquipmentFlyoutFrame.NavigationFrame:RemoveTextures()
	SV.API:Set("!_PageButton", EquipmentFlyoutFrame.NavigationFrame.PrevButton)
	SquareButton_SetIcon(EquipmentFlyoutFrame.NavigationFrame.PrevButton, 'LEFT')
	SV.API:Set("!_PageButton", EquipmentFlyoutFrame.NavigationFrame.NextButton)
	SquareButton_SetIcon(EquipmentFlyoutFrame.NavigationFrame.NextButton, 'RIGHT')
	local counter = 1;
	local button = _G["EquipmentFlyoutFrameButton"..counter]
	while button do
		local texture = _G["EquipmentFlyoutFrameButton"..counter.."IconTexture"]
		StyleFlyoutButton(button, texture)
		counter = counter + 1;
		button = _G["EquipmentFlyoutFrameButton"..counter]
	end
end

local function PaperDollUpdateStats()
	
	--TODO: Skin this Pane
	-- local i = 1
	-- for stat in CharacterStatsPane.statsFramePool:EnumerateActive() do
	-- 	stat.Background:SetVertexColor(color.r, color.g, color.b)
	-- end

end

local function Reputation_OnShow(frame)

	for _, child in next, { frame.ScrollTarget:GetChildren() } do
		local content = child.Content
		if content and not content.IsSkinned then
			content.IsSkinned = true

			content:RemoveTextures()

			if content.ReputationBar then
				content.ReputationBar:RemoveTextures()
				content.ReputationBar:SetStatusBarTexture(SV.media.statusbar.default)
			end
		end
	end

end

local function PaperDollTitlesPane_OnShow()
	for i,btn in pairs(PaperDollTitlesPane.buttons) do
		if(btn) then
			btn.BgTop:SetTexture("")
			btn.BgBottom:SetTexture("")
			btn.BgMiddle:SetTexture("")
			SV:FontManager(btn.text, "default")
		end
	end
	PaperDollTitlesPane_Update()
end

local function PaperDollEquipmentManagerPane_OnShow()
	for i,btn in pairs(PaperDollEquipmentManagerPane.buttons) do
		if(btn) then
			btn.BgTop:SetTexture("")
			btn.BgBottom:SetTexture("")
			btn.BgMiddle:SetTexture("")
			btn.icon:SetSize(36, 36)
			btn.Check:SetTexture("")
			btn.icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
			btn.icon:SetPoint("LEFT", btn, "LEFT", 4, 0)
			if not btn.icon.bordertop then
				 SetItemFrame(btn, btn.icon)
			end
		end
	end

	GearManagerDialogPopup:RemoveTextures()
	GearManagerDialogPopup:SetStyle("Frame", "Inset", true)
	GearManagerDialogPopup:SetPoint("LEFT", PaperDollFrame, "RIGHT", 4, 0)
	GearManagerDialogPopupScrollFrameScrollBar:RemoveTextures()
	GearManagerDialogPopupEditBox:RemoveTextures()
	GearManagerDialogPopupEditBox:SetStyle("Frame", 'Inset')
	GearManagerDialogPopupOkay:SetStyle("Button")
	GearManagerDialogPopupCancel:SetStyle("Button")

	for i = 1, NUM_GEARSET_ICONS_SHOWN do
		local btn = _G["GearManagerDialogPopupButton"..i]
		if(btn and (not btn.Panel)) then
			btn:RemoveTextures()
			btn:SetFrameLevel(btn:GetFrameLevel() + 2)
			btn:SetStyle("Button")
			if(btn.icon) then
				btn.icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
				btn.icon:SetTexture("")
				btn.icon:InsetPoints()
			end
		end
	end
end
--[[
##########################################################
CHARACTERFRAME MODR
##########################################################
]]--
local function CharacterFrameStyle()
	--print('test CharacterFrameStyle')
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.character ~= true then
		 return
	end

	local classToken = select(2,UnitClass("player"))
	color = CUSTOM_CLASS_COLORS[classToken]
	if(not SV.db.general.customClassColor) then
		color = RAID_CLASS_COLORS[classToken]
	end

	SV.API:Set("Window", CharacterFrame, true, true, 1, 3, 3)

	SV.API:Set("CloseButton", CharacterFrameCloseButton)
	SV.API:Set("ScrollBar", CharacterStatsPane)
	SV.API:Set("ScrollBar", ReputationFrame)
	SV.API:Set("ScrollBar", TokenFrame)
	SV.API:Set("ScrollBar", PaperDollFrame.EquipmentManagerPane)
	SV.API:Set("ScrollBar", PaperDollFrame.TitleManagerPane)

	StyleCharacterSlots()

	CharacterFrame.Inset:Hide()
	CharacterFrame.PortraitContainer:Die()
	CharacterFrameInsetRight.Bg:Hide()
	CharacterFrameInsetRight.NineSlice:Hide()
	CharacterFrameInsetRight:SetStyle("Frame", 'Inset')
	CharacterModelScene:SetStyle("!_Frame", "Model")


	SlotListener:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	SlotListener:SetScript("OnEvent", StyleCharacterSlots)
	CharacterFrame:HookScript("OnShow", StyleCharacterSlots)
	CharacterFrame.TitleContainer.TitleText:SetFontObject(SVUI_Font_Header)

	SV.API:Set("CloseButton", ReputationDetailCloseButton)
	SV.API:Set("Window", ReputationFrame.ReputationDetailFrame)
	-- SV.API:Set("Tooltip", ReputationParagonTooltip)
	-- SV.API:Set("CloseButton", TokenFramePopupCloseButton)
	ReputationFrame.ReputationDetailFrame.AtWarCheckbox:SetStyle("CheckButton")
	ReputationFrame.ReputationDetailFrame.WatchFactionCheckbox:SetStyle("CheckButton")
	ReputationFrame.ReputationDetailFrame.MakeInactiveCheckbox:SetStyle("CheckButton")
	ReputationFrame.ReputationDetailFrame.ViewRenownButton:SetStyle("Button")
	
	TokenFramePopup.InactiveCheckbox:SetStyle("CheckButton")
	TokenFramePopup.BackpackCheckbox:SetStyle("CheckButton")
	EquipmentFlyoutFrameHighlight:Die()
	EquipmentFlyoutFrame:HookScript("OnShow", EquipmentFlyout_OnShow)
	hooksecurefunc("EquipmentFlyout_Show", EquipmentFlyout_OnShow)

	SV.API:Set("ScrollBar", _G["PaperDollTitlesPaneScrollBar"], 5)
	SV.API:Set("ScrollBar", _G["PaperDollEquipmentManagerPaneScrollBar"], 5)

	for _,gName in pairs(CharFrameList) do
		if(_G[gName] and _G[gName].RemoveTextures) then _G[gName]:RemoveTextures(true) else print(gName) end
	end

	for _,gName in pairs(CharacterStatsSubFrames) do
		if(CharacterStatsPane[gName]) then 
			CharacterStatsPane[gName]:RemoveTextures(true)
			CharacterStatsPane[gName]:SetStyle("Frame", 'Inset')
		end
	end


	for i=1, 6 do
		local pane = _G["CharacterStatsPaneCategory"..i]
		if(pane) then
			pane:RemoveTextures()
		end
	end

	CharacterModelFrameBackgroundTopLeft:SetTexture("")
	CharacterModelFrameBackgroundTopRight:SetTexture("")
	CharacterModelFrameBackgroundBotLeft:SetTexture("")
	CharacterModelFrameBackgroundBotRight:SetTexture("")

        
	for i = 1, 4 do
		 SV.API:Set("Tab", _G["CharacterFrameTab"..i])
	end

	ReputationFrame:RemoveTextures(true)
	ReputationFrame.ReputationDetailFrame:RemoveTextures()
	ReputationFrame.ReputationDetailFrame:SetStyle("Frame", "Inset", true)
	ReputationFrame.ReputationDetailFrame:SetPoint("TOPLEFT", ReputationFrame, "TOPRIGHT", 4, -28)
	-- ReputationFrame:HookScript("OnShow", Reputation_OnShow)
	-- hooksecurefunc(C_Reputation, "ExpandFactionHeader", Reputation_OnShow)
	-- hooksecurefunc(C_Reputation, "CollapseFactionHeader", Reputation_OnShow)
	hooksecurefunc(ReputationFrame.ScrollBox, 'Update', Reputation_OnShow)

	TokenFrame:HookScript("OnShow", function()
		for i = 1, GetCurrencyListSize() do
			local currency = _G["TokenFrameContainerButton"..i]
			if(currency) then
				currency.highlight:Die()
				currency.categoryMiddle:Die()
				currency.categoryLeft:Die()
				currency.categoryRight:Die()
				if currency.icon then
					 currency.icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
				end
			end
		end
		TokenFramePopup:RemoveTextures()
		TokenFramePopup:SetStyle("Frame", "Inset", true)
		TokenFramePopup:SetPoint("TOPLEFT", TokenFrame, "TOPRIGHT", 4, -28)
	end)

	--[[
	PetModelFrame:SetStyle("Frame", "Model", false, 1, -7, -7)
	PetPaperDollPetInfo:GetRegions():SetTexCoord(.12, .63, .15, .55)
	PetPaperDollPetInfo:SetFrameLevel(PetPaperDollPetInfo:GetFrameLevel() + 10)
	PetPaperDollPetInfo:SetStyle("Frame", "Icon")
	PetPaperDollPetInfo.Panel:SetFrameLevel(0)
	PetPaperDollPetInfo:SetSize(24, 24)
	]]--

	hooksecurefunc('PaperDollFrame_UpdateStats', PaperDollUpdateStats)
end
--[[
##########################################################
MOD LOADING
##########################################################
]]--
MOD:SaveCustomStyle("CHARACTER", CharacterFrameStyle)

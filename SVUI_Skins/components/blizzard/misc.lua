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
##########################################################
]]--
local _hook_NavBar_AddButton = function(self, buttonData)
	local navButton = self.navList[#self.navList];
	if(not navButton or navButton.Panel) then return end
	navButton:RemoveTextures()
	navButton:SetStyle("Button")
	if(navButton.MenuArrowButton) then
		navButton.MenuArrowButton:SetNormalTexture('')
		navButton.MenuArrowButton:SetPushedTexture('')
	end
end

hooksecurefunc("NavBar_AddButton", _hook_NavBar_AddButton)
--[[
local MissingLootFrame_OnShow = function(self)
	local numMissing = GetNumMissingLootItems()
	for i = 1, numMissing do
		local slot = _G["MissingLootFrameItem"..i]
		local icon = slot.icon;
		SV.API:Set("!_ItemButton", slot)
		local texture, name, count, quality = GetMissingLootItemInfo(i);
		local r,g,b,hex = GetItemQualityColor(quality)
		if(not r) then
			r,g,b = 0,0,0
		end
		icon:SetTexture(texture)
		_G.MissingLootFrame:SetBackdropBorderColor(r,g,b)
	end
	local calc = (ceil(numMissing * 0.5) * 43) + 38
	_G.MissingLootFrame:SetHeight(calc + _G.MissingLootFrameLabel:GetHeight())
end
]]--
local LootHistoryFrame_OnUpdate = function(self)
	local numItems = _G.C_LootHistory.GetNumItems()
	for i = 1, numItems do
		local frame = _G.LootHistoryFrame.itemFrames[i]
		if not frame.isStyled then
			local Icon = frame.Icon:GetTexture()
			frame:RemoveTextures()
			frame.Icon:SetTexture(Icon)
			frame.Icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))

			frame:SetStyle("!_Frame", "Button")
			frame.Panel:WrapPoints(frame.Icon)
			frame.Icon:SetParent(frame.Panel)

			frame.isStyled = true
		end
	end
end

local _hook_MasterLootFrame_OnShow = function()
	local MasterLooterFrame = _G.MasterLooterFrame;
	local item = MasterLooterFrame.Item;
	local LootFrame = _G.LootFrame;
	if item then
		local icon = item.Icon;
		local tex = icon:GetTexture()
		local colors = ITEM_QUALITY_COLORS[LootFrame.selectedQuality]
		item:RemoveTextures()
		icon:SetTexture(tex)
		icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
		item:SetStyle("Frame", "Pattern")
		item.Panel:WrapPoints(icon)
		item:SetBackdropBorderColor(colors.r, colors.g, colors.b)
	end
	for i = 1, MasterLooterFrame:GetNumChildren()do
		local child = select(i, MasterLooterFrame:GetChildren())
		if child and not child.isStyled and not child:GetName() then
			if child:GetObjectType() == "Button" then
				if child:GetPushedTexture() then
					SV.API:Set("CloseButton", child)
				else
					child:SetStyle("!_Frame")
					child:SetStyle("Button")
				end
				child.isStyled = true
			end
		end
	end
end

local _hook_LossOfControl = function(self, ...)
	self.Icon:ClearAllPoints()
	self.Icon:SetPoint("CENTER", self, "CENTER", 0, 0)
	self.AbilityName:ClearAllPoints()
	self.AbilityName:SetPoint("BOTTOM", self, 0, -28)
	self.AbilityName.scrollTime = nil;
	self.AbilityName:SetFont(SV.media.font.dialog, 20, 'OUTLINE')
	self.TimeLeft.NumberText:ClearAllPoints()
	self.TimeLeft.NumberText:SetPoint("BOTTOM", self, 4, -58)
	self.TimeLeft.NumberText.scrollTime = nil;
	self.TimeLeft.NumberText:SetFont(SV.media.font.number, 20, 'OUTLINE')
	self.TimeLeft.SecondsText:ClearAllPoints()
	self.TimeLeft.SecondsText:SetPoint("BOTTOM", self, 0, -80)
	self.TimeLeft.SecondsText.scrollTime = nil;
	self.TimeLeft.SecondsText:SetFont(SV.media.font.default, 20, 'OUTLINE')
	if self.Anim:IsPlaying() then
		self.Anim:Stop()
	end
end

local function MailFrame_OnUpdate()
	for i = 1, ATTACHMENTS_MAX_SEND do
		local slot = _G["SendMailAttachment"..i]
		if(not slot.Panel) then
			slot:RemoveTextures()
			slot:SetStyle("!_ActionSlot")
		end
		if(slot.GetNormalTexture) then
			local icon = slot:GetNormalTexture()
			if(icon) then
				icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
				icon:InsetPoints()
			end
		end
	end
end

local _hook_GreetingPanelShow = function(self)
	self:RemoveTextures()
	_G.QuestFrameGreetingGoodbyeButton:SetStyle("Button")
	_G.QuestGreetingFrameHorizontalBreak:Die()
end

local function StyleTradeSlots(name)
	local slot = _G[name]
	if(not slot) then return end

	local button = _G[name.."ItemButton"]
	if(button and (not button.Panel)) then
		slot:RemoveTextures()

		button:RemoveTextures()
		button:SetStyle("!_ActionSlot")

		local icon = _G[name.."ItemButtonIconTexture"]
		if(icon) then
			icon:InsetPoints(button)
			icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
		end

		local anchor = _G[name.."NameFrame"]
		if(anchor) then
			local bg = CreateFrame("Frame", nil, button)
			bg:SetStyle("Frame", "Inset")
			bg:SetPoint("TOPLEFT", button, "TOPRIGHT", 4, 0)
			bg:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", -10, 14)

			local level = button:GetFrameLevel()
			if(level < 3) then
				bg:SetFrameLevel(0)
			else
				bg:SetFrameLevel(level - 3)
			end
		end
	end
end

local TABARD_REGIONS = {
	["TabardFrameEmblemTopRight"] = true,
	["TabardFrameEmblemTopLeft"] = true,
	["TabardFrameEmblemBottomRight"] = true,
	["TabardFrameEmblemBottomLeft"] = true,
}

local function SkinIconButton(button, ...)

	-- button:RemoveTextures()
	button:SetStyle("Button")
	
	button.Icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
	button.Icon:InsetPoints()
	
	local region = button:GetRegions()
	region:SetTexCoord(...)
	region:InsetPoints()
end
--[[
##########################################################
##########################################################
]]--
local function MiscStyles()
	--print('test MiscStyles')
	if SV.db.Skins.blizzard.enable ~= true then
		 return
	end

	if(SV.db.Skins.blizzard.dressingroom) then
		DressUpFrame:SetSize(500, 600)
		SV.API:Set("Window", DressUpFrame, true, true)

		-- DressUpModel:ClearAllPoints()
		-- DressUpModel:SetPoint("TOPLEFT", DressUpFrame, "TOPLEFT", 12, -76)
		-- DressUpModel:SetPoint("BOTTOMRIGHT", DressUpFrame, "BOTTOMRIGHT", -12, 36)

		-- DressUpModel:SetStyle("!_Frame", "Model")
		DressUpFrame.Inset:Hide()

		DressUpFrame.ModelScene:ClearAllPoints()
		DressUpFrame.ModelScene:SetPoint("TOPLEFT", DressUpFrame, "TOPLEFT", 12, -76)
		DressUpFrame.ModelScene:SetPoint("BOTTOMRIGHT", DressUpFrame, "BOTTOMRIGHT", -12, 46)

		DressUpFrame.ModelScene:SetStyle("!_Frame", "Model")

		DressUpFrameCancelButton:SetPoint("BOTTOMRIGHT", DressUpFrame, "BOTTOMRIGHT", -12, 12)
		DressUpFrameCancelButton:SetStyle("Button")

		DressUpFrameResetButton:SetPoint("RIGHT", DressUpFrameCancelButton, "LEFT", -12, 0)
		DressUpFrameResetButton:SetStyle("Button")

		DressUpFrameOutfitDropdown:SetStyle("DropDown")
		DressUpFrameOutfitDropdown.SaveButton:SetStyle("Button")

		SV.API:Set("CloseButton", DressUpFrameCloseButton, DressUpFrame.Panel)

		-- DressUpFrame.LinkButton
		DressUpFrame.LinkButton:SetStyle("Button")
		DressUpFrame.LinkButton:ClearAllPoints()
		DressUpFrame.LinkButton:SetPoint("BOTTOMRIGHT", DressUpFrame.ModelScene, "BOTTOMRIGHT", 0, 0)
		-- DressUpFrame.LinkButton:SetFrameLevel(DressUpFrame.ModelScene:GetFrameLevel()+1)
		DressUpFrame.LinkButton:RaiseFrameLevel(DressUpFrame.ModelScene)

		SV.API:Set("Window", DressUpFrame.OutfitDetailsPanel, true, true)
	end

	if(SV.db.Skins.blizzard.gossip) then
		SV.API:Set("Window", GossipFrame, true, true)

		ItemTextFrame:RemoveTextures(true)
		ItemTextScrollFrame.ScrollBar:RemoveTextures()
		SV.API:Set("CloseButton", GossipFrameCloseButton)
		SV.API:Set("PageButton", ItemTextPrevPageButton, false, true)
		SV.API:Set("PageButton", ItemTextNextPageButton)
		ItemTextPageText:SetTextColor('P', 1, 1, 1)
		hooksecurefunc(ItemTextPageText, "SetTextColor", function(p, h, k, l, m)
			if k ~= 1 or l ~= 1 or m ~= 1 then
				p:SetTextColor(h, 1, 1, 1)
			end
		end)
		ItemTextFrame:SetStyle("Frame", "Pattern")
		ItemTextFrame.Inset:Die()
		SV.API:Set("ScrollBar", ItemTextScrollFrame)
		SV.API:Set("CloseButton", ItemTextFrameCloseButton)
		-- local r = {"GossipFrame.GreetingPanel", "GossipFrame.Inset", "GossipGreetingScrollFrameScrollBar"}
		GossipFrame.GreetingPanel:RemoveTextures()
		-- GossipFrame.GreetingPanel.ScrollBox:RemoveTextures()
		-- GossipFrame.GreetingPanel.ScrollBar:RemoveTextures()
		SV.API:Set("ScrollBar", GossipFrame.GreetingPanel)
		-- for s, t in pairs(r)do
		-- 	_G[t]:RemoveTextures()
		-- end
		GossipFrame:SetStyle("Frame", "Window")
		GossipFrame.Inset:Hide()

		-- GossipGreetingScrollFrameScrollBar:SetStyle("!_Frame", "Inset", true)
		GossipFrame.GreetingPanel.ScrollBox:RemoveTextures()
		GossipFrame.GreetingPanel.ScrollBox:SetStyle("!_Frame", "Inset", true)
		GossipFrame.GreetingPanel.ScrollBox.spellTex = GossipFrame.GreetingPanel.ScrollBox:CreateTexture(nil, "ARTWORK")
		GossipFrame.GreetingPanel.ScrollBox.spellTex:SetTexture([[Interface\QuestFrame\QuestBG]])
		GossipFrame.GreetingPanel.ScrollBox.spellTex:SetPoint("TOPLEFT", 2, -2)
		GossipFrame.GreetingPanel.ScrollBox.spellTex:SetSize(506, 615)
		GossipFrame.GreetingPanel.ScrollBox.spellTex:SetTexCoord(0, 1, 0.02, 1)
		_G["GossipFramePortrait"]:Die()

		GossipFrame.GreetingPanel.GoodbyeButton:RemoveTextures()
		GossipFrame.GreetingPanel.GoodbyeButton:SetStyle("Button")

		-- _G["GossipFrameGreetingGoodbyeButton"]:RemoveTextures()
		-- _G["GossipFrameGreetingGoodbyeButton"]:SetStyle("Button")
		SV.API:Set("CloseButton", GossipFrameCloseButton, GossipFrame.Panel)

		GossipFrame.FriendshipStatusBar:RemoveTextures()
		GossipFrame.FriendshipStatusBar:SetFrameStrata('HIGH')
		GossipFrame.FriendshipStatusBar:SetWidth(205)
		GossipFrame.FriendshipStatusBar:SetStatusBarTexture(SV.media.statusbar.default)
		GossipFrame.FriendshipStatusBar:SetStyle("Frame", "Bar")

		GossipFrame.FriendshipStatusBar:ClearAllPoints()
		GossipFrame.FriendshipStatusBar:SetPoint("TOPLEFT", GossipFrame, "TOPLEFT", 98, -38)

		GossipFrame.FriendshipStatusBar.icon:SetSize(32,32)
		GossipFrame.FriendshipStatusBar.icon:ClearAllPoints()
		GossipFrame.FriendshipStatusBar.icon:SetPoint("LEFT", GossipFrame.FriendshipStatusBar, "RIGHT", 0, -2)

		SV.NPC:Register(GossipFrame, GossipFrame.TitleContainer.TitleText)

		-- hooksecurefunc("GossipTitleButton_OnClick", function() SV.NPC:PlayerTalksFirst() end)
		hooksecurefunc(GossipOptionButtonMixin, "OnClick", function() SV.NPC:PlayerTalksFirst() end)
		
	end

	if (SV.db.Skins.blizzard.greeting) then
		QuestFrameGreetingPanel:HookScript("OnShow", _hook_GreetingPanelShow)
	end

	if(SV.db.Skins.blizzard.guildregistrar) then
		SV.API:Set("Window", GuildRegistrarFrame, true, true)

		GuildRegistrarFrameInset:Die()
		GuildRegistrarFrameEditBox:RemoveTextures()
		GuildRegistrarGreetingFrame:RemoveTextures()

		GuildRegistrarFrameGoodbyeButton:SetStyle("Button")
		GuildRegistrarFrameCancelButton:SetStyle("Button")
		GuildRegistrarFramePurchaseButton:SetStyle("Button")
		SV.API:Set("CloseButton", GuildRegistrarFrameCloseButton)
		GuildRegistrarFrameEditBox:SetStyle("Editbox")

		for i = 1, GuildRegistrarFrameEditBox:GetNumRegions() do
			local region = select(i, GuildRegistrarFrameEditBox:GetRegions())
			if region and region:GetObjectType() == "Texture"then
				if region:GetTexture() == "Interface\\ChatFrame\\UI-ChatInputBorder-Left" or region:GetTexture() == "Interface\\ChatFrame\\UI-ChatInputBorder-Right" then
					region:Die()
				end
			end
		end

		GuildRegistrarFrameEditBox:SetHeight(20)

		if(_G["GuildRegistrarButton1"]) then
			_G["GuildRegistrarButton1"]:GetFontString():SetTextColor(1, 1, 1)
		end
		if(_G["GuildRegistrarButton2"]) then
			_G["GuildRegistrarButton2"]:GetFontString():SetTextColor(1, 1, 1)
		end

		GuildRegistrarPurchaseText:SetTextColor(1, 1, 1)
		AvailableServicesText:SetTextColor(1, 1, 0)
	end

	if(SV.db.Skins.blizzard.loot) then
		local MasterLooterFrame = _G.MasterLooterFrame;
		--local MissingLootFrame = _G.MissingLootFrame;
		local LootHistoryFrame = _G.GroupLootHistoryFrame;
		local BonusRollFrame = _G.BonusRollFrame;
		--local MissingLootFramePassButton = _G.MissingLootFramePassButton;

		LootHistoryFrame:SetFrameStrata('HIGH')

		--MissingLootFrame:RemoveTextures()
		--MissingLootFrame:SetStyle("Frame", "Pattern")

		--SV.API:Set("CloseButton", MissingLootFramePassButton)
		--hooksecurefunc("MissingLootFrame_Show", MissingLootFrame_OnShow)

		LootHistoryFrame:RemoveTextures()
		LootHistoryFrame:SetStyle("!_Frame", 'Transparent')
		SV.API:Set("CloseButton", LootHistoryFrame.CloseButton)
		SV.API:Set("CloseButton", LootHistoryFrame.ResizeButton)

		LootHistoryFrame.ResizeButton:SetStyle("!_Frame")
		LootHistoryFrame.ResizeButton:SetWidth(LootHistoryFrame:GetWidth())
		LootHistoryFrame.ResizeButton:SetHeight(19)
		LootHistoryFrame.ResizeButton:ClearAllPoints()
		LootHistoryFrame.ResizeButton:SetPoint("TOP", LootHistoryFrame, "BOTTOM", 0, -2)
		LootHistoryFrame.ResizeButton:SetNormalTexture("")

		local txt = LootHistoryFrame.ResizeButton:CreateFontString(nil,"OVERLAY")
		txt:SetFont(SV.media.font.default, 14, "NONE")
		txt:SetAllPoints(LootHistoryFrame.ResizeButton)
		txt:SetJustifyH("CENTER")
		txt:SetText("RESIZE")

		LootHistoryFrame.ScrollBox:RemoveTextures()
		SV.API:Set("ScrollBar", LootHistoryFrame)
		hooksecurefunc(LootHistoryFrame, "DoFullRefresh", LootHistoryFrame_OnUpdate)
		-- hooksecurefunc("LootHistoryFrame_FullUpdate", LootHistoryFrame_OnUpdate)

		MasterLooterFrame:RemoveTextures()
		MasterLooterFrame:SetStyle("!_Frame")
		MasterLooterFrame:SetFrameStrata('FULLSCREEN_DIALOG')

		hooksecurefunc("MasterLooterFrame_Show", _hook_MasterLootFrame_OnShow)

		-- JV - 20161002: This is causing BonusRoll Frame not to show. Removed until I can figure out what's going wrong.
		BonusRollFrame:RemoveTextures()
		SV.API:Set("Alert", BonusRollFrame)
		BonusRollFrame.PromptFrame.Icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
		BonusRollFrame.PromptFrame.Timer.Bar:SetTexture(SV.media.statusbar.default)
		BonusRollFrame.PromptFrame.Timer.Bar:SetVertexColor(0.1, 1, 0.1)
	end

	if(SV.db.Skins.blizzard.losscontrol) then
		local IconBackdrop = CreateFrame("Frame", nil, LossOfControlFrame)
		IconBackdrop:WrapPoints(LossOfControlFrame.Icon)
		IconBackdrop:SetFrameLevel(LossOfControlFrame:GetFrameLevel()-1)
		IconBackdrop:SetStyle("Frame", "Icon")
		LossOfControlFrame.Icon:SetTexCoord(.1, .9, .1, .9)
		LossOfControlFrame:RemoveTextures()
		LossOfControlFrame.AbilityName:ClearAllPoints()
		hooksecurefunc("LossOfControlFrame_SetUpDisplay", _hook_LossOfControl)
	end

	if(SV.db.Skins.blizzard.mail) then
		InboxFrame:RemoveTextures()
		MailFrameInset:Die()
		SendMailMoneyBg:Die()
		SendMailMoneyInset:RemoveTextures()
		SendMailFrame:RemoveTextures()
		MailFrameTab1:RemoveTextures()
		MailFrameTab2:RemoveTextures()
		MailFramePortrait:Die()

		SV.API:Set("Window", MailFrame)
		SV.API:Set("CloseButton", MailFrameCloseButton)

		SV.API:Set("PageButton", InboxPrevPageButton, false, true)
		SV.API:Set("PageButton", InboxNextPageButton)

		SV.API:Set("Tab", MailFrameTab1)
		SV.API:Set("Tab", MailFrameTab2)

		SendMailScrollFrame.ScrollBar:RemoveTextures(true)
		SendMailScrollFrame.ScrollBar:SetStyle("!_Frame", "Inset")
		SV.API:Set("ScrollBar", SendMailScrollFrame)

		SendMailNameEditBox:SetStyle("Editbox")
		SendMailNameEditBox.Panel:SetPoint("BOTTOMRIGHT", 2, 4)

		SendMailSubjectEditBox:SetStyle("Editbox")
		SendMailSubjectEditBox.Panel:SetPoint("BOTTOMRIGHT", 2, 0)

		SendMailMoneyGold:SetStyle("Editbox")

		SendMailMoneySilver:SetStyle("Editbox")
		SendMailMoneySilver.Panel:SetPoint("TOPLEFT", -2, 1)
		SendMailMoneySilver.Panel:SetPoint("BOTTOMRIGHT", -12, -1)
		SendMailMoneySilver:SetTextInsets(-1, -1, -2, -2)

		SendMailMoneyCopper:SetStyle("Editbox")
		SendMailMoneyCopper.Panel:SetPoint("TOPLEFT", -2, 1)
		SendMailMoneyCopper.Panel:SetPoint("BOTTOMRIGHT", -12, -1)
		SendMailMoneyCopper:SetTextInsets(-1, -1, -2, -2)

		hooksecurefunc("SendMailFrame_Update", MailFrame_OnUpdate)
		SendMailCancelButton:SetStyle("Button")
		SendMailMailButton:SetStyle("Button")
		SendMailMailButton:SetPoint("RIGHT", SendMailCancelButton, "LEFT", -2, 0)

		OpenMailFrame:RemoveTextures(true)
		OpenMailFrame:SetStyle("!_Frame", "Transparent", true)
		OpenMailFrameInset:Die()

		OpenMailReportSpamButton:SetStyle("Button")
		OpenMailCancelButton:SetStyle("Button")
		OpenMailDeleteButton:SetStyle("Button")
		OpenMailDeleteButton:SetPoint("RIGHT", OpenMailCancelButton, "LEFT", -2, 0)
		OpenMailReplyButton:SetStyle("Button")
		OpenMailReplyButton:SetPoint("RIGHT", OpenMailDeleteButton, "LEFT", -2, 0)

		SV.API:Set("CloseButton", OpenMailFrameCloseButton)

		-- OpenMailScrollFrameScrollBar:RemoveTextures(true)
		-- OpenMailScrollFrameScrollBar:SetStyle("!_Frame", "Default")

		-- SV.API:Set("ScrollBar", OpenMailScrollFrame)
		SendMailBodyEditBox:SetTextColor(1, 1, 1)
		-- TODO: Simple HTML, need to look about this
		-- OpenMailBodyText:SetTextColor(1, 1, 1)
		InvoiceTextFontNormal:SetTextColor(1, 1, 1)

		OpenMailArithmeticLine:Die()

		OpenMailLetterButton:RemoveTextures()
		OpenMailLetterButton:SetStyle("Button")
		OpenMailLetterButtonIconTexture:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
		OpenMailLetterButtonIconTexture:InsetPoints()

		OpenMailMoneyButton:RemoveTextures()
		OpenMailMoneyButton:SetStyle("Button")
		OpenMailMoneyButtonIconTexture:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
		OpenMailMoneyButtonIconTexture:InsetPoints()
		
		-- Add Open All Mail button
		SV.API:Set("Button", OpenAllMail);
		OpenAllMail:SetPoint("TOPRIGHT", MailFrame, -20, -30);
		
		-- Fix for mail title text
		MailFrame.TitleContainer:ClearAllPoints()
		MailFrame.TitleContainer:SetPoint("TOPLEFT", MailFrame, 0, -1)
		MailFrame.TitleContainer:SetPoint("TOPRIGHT", MailFrame, 0, -1)
		-- InboxTitleText:SetPoint("CENTER", MailFrame, "TOP", 0, -15);
		-- SendMailTitleText:SetPoint("CENTER", MailFrame, "TOP", 0, -15);
		-- OpenMailTitleText:SetPoint("CENTER", MailFrame, "TOP", 0, -15);
		MailFrameTitleText:SetFontObject(SVUI_Font_Header)
		
		for i = 1, INBOXITEMS_TO_DISPLAY do
			local slot = _G["MailItem"..i]
			if(slot) then
				slot:RemoveTextures()
				slot:SetStyle("Frame", "Inset")
				slot.Panel:SetPoint("TOPLEFT", 2, 1)
				slot.Panel:SetPoint("BOTTOMRIGHT", -2, 2)

				local button = _G["MailItem"..i.."Button"]
				if(button) then
					button:RemoveTextures()
					button:SetStyle("!_ActionSlot")
				end

				local icon = _G["MailItem"..i.."ButtonIcon"]
				if(icon) then
					icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
					icon:InsetPoints()
				end
			end
		end

		for i = 1, ATTACHMENTS_MAX_SEND do
			local slot = _G["OpenMailAttachmentButton"..i]
			if(slot) then
				slot:RemoveTextures()
				slot:SetStyle("!_ActionSlot")
				local icon = _G["OpenMailAttachmentButton"..i.."IconTexture"]
				if(icon) then
					icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
					icon:InsetPoints()
				end
			end
		end
	end

	if(SV.db.Skins.blizzard.merchant) then

		SV.API:Set("Window", MerchantFrame, false, true)
		MerchantFrame:SetWidth(360)
		MerchantFrame.Inset:Hide()

		local level = MerchantFrame:GetFrameLevel()
		if(level > 0) then
			MerchantFrame:SetFrameLevel(level - 1)
		else
			MerchantFrame:SetFrameLevel(0)
		end

		MerchantExtraCurrencyInset:RemoveTextures()
		MerchantExtraCurrencyBg:RemoveTextures()
		MerchantFrameInset:RemoveTextures()
		MerchantMoneyBg:RemoveTextures()
		MerchantMoneyInset:RemoveTextures()
		MerchantMoneyInset:Hide()

		MerchantBuyBackItem:RemoveTextures(true)
		MerchantBuyBackItem:SetStyle("Frame", "Inset", true, 2, 2, 3)
		MerchantBuyBackItem.Panel:SetFrameLevel(MerchantBuyBackItem.Panel:GetFrameLevel() + 1)
		MerchantBuyBackItemItemButton:RemoveTextures()
		MerchantBuyBackItemItemButton:SetStyle("Button")
		MerchantFrameInset:SetStyle("Frame", "Inset")
		MerchantFrameInset.Panel:SetFrameLevel(MerchantFrameInset.Panel:GetFrameLevel() + 1)

		SV.API:Set("DropDown", MerchantFrameLootFilter)
		SV.API:Set("Tab", _G["MerchantFrameTab1"])
		SV.API:Set("Tab", _G["MerchantFrameTab2"])

		for i = 1, 12 do
			local slot = _G["MerchantItem"..i]

			if(slot) then
				slot:RemoveTextures(true)
				slot:SetStyle("Frame", "Inset")

				local button = _G["MerchantItem"..i.."ItemButton"]
				if(button) then
					button:RemoveTextures()
					button:SetStyle("!_ActionSlot")
					button:SetPoint("TOPLEFT", slot, "TOPLEFT", 4, -4)
					local icon = _G["MerchantItem"..i.."ItemButtonIconTexture"]
					if(icon) then
						icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
						icon:InsetPoints()
					end
					local money = _G["MerchantItem"..i.."MoneyFrame"]
					if(money) then
						money:ClearAllPoints()
						money:SetPoint("BOTTOMLEFT", button, "BOTTOMRIGHT", 3, 0)
					end
					local border = button.IconBorder
					if not border.hooked then
						border:Hide()
						hooksecurefunc(border, 'Show', function () border:Hide() end)
						hooksecurefunc(border, 'SetShown', function (show) border:Hide() end)
						border.hooked = true
					end
					
				end
			end
		end

		MerchantBuyBackItemItemButton:RemoveTextures()
		MerchantBuyBackItemItemButton:SetStyle("Button")
		MerchantBuyBackItemItemButtonIconTexture:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
		MerchantBuyBackItemItemButtonIconTexture:InsetPoints()

		SkinIconButton(MerchantRepairItemButton, 0.04, 0.24, 0.06, 0.5)
		SkinIconButton(MerchantGuildBankRepairButton, 0.61, 0.82, 0.1, 0.52)
		SkinIconButton(MerchantRepairAllButton, 0.61, 0.82, 0.1, 0.52)

		if MerchantSellAllJunkButton then
			SkinIconButton(MerchantSellAllJunkButton, 0.34, 0.1, 0.34, 0.535, 0.535, 0.1, 0.535, 0.535)
		end

		SV.API:Set("CloseButton", MerchantFrameCloseButton, MerchantFrame.Panel)
		SV.API:Set("!_PageButton", MerchantNextPageButton)
		SV.API:Set("!_PageButton", MerchantPrevPageButton, false, true)

		SV.NPC:Register(MerchantFrame, MerchantFrameTitleText)
	end

	if(SV.db.Skins.blizzard.petition) then
		SV.API:Set("Window", PetitionFrame, nil, true)
		PetitionFrameInset:Die()

		PetitionFrameSignButton:SetStyle("Button")
		PetitionFrameRequestButton:SetStyle("Button")
		PetitionFrameRenameButton:SetStyle("Button")
		PetitionFrameCancelButton:SetStyle("Button")

		SV.API:Set("CloseButton", PetitionFrameCloseButton)

		PetitionFrameCharterTitle:SetTextColor(1, 1, 0)
		PetitionFrameCharterName:SetTextColor(1, 1, 1)
		PetitionFrameMasterTitle:SetTextColor(1, 1, 0)
		PetitionFrameMasterName:SetTextColor(1, 1, 1)
		PetitionFrameMemberTitle:SetTextColor(1, 1, 0)

		for i=1, 9 do
			local frameName = ("PetitionFrameMemberName%d"):format(i)
			local frame = _G[frameName];
			if(frame) then
				frame:SetTextColor(1, 1, 1)
			end
		end

		PetitionFrameInstructions:SetTextColor(1, 1, 1)

		PetitionFrameRenameButton:SetPoint("LEFT", PetitionFrameRequestButton, "RIGHT", 3, 0)
		PetitionFrameRenameButton:SetPoint("RIGHT", PetitionFrameCancelButton, "LEFT", -3, 0)
	end

	if(SV.db.Skins.blizzard.stable) then
		--TODO: FIX STABLE SKIN
		StableFrame:RemoveTextures()
		-- PetStableFrameInset:RemoveTextures()
		-- PetStableLeftInset:RemoveTextures()
		-- PetStableBottomInset:RemoveTextures()
		StableFrame:SetStyle("Frame", "Window")
		-- PetStableFrameInset:SetStyle("!_Frame", 'Inset')
		StableFrame.StabledPetList:SetStyle("!_Frame", 'Inset')
		SV.API:Set("CloseButton", StableFrameCloseButton)
		SV.API:Set("ScrollBar", StableFrame.StabledPetList)

		StableFrame.StableTogglePetButton:SetStyle("Button")
		StableFrame.ReleasePetButton:SetStyle("Button")
		
		-- PetStablePrevPageButton:SetStyle("Button")
		-- PetStableNextPageButton:SetStyle("Button")
		-- SV.API:Set("PageButton", PetStablePrevPageButton)
		-- SV.API:Set("PageButton", PetStableNextPageButton)
		-- Constants.PetConsts
		-- for i = 1, NUM_PET_ACTIVE_SLOTS do
		-- 	 SV.API:Set("!_ItemButton", _G['StableActivePet'..i])
		-- end
		-- for i = 1, NUM_PET_STABLE_SLOTS do
		-- 	 SV.API:Set("!_ItemButton", _G['StableStabledPet'..i])
		-- end
		-- PetStableSelectedPetIcon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
	end

	if(SV.db.Skins.blizzard.tabard) then
		for i=1, TabardFrame:GetNumRegions() do
			local region = select(i, TabardFrame:GetRegions())
			if(region and region.GetObjectType and region:GetObjectType() == "Texture") then
				local regionName = region:GetName();
				if(not TABARD_REGIONS[regionName]) then
					region:Die()
				end
			end
		end

		TabardFrame:SetStyle("Frame", "Window2", false)
		TabardModel:SetStyle("!_Frame", "Transparent")
		TabardFrameCancelButton:SetStyle("Button")
		TabardFrameAcceptButton:SetStyle("Button")
		SV.API:Set("CloseButton", TabardFrameCloseButton)
		TabardFrameCostFrame:RemoveTextures()
		TabardFrameCustomizationFrame:RemoveTextures()
		TabardFrameInset:Die()
		TabardFrameMoneyInset:Die()
		TabardFrameMoneyBg:RemoveTextures()

		for i = 1, 5 do
			local name = "TabardFrameCustomization"..i;
			local frame = _G[name];
			if(frame) then
				frame:RemoveTextures()
				SV.API:Set("PageButton", _G[name.."LeftButton"])
				SV.API:Set("PageButton", _G[name.."RightButton"])

				if(i == 1) then
					local p1, a, p2, x, y = frame:GetPoint()
					frame:SetPoint(p1, a, p2, x, y + 4)
				else
					local last = _G["TabardFrameCustomization"..i-1];
					if(last) then
						frame:ClearAllPoints()
						frame:SetPoint("TOP", last, "BOTTOM", 0, -6)
					end
				end
			end
		end

		TabardCharacterModelRotateLeftButton:SetPoint("BOTTOMLEFT", 4, 4)
		TabardCharacterModelRotateRightButton:SetPoint("TOPLEFT", TabardCharacterModelRotateLeftButton, "TOPRIGHT", 4, 0)

		-- hooksecurefunc(TabardCharacterModelRotateLeftButton, "SetPoint", function(self, p1, a, p2, x, y)
		-- 	if((p1 ~= "BOTTOMLEFT") or (x ~= 4) or (y ~= 4)) then
		-- 		 self:SetPoint("BOTTOMLEFT", 4, 4)
		-- 	end
		-- end)

		-- hooksecurefunc(TabardCharacterModelRotateRightButton, "SetPoint", function(self, p1, a, p2, x, y)
		--     local anchor = _G.TabardCharacterModelRotateLeftButton
		-- 	if((anchor) and ((p1 ~= "TOPLEFT") or (x ~= 4) or (y ~= 0))) then
		-- 		 self:SetPoint("TOPLEFT", anchor, "TOPRIGHT", 4, 0)
		-- 	end
		-- end)
	end

	if(SV.db.Skins.blizzard.taxi) then
		SV.API:Set("Window", TaxiFrame)
		SV.API:Set("CloseButton", TaxiFrame.CloseButton)
	end
	
	if (SV.db.Skins.blizzard.trade) then
		TradeFrameInset:Die()
		TradeRecipientItemsInset:Die()
		TradePlayerItemsInset:Die()
		TradePlayerInputMoneyInset:Die()
		TradePlayerEnchantInset:Die()
		TradeRecipientEnchantInset:Die()
		TradeRecipientMoneyInset:Die()
		TradeRecipientMoneyBg:Die()
		--TradeFramePlayerPortrait:Die()
		--TradeFrameRecipientPortrait:Die()

		SV.API:Set("Window", TradeFrame, true)

		TradeFrameTradeButton:SetStyle("Button")
		TradeFrameCancelButton:SetStyle("Button")
		SV.API:Set("CloseButton", TradeFrameCloseButton, TradeFrame.Panel)

		TradePlayerInputMoneyFrameGold:SetStyle("Editbox")

		TradePlayerInputMoneyFrameSilver:SetStyle("Editbox")
		TradePlayerInputMoneyFrameSilver.Panel:SetPoint("TOPLEFT", -2, 1)
		TradePlayerInputMoneyFrameSilver.Panel:SetPoint("BOTTOMRIGHT", -12, -1)
		TradePlayerInputMoneyFrameSilver:SetTextInsets(-1, -1, -2, -2)

		TradePlayerInputMoneyFrameCopper:SetStyle("Editbox")
		TradePlayerInputMoneyFrameCopper.Panel:SetPoint("TOPLEFT", -2, 1)
		TradePlayerInputMoneyFrameCopper.Panel:SetPoint("BOTTOMRIGHT", -12, -1)
		TradePlayerInputMoneyFrameCopper:SetTextInsets(-1, -1, -2, -2)

		for i = 1, 7 do
			StyleTradeSlots("TradePlayerItem"..i)
			StyleTradeSlots("TradeRecipientItem"..i)
		end

		TradeHighlightPlayerTop:SetColorTexture(0.28, 0.75, 1, 0.2)
		TradeHighlightPlayerBottom:SetColorTexture(0.28, 0.75, 1, 0.2)
		TradeHighlightPlayerMiddle:SetColorTexture(0.28, 0.75, 1, 0.2)
		TradeHighlightPlayer:SetFrameStrata("HIGH")
		TradeHighlightPlayerEnchantTop:SetColorTexture(0.28, 0.75, 1, 0.2)
		TradeHighlightPlayerEnchantBottom:SetColorTexture(0.28, 0.75, 1, 0.2)
		TradeHighlightPlayerEnchantMiddle:SetColorTexture(0.28, 0.75, 1, 0.2)
		TradeHighlightPlayerEnchant:SetFrameStrata("HIGH")
		TradeHighlightRecipientTop:SetColorTexture(0.28, 0.75, 1, 0.2)
		TradeHighlightRecipientBottom:SetColorTexture(0.28, 0.75, 1, 0.2)
		TradeHighlightRecipientMiddle:SetColorTexture(0.28, 0.75, 1, 0.2)
		TradeHighlightRecipient:SetFrameStrata("HIGH")
		TradeHighlightRecipientEnchantTop:SetColorTexture(0.28, 0.75, 1, 0.2)
		TradeHighlightRecipientEnchantBottom:SetColorTexture(0.28, 0.75, 1, 0.2)
		TradeHighlightRecipientEnchantMiddle:SetColorTexture(0.28, 0.75, 1, 0.2)
		TradeHighlightRecipientEnchant:SetFrameStrata("HIGH")
	end


	if(SV.db.Skins.blizzard.bgscore) then
		-- These lines were causing errors on start, possibly due to functionality removed in  last update.
		--WorldStateScoreScrollFrameScrollBar:RemoveTextures()
		--WorldStateScoreFrame:RemoveTextures()
		--WorldStateScoreFrame:SetStyle("Frame", "Window")
		SV.API:Set("CloseButton", WorldStateScoreFrameCloseButton)
		SV.API:Set("ScrollBar", WorldStateScoreScrollFrame)
		--WorldStateScoreFrameInset:SetAlpha(0)
		--WorldStateScoreFrameLeaveButton:SetStyle("Button")
		SV.API:Set("Tab", _G["WorldStateScoreFrameTab1"])
		SV.API:Set("Tab", _G["WorldStateScoreFrameTab2"])
		SV.API:Set("Tab", _G["WorldStateScoreFrameTab3"])
	end

	if(SV.db.Skins.blizzard.talkingHead) then
		--TalkingHeadFrame:RemoveTextures()
		--TalkingHeadFrame:SetStyle("Frame", "Window")
		TalkingHeadFrame.BackgroundFrame:RemoveTextures(true)
		TalkingHeadFrame.BackgroundFrame.TextBackground:SetAtlas(nil)
		TalkingHeadFrame.MainFrame.Model.PortraitBg:SetAtlas(nil)
		-- TalkingHeadFrame.MainFrame.Model.PortraitBg:RemoveTextures(true)
		TalkingHeadFrame.PortraitFrame:RemoveTextures(true)
		TalkingHeadFrame.PortraitFrame.Portrait:SetAtlas(nil)
		-- TalkingHeadFrame.PortraitFrame:Hide()
		
		TalkingHeadFrame:RemoveTextures()
		TalkingHeadFrame:SetStyle("Frame", "Window")

		local function noop() end

		TalkingHeadFrame.BackgroundFrame.TextBackground.SetAtlas = noop
		TalkingHeadFrame.PortraitFrame.Portrait.SetAtlas = noop
		TalkingHeadFrame.MainFrame.Model.PortraitBg.SetAtlas = noop


		--narrator
		--SVUI_Font_Narrator
		--SV.media.font.dialog
		TalkingHeadFrame.NameFrame.Name:SetTextColor(1, 0.82, 0.02)
		TalkingHeadFrame.NameFrame.Name.SetTextColor = noop
		TalkingHeadFrame.NameFrame.Name:SetShadowColor(0, 0, 0, 1)
		TalkingHeadFrame.NameFrame.Name:SetShadowOffset(2, -2)
		TalkingHeadFrame.NameFrame.Name:SetFontObject(SVUI_Font_Narrator)

		TalkingHeadFrame.TextFrame.Text:SetTextColor(1, 1, 1)
		TalkingHeadFrame.TextFrame.Text.SetTextColor = noop
		TalkingHeadFrame.TextFrame.Text:SetShadowColor(0, 0, 0, 1)
		TalkingHeadFrame.TextFrame.Text:SetShadowOffset(2, -2)
		TalkingHeadFrame.TextFrame.Text:SetFontObject(SVUI_Font_Default)

		SV.API:Set("CloseButton", TalkingHeadFrame.MainFrame.CloseButton, TalkingHeadFrame)
	end
end
--[[
##########################################################
MOD LOADING
##########################################################
]]--

--Just some test code

-- local talkingHeadTextureKitRegionFormatStrings = {
-- 	TextBackground = '%s-TextBackground',
-- 	Portrait = '%s-PortraitFrame',
-- }
-- local talkingHeadDefaultAtlases = {
-- 	TextBackground = 'TalkingHeads-TextBackground',
-- 	Portrait = 'TalkingHeads-Alliance-PortraitFrame',
-- }
-- local talkingHeadFontColor = {
-- 	['TalkingHeads-Horde'] = {Name = CreateColor(0.28, 0.02, 0.02), Text = CreateColor(0.0, 0.0, 0.0), Shadow = CreateColor(0.0, 0.0, 0.0, 0.0)},
-- 	['TalkingHeads-Alliance'] = {Name = CreateColor(0.02, 0.17, 0.33), Text = CreateColor(0.0, 0.0, 0.0), Shadow = CreateColor(0.0, 0.0, 0.0, 0.0)},
-- 	['TalkingHeads-Neutral'] = {Name = CreateColor(0.33, 0.16, 0.02), Text = CreateColor(0.0, 0.0, 0.0), Shadow = CreateColor(0.0, 0.0, 0.0, 0.0)},
-- 	['Normal'] = {Name = CreateColor(1, 0.82, 0.02), Text = CreateColor(1, 1, 1), Shadow = CreateColor(0.0, 0.0, 0.0, 1.0)},
-- }


-- function TestTalkingHead()
-- 	local frame = TalkingHeadFrame
-- 	local model = frame.MainFrame.Model

-- 	if frame.finishTimer then
-- 		frame.finishTimer:Cancel()
-- 		frame.finishTimer = nil
-- 	end
-- 	if frame.voHandle then
-- 		StopSound(frame.voHandle)
-- 		frame.voHandle = nil
-- 	end

-- 	local currentDisplayInfo = model:GetDisplayInfo()
-- 	local displayInfo, cameraID, vo, duration, lineNumber, numLines, name, text, isNewTalkingHead, textureKitID

-- 	displayInfo = 76291
-- 	cameraID = 1240
-- 	vo = 103175
-- 	duration = 20.220001220703
-- 	lineNumber = 0
-- 	numLines = 4
-- 	name = 'Some Ugly Woman'
-- 	text = 'Testing this sheet out Testing this sheet out Testing this sheet out Testing this sheet out Testing this sheet out Testing this sheet out Testing this sheet out '
-- 	isNewTalkingHead = true
-- 	textureKitID = 0

-- 	local textFormatted = format(text)
-- 	if displayInfo and displayInfo ~= 0 then
-- 		local textureKit
-- 		if textureKitID ~= 0 then
-- 			SetupTextureKits(textureKitID, frame.BackgroundFrame, talkingHeadTextureKitRegionFormatStrings, false, true)
-- 			SetupTextureKits(textureKitID, frame.PortraitFrame, talkingHeadTextureKitRegionFormatStrings, false, true)
-- 			textureKit = GetUITextureKitInfo(textureKitID)
-- 		else
-- 			SetupAtlasesOnRegions(frame.BackgroundFrame, talkingHeadDefaultAtlases, true)
-- 			SetupAtlasesOnRegions(frame.PortraitFrame, talkingHeadDefaultAtlases, true)
-- 			textureKit = 'Normal'
-- 		end
-- 		local nameColor = talkingHeadFontColor[textureKit].Name
-- 		local textColor = talkingHeadFontColor[textureKit].Text
-- 		local shadowColor = talkingHeadFontColor[textureKit].Shadow
-- 		frame.NameFrame.Name:SetTextColor(nameColor:GetRGB())
-- 		frame.NameFrame.Name:SetShadowColor(shadowColor:GetRGBA())
-- 		frame.TextFrame.Text:SetTextColor(textColor:GetRGB())
-- 		frame.TextFrame.Text:SetShadowColor(shadowColor:GetRGBA())
-- 		frame:Show()
-- 		if currentDisplayInfo ~= displayInfo then
-- 			model.uiCameraID = cameraID
-- 			model:SetDisplayInfo(displayInfo)
-- 		else
-- 			if model.uiCameraID ~= cameraID then
-- 				model.uiCameraID = cameraID
-- 				Model_ApplyUICamera(model, model.uiCameraID)
-- 			end
-- 			TalkingHeadFrame_SetupAnimations(model)
-- 		end

-- 		if isNewTalkingHead then
-- 			TalkingHeadFrame:Reset(textFormatted, name)
-- 			TalkingHeadFrame:FadeinFrames()
-- 		else
-- 			if name ~= frame.NameFrame.Name:GetText() then
-- 				-- Fade out the old name and fade in the new name
-- 				frame.NameFrame.Fadeout:Play()
-- 				E:Delay(0.25, frame.NameFrame.Name.SetText, frame.NameFrame.Name, name)
-- 				E:Delay(0.5, frame.NameFrame.Fadein.Play, frame.NameFrame.Fadein)

-- 				frame.MainFrame.TalkingHeadsInAnim:Play()
-- 			end

-- 			if textFormatted ~= frame.TextFrame.Text:GetText() then
-- 				-- Fade out the old text and fade in the new text
-- 				frame.TextFrame.Fadeout:Play()
-- 				E:Delay(0.25, frame.TextFrame.Text.SetText, frame.TextFrame.Text, textFormatted)
-- 				E:Delay(0.5, frame.TextFrame.Fadein.Play, frame.TextFrame.Fadein)
-- 			end
-- 		end

-- 		local success, voHandle = PlaySound(vo, 'Talking Head', true, true)
-- 		if success then
-- 			frame.voHandle = voHandle
-- 		end
-- 	end
-- end

MOD:SaveCustomStyle("MISC", MiscStyles)

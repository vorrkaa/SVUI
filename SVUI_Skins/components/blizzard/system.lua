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
local ceil = math.ceil
--[[ WOW API ]]--
local IsAddOnLoaded = C_AddOns.IsAddOnLoaded
--[[
##########################################################
MASSIVE LIST OF LISTS
##########################################################
]]--
local SystemPopList = {
	"StaticPopup1",
	"StaticPopup2",
	"StaticPopup3"
};
local SystemDropDownList = {
	"DropDownList1MenuBackdrop",
	"DropDownList2MenuBackdrop",
	"DropDownList1Backdrop",
	"DropDownList2Backdrop",
};
local SystemFrameList1 = {
	"GameMenuFrame",
	"TicketStatusFrameButton",
	"AutoCompleteBox",
	"ConsolidatedBuffsTooltip",
	"ReadyCheckFrame",
	"StackSplitFrame",
	"QueueStatusFrame",
	"SettingsPanel"
	-- "InterfaceOptionsFrame",
	-- "VideoOptionsFrame",
	-- "AudioOptionsFrame"
};
local SystemFrameList4 = {
	"Options",
	"Store",
	"SoundOptions",
	"UIOptions",
	"Keybindings",
	"Macros",
	"Ratings",
	"AddOns",
	"Logout",
	"Quit",
	"Continue",
	"MacOptions",
	"Help",
	"WhatsNew",
	"Addons",
	"SVUI"
};
local SystemFrameList5 = {
	"GameMenuFrame",
	-- "InterfaceOptionsFrame",
	-- "AudioOptionsFrame",
	-- "VideoOptionsFrame",
};
local SystemFrameList6 = {
	-- "VideoOptionsFrameOkay",
	-- "VideoOptionsFrameCancel",
	-- "VideoOptionsFrameDefaults",
	-- "VideoOptionsFrameApply",
	-- "AudioOptionsFrameOkay",
	-- "AudioOptionsFrameCancel",
	-- "AudioOptionsFrameDefaults",
	"InterfaceOptionsFrameDefaults",
	"InterfaceOptionsFrameOkay",
	"InterfaceOptionsFrameCancel",
	"ReadyCheckFrameYesButton",
	"ReadyCheckFrameNoButton",
	"StackSplitOkayButton",
	"StackSplitCancelButton",
	"RolePollPopupAcceptButton"
};

local SystemFrameList13 = {
	"VideoOptionsFrameCategoryFrame",
	"VideoOptionsFramePanelContainer",
	"InterfaceOptionsFrameCategories",
	"InterfaceOptionsFramePanelContainer",
	"InterfaceOptionsFrameAddOns",
	"AudioOptionsSoundPanelPlayback",
	"AudioOptionsSoundPanelVolume",
	"AudioOptionsSoundPanelHardware",
	"AudioOptionsVoicePanelTalking",
	"AudioOptionsVoicePanelBinding",
	"AudioOptionsVoicePanelListening",
};
local SystemFrameList14 = {
	"InterfaceOptionsFrameTab1",
	"InterfaceOptionsFrameTab2",
};
local SystemFrameList15 = {
	"ControlsPanelBlockChatChannelInvites",
	"ControlsPanelStickyTargeting",
	"ControlsPanelAutoDismount",
	"ControlsPanelAutoClearAFK",
	"ControlsPanelBlockTrades",
	"ControlsPanelBlockGuildInvites",
	"ControlsPanelLootAtMouse",
	"ControlsPanelAutoLootCorpse",
	"ControlsPanelInteractOnLeftClick",
	"ControlsPanelAutoOpenLootHistory",
	"ControlsPanelReverseCleanUpBags",
	"ControlsPanelReverseNewLoot",
	"CombatPanelEnemyCastBarsOnOnlyTargetNameplates",
	"CombatPanelEnemyCastBarsNameplateSpellNames",
	"CombatPanelAttackOnAssist",
	"CombatPanelStopAutoAttack",
	"CombatPanelNameplateClassColors",
	"CombatPanelTargetOfTarget",
	"CombatPanelShowSpellAlerts",
	"CombatPanelReducedLagTolerance",
	"CombatPanelActionButtonUseKeyDown",
	"CombatPanelEnemyCastBarsOnPortrait",
	"CombatPanelEnemyCastBarsOnNameplates",
	"CombatPanelAutoSelfCast",
	"CombatPanelLossOfControl",
	"DisplayPanelShowCloak",
	"DisplayPanelShowHelm",
	"DisplayPanelShowAggroPercentage",
	"DisplayPanelPlayAggroSounds",
	"DisplayPanelDetailedLootInfo",
	"DisplayPanelShowSpellPointsAvg",
	"DisplayPanelemphasizeMySpellEffects",
	"DisplayPanelShowFreeBagSpace",
	"DisplayPanelCinematicSubtitles",
	"DisplayPanelRotateMinimap",
	"DisplayPanelScreenEdgeFlash",
	"DisplayPanelShowAccountAchievments",
	"ObjectivesPanelAutoQuestTracking",
	"ObjectivesPanelAutoQuestProgress",
	"ObjectivesPanelMapQuestDifficulty",
	"ObjectivesPanelAdvancedWorldMap",
	"ObjectivesPanelWatchFrameWidth",
	"ObjectivesPanelMapFade",
	"SocialPanelProfanityFilter",
	"SocialPanelSpamFilter",
	"SocialPanelChatBubbles",
	"SocialPanelPartyChat",
	"SocialPanelChatHoverDelay",
	"SocialPanelGuildMemberAlert",
	"SocialPanelChatMouseScroll",
	"SocialPanelEnableTwitter",
	"ActionBarsPanelLockActionBars",
	"ActionBarsPanelSecureAbilityToggle",
	"ActionBarsPanelAlwaysShowActionBars",
	"ActionBarsPanelBottomLeft",
	"ActionBarsPanelBottomRight",
	"ActionBarsPanelRight",
	"ActionBarsPanelRightTwo",
	"ActionBarsPanelCountdownCooldowns",
	"NamesPanelMyName",
	"NamesPanelFriendlyPlayerNames",
	"NamesPanelFriendlyPets",
	"NamesPanelFriendlyGuardians",
	"NamesPanelFriendlyTotems",
	"NamesPanelUnitFriendlyMinions",
	"NamesPanelUnitEnemyMinions",
	"NamesPanelUnitNameplatesPersonalResource",
	"NamesPanelUnitNameplatesPersonalResourceOnEnemy",
	"NamesPanelUnitNameplatesMakeLarger",
	"NamesPanelUnitNameplatesShowAll",
	"NamesPanelUnitNameplatesAggroFlash",
	--"NamesPanelUnitNameplatesFriends",
	"NamesPanelUnitNameplatesFriendlyGuardians",
	"NamesPanelUnitNameplatesFriendlyPets",
	"NamesPanelUnitNameplatesFriendlyTotems",
	"NamesPanelUnitNameplatesFriendlyMinions",
	"NamesPanelGuilds",
	"NamesPanelGuildTitles",
	"NamesPanelTitles",
	"NamesPanelMinus",
	"NamesPanelNonCombatCreature",
	"NamesPanelEnemyPlayerNames",
	"NamesPanelEnemyPets",
	"NamesPanelEnemyGuardians",
	"NamesPanelEnemyTotems",
	"NamesPanelUnitNameplatesEnemyPets",
	--"NamesPanelUnitNameplatesEnemies",
	"NamesPanelUnitNameplatesEnemyGuardians",
	"NamesPanelUnitNameplatesEnemyTotems",
	"NamesPanelUnitNameplatesEnemyMinus",
	"NamesPanelUnitNameplatesEnemyMinions",
	"CombatTextPanelTargetDamage",
	"CombatTextPanelPeriodicDamage",
	"CombatTextPanelPetDamage",
	"CombatTextPanelHealing",
	"CombatTextPanelHealingAbsorbTarget",
	"CombatTextPanelHealingAbsorbSelf",
	"CombatTextPanelTargetEffects",
	"CombatTextPanelOtherTargetEffects",
	"CombatTextPanelEnableFCT",
	"CombatTextPanelDodgeParryMiss",
	"CombatTextPanelDamageReduction",
	"CombatTextPanelRepChanges",
	"CombatTextPanelReactiveAbilities",
	"CombatTextPanelFriendlyHealerNames",
	"CombatTextPanelCombatState",
	"CombatTextPanelComboPoints",
	"CombatTextPanelLowManaHealth",
	"CombatTextPanelEnergyGains",
	"CombatTextPanelPeriodicEnergyGains",
	"CombatTextPanelHonorGains",
	"CombatTextPanelAuras",
	"CombatTextPanelPetBattle",
	"BuffsPanelBuffDurations",
	"BuffsPanelDispellableDebuffs",
	"BuffsPanelCastableBuffs",
	"BuffsPanelConsolidateBuffs",
	"BuffsPanelShowAllEnemyDebuffs",
	"CameraPanelFollowTerrain",
	"CameraPanelHeadBob",
	"CameraPanelWaterCollision",
	"CameraPanelSmartPivot",
	"MousePanelInvertMouse",
	"MousePanelClickToMove",
	"MousePanelWoWMouse",
	"MousePanelEnableMouseSpeed",
	"HelpPanelShowTutorials",
	"HelpPanelLoadingScreenTips",
	"HelpPanelEnhancedTooltips",
	"HelpPanelBeginnerTooltips",
	"HelpPanelShowLuaErrors",
	"HelpPanelColorblindMode",
	"HelpPanelMovePad",
	"BattlenetPanelOnlineFriends",
	"BattlenetPanelOfflineFriends",
	"BattlenetPanelBroadcasts",
	"BattlenetPanelFriendRequests",
	"BattlenetPanelConversations",
	"BattlenetPanelShowToastWindow",
	"StatusTextPanelPlayer",
	"StatusTextPanelPet",
	"StatusTextPanelParty",
	"StatusTextPanelTarget",
	"StatusTextPanelAlternateResource",
	"StatusTextPanelPercentages",
	"StatusTextPanelXP",
	"UnitFramePanelPartyBackground",
	"UnitFramePanelPartyPets",
	"UnitFramePanelArenaEnemyFrames",
	"UnitFramePanelArenaEnemyCastBar",
	"UnitFramePanelArenaEnemyPets",
	"UnitFramePanelFullSizeFocusFrame",
	"NamesPanelUnitNameplatesNameplateClassColors",
	"AccessibilityPanelMovePad",
	"AccessibilityPanelColorblindMode"
};
local SystemFrameList16 ={
	"ControlsPanelAutoLootKeyDropDown",
	"CombatPanelTOTDropDown",
	"CombatPanelFocusCastKeyDropDown",
	"CombatPanelSelfCastKeyDropDown",
	"CombatPanelLossOfControlFullDropDown",
	"CombatPanelLossOfControlSilenceDropDown",
	"CombatPanelLossOfControlInterruptDropDown",
	"CombatPanelLossOfControlDisarmDropDown",
	"CombatPanelLossOfControlRootDropDown",
	"CombatTextPanelTargetModeDropDown",
	"DisplayPanelAggroWarningDisplay",
	"DisplayPanelWorldPVPObjectiveDisplay",
	"DisplayPanelOutlineDropDown",
	"ObjectivesPanelQuestSorting",
	"SocialPanelChatStyle",
	"SocialPanelWhisperMode",
	"SocialPanelTimestamps",
	"SocialPanelBnWhisperMode",
	"SocialPanelConversationMode",
	"ActionBarsPanelPickupActionKeyDropDown",
	"NamesPanelNPCNamesDropDown",
	"NamesPanelUnitNameplatesMotionDropDown",
	"CombatTextPanelFCTDropDown",
	"CameraPanelStyleDropDown",
	"MousePanelClickMoveStyleDropDown",
	"LanguagesPanelLocaleDropDown",
	"LanguagesPanelAudioLocaleDropDown",
	"StatusTextPanelDisplayDropDown",
	"AccessibilityPanelColorFilterDropDown"
};
local SystemFrameList17 = {
	"Advanced_MaxFPSCheckBox",
	"Advanced_MaxFPSBKCheckBox",
	"Advanced_DesktopGamma",
	"Advanced_UseUIScale",
	"AudioOptionsSoundPanelEnableSound",
	"AudioOptionsSoundPanelSoundEffects",
	"AudioOptionsSoundPanelErrorSpeech",
	"AudioOptionsSoundPanelEmoteSounds",
	"AudioOptionsSoundPanelPetSounds",
	"AudioOptionsSoundPanelMusic",
	"AudioOptionsSoundPanelLoopMusic",
	"AudioOptionsSoundPanelAmbientSounds",
	"AudioOptionsSoundPanelSoundInBG",
	"AudioOptionsSoundPanelReverb",
	"AudioOptionsSoundPanelHRTF",
	"AudioOptionsSoundPanelEnableDSPs",
	"AudioOptionsSoundPanelUseHardware",
	"AudioOptionsVoicePanelEnableVoice",
	"AudioOptionsVoicePanelEnableMicrophone",
	"AudioOptionsVoicePanelPushToTalkSound",
	"AudioOptionsVoicePanelDialogVolume",
	"AudioOptionsSoundPanelPetBattleMusic",
	"NetworkOptionsPanelOptimizeSpeed",
	"NetworkOptionsPanelUseIPv6",
	"NetworkOptionsPanelAdvancedCombatLogging"
};
local SystemFrameList18 = {
	"Display_AntiAliasingDropDown",
	"Display_DisplayModeDropDown",
	"Display_ResolutionDropDown",
	"Display_RefreshDropDown",
	"Display_PrimaryMonitorDropDown",
	"Display_MultiSampleDropDown",
	"Display_VerticalSyncDropDown",
	"Graphics_TextureResolutionDropDown",
	"Graphics_FilteringDropDown",
	"Graphics_ProjectedTexturesDropDown",
	"Graphics_ViewDistanceDropDown",
	"Graphics_EnvironmentalDetailDropDown",
	"Graphics_GroundClutterDropDown",
	"Graphics_ShadowsDropDown",
	"Graphics_LiquidDetailDropDown",
	"Graphics_SunshaftsDropDown",
	"Graphics_ParticleDensityDropDown",
	"Graphics_SSAODropDown",
	"Graphics_RefractionDropDown",
	"Advanced_BufferingDropDown",
	"Advanced_LagDropDown",
	"Advanced_HardwareCursorDropDown",
	"Advanced_GraphicsAPIDropDown",
	"AudioOptionsSoundPanelHardwareDropDown",
	"AudioOptionsSoundPanelSoundChannelsDropDown",
	"AudioOptionsVoicePanelInputDeviceDropDown",
	"AudioOptionsVoicePanelChatModeDropDown",
	"AudioOptionsVoicePanelOutputDeviceDropDown",
	"CompactUnitFrameProfilesProfileSelector",
	"CompactUnitFrameProfilesGeneralOptionsFrameHealthTextDropdown",
	"CompactUnitFrameProfilesGeneralOptionsFrameSortByDropdown",
};
local SystemFrameList19 = {
	"RecordLoopbackSoundButton",
	"PlayLoopbackSoundButton",
	"AudioOptionsVoicePanel.PushToTalkKeybindButton",
	"InterfaceOptionsSocialPanelTwitterLoginButton",
	"CompactUnitFrameProfilesSaveButton",
	"CompactUnitFrameProfilesDeleteButton",
};
local SystemFrameList20 = {
	"KeepGroupsTogether",
	"DisplayIncomingHeals",
	"DisplayPowerBar",
	"DisplayAggroHighlight",
	"UseClassColors",
	"DisplayPets",
	"DisplayMainTankAndAssist",
	"DisplayBorder",
	"ShowDebuffs",
	"DisplayOnlyDispellableDebuffs",
	"AutoActivate2Players",
	"AutoActivate3Players",
	"AutoActivate5Players",
	"AutoActivate10Players",
	"AutoActivate15Players",
	"AutoActivate25Players",
	"AutoActivate40Players",
	"AutoActivateSpec1",
	"AutoActivateSpec2",
	"AutoActivatePvP",
	"AutoActivatePvE",
};
local SystemFrameList21 = {
	"Graphics_Quality",
	"Advanced_UIScaleSlider",
	"Advanced_MaxFPSSlider",
	"Advanced_MaxFPSBKSlider",
	"AudioOptionsSoundPanelSoundQuality",
	"AudioOptionsSoundPanelMasterVolume",
	"AudioOptionsSoundPanelSoundVolume",
	"AudioOptionsSoundPanelMusicVolume",
	"AudioOptionsSoundPanelAmbienceVolume",
	"AudioOptionsVoicePanelMicrophoneVolume",
	"AudioOptionsVoicePanelSpeakerVolume",
	"AudioOptionsVoicePanelSoundFade",
	"AudioOptionsVoicePanelMusicFade",
	"AudioOptionsVoicePanelAmbienceFade",
	"InterfaceOptionsCombatPanelSpellAlertOpacitySlider",
	"InterfaceOptionsCombatPanelMaxSpellStartRecoveryOffset",
	"InterfaceOptionsBattlenetPanelToastDurationSlider",
	"InterfaceOptionsCameraPanelMaxDistanceSlider",
	"InterfaceOptionsCameraPanelFollowSpeedSlider",
	"InterfaceOptionsMousePanelMouseSensitivitySlider",
	"InterfaceOptionsMousePanelMouseLookSpeedSlider",
	"AddonListScrollFrameScrollBar",
	"OpacityFrameSlider",
};
--[[
##########################################################
HELPER FUNCTIONS
##########################################################
]]--
local _hook_GhostFrameBackdropColor = function(self, r, g, b, a)
	if r ~= 0 or g ~= 0 or b ~= 0 or a ~= 0 then
		self:SetBackdropColor(0,0,0,0)
		self:SetBackdropBorderColor(0,0,0,0)
	end
end

local _hook_AddonsList_InitButton = function(entry, addonIndex)
	if not entry.isSkinned then
		entry:SetWidth(570)
		entry.Enabled:RemoveTextures()
		SV.API:Set("CheckButton", entry.Enabled)
		entry.LoadAddonButton:RemoveTextures()
		SV.API:Set("Button", entry.LoadAddonButton)

		entry.isSkinned = true

		entry.Title:SetFontObject('SVUI_Font_Default')
		entry.Title:SetWidth(270)
		entry.Status:SetFontObject('SVUI_Font_Default')
		entry.Reload:SetFontObject('SVUI_Font_Default')
		-- entry.Reload:SetTextColor(1.0, 0.3, 0.3)
		entry.LoadAddonButton.Text:SetFontObject('SVUI_Font_Default')
	end
end

local OptionUpdate = function(frame)
	for _, child in next, { frame.ScrollTarget:GetChildren() } do
		if not child.isSkinned then
			-- if child.Background then
			-- 	child.Background:SetAlpha(0)
			-- 	child.Label:SetFontObject(SVUI_Font_Header)
			-- end

			if child.Checkbox then
				child.Checkbox:RemoveTextures()
				SV.API:Set("CheckButton", child.Checkbox)
			end

			if child.Dropdown then
				SV.API:Set("DropDown", child.Dropdown)
			end

			if child.Dropdown then
				SV.API:Set("DropDown", child.Dropdown)
				child.DecrementButton:RemoveTextures()
				SV.API:Set("Button", child.DecrementButton)
				child.IncrementButton:RemoveTextures()
				SV.API:Set("Button", child.IncrementButton)
			end

			if child.Button then
				child.Button:RemoveTextures()
				SV.API:Set("Button", child.Button)
			end

			if child.Button1 then
				child.Button1:RemoveTextures()
				SV.API:Set("Button", child.Button1)
			end
			
			if child.Button2 then
				child.Button2:RemoveTextures()
				SV.API:Set("Button", child.Button2)
			end

			if child.NineSlice then
				child.NineSlice:Hide()
			end

			if child.BaseTab then
				child.BaseTab:RemoveTextures(true)
			end

			if child.RaidTab then
				child.RaidTab:RemoveTextures(true)
			end

			if child.RaidQualityControls then
				child.RaidQualityControls.GraphicsQuality.Checkbox:RemoveTextures()
				SV.API:Set("CheckButton", child.RaidQualityControls.GraphicsQuality.Checkbox)
			end

			child.isSkinned = true
		end
	end
end

local CategoryUpdate = function(frame)
	for _, child in next, { frame.ScrollTarget:GetChildren() } do
		if not child.isSkinned then
			if child.Background then
				child.Background:SetAlpha(0)
				child.Label:SetFontObject(SVUI_Font_Header)
				-- child.Background:CreateBackdrop('Transparent')
				-- child.Background.backdrop:Point('TOPLEFT', 5, -5)
				-- child.Background.backdrop:Point('BOTTOMRIGHT', -5, 0)
			end

			local toggle = child.Toggle
			if toggle then -- ToDo Handle the toggle. DF
				toggle:GetPushedTexture():SetAlpha(0)
			end

			child.isSkinned = true
		end
	end
end

--[[
##########################################################
SYSTEM WIDGET MODRS
##########################################################
]]--
local function SystemPanelQue()
	--print('test SystemPanelQue')
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.misc ~= true then return end

	local GhostFrame = _G.GhostFrame;
	local ReadyCheckFrame = _G.ReadyCheckFrame;
	local InterfaceOptionsFrame = _G.SettingsPanel;
	local GuildInviteFrame = _G.GuildInviteFrame;
	local BattleTagInviteFrame = _G.BattleTagInviteFrame;

	-- local MacOptionsFrame = _G.MacOptionsFrame;

	QueueStatusFrame:RemoveTextures()

	for i = 1, #SystemPopList do
		local this = _G[SystemPopList[i]]
		if(this) then
			this:RemoveTextures()
			SV.API:Set("Alert", this)
		end
	end
	for i = 1, #SystemDropDownList do
		local this = _G[SystemDropDownList[i]]
		if(this) then
			this:RemoveTextures()
			this:SetStyle("Frame")
		end
	end
	for i = 1, #SystemFrameList1 do
		local this = _G[SystemFrameList1[i]]
		if(this) then
			SV.API:Set("Window", this)
		end
	end

	LFDRoleCheckPopup:RemoveTextures()
	LFDRoleCheckPopup:SetStyle("!_Frame")
	LFDRoleCheckPopupAcceptButton:SetStyle("Button")
	LFDRoleCheckPopupDeclineButton:SetStyle("Button")
	LFDRoleCheckPopupRoleButtonTank.checkButton:SetStyle("CheckButton")
	LFDRoleCheckPopupRoleButtonDPS.checkButton:SetStyle("CheckButton")
	LFDRoleCheckPopupRoleButtonHealer.checkButton:SetStyle("CheckButton")
	LFDRoleCheckPopupRoleButtonTank.checkButton:SetFrameLevel(LFDRoleCheckPopupRoleButtonTank.checkButton:GetFrameLevel() + 1)
	LFDRoleCheckPopupRoleButtonDPS.checkButton:SetFrameLevel(LFDRoleCheckPopupRoleButtonDPS.checkButton:GetFrameLevel() + 1)
	LFDRoleCheckPopupRoleButtonHealer.checkButton:SetFrameLevel(LFDRoleCheckPopupRoleButtonHealer.checkButton:GetFrameLevel() + 1)
	local popup
	for i = 1, 4 do
		popup = _G["StaticPopup"..i]
		popup.Border:Hide()
		-- _G["StaticPopup"..i.."EditBox"]:SetStyle("Editbox")
		-- _G["StaticPopup"..i.."EditBox"].Panel:SetPoint("TOPLEFT", -2, -4)
		-- _G["StaticPopup"..i.."EditBox"].Panel:SetPoint("BOTTOMRIGHT", 2, 4)
		popup.editBox:SetStyle("Editbox")
		popup.editBox.Panel:SetPoint("TOPLEFT", -2, -4)
		popup.editBox.Panel:SetPoint("BOTTOMRIGHT", 2, 4)
		-- _G["StaticPopup"..i.."MoneyInputFrameGold"]:SetStyle("Editbox")
		_G["StaticPopup"..i.."MoneyInputFrameGoldLeft"]:Die()
		_G["StaticPopup"..i.."MoneyInputFrameGoldRight"]:Die()
		_G["StaticPopup"..i.."MoneyInputFrameGoldMiddle"]:Die()
		popup.moneyInputFrame.gold:SetStyle("EditBox")
		-- _G["StaticPopup"..i.."MoneyInputFrameSilver"]:SetStyle("Editbox")
		_G["StaticPopup"..i.."MoneyInputFrameSilverLeft"]:Die()
		_G["StaticPopup"..i.."MoneyInputFrameSilverRight"]:Die()
		_G["StaticPopup"..i.."MoneyInputFrameSilverMiddle"]:Die()
		popup.moneyInputFrame.silver:SetStyle("EditBox")
		-- _G["StaticPopup"..i.."MoneyInputFrameCopper"]:SetStyle("Editbox")
		_G["StaticPopup"..i.."MoneyInputFrameCopperLeft"]:Die()
		_G["StaticPopup"..i.."MoneyInputFrameCopperRight"]:Die()
		_G["StaticPopup"..i.."MoneyInputFrameCopperMiddle"]:Die()
		popup.moneyInputFrame.copper:SetStyle("EditBox")
		_G["StaticPopup"..i.."ItemFrameNameFrame"]:Die()

		-- _G["StaticPopup"..i.."ItemFrame"]:GetNormalTexture():Die()
		popup.ItemFrame:GetNormalTexture():Die()
		-- _G["StaticPopup"..i.."ItemFrame"]:SetStyle("!_Frame", "Default")
		popup.ItemFrame:SetStyle("!_Frame", "Default")
		-- _G["StaticPopup"..i.."ItemFrame"]:SetStyle("Button")
		popup.ItemFrame:SetStyle("Button")
		-- _G["StaticPopup"..i.."ItemFrameIconTexture"]:SetTexCoord(0.1,0.9,0.1,0.9 )
		popup.ItemFrame.icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
		-- _G["StaticPopup"..i.."ItemFrameIconTexture"]:InsetPoints()
		popup.ItemFrame.icon:InsetPoints()
		SV.API:Set("CloseButton", popup.CloseButton)
		popup.CloseButton:ClearAllPoints()
		popup.CloseButton:SetPoint("TOPRIGHT", popup, "TOPRIGHT", 30, 0)
		for j = 1, 4 do
			_G["StaticPopup"..i.."Button"..j]:SetStyle("Button")
		end
	end
	local CAPS_TEXT_FONT = LibStub("LibSharedMedia-3.0"):Fetch("font", SV.media.font.caps.file);
  	local caps_fontsize = SV.media.font.caps.size;
	for i = 1, #SystemFrameList4 do
		local this = _G["GameMenuButton"..SystemFrameList4[i]]
		if(this) then
			this:SetStyle("Button")
		end
	end

	do
		GhostFrame:SetStyle("Button")
		GhostFrame:SetBackdropColor(0,0,0,0)
		GhostFrame:SetBackdropBorderColor(0,0,0,0)
		hooksecurefunc(GhostFrame, "SetBackdropColor", _hook_GhostFrameBackdropColor)
		hooksecurefunc(GhostFrame, "SetBackdropBorderColor", _hook_GhostFrameBackdropColor)
		GhostFrame:ClearAllPoints()
		GhostFrame:SetPoint("CENTER", SVUI_SpecialAbility, "CENTER", 0, 0)
		GhostFrameContentsFrame:SetStyle("Button")
		GhostFrameContentsFrameIcon:SetTexture("")
		local x = CreateFrame("Frame", nil, GhostFrame)
		x:SetFrameStrata("MEDIUM")
		x:SetStyle("!_Frame", "Default")
		x:WrapPoints(GhostFrameContentsFrameIcon)
		local tex = x:CreateTexture(nil, "OVERLAY")
		tex:SetTexture("Interface\\Icons\\spell_holy_guardianspirit")
		tex:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
		tex:InsetPoints()
	end

	if(AddonList) then
		AddonList:SetSize(550, 550)
		AddonList.ScrollBox:SetSize(516, 458)
		--AddonList:RemoveTextures(true)
		SV.API:Set("Window", AddonList, true, true)
		AddonList.EnableAllButton:RemoveTextures(true)
		SV.API:Set("Button", AddonList.EnableAllButton)
		AddonList.DisableAllButton:RemoveTextures(true)
		SV.API:Set("Button", AddonList.DisableAllButton)
		-- SV.API:Set("Button", AddonListDisableAllButton)
		AddonList.CancelButton:RemoveTextures(true)
		SV.API:Set("Button", AddonList.CancelButton)
		AddonList.OkayButton:RemoveTextures(true)
		SV.API:Set("Button", AddonList.OkayButton)
		AddonListForceLoad:RemoveTextures()
		SV.API:Set("CheckButton", AddonListForceLoad)
		-- AddonList.Dropdown:RemoveTextures()
		-- SV.API:Set("DropDown", AddonList.Dropdown)
		AddonList.Inset:Hide()
		SV.API:Set("ScrollBar", AddonList)

		hooksecurefunc('AddonList_InitButton', _hook_AddonsList_InitButton)

	end

	GameMenuFrame.Header:RemoveTextures()
	GameMenuFrame.Header.Text:SetFontObject(SVUI_Font_Header)
	GameMenuFrame.Header:ClearAllPoints()
	GameMenuFrame.Header:SetPoint("TOP", GameMenuFrame, 0, 7)

	GameMenuFrame.Border:RemoveTextures()

	--for i = 1, #SystemFrameList5 do
	--	local this = _G[SystemFrameList5[i].."Header"]
	--	if(this) then
	--		this:SetTexture("")
	--		this:ClearAllPoints()
	--		if this == _G["GameMenuFrameHeader"] then
	--			this:SetPoint("TOP", GameMenuFrame, 0, 7)
	--		else
	--			this:SetPoint("TOP", SystemFrameList5[i], 0, 0)
	--		end
	--	end
	--end
	for i = 1, #SystemFrameList6 do
		local this = _G[SystemFrameList6[i]]
		if(this) then
			this:SetStyle("Button")
		end
	end

	SettingsPanel.Container.SettingsList.Header.DefaultsButton:SetStyle("Button")
	SettingsPanel.CloseButton:SetStyle("Button")
	SettingsPanel.ApplyButton:SetStyle("Button")
	-- SettingsPanel.SearchBox:SetStyle("Editbox")
	SettingsPanel.Bg:Hide()
	SV.API:Set("ScrollBar", SettingsPanel.CategoryList)
	SV.API:Set("CloseButton", SettingsPanel.ClosePanelButton)
	SV.API:Set("EditBox", SettingsPanel.SearchBox)
	SettingsPanel.GameTab:RemoveTextures(true)
	SettingsPanel.AddOnsTab:RemoveTextures(true)

	CategoryUpdate(SettingsPanel.CategoryList.ScrollBox)
	SettingsPanel.CategoryList.BG:ClearAllPoints()
	SettingsPanel.CategoryList.BG:SetPoint("TOPLEFT", SettingsPanel.CategoryList.ScrollBar.Back, "TOPRIGHT", -4, -10 )
	SettingsPanel.CategoryList.BG:SetPoint("BOTTOMRIGHT", SettingsPanel.CategoryList.ScrollBar.Forward, "BOTTOMRIGHT", -1, 10 )
	hooksecurefunc(SettingsPanel.CategoryList.ScrollBox, "Update", CategoryUpdate)
	hooksecurefunc(SettingsPanel.Container.SettingsList.ScrollBox, "Update", OptionUpdate)

	-- VideoOptionsFrameCancel:ClearAllPoints()
	-- VideoOptionsFrameCancel:SetPoint("RIGHT",VideoOptionsFrameApply,"LEFT",-4,0)
	-- VideoOptionsFrameOkay:ClearAllPoints()
	-- VideoOptionsFrameOkay:SetPoint("RIGHT",VideoOptionsFrameCancel,"LEFT",-4,0)
	-- AudioOptionsFrameOkay:ClearAllPoints()
	-- AudioOptionsFrameOkay:SetPoint("RIGHT",AudioOptionsFrameCancel,"LEFT",-4,0)
	-- InterfaceOptionsFrameOkay:ClearAllPoints()
	-- InterfaceOptionsFrameOkay:SetPoint("RIGHT",InterfaceOptionsFrameCancel,"LEFT", -4,0)

	ReadyCheckFrameYesButton:SetParent(ReadyCheckFrame)
	ReadyCheckFrameNoButton:SetParent(ReadyCheckFrame)
	ReadyCheckFrameYesButton:SetPoint("RIGHT", ReadyCheckFrame, "CENTER", -1, 0)
	ReadyCheckFrameNoButton:SetPoint("LEFT", ReadyCheckFrameYesButton, "RIGHT", 3, 0)
	ReadyCheckFrameText:SetParent(ReadyCheckFrame)
	ReadyCheckFrameText:ClearAllPoints()
	ReadyCheckFrameText:SetPoint("TOP", 0, -12)
	ReadyCheckListenerFrame:SetAlpha(0)
	ReadyCheckFrame:HookScript("OnShow", function(self) if self.initiator and UnitIsUnit("player", self.initiator) then self:Hide() end end)
	StackSplitFrame:GetRegions():Hide()
	RolePollPopup:SetStyle("!_Frame", "Transparent", true)
	InterfaceOptionsFrame:SetClampedToScreen(true)
	InterfaceOptionsFrame:SetMovable(true)
	InterfaceOptionsFrame:EnableMouse(true)
	InterfaceOptionsFrame:RegisterForDrag("LeftButton", "RightButton")
	InterfaceOptionsFrame:SetScript("OnDragStart", function(self)
		if InCombatLockdown() then return end
		if IsShiftKeyDown() then
			self:StartMoving()
		end
	end)
	InterfaceOptionsFrame:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
	end)
	if IsMacClient() then
		MacOptionsFrame:SetStyle("!_Frame", "Default")
		MacOptionsFrameHeader:SetTexture("")
		MacOptionsFrameHeader:ClearAllPoints()
		MacOptionsFrameHeader:SetPoint("TOP", MacOptionsFrame, 0, 0)
		MacOptionsFrameMovieRecording:SetStyle("!_Frame", "Default")
		MacOptionsITunesRemote:SetStyle("!_Frame", "Default")
		MacOptionsFrameCancel:SetStyle("Button")
		MacOptionsFrameOkay:SetStyle("Button")
		MacOptionsButtonKeybindings:SetStyle("Button")
		MacOptionsFrameDefaults:SetStyle("Button")
		MacOptionsButtonCompress:SetStyle("Button")
		local tPoint, tRTo, tRP, tX, tY = MacOptionsButtonCompress:GetPoint()
		MacOptionsButtonCompress:SetWidth(136)
		MacOptionsButtonCompress:ClearAllPoints()
		MacOptionsButtonCompress:SetPoint(tPoint, tRTo, tRP, 4, tY)
		MacOptionsFrameCancel:SetWidth(96)
		MacOptionsFrameCancel:SetHeight(22)
		tPoint, tRTo, tRP, tX, tY = MacOptionsFrameCancel:GetPoint()
		MacOptionsFrameCancel:ClearAllPoints()
		MacOptionsFrameCancel:SetPoint(tPoint, tRTo, tRP, -14, tY)
		MacOptionsFrameOkay:ClearAllPoints()
		MacOptionsFrameOkay:SetWidth(96)
		MacOptionsFrameOkay:SetHeight(22)
		MacOptionsFrameOkay:SetPoint("LEFT",MacOptionsFrameCancel, -99,0)
		MacOptionsButtonKeybindings:ClearAllPoints()
		MacOptionsButtonKeybindings:SetWidth(96)
		MacOptionsButtonKeybindings:SetHeight(22)
		MacOptionsButtonKeybindings:SetPoint("LEFT",MacOptionsFrameOkay, -99,0)
		MacOptionsFrameDefaults:SetWidth(96)
		MacOptionsFrameDefaults:SetHeight(22)
	end
	OpacityFrame:RemoveTextures()
	OpacityFrame:SetStyle("!_Frame", "Transparent", true)

	hooksecurefunc("UIDropDownMenu_InitializeHelper", function(self)
		for i = 1, UIDROPDOWNMENU_MAXLEVELS do
			local name = ("DropDownList%d"):format(i)
			local bg = _G[("%sBackdrop"):format(name)]
			bg:SetStyle("Frame", 'Transparent')
			local menu = _G[("%sMenuBackdrop"):format(name)]
			menu:SetStyle("Frame", 'Transparent')
		end
	end)

	for i=1, BattleTagInviteFrame:GetNumChildren() do
		local child = select(i, BattleTagInviteFrame:GetChildren())
		if child:GetObjectType() == 'Button' then
			child:SetStyle("Button")
		end
	end

	for i = 1, #SystemFrameList13 do
		local frame = _G[SystemFrameList13[i]]
		if(frame) then
			frame:RemoveTextures()
			frame:SetStyle("Frame", 'Transparent')
		end
	end

	for i = 1, #SystemFrameList14 do
		local this = _G[SystemFrameList14[i]]
		if(this) then
			this:RemoveTextures()
			SV.API:Set("Tab", this)
		end
	end

	-- InterfaceOptionsFrameTab1:ClearAllPoints()
	-- InterfaceOptionsFrameTab1:SetPoint("BOTTOMLEFT",InterfaceOptionsFrameCategories,"TOPLEFT",-11,-2)
	-- VideoOptionsFrameDefaults:ClearAllPoints()
	-- InterfaceOptionsFrameDefaults:ClearAllPoints()
	-- InterfaceOptionsFrameCancel:ClearAllPoints()
	-- VideoOptionsFrameDefaults:SetPoint("TOPLEFT",VideoOptionsFrameCategoryFrame,"BOTTOMLEFT",-1,-5)
	-- InterfaceOptionsFrameDefaults:SetPoint("TOPLEFT",InterfaceOptionsFrameCategories,"BOTTOMLEFT",-1,-5)
	-- InterfaceOptionsFrameCancel:SetPoint("TOPRIGHT",InterfaceOptionsFramePanelContainer,"BOTTOMRIGHT",0,-6)

	-- for i = 1, #SystemFrameList15 do
	-- 	local this = _G["InterfaceOptions"..SystemFrameList15[i]]
	-- 	if(this) then
	-- 		this:SetStyle("CheckButton")
	-- 	end
	-- end

	-- for i = 1, #SystemFrameList16 do
	-- 	local this = _G["InterfaceOptions"..SystemFrameList16[i]]
	-- 	if(this) then
	-- 		SV.API:Set("DropDown", this)
	-- 	end
	-- end

	-- for i = 1, #SystemFrameList17 do
	-- 	local this = _G[SystemFrameList17[i]]
	-- 	if(this) then
	-- 		this:SetStyle("CheckButton")
	-- 	end
	-- end

	-- for i = 1, #SystemFrameList18 do
	-- 	local this = _G[SystemFrameList18[i]]
	-- 	if(this) then
	-- 		SV.API:Set("DropDown", this, 165)
	-- 	end
	-- end

	-- for i = 1, #SystemFrameList19 do
	-- 	local this = _G[SystemFrameList19[i]]
	-- 	if(this) then
	-- 		this:SetStyle("Button")
	-- 	end
	-- end

    --AudioOptionsVoicePanel.PushToTalkKeybindButton:ClearAllPoints()
	--AudioOptionsVoicePanel.PushToTalkKeybindButton:SetPoint("CENTER", AudioOptionsVoicePanelBinding, "CENTER", 0, -10)
	-- if(CompactUnitFrameProfilesRaidStylePartyFrames) then CompactUnitFrameProfilesRaidStylePartyFrames:SetStyle("CheckButton") end
	-- if(CompactUnitFrameProfilesGeneralOptionsFrameResetPositionButton) then CompactUnitFrameProfilesGeneralOptionsFrameResetPositionButton:SetStyle("Button") end

	for i = 1, #SystemFrameList20 do
		local this = _G["CompactUnitFrameProfilesGeneralOptionsFrame"..SystemFrameList20[i]]
		if(this) then
			this:SetStyle("CheckButton")
			this:SetFrameLevel(40)
		end
	end

	for i = 1, #SystemFrameList21 do
		local this = _G[SystemFrameList21[i]]
		if(this) then
			SV.API:Set("ScrollBar", this)
		end
	end
	
	--print('test SystemPanelQue 2')
	if(MacOptionsFrame) then
		MacOptionsFrame:RemoveTextures()
		MacOptionsFrame:SetStyle("!_Frame")
		MacOptionsButtonCompress:SetStyle("Button")
		MacOptionsButtonKeybindings:SetStyle("Button")
		MacOptionsFrameDefaults:SetStyle("Button")
		MacOptionsFrameOkay:SetStyle("Button")
		MacOptionsFrameCancel:SetStyle("Button")
		MacOptionsFrameMovieRecording:RemoveTextures()
		MacOptionsITunesRemote:RemoveTextures()
		MacOptionsFrameMisc:RemoveTextures()
		--print('test SystemPanelQue m1')
		SV.API:Set("DropDown", MacOptionsFrameResolutionDropDown)
		SV.API:Set("DropDown", MacOptionsFrameFramerateDropDown)
		SV.API:Set("DropDown", MacOptionsFrameCodecDropDown)
		SV.API:Set("ScrollBar", MacOptionsFrameQualitySlider)
		for i = 1, 11 do
			local this = _G["MacOptionsFrameCheckButton"..i]
			if(this) then
				this:SetStyle("CheckButton")
			end
		end
		--print('test SystemPanelQue m2')
		MacOptionsButtonKeybindings:ClearAllPoints()
		MacOptionsButtonKeybindings:SetPoint("LEFT", MacOptionsFrameDefaults, "RIGHT", 2, 0)
		MacOptionsFrameOkay:ClearAllPoints()
		MacOptionsFrameOkay:SetPoint("LEFT", MacOptionsButtonKeybindings, "RIGHT", 2, 0)
		MacOptionsFrameCancel:ClearAllPoints()
		MacOptionsFrameCancel:SetPoint("LEFT", MacOptionsFrameOkay, "RIGHT", 2, 0)
		MacOptionsFrameCancel:SetWidth(MacOptionsFrameCancel:GetWidth() - 6)
	end

	--print('test SystemPanelQue 3')
	ReportCheatingDialog:RemoveTextures()
	ReportCheatingDialogCommentFrame:RemoveTextures()
	ReportCheatingDialogReportButton:SetStyle("Button")
	ReportCheatingDialogCancelButton:SetStyle("Button")
	ReportCheatingDialog:SetStyle("!_Frame", "Transparent", true)
	ReportCheatingDialogCommentFrameEditBox:SetStyle("Editbox")
	--Removed for 7.3
	--ReportPlayerNameDialog:RemoveTextures()
	--ReportPlayerNameDialogCommentFrame:RemoveTextures()
	--ReportPlayerNameDialogCommentFrameEditBox:SetStyle("Editbox")
	--ReportPlayerNameDialog:SetStyle("!_Frame", "Transparent", true)
	--ReportPlayerNameDialogReportButton:SetStyle("Button")
	--ReportPlayerNameDialogCancelButton:SetStyle("Button")

	--print('test SystemPanelQue 4')
end
--[[
##########################################################
MOD LOADING
##########################################################
]]--
MOD:SaveCustomStyle("SYSTEM", SystemPanelQue)

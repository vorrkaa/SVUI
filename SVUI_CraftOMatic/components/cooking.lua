--[[
##########################################################
S V U I   By: S.Jackson
##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack 	= _G.unpack;
local select 	= _G.select;
local type 		= _G.type;
local string    = _G.string;
local math 		= _G.math;
local table 	= _G.table;
local rept      = string.rep;
local tsort,twipe = table.sort,table.wipe;
local floor,ceil  = math.floor, math.ceil;
local band 		= _G.bit.band;
--BLIZZARD API
local CreateFrame           = _G.CreateFrame;
local InCombatLockdown      = _G.InCombatLockdown;
local GameTooltip           = _G.GameTooltip;
local hooksecurefunc        = _G.hooksecurefunc;
local IsSpellKnown      	= _G.IsSpellKnown;
local GetSpellInfo      	= C_Spell.GetSpellInfo;
local GetProfessions      	= _G.GetProfessions;
local GetProfessionInfo     = _G.GetProfessionInfo;
local PlaySound             = _G.PlaySound;
local PlaySoundFile         = _G.PlaySoundFile;
local C_PetJournal          = _G.C_PetJournal;
local GetItemInfo           = C_Item.GetItemInfo;
local GetItemCount          = C_Item.GetItemCount;
local GetItemQualityColor   = C_Item.GetItemQualityColor;
local GetItemFamily         = C_Item.GetItemFamily;
local EquipItemByName		= C_Item.EquipItemByName
local GetInventoryItemID	= GetInventoryItemID
local GetSpellCooldown		= C_Spell.GetSpellCooldown
--[[
##########################################################
GET ADDON DATA
##########################################################
]]--
local SV = _G.SVUI;
local L = SV.L;
local PLUGIN = select(2, ...);
local CONFIGS = SV.defaults[PLUGIN.Schema];
--[[
##########################################################
LOCAL VARS
##########################################################
]]--
local cookingSpell, campFire, skillRank, skillModifier, usePierre;
local NUM_FAVORITE_BARS = 5
local favoriteButtons,cookingToolButtons,portalButtons = {},{},{};

--Hack Hashtable to use id as a Key
--https://warcraft.wiki.gg/wiki/TradeSkillLineID
local CookingSkillLineID = {
	[185] = true,
	[2548] = true,
	[2547] = true,
	[2546] = true,
	[2545] = true,
	[2544] = true,
	[2543] = true,
	[2542] = true,
	[2541] = true,
	[2752] = true,
	[2824] = true,
}

local refFavorites = {}
local refTools = {
	[818] = true,
}
--[[
##########################################################
LOCAL FUNCTIONS
##########################################################
]]--
local Scroll_OnValueChanged = function(self,argValue)
	self:GetParent():SetVerticalScroll(argValue)
end

local Scroll_OnMouseWheel = function(self, delta)
	local scroll = self:GetVerticalScroll();
	local value = (scroll - (20 * delta));
	if value < -1 then
		value = 0
	end
	if value > 420 then
		value = 420
	end
	self:SetVerticalScroll(value)
	self.slider:SetValue(value)
end

local function UpdateChefWear()
	if(GetItemCount(46349) > 0) then
		PLUGIN.WornItems["HEAD"] = GetInventoryItemID("player", INVSLOT_HEAD);
		EquipItemByName(46349)
		PLUGIN.InModeGear = true
	end
	if(GetItemCount(86468) > 0) then
		PLUGIN.WornItems["TAB"] = GetInventoryItemID("player", INVSLOT_TABARD);
		EquipItemByName(86468)
		PLUGIN.InModeGear = true
	end
	if(GetItemCount(86559) > 0) then
		PLUGIN.WornItems["MAIN"] = GetInventoryItemID("player", INVSLOT_MAINHAND);
		EquipItemByName(86559)
		PLUGIN.InModeGear = true
	end
	if(GetItemCount(86558) > 0) then
		PLUGIN.WornItems["OFF"] = GetInventoryItemID("player", INVSLOT_OFFHAND);
		EquipItemByName(86558)
		PLUGIN.InModeGear = true
	end
end

local function GetTitleAndSkill()
	local msg = "|cff22ff11Cooking Mode|r"
	if(skillRank) then
		if(skillModifier) then
			skillRank = skillRank + skillModifier;
		end
		msg = msg .. " (|cff00ddff" .. skillRank .. "|r)";
	end
	return msg
end

local function FindPierre()
	local summonedPetGUID = C_PetJournal.GetSummonedPetGUID()
	if usePierre then
		if((not summonedPetGUID) or (summonedPetGUID and (summonedPetGUID ~= usePierre))) then
			C_PetJournal.SummonPetByGUID(usePierre)
		end
	else
		local numPets, numOwned = C_PetJournal.GetNumPets()
		for index = 1, numOwned, 1 do
			local petID, _, _, _, _, _, _, _, _, _, companionID = C_PetJournal.GetPetInfoByIndex(index)
			if(companionID == 70082) then
				usePierre = petID
				if((not summonedPetGUID) or (summonedPetGUID and (summonedPetGUID ~= usePierre))) then
					C_PetJournal.SummonPetByGUID(usePierre)
				end
				break
			end
		end
	end
end

local function GetCookingRecipe()
	ProfessionsFrame_LoadUI()

	local tradeSkillID, parentTradeSkillID

	for _, id in pairs(C_TradeSkillUI.GetAllRecipeIDs()) do
		local recipeInfo = C_TradeSkillUI.GetRecipeInfo(id)
		
		if recipeInfo.learned and recipeInfo.favorite then
			tradeSkillID, _, parentTradeSkillID = C_TradeSkillUI.GetTradeSkillLineForRecipe(recipeInfo.recipeID)

			if CookingSkillLineID[tradeSkillID] or CookingSkillLineID[parentTradeSkillID] then
				DevTool:AddData(recipeInfo, id)
				refFavorites[id] = recipeInfo
			end
		end
	end
end
--[[
##########################################################
CORE NAMESPACE
##########################################################
]]--
PLUGIN.Cooking = {};
PLUGIN.Cooking.Log = {};
PLUGIN.Cooking.Loaded = false;
--[[
##########################################################
EVENT HANDLER
##########################################################
]]--
-- local EnableListener, DisableListener
-- do
-- 	local proxyTest = false;
-- 	local CookEventHandler = CreateFrame("Frame")
-- 	local LootProxy = function(item, name)
-- 		if(item) then
-- 			local mask = [[0x10000]];
-- 			local itemType = GetItemFamily(item);
-- 			local pass = band(itemType, mask);
-- 			if pass > 0 then
-- 				proxyTest = true;
-- 			end
-- 		end
-- 	end

-- 	local Cook_OnEvent = function(self, event, ...)
-- 		print ("Cook_OnEvent", event, ...)
-- 		if(InCombatLockdown()) then return end
-- 		if(event == "BAG_UPDATE" or event == "CHAT_MSG_SKILL") then
-- 			local msg = GetTitleAndSkill()
-- 			PLUGIN.TitleWindow:Clear()
-- 			PLUGIN.TitleWindow:AddMessage(msg)
-- 		elseif(event == "CHAT_MSG_LOOT") then
-- 			local item, amt = PLUGIN:CheckForModeLoot(...);
-- 			if item then
-- 				local name, lnk, rarity, lvl, mlvl, itype, stype, cnt, ieq, tex, price = GetItemInfo(item);
-- 				if proxyTest == false then
-- 					LootProxy(lnk, name)
-- 				end
-- 				if proxyTest == false then return end
-- 				if not PLUGIN.Cooking.Log[name] then
-- 					PLUGIN.Cooking.Log[name] = {amount = 0, texture = ""};
-- 				end
-- 				local r, g, b, hex = GetItemQualityColor(rarity);
-- 				local stored = PLUGIN.Cooking.Log
-- 				local mod = stored[name];
-- 				local newAmt = mod.amount + 1;
-- 				if amt >= 2 then newAmt = mod.amount + amt end
-- 				PLUGIN.Cooking.Log[name].amount = newAmt;
-- 				PLUGIN.Cooking.Log[name].texture = tex;
-- 				PLUGIN.LogWindow:Clear();
-- 				for name,data in pairs(stored) do
-- 					if type(data) == "table" and data.amount and data.texture then
-- 						PLUGIN.LogWindow:AddMessage("|cff55FF55"..data.amount.." x|r |T".. data.texture ..":16:16:0:0:64:64:4:60:4:60|t".." "..name, r, g, b);
-- 					end
-- 				end
-- 				PLUGIN.LogWindow:AddMessage("----------------", 0, 0, 0);
-- 				PLUGIN.LogWindow:AddMessage("Cooked So Far...", 0, 1, 1);
-- 				PLUGIN.LogWindow:AddMessage(" ", 0, 0, 0);
-- 				proxyTest = false;
-- 			end
-- 		end
-- 	end

-- 	function EnableListener()
-- 		CookEventHandler:RegisterEvent("ZONE_CHANGED")
-- 		CookEventHandler:RegisterEvent("BAG_UPDATE")
-- 		CookEventHandler:RegisterEvent("CHAT_MSG_SKILL")
-- 		CookEventHandler:SetScript("OnEvent", Cook_OnEvent)
-- 	end

-- 	function DisableListener()
-- 		CookEventHandler:UnregisterAllEvents()
-- 		CookEventHandler:SetScript("OnEvent", nil)
-- 	end
-- end

do
	local CookingEventHandler = CreateFrame("Frame")

	local ButtonUpdate = function(button)
		button.items = GetItemCount(button.itemId)
		if button.text then
			button.text:SetText(button.items)
		end
		button.icon:SetDesaturated(button.items == 0)
		button.icon:SetAlpha(button.items == 0 and .25 or 1)
	end

	local InFarmZone = function()
		local zone = GetSubZoneText()
		if (zone == L["Sunsong Ranch"] or zone == L["The Halfhill Market"]) then
			if PLUGIN.Cooking.ToolsLoaded and PLUGIN.ModeAlert:IsShown() then
				PLUGIN.TitleWindow:Clear()
	 			PLUGIN.TitleWindow:AddMessage("|cff22ff11Farming Mode|r")
			end
			return true
		else
			if PLUGIN.Cooking.ToolsLoaded and PLUGIN.ModeAlert:IsShown() then
				PLUGIN.TitleWindow:Clear()
	 			PLUGIN.TitleWindow:AddMessage("|cffff2211Must be in Sunsong Ranch|r")
			end
			return false
		end
	end

	local UpdateFarmtoolCooldown = function()
		for i = 1, NUM_FAVORITE_BARS do
			for _, button in ipairs(favoriteButtons[i]) do
				if button.cooldown then
					button.cooldown:SetCooldown(GetItemCooldown(button.itemId))
				end
			end
		end
		for _, button in ipairs(cookingToolButtons) do
			if button.cooldown then
				button.cooldown:SetCooldown(GetItemCooldown(button.itemId))
			end
		end
		for _, button in ipairs(portalButtons) do
			if button.cooldown then
				button.cooldown:SetCooldown(GetItemCooldown(button.itemId))
			end
		end
	end

	local Farm_OnEvent = function(self, event, ...)
		if(InCombatLockdown()) then return end
		if(event == "ZONE_CHANGED") then
			-- local inZone = InFarmZone()
			-- if((not inZone) and CONFIGS.farming.droptools) then
			-- 	for k, v in pairs(refTools) do
			-- 		local container, slot = FindItemInBags(k)
			-- 		if container and slot then
			-- 			PickupContainerItem(container, slot)
			-- 			DeleteCursorItem()
			-- 		end
			-- 	end
			-- end
			InventoryUpdate()
		elseif(event == "BAG_UPDATE") then
			InventoryUpdate()
		elseif(event == "BAG_UPDATE_COOLDOWN") then
			UpdateFarmtoolCooldown()
		end
	end

	InventoryUpdate = function()
		if InCombatLockdown() then
			CookingEventHandler:RegisterEvent("PLAYER_REGEN_ENABLED", InventoryUpdate)
			return
		else
			CookingEventHandler:UnregisterEvent("PLAYER_REGEN_ENABLED")
	 	end
		for i = 1, NUM_FAVORITE_BARS do
			for _, button in ipairs(favoriteButtons[i]) do
				ButtonUpdate(button)
			end
		end
		for _, button in ipairs(cookingToolButtons) do
			ButtonUpdate(button)
		end
		-- for _, button in ipairs(portalButtons) do
		-- 	ButtonUpdate(button)
		-- end

		PLUGIN:RefreshCookingTools()
	end

	EnableListener = function()
		CookingEventHandler:RegisterEvent("ZONE_CHANGED")
		CookingEventHandler:RegisterEvent("BAG_UPDATE")
		CookingEventHandler:RegisterEvent("BAG_UPDATE_COOLDOWN")
		CookingEventHandler:SetScript("OnEvent", Farm_OnEvent)
	end

	DisableListener = function()
		CookingEventHandler:UnregisterAllEvents()
		CookingEventHandler:SetScript("OnEvent", nil)
	end
end
--[[
##########################################################
LOADING HANDLER
##########################################################
]]--
do
	local favoriteSort = function (a, b)
		return a.sortname < b.sortname
	end

	local Button_OnEnter = function(self)
		GameTooltip:SetOwner(self, 'ANCHOR_TOPLEFT', 2, 4)
		GameTooltip:ClearLines()
		GameTooltip:AddDoubleLine(self.sortname)
		if self.allowDrop then
			GameTooltip:AddLine(L['Right-click to drop the item.'])
		end
		GameTooltip:Show()
	end

	local Button_OnLeave = function()
		GameTooltip:Hide()
	end

	local Button_OnMouseDown = function(self, mousebutton)
		if InCombatLockdown() then return end
		if mousebutton == "LeftButton" then
			self:SetAttribute("type", self.buttonType)
			self:SetAttribute(self.buttonType, self.sortname)
			-- if(SeedToSoil(refSeeds, self.itemId)) then
			-- 	local container, slot = FindItemInBags(self.itemId)
			-- 	if container and slot then
			-- 		self:SetAttribute("type", "macro")
			-- 		self:SetAttribute("macrotext", format("/targetexact %s \n/use %s %s", L["Tilled Soil"], container, slot))
			-- 	end
			-- end
			-- if self.cooldown then
			-- 	self.cooldown:SetCooldown(GetItemCooldown(self.itemId))
			-- end
		elseif mousebutton == "RightButton" and self.allowDrop then
			-- self:SetAttribute("type", "click")
			-- local container, slot = FindItemInBags(self.itemId)
			-- if container and slot then
			-- 	PickupContainerItem(container, slot)
			-- 	DeleteCursorItem()
			-- end
		end
	end

	local function CreateCookingButton(index, owner, buttonName, buttonType, name, texture, allowDrop, showCount)
		local BUTTONSIZE = owner.ButtonSize;
		local button = CreateFrame("Button", ("CookingButton"..buttonName.."%d"):format(index), owner, "SecureActionButtonTemplate")
		button:SetStyle("!_Frame", "Transparent")
		button.Panel:SetFrameLevel(0)
		button:SetNormalTexture("")
		button:SetSize(BUTTONSIZE, BUTTONSIZE)
		button.sortname = name
		button.itemId = index
		button.allowDrop = allowDrop
		button.buttonType = buttonType
		button.items = GetItemCount(index)
		button.icon = button:CreateTexture(nil, "OVERLAY", nil, 2)
		button.icon:SetTexture(texture)
		button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		button.icon:InsetPoints(button,2,2)
		if showCount then
			button.text = button:CreateFontString(nil, "OVERLAY")
			button.text:SetFontObject(SVUI_Font_CraftNumber)
			button.text:SetPoint("BOTTOMRIGHT", button, 1, 2)
		end
		button.cooldown = CreateFrame("Cooldown", ("CookingButton"..buttonName.."%dCooldown"):format(index), button)
		button.cooldown:SetAllPoints(button)
		button:SetScript("OnEnter", Button_OnEnter)
		button:SetScript("OnLeave", Button_OnLeave)
		button:SetScript("OnMouseDown", Button_OnMouseDown)
		return button
	end

	function LoadCookingModeTools()
		local itemError = false
		-- for k, v in pairs(refFavorites) do
		-- 	if select(2, GetItemInfo(k)) == nil then print(GetItemInfo(k)) itemError = true end
		-- end
		-- for k, v in pairs(refTools) do
		-- 	if select(2, GetItemInfo(k)) == nil then print(GetItemInfo(k)) itemError = true end
		-- end
		-- for k, v in pairs(refPortals) do
		-- 	if select(2, GetItemInfo(k)) == nil then print(GetItemInfo(k)) itemError = true end
		-- end
		if InCombatLockdown() or itemError then
			if PLUGIN.CookingLoadTimer then
				PLUGIN.CookingLoadTimer = nil
				PLUGIN.Cooking:Disable()
				PLUGIN.TitleWindow:AddMessage("|cffffff11The Loader is Being Dumb...|r|cffff1111PLEASE TRY AGAIN|r")
				return
			end
			PLUGIN.TitleWindow:AddMessage("|cffffff11Loading Cooking Tools...|r|cffff1111PLEASE WAIT|r")
			PLUGIN.CookingLoadTimer = SV.Timers:ExecuteTimer(LoadCookingModeTools, 5)
		else
			local horizontal = CONFIGS.farming.toolbardirection == 'HORIZONTAL'

			local favorites, cookingTools, portals = {},{},{}

			-- for k, v in pairs(refFavorites) do
			-- 	favorites[k] = { v[1], GetItemInfo(k) }
			-- end

			-- for k, v in pairs(refTools) do
			-- 	cookingTools[k] = { v[1], GetItemInfo(k) }
			-- end

			-- for k, v in pairs(refPortals) do
			-- 	portals[k] = { v[1], GetItemInfo(k) }
			-- end

			local slot = 1
			local row = 1
			local maxSlotPerRow = 10
			for k, v in pairs(refFavorites) do
				if row <= NUM_FAVORITE_BARS then
					local favoriteBar = _G["CookingFavoriteBar"..row]
					favoriteButtons[row] = favoriteButtons[row] or {}

					favoriteButtons[row][slot] = CreateCookingButton(k, favoriteBar, "FavoriteBar"..row.."Favorite", "item", v.name, v.icon, false, false);
					if slot < maxSlotPerRow then
						slot = slot + 1
					else
						tsort(favoriteButtons[row], favoriteSort)
						row = row + 1
						slot = 1
					end
				end
			end


			-- for i = 1, NUM_FAVORITE_BARS do
			-- 	local favoriteBar = _G["CookingFavoriteBar"..i]
			-- 	favoriteButtons[i] = favoriteButtons[i] or {}
			-- 	local sbc = 1;
			-- 	for k, v in pairs(refFavorites) do
			-- 		DevTool:AddData(v, k)
			-- 	-- for k, v in pairs(favorites) do
			-- 		-- if v[1] == i then
			-- 									--CreateCookingButton(index, owner, buttonName, buttonType, 				name, texture, allowDrop, showCount)
			-- 			favoriteButtons[i][sbc] = CreateCookingButton(k, favoriteBar, "FavoriteBar"..i.."Favorite", "item", v.icon, v.name, false, false);
			-- 			sbc = sbc + 1;
			-- 		-- end
			-- 		tsort(favoriteButtons[i], favoriteSort)
			-- 	end
			-- end

			local ftc = 1;
			for k, v in pairs(cookingTools) do
				cookingToolButtons[ftc] = CreateCookingButton(k, _G["FarmToolBar"], "Tools", "item", v[2], v[11], true, false);
				ftc = ftc + 1;
			end

			-- local playerFaction = UnitFactionGroup('player')
			-- local pbc = 1;
			-- for k, v in pairs(portals) do
			-- 	if v[1] == playerFaction then
			-- 		portalButtons[pbc] = CreateCookingButton(k, _G["FarmPortalBar"], "Portals", "item", v[2], v[11], false, true);
			-- 		pbc = pbc + 1;
			-- 	end
			-- end

			PLUGIN.Cooking.Loaded = true
			PLUGIN.CookingLoadTimer = nil
			PLUGIN.CookingEnableTimer = SV.Timers:ExecuteTimer(PLUGIN.Cooking.Enable, 1.5)
		end
	end
end
--[[
##########################################################
CORE METHODS
##########################################################
]]--
PLUGIN.Cooking = {};
PLUGIN.Cooking.Loaded = false;
PLUGIN.Cooking.ToolsLoaded = false;

function PLUGIN.Cooking:Enable()
	if InCombatLockdown() then return end

 	PLUGIN:ModeLootLoader("Cooking", "Cooking Mode", "This mode will provide you \nwith fast-access buttons for each \nof your favorite recipes and cooking tools.");

 	PLUGIN.TitleWindow:Clear()
	if(not PLUGIN.Cooking.Loaded) then
		PLUGIN.TitleWindow:AddMessage("|cffffff11Loading Cooking Tools...|r")
		LoadCookingModeTools()
		return
	else
		if not PLUGIN.Cooking.ToolsLoaded then
			PlaySoundFile("Sound\\Effects\\DeathImpacts\\mDeathImpactColossalDirtA.wav")
			PLUGIN.TitleWindow:AddMessage("|cff22ff11Cooking Mode|r")
			PLUGIN.ModeAlert:Show()
			InventoryUpdate()
			PLUGIN.Cooking.ToolsLoaded = true
			EnableListener()
			if not CookingModeFrame:IsShown() then CookingModeFrame:Show() end
			if(not PLUGIN.Docklet:IsShown()) then DockButton:Click() end
		end
	end

end

function PLUGIN.Cooking:Disable()
	if(InCombatLockdown() or (not PLUGIN.Cooking.Loaded) or (not PLUGIN.Cooking.ToolsLoaded)) then
		DisableListener()
		return
	end
	if CONFIGS.farming.droptools then
		for k, v in pairs(refTools) do
			local container, slot = FindItemInBags(k)
			if container and slot then
				PickupContainerItem(container, slot)
				DeleteCursorItem()
			end
		end
	end
	if CookingModeFrame:IsShown() then CookingModeFrame:Hide() end
	PLUGIN.Cooking.ToolsLoaded = false
	DisableListener()
end


-- C_TradeSkillUI.GetRecipeInfo
-- C_TradeSkillUI
-- Professions.GetProfessionInfo()


-- function PLUGIN.Cooking:Enable()
-- 	print ("PLUGIN.Cooking:Enable")
-- 	PLUGIN.Cooking:Update()
-- 	if(not PLUGIN.Docklet:IsShown()) then PLUGIN.Docklet.Button:Click() end
-- 	if(CONFIGS.cooking.autoequip) then
-- 		UpdateChefWear();
-- 	end
-- 	PlaySoundFile("Sound\\Spells\\Tradeskills\\CookingPrepareA.wav")
-- 	PLUGIN.ModeAlert:SetBackdropColor(0.25, 0.52, 0.1)

-- 	FindPierre()

-- 	if(not IsSpellKnown(818)) then
-- 		PLUGIN:ModeLootLoader("Cooking", "WTF is Cooking?", "You have no clue how to cook! \nEven toast is a mystery to you. \nGo find a trainer and learn \nhow to do this simple job.");
-- 		PLUGIN.TitleWindow:Clear();
-- 		PLUGIN.TitleWindow:AddMessage("WTF is Cooking?");
-- 		PLUGIN.LogWindow:Clear();
-- 		PLUGIN.LogWindow:AddMessage("You have no clue how to cook! \nEven toast is a mystery to you. \nGo find a trainer and learn \nhow to do this simple job.", 1, 1, 1);
-- 		PLUGIN.LogWindow:AddMessage(" ", 1, 1, 1);
-- 	else

-- 		local msg = GetTitleAndSkill();
-- 		--70082
-- 		local cd = GetSpellCooldown(campFire)
-- 		print ("--", campFire, cd, usePierre)
-- 		if(usePierre or (cookingSpell and (cd and cd.startTime > 0))) then
-- 			PLUGIN:ModeLootLoader("Cooking", msg, "Double-Right-Click anywhere on the screen \nto open your cookbook.");
-- 			_G["SVUI_ModeCaptureWindow"]:SetAttribute("type", "spell")
-- 			_G["SVUI_ModeCaptureWindow"]:SetAttribute('spell', cookingSpell)
-- 			PLUGIN.Cooking.Btn:SetAttribute("type", "spell")
-- 			PLUGIN.Cooking.Btn:SetAttribute("spell", cookingSpell)
-- 			PLUGIN.Cooking.Btn:Show()
-- 		else
-- 			PLUGIN:ModeLootLoader("Cooking", msg, "Double-Right-Click anywhere on the screen \nto start a cooking fire.");
-- 			_G["SVUI_ModeCaptureWindow"]:SetAttribute("type", "spell")
-- 			_G["SVUI_ModeCaptureWindow"]:SetAttribute('spell', campFire)
-- 			PLUGIN.Cooking.Btn:SetAttribute("type", "spell")
-- 			PLUGIN.Cooking.Btn:SetAttribute("spell", campFire)
-- 			PLUGIN.Cooking.Btn:Show()
-- 			print ("tmp", _G["SVUI_ModeCaptureWindow"]:GetAttribute("type"), _G["SVUI_ModeCaptureWindow"]:GetAttribute("spell"))
-- 		end
-- 	end
-- 	EnableListener()
-- 	PLUGIN.ModeAlert:Show()
-- 	SV:SCTMessage("Cooking Mode Enabled", 0.28, 0.9, 0.1);
-- end

-- function PLUGIN.Cooking:Disable()
-- 	DisableListener()

-- 	PLUGIN.Cooking.Btn:Hide()
-- end

-- function PLUGIN.Cooking:Bind()
-- 	print ("BIND", cookingSpell)
-- 	if InCombatLockdown() then return end
-- 	if cookingSpell then
-- 		local cd = GetSpellCooldown(campFire)
-- 		if cookingSpell and cd and cd.startTime > 0 then
-- 			_G["SVUI_ModeCaptureWindow"]:SetAttribute("type", "spell")
-- 			_G["SVUI_ModeCaptureWindow"]:SetAttribute('spell', cookingSpell)
-- 			PLUGIN.ModeAlert.HelpText = 'Double-Right-Click to open the cooking window.'

-- 			PLUGIN.Cooking.Btn:SetAttribute("type", "spell")
-- 			PLUGIN.Cooking.Btn:SetAttribute("spell", cookingSpell)
-- 			PLUGIN.Cooking.Btn:Show()
-- 		end
-- 		SetOverrideBindingClick(_G["SVUI_ModeCaptureWindow"], true, "BUTTON2", "SVUI_ModeCaptureWindow");
-- 		-- _G["SVUI_ModeCaptureWindow"].Handler:Show();
-- 		_G["SVUI_ModeCaptureWindow"]:Show()
-- 	end
-- end

-- function PLUGIN.Cooking:Update()
-- 	campFire = GetSpellInfo(818).name; -- 818
-- 	local _,_,_,_,cook,_ = GetProfessions();
-- 	print ("PLUGIN.Cooking:Update", cook)
-- 	if cook ~= nil then
-- 		cookingSpell, _, skillRank, _, _, _, _, skillModifier = GetProfessionInfo(cook)
-- 	end
-- end
--[[
##########################################################
LOADER
##########################################################
]]--
-- function PLUGIN:LoadCookingMode()
-- 	print ("LoadCookingMode")
-- 	CONFIGS = SV.db[self.Schema];
-- 	usePierre = FindPierre()
-- 	self.Cooking:Update()

-- 	local btn = CreateFrame("Button", "myButton", UIParent, "SecureActionButtonTemplate")
-- 	btn:SetSize(64 ,64)
-- 	btn.texture = btn:CreateTexture(nil, "ARTWORK")
-- 	btn.texture:SetAllPoints()
-- 	-- btn.texture:SetTexture(C_Spell.GetSpellInfo(818).iconID)
-- 	btn:RegisterForClicks("AnyDown")
-- 	btn:SetPoint("CENTER")
-- 	-- btn:SetAttribute("type", "spell")
-- 	-- btn:SetAttribute("spell", C_Spell.GetSpellInfo(818).name)
-- 	btn:Hide()

-- 	self.Cooking.Btn = btn
-- end

function PLUGIN:RefreshCookingTools()
	local count, horizontal = 0, CONFIGS.farming.toolbardirection == 'HORIZONTAL'
	local BUTTONSPACE = CONFIGS.farming.buttonspacing or 2;
	local lastBar;

	if not CookingToolBar:IsShown() then
		_G["CookingFavoriteBarAnchor"]:SetPoint("TOPLEFT", _G["CookingModeFrameSlots"], "TOPLEFT", 0, 0)
	else
		_G["CookingFavoriteBarAnchor"]:SetPoint("TOPLEFT", _G["CookingToolBar"], horizontal and "BOTTOMLEFT" or "TOPRIGHT", 0, 0)
	end

	for i = 1, NUM_FAVORITE_BARS do

		local favoriteBar = _G["CookingFavoriteBar"..i]
		count = 0
		if(favoriteButtons[i]) then
			for i, button in ipairs(favoriteButtons[i]) do
				local BUTTONSIZE = favoriteBar.ButtonSize;
				button:SetPoint("TOPLEFT", favoriteBar, "TOPLEFT", horizontal and (count * (BUTTONSIZE + BUTTONSPACE) + 1) or 1, horizontal and -1 or -(count * (BUTTONSIZE + BUTTONSPACE) + 1))
				button:SetSize(BUTTONSIZE,BUTTONSIZE)
				if (not CONFIGS.farming.onlyactive or (CONFIGS.farming.onlyactive and button.items > 0)) then
					button.icon:SetVertexColor(1,1,1)
					count = count + 1
				elseif (not CONFIGS.farming.onlyactive and button.items <= 0) then
					button:Show()
					button.icon:SetVertexColor(0.25,0.25,0.25)
					count = count + 1
				else
					button:Hide()
				end
			end
		end
		if(CONFIGS.farming.onlyactive and not CONFIGS.farming.undocked) then
			if count==0 then
				favoriteBar:Hide()
			else
				favoriteBar:Show()
				if(not lastBar) then
					favoriteBar:SetPoint("TOPLEFT", _G["CookingFavoriteBarAnchor"], "TOPLEFT", 0, 0)
				else
					favoriteBar:SetPoint("TOPLEFT", lastBar, horizontal and "BOTTOMLEFT" or "TOPRIGHT", 0, 0)
				end
				lastBar = favoriteBar
			end
		end
	end
	count = 0;
	lastBar = nil;
	CookingToolBar:ClearAllPoints()
	CookingToolBar:SetAllPoints(CookingToolBarAnchor)
	for i, button in ipairs(cookingToolButtons) do
		local BUTTONSIZE = CookingToolBar.ButtonSize;
		button:SetPoint("TOPLEFT", CookingToolBar, "TOPLEFT", horizontal and (count * (BUTTONSIZE + BUTTONSPACE) + 1) or 1, horizontal and -1 or -(count * (BUTTONSIZE + BUTTONSPACE) + 1))
		button:SetSize(BUTTONSIZE,BUTTONSIZE)
		if (not CONFIGS.farming.onlyactive or (CONFIGS.farming.onlyactive and button.items > 0)) then
			button:Show()
			button.icon:SetVertexColor(1,1,1)
			count = count + 1
		elseif (not CONFIGS.farming.onlyactive and button.items == 0) then
			button:Show()
			button.icon:SetVertexColor(0.25,0.25,0.25)
			count = count + 1
		else
			button:Hide()
		end
	end
	if(CONFIGS.farming.onlyactive and not CONFIGS.farming.undocked) then
		if count==0 then
			CookingToolBarAnchor:Hide()
			-- FarmPortalBar:SetPoint("TOPLEFT", FarmModeFrameSlots, "TOPLEFT", 0, 0)
		else
			CookingToolBarAnchor:Show()
			-- FarmPortalBar:SetPoint("TOPLEFT", CookingToolBarAnchor, "TOPRIGHT", 0, 0)
		end
	end
	count = 0;
	-- FarmPortalBar:ClearAllPoints()
	-- FarmPortalBar:SetAllPoints(FarmPortalBarAnchor)
	-- for i, button in ipairs(portalButtons) do
	-- 	local BUTTONSIZE = FarmPortalBar.ButtonSize;
	-- 	button:SetPoint("TOPLEFT", FarmPortalBar, "TOPLEFT", horizontal and (count * (BUTTONSIZE + BUTTONSPACE) + 1) or 1, horizontal and -1 or -(count * (BUTTONSIZE + BUTTONSPACE) + 1))
	-- 	button:SetSize(BUTTONSIZE,BUTTONSIZE)
	-- 	if (not CONFIGS.farming.onlyactive or (CONFIGS.farming.onlyactive and button.items > 0)) then
	-- 		button:Show()
	-- 		button.icon:SetVertexColor(1,1,1)
	-- 		count = count + 1
	-- 	elseif (not CONFIGS.farming.onlyactive and button.items == 0) then
	-- 		button:Show()
	-- 		button.icon:SetVertexColor(0.25,0.25,0.25)
	-- 		count = count + 1
	-- 	else
	-- 		button:Hide()
	-- 	end
	-- end
	-- if(CONFIGS.farming.onlyactive) then
	-- 	if count==0 then
	-- 		FarmPortalBar:Hide()
	-- 	else
	-- 		FarmPortalBar:Show()
	-- 	end
	-- end
end

function PLUGIN:PrepareCookingTools()


	CONFIGS = SV.db[self.Schema];
	local horizontal = CONFIGS.farming.toolbardirection == "HORIZONTAL"
	local BUTTONSPACE = CONFIGS.farming.buttonspacing or 2;

	ModeLogsFrame = self.LogWindow;
	DockButton = self.Docklet.Button

	if not CONFIGS.farming.undocked then
		local bgTex = [[Interface\BUTTONS\WHITE8X8]]
		local bdTex = SV.media.statusbar.glow
		local cookingDocklet = CreateFrame("ScrollFrame", "CookingModeFrame", ModeLogsFrame);
		cookingDocklet:SetPoint("TOPLEFT", ModeLogsFrame, 31, -3);
		cookingDocklet:SetPoint("BOTTOMRIGHT", ModeLogsFrame, -3, 3);
		cookingDocklet:EnableMouseWheel(true);

		local cookingDockletSlots = CreateFrame("Frame", "CookingModeFrameSlots", cookingDocklet);
		cookingDockletSlots:SetPoint("TOPLEFT", cookingDocklet, 0, 0);
		cookingDockletSlots:SetWidth(cookingDocklet:GetWidth())
		cookingDockletSlots:SetHeight(500);
		cookingDockletSlots:SetFrameLevel(cookingDocklet:GetFrameLevel() + 1)
		cookingDocklet:SetScrollChild(cookingDockletSlots)

		local slotSlider = CreateFrame("Slider", "CookingModeSlotSlider", cookingDocklet, "BackdropTemplate")
		slotSlider:SetHeight(cookingDocklet:GetHeight() - 3);
		slotSlider:SetWidth(18);
		slotSlider:SetPoint("TOPLEFT", cookingDocklet, -28, 0);
		slotSlider:SetPoint("BOTTOMLEFT", cookingDocklet, -28, 0);
		slotSlider:SetBackdrop({bgFile = bgTex, edgeFile = bdTex, edgeSize = 4, insets = {left = 3, right = 3, top = 3, bottom = 3}});
		slotSlider:SetFrameLevel(6)
		slotSlider:SetStyle("!_Frame", "Transparent", true);
		slotSlider:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob");
		slotSlider:SetOrientation("VERTICAL");
		slotSlider:SetValueStep(5);
		slotSlider:SetMinMaxValues(1, 420);
		slotSlider:SetValue(1);

		cookingDocklet.slider = slotSlider;
		slotSlider:SetScript("OnValueChanged", Scroll_OnValueChanged)
		cookingDocklet:SetScript("OnMouseWheel", Scroll_OnMouseWheel);

		local parentWidth = cookingDockletSlots:GetWidth() - 31
		local BUTTONSIZE = (parentWidth / (horizontal and 10 or 8));
		local TOOLSIZE = (parentWidth / 8);

		-- COOKING TOOLS
		local cookingToolBarAnchor = CreateFrame("Frame", "CookingToolBarAnchor", cookingDockletSlots)
		cookingToolBarAnchor:SetPoint("TOPLEFT", cookingDockletSlots, "TOPLEFT", 0, 0)
		cookingToolBarAnchor:SetSize(horizontal and ((TOOLSIZE + BUTTONSPACE) * 4) or (TOOLSIZE + BUTTONSPACE), horizontal and (TOOLSIZE + BUTTONSPACE) or ((TOOLSIZE + BUTTONSPACE) * 4))

		local cookingToolBar = CreateFrame("Frame", "CookingToolBar", cookingToolBarAnchor)
		cookingToolBar:SetSize(horizontal and ((TOOLSIZE + BUTTONSPACE) * 4) or (TOOLSIZE + BUTTONSPACE), horizontal and (TOOLSIZE + BUTTONSPACE) or ((TOOLSIZE + BUTTONSPACE) * 4))
		cookingToolBar:SetPoint("TOPLEFT", cookingToolBarAnchor, "TOPLEFT", (horizontal and BUTTONSPACE or (TOOLSIZE + BUTTONSPACE)), (horizontal and -(TOOLSIZE + BUTTONSPACE) or -BUTTONSPACE))
		cookingToolBar.ButtonSize = TOOLSIZE;

		-- FAVORITES
		local cookingFavoriteBarAnchor = CreateFrame("Frame", "CookingFavoriteBarAnchor", cookingDockletSlots)
		cookingFavoriteBarAnchor:SetPoint("TOPLEFT", cookingToolBarAnchor, horizontal and "BOTTOMLEFT" or "TOPRIGHT", 0, 0)
		cookingFavoriteBarAnchor:SetSize(horizontal and ((BUTTONSIZE + BUTTONSPACE) * 10) or ((BUTTONSIZE + BUTTONSPACE) * 8), horizontal and ((BUTTONSIZE + BUTTONSPACE) * 8) or ((BUTTONSIZE + BUTTONSPACE) * 10))

		for i = 1, NUM_FAVORITE_BARS do
			local favoriteBar = CreateFrame("Frame", "CookingFavoriteBar"..i, cookingFavoriteBarAnchor)
			favoriteBar.ButtonSize = BUTTONSIZE;
			favoriteBar:SetSize(horizontal and ((BUTTONSIZE + BUTTONSPACE) * 10) or (BUTTONSIZE + BUTTONSPACE), horizontal and (BUTTONSIZE + BUTTONSPACE) or ((BUTTONSIZE + BUTTONSPACE) * 10))
			if i == 1 then
				favoriteBar:SetPoint("TOPLEFT", cookingFavoriteBarAnchor, "TOPLEFT", 0, 0)
			else
				favoriteBar:SetPoint("TOPLEFT", "CookingFavoriteBar"..i-1, horizontal and "BOTTOMLEFT" or "TOPRIGHT", 0, 0)
			end
			favoriteButtons[i] = {}
		end

		cookingDocklet:Hide()
	else
		local BUTTONSIZE = CONFIGS.farming.buttonsize or 35;

		-- FAVORITES
		local cookingFavoriteBarAnchor = CreateFrame("Frame", "CookingFavoriteBarAnchor", UIParent)
		cookingFavoriteBarAnchor:SetPoint("TOPRIGHT", SV.Screen, "TOPRIGHT", -40, -300)
		cookingFavoriteBarAnchor:SetSize(horizontal and ((BUTTONSIZE + BUTTONSPACE) * 10) or ((BUTTONSIZE + BUTTONSPACE) * 8), horizontal and ((BUTTONSIZE + BUTTONSPACE) * 8) or ((BUTTONSIZE + BUTTONSPACE) * 10))
		for i = 1, NUM_FAVORITE_BARS do
			local favoriteBar = CreateFrame("Frame", "CookingFavoriteBar"..i, cookingFavoriteBarAnchor)
			favoriteBar:SetSize(horizontal and ((BUTTONSIZE + BUTTONSPACE) * 10) or (BUTTONSIZE + BUTTONSPACE), horizontal and (BUTTONSIZE + BUTTONSPACE) or ((BUTTONSIZE + BUTTONSPACE) * 10))
			favoriteBar:SetPoint("TOPRIGHT", cookingFavoriteBarAnchor, "TOPRIGHT", (horizontal and 0 or -((BUTTONSIZE + BUTTONSPACE) * i)), (horizontal and -((BUTTONSIZE + BUTTONSPACE) * i) or 0))
			favoriteBar.ButtonSize = BUTTONSIZE;
		end
		SV.Mentalo:Add(cookingFavoriteBarAnchor, "Cooking Favorites")

		-- COOKING TOOLS
		local cookingToolBarAnchor = CreateFrame("Frame", "CookingToolBarAnchor", UIParent)
		cookingToolBarAnchor:SetPoint("TOPRIGHT", cookingFavoriteBarAnchor, horizontal and "BOTTOMRIGHT" or "TOPLEFT", horizontal and 0 or -(BUTTONSPACE * 2), horizontal and -(BUTTONSPACE * 2) or 0)
		cookingToolBarAnchor:SetSize(horizontal and ((BUTTONSIZE + BUTTONSPACE) * 4) or (BUTTONSIZE + BUTTONSPACE), horizontal and (BUTTONSIZE + BUTTONSPACE) or ((BUTTONSIZE + BUTTONSPACE) * 4))
		
		local cookingToolBar = CreateFrame("Frame", "CookingToolBar", cookingToolBarAnchor)
		cookingToolBar:SetSize(horizontal and ((BUTTONSIZE + BUTTONSPACE) * 4) or (BUTTONSIZE + BUTTONSPACE), horizontal and (BUTTONSIZE + BUTTONSPACE) or ((BUTTONSIZE + BUTTONSPACE) * 4))
		cookingToolBar:SetPoint("TOPRIGHT", cookingToolBarAnchor, "TOPRIGHT", (horizontal and -BUTTONSPACE or -(BUTTONSIZE + BUTTONSPACE)), (horizontal and -(BUTTONSIZE + BUTTONSPACE) or -BUTTONSPACE))
		cookingToolBar.ButtonSize = BUTTONSIZE;
		SV.Mentalo:Add(cookingToolBarAnchor, "Cooking Tools")

	end

	GetCookingRecipe()

end
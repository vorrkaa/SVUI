--[[
##########################################################
S V U I   By: Failcoder
##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--LUA
local unpack        = unpack;
local select        = select;
local pairs         = pairs;
local type          = type;
local rawset        = rawset;
local rawget        = rawget;
local tostring      = tostring;
local error         = error;
local next          = next;
local pcall         = pcall;
local getmetatable  = getmetatable;
local setmetatable  = setmetatable;
local assert        = assert;
--BLIZZARD
local _G            = _G;
local tinsert       = _G.tinsert;
local tremove       = _G.tremove;
local twipe         = _G.wipe;
--STRING
local string        = string;
local upper         = string.upper;
local format        = string.format;
local find          = string.find;
local match         = string.match;
local gsub          = string.gsub;
--MATH
local math          = math;
local floor         = math.floor
local ceil         	= math.ceil
local hugeMath 		= math.huge;
--TABLE
local table         = table;
local tsort         = table.sort;
local tremove       = table.remove;

local CreateFrame           = _G.CreateFrame;
local InCombatLockdown      = _G.InCombatLockdown;
local GameTooltip           = _G.GameTooltip;
--[[
##########################################################
GET ADDON DATA
##########################################################
]]--
local SV = _G['SVUI']
local L = SV.L;
local LSM = _G.LibStub("LibSharedMedia-3.0")
local MOD = SV.UnitFrames

if(not MOD) then return end

local oUF_SVUI = MOD.oUF
assert(oUF_SVUI, "SVUI UnitFrames: unable to locate oUF.")

local DEFAULT_BUFFS_COLOR = {0.04, 0.52, 0.95};
local BUFFS_COLOR = DEFAULT_BUFFS_COLOR;
local DEFAULT_DEBUFFS_COLOR = {.9, 0, 0};
local DEBUFFS_COLOR = DEFAULT_DEBUFFS_COLOR;
local AURA_STATUSBAR = SV.media.statusbar.default;
local BASIC_TEXTURE = SV.media.statusbar.default;
local CanSteal = (SV.class == "MAGE");

local CreateFrame 		= _G.CreateFrame;
local UnitIsEnemy 		= _G.UnitIsEnemy;
local IsShiftKeyDown 	= _G.IsShiftKeyDown;
local DebuffTypeColor 	= _G.DebuffTypeColor;

local SVUI_Font_UnitAura 		= _G.SVUI_Font_UnitAura;
local SVUI_Font_UnitAura_Bar 	= _G.SVUI_Font_UnitAura_Bar;
--[[
##########################################################
LOCAL FUNCTIONS
##########################################################
]]--
local FilterAura_OnClick = function(self)
	if not IsShiftKeyDown() then return end
	local name = self.name;
	local spellID = self.spellID;
	local filterKey = tostring(spellID)
	if name and filterKey then
		SV:AddonMessage((L["The spell '%s' has been added to the BlackList unitframe aura filter."]):format(name))
		SV.db.Filters["BlackList"][filterKey] = {['enable'] = true, ['id'] = spellID}
		MOD:RefreshUnitFrames()
	end
end

local Aura_OnEnter = function(self)
	if(not self:IsVisible()) then return end
	-- GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
	GameTooltip:SetOwner(self, self:GetParent().__restricted and 'ANCHOR_BOTTOMRIGHT' or self:GetParent().tooltipAnchor)
	GameTooltip:SetUnitAura(self.unit or self:GetParent().__owner.unit, self.index or self.auraInstanceID, self.filter)
end

local Aura_OnLeave = function()
	GameTooltip:Hide()
end

local _hook_AuraBGBorderColor = function(self, ...) self.bg:SetBackdropBorderColor(...) end

local CreateAuraButton = function(element, index)
	local baseSize = element.size or 16
	local button = CreateFrame('Button', element:GetDebugName() .. 'Button' .. index, element, "BackdropTemplate")
	button:RemoveTextures()
	button:EnableMouse(true)
	button:RegisterForClicks('RightButtonUp')

	button:SetBackdrop({
		bgFile = [[Interface\BUTTONS\WHITE8X8]],
		tile = false,
		tileSize = 0,
		edgeFile = [[Interface\BUTTONS\WHITE8X8]],
		 edgeSize = 1,
		insets = {
			left = 0,
			right = 0,
			top = 0,
			bottom = 0
		}
	});
	button:SetBackdropColor(0, 0, 0, 0)
	button:SetBackdropBorderColor(0, 0, 0)

	local bg = CreateFrame("Frame", nil, button, "BackdropTemplate")
	bg:SetFrameStrata("BACKGROUND")
	bg:SetFrameLevel(0)
	bg:WrapPoints(button, 2, 2)
	bg:SetBackdrop(SV.media.backdrop.aura)
	bg:SetBackdropColor(0, 0, 0, 0)
	bg:SetBackdropBorderColor(0, 0, 0, 0)
	button.bg = bg;

	local fontgroup = "SVUI_Font_UnitAura";
	if(baseSize < 18) then
		fontgroup = "SVUI_Font_UnitAura_Small";
	end

	local cd = CreateFrame('Cooldown', '$parentCooldown', button, 'CooldownFrameTemplate')
	cd:InsetPoints(button, 1, 1);
	cd.noOCC = true;
	cd.noCooldownCount = true;
	cd:SetReverse(true);
	cd:SetHideCountdownNumbers(true);

	local fg = CreateFrame("Frame", nil, button)
  	fg:WrapPoints(button, 2, 2)

	local text = fg:CreateFontString(nil, 'OVERLAY');
	text:SetFontObject(_G[fontgroup]);
	text:SetPoint('CENTER', button, 'CENTER', 1, 1);
	text:SetJustifyH('CENTER');

	local count = fg:CreateFontString(nil, "OVERLAY");
	count:SetFontObject(_G[fontgroup]);
	count:SetPoint("CENTER", button, "BOTTOMRIGHT", -3, 3);

	local icon = button:CreateTexture(nil, "BACKGROUND");
	icon:SetAllPoints(button);
	icon:InsetPoints(button, 1, 1);
  	icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS));

	local overlay = button:CreateTexture(nil, "OVERLAY");
	overlay:InsetPoints(button, 1, 1);
	overlay:SetTexture(BASIC_TEXTURE);
	overlay:SetVertexColor(0, 0, 0);
	overlay:Hide();

	local stealable = button:CreateTexture(nil, 'OVERLAY')
	stealable:SetTexture([[Interface\TargetingFrame\UI-TargetingFrame-Stealable]])
	stealable:SetPoint('TOPLEFT', -3, 3)
	stealable:SetPoint('BOTTOMRIGHT', 3, -3)
	stealable:SetBlendMode('ADD')

	local function onEnter(self)
		if(GameTooltip:IsForbidden() or not self:IsVisible()) then return end

		-- Avoid parenting GameTooltip to frames with anchoring restrictions,
		-- otherwise it'll inherit said restrictions which will cause issues with
		-- its further positioning, clamping, etc
		GameTooltip:SetOwner(self, self:GetParent().__restricted and 'ANCHOR_BOTTOMRIGHT' or self:GetParent().tooltipAnchor)
		self:UpdateTooltip()
	end

	local function onLeave()
		if(GameTooltip:IsForbidden()) then return end
	
		GameTooltip:Hide()
	end

	local function updateTooltip(self)
		if(GameTooltip:IsForbidden()) then return end
	
		if(self.isHarmful) then
			GameTooltip:SetUnitDebuffByAuraInstanceID(self:GetParent().__owner.unit, self.auraInstanceID)
		else
			GameTooltip:SetUnitBuffByAuraInstanceID(self:GetParent().__owner.unit, self.auraInstanceID)
		end
	end

	button:SetScript("OnClick", FilterAura_OnClick);
	button:SetScript("OnEnter", onEnter);
	button:SetScript("OnLeave", onLeave);
	button.UpdateTooltip = updateTooltip

	button.parent = icons;
	button.Cooldown = cd;
	button.Text = text;
	button.Icon = icon;
	button.Count = count;
	button.Overlay = overlay;
	button.Stealable = stealable

	--[[ Callback: Auras:PostCreateButton(button)
	Called after a new aura button has been created.

	* self   - the widget holding the aura buttons
	* button - the newly created aura button (Button)
	--]]
	if(element.PostCreateButton) then element:PostCreateButton(button) end

	return button

end

local CreateAuraIcon = function(icons, index)
	local baseSize = icons.auraSize or 16
	local aura = CreateFrame("Button", nil, icons, "BackdropTemplate")
	aura:RemoveTextures()
	aura:EnableMouse(true)
	aura:RegisterForClicks('RightButtonUp')

	aura:SetWidth(baseSize)
	aura:SetHeight(baseSize)

	aura:SetBackdrop({
    bgFile = [[Interface\BUTTONS\WHITE8X8]],
		tile = false,
		tileSize = 0,
		edgeFile = [[Interface\BUTTONS\WHITE8X8]],
      edgeSize = 1,
      insets = {
          left = 0,
          right = 0,
          top = 0,
          bottom = 0
      }
	});
	aura:SetBackdropColor(0, 0, 0, 0)
	aura:SetBackdropBorderColor(0, 0, 0)

	local bg = CreateFrame("Frame", nil, aura, "BackdropTemplate")
	bg:SetFrameStrata("BACKGROUND")
	bg:SetFrameLevel(0)
	bg:WrapPoints(aura, 2, 2)
	bg:SetBackdrop(SV.media.backdrop.aura)
	bg:SetBackdropColor(0, 0, 0, 0)
	bg:SetBackdropBorderColor(0, 0, 0, 0)
	aura.bg = bg;

  --hooksecurefunc(aura, "SetBackdropBorderColor", _hook_AuraBGBorderColor)

	local fontgroup = "SVUI_Font_UnitAura";
	if(baseSize < 18) then
		fontgroup = "SVUI_Font_UnitAura_Small";
	end
  --print(baseSize)
  --print(fontgroup)

	local cd = CreateFrame("Cooldown", nil, aura, "CooldownFrameTemplate");
	cd:InsetPoints(aura, 1, 1);
	cd.noOCC = true;
	cd.noCooldownCount = true;
	cd:SetReverse(true);
	cd:SetHideCountdownNumbers(true);

	local fg = CreateFrame("Frame", nil, aura)
  	fg:WrapPoints(aura, 2, 2)

	local text = fg:CreateFontString(nil, 'OVERLAY');
	text:SetFontObject(_G[fontgroup]);
	text:SetPoint('CENTER', aura, 'CENTER', 1, 1);
	text:SetJustifyH('CENTER');

	local count = fg:CreateFontString(nil, "OVERLAY");
	count:SetFontObject(_G[fontgroup]);
	count:SetPoint("CENTER", aura, "BOTTOMRIGHT", -3, 3);

	local icon = aura:CreateTexture(nil, "BACKGROUND");
	icon:SetAllPoints(aura);
	icon:InsetPoints(aura, 1, 1);
  	icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS));

	local overlay = aura:CreateTexture(nil, "OVERLAY");
	overlay:InsetPoints(aura, 1, 1);
	overlay:SetTexture(BASIC_TEXTURE);
	overlay:SetVertexColor(0, 0, 0);
	overlay:Hide();

	-- local stealable = aura:CreateTexture(nil, 'OVERLAY')
	-- stealable:SetTexture("")
	-- stealable:SetPoint('TOPLEFT', -3, 3)
	-- stealable:SetPoint('BOTTOMRIGHT', 3, -3)
	-- aura.stealable = stealable

	aura:SetScript("OnClick", FilterAura_OnClick);
	aura:SetScript("OnEnter", Aura_OnEnter);
	aura:SetScript("OnLeave", Aura_OnLeave);

	aura.parent = icons;
	aura.cooldown = cd;
	aura.text = text;
	aura.icon = icon;
	aura.count = count;
	aura.overlay = overlay;

	return aura
end

local PostCreateAuraBars = function(self)
	local bar = self.statusBar
	local barTexture = LSM:Fetch("statusbar", SV.db.UnitFrames.auraBarStatusbar)
	bar:SetStatusBarTexture(barTexture)
	bar.spelltime:SetFontObject(SVUI_Font_UnitAura_Bar);
	bar.spelltime:SetTextColor(1 ,1, 1)
	bar.spelltime:SetShadowOffset(1, -1)
  	bar.spelltime:SetShadowColor(0, 0, 0)
	bar.spelltime:SetJustifyH('RIGHT')
	bar.spelltime:SetJustifyV('MIDDLE')
	bar.spelltime:SetPoint('RIGHT')

	bar.spellname:SetFontObject(SVUI_Font_UnitAura_Bar);
	bar.spellname:SetTextColor(1, 1, 1)
	bar.spellname:SetShadowOffset(1, -1)
  	bar.spellname:SetShadowColor(0, 0, 0)
	bar.spellname:SetJustifyH('LEFT')
	bar.spellname:SetJustifyV('MIDDLE')
	bar.spellname:SetPoint('LEFT')
	bar.spellname:SetPoint('RIGHT', bar.spelltime, 'LEFT')

	self:RegisterForClicks("RightButtonUp")
	self:SetScript("OnClick", FilterAura_OnClick)
end

local PostBarUpdate = function(self, bar, spellID, isDebuff, debuffType)
	if((not bar) or (not bar:IsVisible())) then return end

	local color;
	if(SV.db.UnitFrames.auraBarByType) then
		local filterKey = tostring(spellID)
		if(SV.db.Filters.AuraBars[filterKey]) then
			color = SV.db.Filters.AuraBars[filterKey]
		elseif isDebuff then
			if(debuffType and DebuffTypeColor[debuffType]) then
				color = {DebuffTypeColor[debuffType].r, DebuffTypeColor[debuffType].g, DebuffTypeColor[debuffType].b}
			else
				color = DEBUFFS_COLOR;
			end
		else
			color = BUFFS_COLOR;
		end
	else
		color = BUFFS_COLOR;
	end

	bar:SetStatusBarTexture(AURA_STATUSBAR)

	bar:SetStatusBarColor(unpack(color))
end

--[[ AURA FILTERING ]]--
---comment
---@param self table
---@param element table
---@param unit Unit
---@param data AuraData
---@return boolean
local CommonAuraFilter = function(self, unit, data)
	local db = SV.db.UnitFrames[self.___unitkey]

	if self.___aurakey == "auras" then
		if((not db) or (db and not db["buffs"])) then
			return false;
		elseif((not db) or (db and not db["debuffs"])) then
			return false;
		end
	elseif((not db) or (db and not db[self.___aurakey])) then
		return false;
	end

	-- if((not db) or (db and not db[self.___aurakey])) then
	-- 	return false;
	-- end

	local keys = {}

	if self.___aurakey == "auras" then
		tinsert(keys, "buffs")
		tinsert(keys, "debuffs")
	else
		tinsert(keys, self.___aurakey)
	end

	for i =1, #keys do
		local auraDB = db[keys[i]]
		local filterKey = tostring(data.spellId)
		-- local isPlayer = data.sourceUnit == "player" or data.sourceUnit == "vehicle"
		local isPlayer = data.isPlayerAura or (data.sourceUnit and (UnitIsUnit('player', data.sourceUnit) or UnitIsOwnerOrControllerOfUnit('player', data.sourceUnit)))

		if(auraDB.filterWhiteList and (not SV.db.Filters.WhiteList[filterKey])) then
			return false;
		elseif(SV.db.Filters.BlackList[filterKey] and SV.db.Filters.BlackList[filterKey].enable) then
			return false;
		else
			if(auraDB.filterPlayer and (not isPlayer)) then
				return false
			end

			if(auraDB.filterDispellable and (data.dispelName and not MOD.Dispellable[data.dispelName])) then
				return false
			end

			-- if(auraDB.filterRaid and not data.isRaid) then
			-- 	return false
			-- end

			if(auraDB.filterInfinite and ((not data.duration) or (data.duration and data.duration == 0))) then
				return false
			end

			local active = auraDB.useFilter
			if(active and SV.db.Filters[active]) then
				local spellDB = SV.db.Filters[active];
				if(spellDB[filterKey] and spellDB[filterKey].enable) then
					return false
				end
			end
		end
	end

	-- local auraDB = db[self.___aurakey];
	-- local filterKey = tostring(data.spellId)
	-- -- local isPlayer = data.sourceUnit == "player" or data.sourceUnit == "vehicle"
	-- local isPlayer = data.isPlayerAura or (data.sourceUnit and (UnitIsUnit('player', data.sourceUnit) or UnitIsOwnerOrControllerOfUnit('player', data.sourceUnit)))

	-- if(auraDB.filterWhiteList and (not SV.db.Filters.WhiteList[filterKey])) then
	-- 	return false;
	-- elseif(SV.db.Filters.BlackList[filterKey] and SV.db.Filters.BlackList[filterKey].enable) then
	-- 	return false;
	-- else
	-- 	if(auraDB.filterPlayer and (not isPlayer)) then
	-- 		return false
	-- 	end

	-- 	if(auraDB.filterDispellable and (data.dispelName and not MOD.Dispellable[data.dispelName])) then
	-- 		return false
	-- 	end

	-- 	-- if(auraDB.filterRaid and not data.isRaid) then
	-- 	-- 	return false
	-- 	-- end

	-- 	if(auraDB.filterInfinite and ((not data.duration) or (data.duration and data.duration == 0))) then
	-- 		return false
	-- 	end

	-- 	local active = auraDB.useFilter
	-- 	if(active and SV.db.Filters[active]) then
	-- 		local spellDB = SV.db.Filters[active];
	-- 		if(spellDB[filterKey] and spellDB[filterKey].enable) then
	-- 			return false
	-- 		end
	-- 	end
	-- end
  	return true
end

-- local CommonAuraFilter = function(self, isEnemy, isPlayer, auraName, spellID, debuffType, duration, shouldConsolidate)
-- 	local db = SV.db.UnitFrames[self.___unitkey]
-- 	if((not db) or (db and not db[self.___aurakey])) then
-- 		return false;
-- 	end

-- 	local auraDB = db[self.___aurakey];
-- 	local filterKey = tostring(spellID)

-- 	if(auraDB.filterWhiteList and (not SV.db.Filters.WhiteList[filterKey])) then
-- 		return false;
-- 	elseif(SV.db.Filters.BlackList[filterKey] and SV.db.Filters.BlackList[filterKey].enable) then
-- 		return false;
-- 	else
-- 		if(auraDB.filterPlayer and (not isPlayer)) then
-- 			return false
-- 		end

-- 		if(auraDB.filterDispellable and (debuffType and not MOD.Dispellable[debuffType])) then
-- 			return false
-- 		end

-- 		if(auraDB.filterRaid and shouldConsolidate) then
-- 			return false
-- 		end

-- 		if(auraDB.filterInfinite and ((not duration) or (duration and duration == 0))) then
-- 			return false
-- 		end

-- 		local active = auraDB.useFilter
-- 		if(active and SV.db.Filters[active]) then
-- 			local spellDB = SV.db.Filters[active];
-- 			if(spellDB[filterKey] and spellDB[filterKey].enable) then
-- 				return false
-- 			end
-- 		end
-- 	end
--   	return true
-- end

--[[ DETAILED AURA FILTERING ]]--

local function filter_test(setting, isEnemy)
	if((not setting) or (setting and type(setting) ~= "table")) then
		return false;
	end
	if((setting.enemy and isEnemy) or (setting.friendly and (not isEnemy))) then
	  return true;
	end
  	return false
end

--[[ AURA FILTERING ]]--
---comment
---@param self table
---@param element table
---@param unit Unit
---@param data AuraData
---@return boolean
local DetailedAuraFilter = function(self, unit, data)
	local db = SV.db.UnitFrames[self.___unitkey]

	if self.___aurakey == "auras" then
		if((not db) or (db and not db["buffs"])) then
			return false;
		elseif((not db) or (db and not db["debuffs"])) then
			return false;
		end
	elseif((not db) or (db and not db[self.___aurakey])) then
		return false;
	end

	-- local auraType = self.___aurakey
	-- if((not db) or (not auraType) or (db and (not db[auraType]))) then
	-- 	return false;
	-- end

	local keys = {}

	if self.___aurakey == "auras" then
		tinsert(keys, "buffs")
		tinsert(keys, "debuffs")
	else
		tinsert(keys, self.___aurakey)
	end

	for i =1, #keys do
		local auraDB = db[keys[i]]
		local filterKey = tostring(data.spellId)
		-- local isPlayer = data.sourceUnit == "player" or data.sourceUnit == "vehicle"
		local isPlayer = data.isPlayerAura or (data.sourceUnit and (UnitIsUnit('player', data.sourceUnit) or UnitIsOwnerOrControllerOfUnit('player', data.sourceUnit)))
		local isEnemy = not isPlayer

		if(filter_test(auraDB.filterAll, isEnemy)) then
			return false
		elseif(filter_test(auraDB.filterWhiteList, isEnemy) and (not SV.db.Filters.WhiteList[filterKey])) then
			return false;
		elseif(SV.db.Filters.BlackList[filterKey] and SV.db.Filters.BlackList[filterKey].enable) then
			return false
		else
			if(filter_test(auraDB.filterPlayer, isEnemy) and (not isPlayer)) then
				return false
			end
			if(filter_test(auraDB.filterDispellable, isEnemy)) then
				if((CanSteal and (auraType == 'buffs' and data.isStealable)) or (data.dispelName and (not MOD.Dispellable[data.dispelName])) or (not data.dispelName)) then
					return false
				end
			end
			
			-- if(filter_test(auraDB.filterRaid, isEnemy) and data.isRaid) then
			-- 	return false
			-- end

			if(filter_test(auraDB.filterInfinite, isEnemy) and ((not data.duration) or (data.duration and data.duration == 0))) then
				return false
			end
			local active = auraDB.useFilter
			if(active and SV.db.Filters[active]) then
				local spellDB = SV.db.Filters[active];
				if(spellDB[filterKey] and spellDB[filterKey].enable) then
					return false
				end
			end
		end
	end

	-- local auraDB = db[self.___aurakey];
	-- local filterKey = tostring(data.spellId)
	-- -- local isPlayer = data.sourceUnit == "player" or data.sourceUnit == "vehicle"
	-- local isPlayer = data.isPlayerAura or (data.sourceUnit and (UnitIsUnit('player', data.sourceUnit) or UnitIsOwnerOrControllerOfUnit('player', data.sourceUnit)))
	-- local isEnemy = not isPlayer

	-- if(filter_test(auraDB.filterAll, isEnemy)) then
	-- 	return false
	-- elseif(filter_test(auraDB.filterWhiteList, isEnemy) and (not SV.db.Filters.WhiteList[filterKey])) then
	-- 	return false;
	-- elseif(SV.db.Filters.BlackList[filterKey] and SV.db.Filters.BlackList[filterKey].enable) then
	-- 	return false
	-- else
	-- 	if(filter_test(auraDB.filterPlayer, isEnemy) and (not isPlayer)) then
	-- 		return false
	-- 	end
	-- 	if(filter_test(auraDB.filterDispellable, isEnemy)) then
	-- 		if((CanSteal and (auraType == 'buffs' and data.isStealable)) or (data.dispelName and (not MOD.Dispellable[data.dispelName])) or (not data.dispelName)) then
	-- 			return false
	-- 		end
	-- 	end
		
	-- 	-- if(filter_test(auraDB.filterRaid, isEnemy) and data.isRaid) then
	-- 	-- 	return false
	-- 	-- end

	-- 	if(filter_test(auraDB.filterInfinite, isEnemy) and ((not data.duration) or (data.duration and data.duration == 0))) then
	-- 		return false
	-- 	end
	-- 	local active = auraDB.useFilter
	-- 	if(active and SV.db.Filters[active]) then
	-- 		local spellDB = SV.db.Filters[active];
	-- 		if(spellDB[filterKey] and spellDB[filterKey].enable) then
	-- 			return false
	-- 		end
	-- 	end
	-- end
  	return true
end

-- local DetailedAuraFilter = function(self, isEnemy, isPlayer, auraName, spellID, debuffType, duration, shouldConsolidate)

-- 	local db = SV.db.UnitFrames[self.___unitkey]
-- 	local auraType = self.___aurakey
-- 	if((not db) or (not auraType) or (db and (not db[auraType]))) then
-- 		return false;
-- 	end

-- 	local auraDB = db[self.___aurakey];
-- 	local filterKey = tostring(spellID)

-- 	if(filter_test(auraDB.filterAll, isEnemy)) then
-- 		return false
-- 	elseif(filter_test(auraDB.filterWhiteList, isEnemy) and (not SV.db.Filters.WhiteList[filterKey])) then
-- 		return false;
-- 	elseif(SV.db.Filters.BlackList[filterKey] and SV.db.Filters.BlackList[filterKey].enable) then
-- 		return false
-- 	else
-- 		if(filter_test(auraDB.filterPlayer, isEnemy) and (not isPlayer)) then
-- 			return false
-- 		end
-- 		if(filter_test(auraDB.filterDispellable, isEnemy)) then
-- 			if((CanSteal and (auraType == 'buffs' and isStealable)) or (debuffType and (not MOD.Dispellable[debuffType])) or (not debuffType)) then
-- 				return false
-- 			end
-- 		end
-- 		if(filter_test(auraDB.filterRaid, isEnemy) and shouldConsolidate) then
-- 			return false
-- 		end
-- 		if(filter_test(auraDB.filterInfinite, isEnemy) and ((not duration) or (duration and duration == 0))) then
-- 			return false
-- 		end
-- 		local active = auraDB.useFilter
-- 		if(active and SV.db.Filters[active]) then
-- 			local spellDB = SV.db.Filters[active];
-- 			if(spellDB[filterKey] and spellDB[filterKey].enable) then
-- 				return false
-- 			end
-- 		end
-- 	end
--   	return true
-- end
--[[
##########################################################
BUILD FUNCTION
##########################################################
]]--
local BoolFilters = {
	['player'] = true,
	['pet'] = true,
	['boss'] = true,
	['arena'] = true,
	['party'] = true,
	['raid'] = true,
	['raidpet'] = true,
};

local SORTING_METHODS = {
	["TIME_REMAINING"] = function(a, b)

		-- local auraA = C_UnitAuras.GetAuraDataByAuraInstanceID(a.sourceUnit, a.auraInstanceID)
		-- local auraB = C_UnitAuras.GetAuraDataByAuraInstanceID(b.sourceUnit, b.auraInstanceID)

		-- local compA = auraA and (auraA.duration == 0 and auraA.expirationTime == 0) and hugeMath or auraA.expirationTime
		-- local compB = auraB and (auraB.duration == 0 and auraB.expirationTime == 0) and hugeMath or auraB.expirationTime
		-- return compA > compB

		local compA = (a.duration == 0 and a.expirationTime == 0) and hugeMath or a.expirationTime
		local compB = (b.duration == 0 and b.expirationTime == 0) and hugeMath or b.expirationTime
		return compA > compB
		-- local compA = a.noTime and hugeMath or a.expirationTime
		-- local compB = b.noTime and hugeMath or b.expirationTime 
		-- return compA > compB 
	end,
	["TIME_REMAINING_REVERSE"] = function(a, b)
		-- local auraA = C_UnitAuras.GetAuraDataByAuraInstanceID(a.sourceUnit, a.auraInstanceID)
		-- local auraB = C_UnitAuras.GetAuraDataByAuraInstanceID(b.sourceUnit, b.auraInstanceID)

		-- local compA = auraA and (auraA.duration == 0 and auraA.expirationTime == 0) and hugeMath or auraA.expirationTime
		-- local compB = auraB and (auraB.duration == 0 and auraB.expirationTime == 0) and hugeMath or auraB.expirationTime
		-- return compA < compB

		local compA = (a.duration == 0 and a.expirationTime == 0) and hugeMath or a.expirationTime
		local compB = (b.duration == 0 and b.expirationTime == 0) and hugeMath or b.expirationTime
		return compA < compB
		-- local compA = a.noTime and hugeMath or a.expirationTime
		-- local compB = b.noTime and hugeMath or b.expirationTime 
		-- return compA < compB 
	end,
	["TIME_DURATION"] = function(a, b)
		-- local auraA = C_UnitAuras.GetAuraDataByAuraInstanceID(a.sourceUnit, a.auraInstanceID)
		-- local auraB = C_UnitAuras.GetAuraDataByAuraInstanceID(b.sourceUnit, b.auraInstanceID)

		-- local compA = auraA and (auraA.duration == 0 and auraA.expirationTime == 0) and hugeMath or auraA.duration
		-- local compB = auraB and (auraB.duration == 0 and auraB.expirationTime == 0) and hugeMath or auraB.duration
		-- return compA > compB

		local compA = (a.duration == 0 and a.expirationTime == 0) and hugeMath or a.duration
		local compB = (b.duration == 0 and b.expirationTime == 0) and hugeMath or b.duration
		return compA > compB
		-- local compA = a.noTime and hugeMath or a.duration
		-- local compB = b.noTime and hugeMath or b.duration 
		-- return compA > compB 
	end,
	["TIME_DURATION_REVERSE"] = function(a, b)
		-- local compA = a.noTime and hugeMath or a.duration
		-- local compB = b.noTime and hugeMath or b.duration 
		-- return compA < compB 

		local compA = (a.duration == 0 and a.expirationTime == 0) and hugeMath or a.duration
		local compB = (b.duration == 0 and b.expirationTime == 0) and hugeMath or b.duration
		return compA < compB

		-- local auraA = C_UnitAuras.GetAuraDataByAuraInstanceID(a.sourceUnit, a.auraInstanceID)
		-- local auraB = C_UnitAuras.GetAuraDataByAuraInstanceID(b.sourceUnit, b.auraInstanceID)

		-- local compA = auraA and (auraA.duration == 0 and auraA.expirationTime == 0) and hugeMath or auraA.duration
		-- local compB = auraB and (auraB.duration == 0 and auraB.expirationTime == 0) and hugeMath or auraB.duration
		-- return compA < compB
	end,
	["NAME"] = function(a, b)

		local spellA = C_Spell:GetSpellInfo(a.spellId)
		local spellB = C_Spell:GetSpellInfo(b.spellId)

		if spellA and spellB then
			return spellA.name > spellB.name
		else
			return AuraUtil.DefaultAuraCompare(a, b)
		end

		-- local auraA = C_UnitAuras.GetAuraDataByAuraInstanceID(a.sourceUnit, a.auraInstanceID)
		-- local auraB = C_UnitAuras.GetAuraDataByAuraInstanceID(b.sourceUnit, b.auraInstanceID)

		-- if auraA and auraB then
		-- 	return auraA.name > auraB.name
		-- else
		-- 	return AuraUtil.DefaultAuraCompare(a, b)
		-- end
	end,
}

--[[
	OnUpdate version reworkd with C_Timer
]]--
-- local AuraBar_OnUpdate = function(self, elapsed)
-- 	self.expiration = self.expiration - elapsed;
	
-- 	-- if(self.nextUpdate > 0) then 
-- 	-- 	self.nextUpdate = self.nextUpdate - elapsed;
-- 	-- 	return;
-- 	-- end

-- 	if(self.expiration <= 0) then 
-- 		self:SetScript("OnUpdate", nil)
-- 		self.StatusBar.SpellTime:SetText('')
-- 		return;
-- 	end

	
-- 	self.StatusBar:SetValue(self.expiration)

-- 	local expires = self.expiration;
-- 	local calc, timeLeft = 0, 0;
-- 	if expires < 4 then
--         self.nextUpdate = 0.051
--         self.StatusBar.SpellTime:SetFormattedText("|cffff0000%.1f|r", expires)
--     elseif expires < 60 then 
--         self.nextUpdate = 0.51
--         self.StatusBar.SpellTime:SetFormattedText("|cffffff00%d|r", floor(expires)) 
--     elseif expires < 3600 then
--         timeLeft = ceil(expires / 60);
--         calc = floor((expires / 60) + .5);
--         self.nextUpdate = calc > 1 and ((expires - calc) * 29.5) or (expires - 59.5);
--         self.StatusBar.SpellTime:SetFormattedText("|cffffffff%dm|r", timeLeft)
--     elseif expires < 86400 then
--         timeLeft = ceil(expires / 3600);
--         calc = floor((expires / 3600) + .5);
--         self.nextUpdate = calc > 1 and ((expires - calc) * 1799.5) or (expires - 3570);
--         self.StatusBar.SpellTime:SetFormattedText("|cff66ffff%dh|r", timeLeft)
--     else
--         timeLeft = ceil(expires / 86400);
--         calc = floor((expires / 86400) + .5);
--         self.nextUpdate = calc > 1 and ((expires - calc) * 43199.5) or (expires - 85680);
--         if(timeLeft > 7) then
--             self.StatusBar.SpellTime:SetFormattedText("|cff6666ff%s|r", "long")
--         else
--             self.StatusBar.SpellTime:SetFormattedText("|cff6666ff%dd|r", timeLeft)
--         end
--     end
-- end

local function AuraBar_OnUpdate(self)
	self.expiration = self.expiration - (self.elapsed or 0);

	if(self.expiration <= 0) then 
		self.shouldBeUpdated = false
		self.elapsed = nil
		self.StatusBar.SpellTime:SetText('')
		return;
	end

	self.StatusBar:SetValue(self.expiration)

	self.elapsed = 0.1
	C_Timer.After( self.elapsed, function ()
		AuraBar_OnUpdate(self)
	end)

	local expires = self.expiration;
	local calc, timeLeft = 0, 0;
	if expires < 4 then

        self.StatusBar.SpellTime:SetFormattedText("|cffff0000%.1f|r", expires)
    elseif expires < 60 then 
        self.StatusBar.SpellTime:SetFormattedText("|cffffff00%d|r", floor(expires)) 
    elseif expires < 3600 then
        timeLeft = ceil(expires / 60);
        calc = floor((expires / 60) + .5);
        self.StatusBar.SpellTime:SetFormattedText("|cffffffff%dm|r", timeLeft)
    elseif expires < 86400 then
        timeLeft = ceil(expires / 3600);
        calc = floor((expires / 3600) + .5);
        self.StatusBar.SpellTime:SetFormattedText("|cff66ffff%dh|r", timeLeft)
    else
        timeLeft = ceil(expires / 86400);
        calc = floor((expires / 86400) + .5);
        if(timeLeft > 7) then
            self.StatusBar.SpellTime:SetFormattedText("|cff6666ff%s|r", "long")
        else
            self.StatusBar.SpellTime:SetFormattedText("|cff6666ff%dd|r", timeLeft)
        end
    end
end

--[[
	OnUpdate version reworkd with C_Timer
]]--
-- local AuraIcon_OnUpdate = function(self, elapsed)
-- 	self.expiration = self.expiration - elapsed;
	
-- 	if(self.nextUpdate > 0) then 
-- 		self.nextUpdate = self.nextUpdate - elapsed;
-- 		return;
-- 	end

-- 	if(self.expiration <= 0) then 
-- 		self:SetScript("OnUpdate", nil)
-- 		self.Text:SetText('')
-- 		return;
-- 	end

-- 	local expires = self.expiration;
-- 	local calc, timeLeft = 0, 0;
-- 	if expires < 4 then
--         self.nextUpdate = 0.051
--         self.Text:SetFormattedText("|cffff0000%.1f|r", expires)
--     elseif expires < 60 then 
--         self.nextUpdate = 0.51
--         self.Text:SetFormattedText("|cffffff00%d|r", floor(expires)) 
--     elseif expires < 3600 then
--         timeLeft = ceil(expires / 60);
--         calc = floor((expires / 60) + .5);
--         self.nextUpdate = calc > 1 and ((expires - calc) * 29.5) or (expires - 59.5);
--         self.Text:SetFormattedText("|cffffffff%dm|r", timeLeft)
--     elseif expires < 86400 then
--         timeLeft = ceil(expires / 3600);
--         calc = floor((expires / 3600) + .5);
--         self.nextUpdate = calc > 1 and ((expires - calc) * 1799.5) or (expires - 3570);
--         self.Text:SetFormattedText("|cff66ffff%dh|r", timeLeft)
--     else
--         timeLeft = ceil(expires / 86400);
--         calc = floor((expires / 86400) + .5);
--         self.nextUpdate = calc > 1 and ((expires - calc) * 43199.5) or (expires - 85680);
--         if(timeLeft > 7) then
--             self.Text:SetFormattedText("|cff6666ff%s|r", "long")
--         else
--             self.Text:SetFormattedText("|cff6666ff%dd|r", timeLeft)
--         end
--     end
-- end

local function AuraIcon_OnUpdate(self)
	self.expiration = self.expiration - (self.elapsed or 0);
	

	if(self.expiration <= 0) then 
		self.shouldBeUpdated = false
		self.elapsed = nil
		self.Text:SetText('')
		return;
	end

	self.elapsed = 0.1
	C_Timer.After( self.elapsed, function ()
		AuraIcon_OnUpdate(self)
	end)

	local expires = self.expiration;
	local calc, timeLeft = 0, 0;
	if expires < 4 then
        self.Text:SetFormattedText("|cffff0000%.1f|r", expires)
    elseif expires < 60 then 
        self.Text:SetFormattedText("|cffffff00%d|r", floor(expires)) 
    elseif expires < 3600 then
        timeLeft = ceil(expires / 60);
        calc = floor((expires / 60) + .5);
        self.Text:SetFormattedText("|cffffffff%dm|r", timeLeft)
    elseif expires < 86400 then
        timeLeft = ceil(expires / 3600);
        calc = floor((expires / 3600) + .5);
        self.Text:SetFormattedText("|cff66ffff%dh|r", timeLeft)
    else
        timeLeft = ceil(expires / 86400);
        calc = floor((expires / 86400) + .5);
        if(timeLeft > 7) then
            self.Text:SetFormattedText("|cff6666ff%s|r", "long")
        else
            self.Text:SetFormattedText("|cff6666ff%dd|r", timeLeft)
        end
    end
end

local function PostUpdateBar(self, button, unit, data, position)
	local timeNow = GetTime()
	local noTime = (data.duration == 0 and data.expirationTime == 0)

	if noTime then
		button.shouldBeUpdated = false
		-- button:SetScript('OnUpdate', nil)
		button.StatusBar:SetMinMaxValues(0,1)
		button.StatusBar:SetValue(1)
		button.StatusBar.SpellTime:SetText('')
	elseif (not button.shouldBeUpdated) then
		button.shouldBeUpdated = true
		button.expirationTime = data.expirationTime
		button.expiration = data.expirationTime - timeNow
		-- button.nextUpdate = -1
		AuraBar_OnUpdate(button)
		-- button:SetScript('OnUpdate', AuraBar_OnUpdate)
	elseif(button.expirationTime ~= data.expirationTime) then
		button.expirationTime = data.expirationTime
		button.expiration = data.expirationTime - timeNow
		-- button.nextUpdate = -1
	end

	-- if noTime then
	-- 	button:SetScript('OnUpdate', nil)
	-- 	button.StatusBar:SetMinMaxValues(0,1)
	-- 	button.StatusBar:SetValue(1)
	-- 	button.StatusBar.SpellTime:SetText('')
	-- elseif(not button:GetScript('OnUpdate')) then
	-- 	button.expirationTime = data.expirationTime
	-- 	button.expiration = data.expirationTime - timeNow
	-- 	button.nextUpdate = -1
	-- 	button:SetScript('OnUpdate', AuraBar_OnUpdate)
	-- elseif(button.expirationTime ~= data.expirationTime) then
	-- 	button.expirationTime = data.expirationTime
	-- 	button.expiration = data.expirationTime - timeNow
	-- 	button.nextUpdate = -1
	-- end

	if (data.isHarmful) then
		button.StatusBar:SetStatusBarColor(.9, 0, 0)
	else
		button.StatusBar:SetStatusBarColor(.2, .6, 1)
	end
end

local function PostUpdateButton(self, button, unit, data, position)
	
	local timeNow = GetTime()
	local noTime = (data.duration == 0 and data.expirationTime == 0)
	local isFriend = (UnitIsFriend('player', unit) == 1) and true or false;

	if(noTime) then
		-- button:SetScript('OnUpdate', nil)
		button.shouldBeUpdated = false
		button.Text:SetText('')
	-- elseif(not button:GetScript('OnUpdate')) then
	elseif (not button.shouldBeUpdated) then
		button.shouldBeUpdated = true
		button.expirationTime = data.expirationTime
		button.expiration = data.expirationTime - timeNow
		-- button.nextUpdate = -1
		-- button:SetScript('OnUpdate', AuraIcon_OnUpdate)
		AuraIcon_OnUpdate(button)
	elseif(button.expirationTime ~= data.expirationTime) then
		button.expirationTime = data.expirationTime
		button.expiration = data.expirationTime - timeNow
		-- button.nextUpdate = -1
	end

	if data.isHarmful then
		local color = DebuffTypeColor[data.dispelName] or DebuffTypeColor.none

		if((not isFriend) and data.sourceUnit and (data.sourceUnit ~= "player") and (data.sourceUnit ~= "vehicle")) then
			button:SetBackdropBorderColor(0.9, 0.1, 0.1, 1)
			button.bg:SetBackdropColor(1, 0, 0, 1)
			button.Icon:SetDesaturated((unit and not unit:find('arena%d')) and true or false)
		else
			button:SetBackdropBorderColor(color.r * 0.6, color.g * 0.6, color.b * 0.6, 1)
			button.bg:SetBackdropColor(color.r, color.g, color.b, 1)
			button.Icon:SetDesaturated(false)
		end

		button.bg:SetBackdropBorderColor(0, 0, 0, 1)

		if(self.showType and button.overlay) then
			button.Overlay:SetVertexColor(color.r, color.g, color.b)
			button.Overlay:Show()
		else
			button.Overlay:Hide()
		end
	else
		if((data.isStealable) and (not isFriend)) then
			button:SetBackdropBorderColor(0.92, 0.91, 0.55, 1)
			button.bg:SetBackdropColor(1, 1, 0.5, 1)
			button.bg:SetBackdropBorderColor(0, 0, 0, 1)
		else
			button:SetBackdropBorderColor(0, 0, 0, 1)
			button.bg:SetBackdropColor(0, 0, 0, 0)
			button.bg:SetBackdropBorderColor(0, 0, 0, 0)		
		end	
	end

end

function MOD:CreateAuraFrames(frame, unit, barsAvailable)
	-- local buffs = CreateFrame("Frame", frame:GetName().."Buffs", frame)
	-- buffs.___unitkey = unit;
	-- buffs.___aurakey = "buffs";
	-- buffs.CreateAuraIcon = CreateAuraIcon;
	-- if(BoolFilters[unit]) then
	-- 	buffs.CustomFilter = CommonAuraFilter;
	-- else
	-- 	buffs.CustomFilter = DetailedAuraFilter;
	-- end
	-- buffs:SetFrameLevel(10)
	-- frame.SV_Buffs = buffs

	-- local debuffs = CreateFrame("Frame", frame:GetName().."Debuffs", frame)
	-- debuffs.___unitkey = unit;
	-- debuffs.___aurakey = "debuffs";
	-- debuffs.CreateAuraIcon = CreateAuraIcon;
	-- if(BoolFilters[unit]) then
	-- 	debuffs.CustomFilter = CommonAuraFilter;
	-- else
	-- 	debuffs.CustomFilter = DetailedAuraFilter;
	-- end
	-- debuffs:SetFrameLevel(10)
	-- frame.SV_Debuffs = debuffs

	local buffs = CreateFrame("Frame", frame:GetName().."Buffs", frame)
	buffs:SetSize(210, 100)
	buffs.___unitkey = unit;
	buffs.___aurakey = "buffs";
	buffs.CreateButton = CreateAuraButton
	buffs.PostUpdateButton = PostUpdateButton
	if(BoolFilters[unit]) then
		buffs.FilterAura = CommonAuraFilter;
	else
		buffs.FilterAura = DetailedAuraFilter;
	end
	buffs.SetSorting = function(self, sorting)
		if(sorting) then
			if((type(sorting) == "string") and SORTING_METHODS[sorting]) then 
				self.SortBuffs = SORTING_METHODS[sorting];
			else
				self.SortBuffs = SORTING_METHODS["TIME_REMAINING"];
			end
		end 
	end

	buffs:SetFrameLevel(10)
	frame.Buffs = buffs

	local debuffs = CreateFrame("Frame", frame:GetName().."Debuffs", frame)
	debuffs:SetSize(210, 100)
	debuffs.___unitkey = unit;
	debuffs.___aurakey = "debuffs";
	debuffs.CreateButton = CreateAuraButton
	debuffs.PostUpdateButton = PostUpdateButton
	if(BoolFilters[unit]) then
		debuffs.FilterAura = CommonAuraFilter;
	else
		debuffs.FilterAura = DetailedAuraFilter;
	end
	debuffs.SetSorting = function(self, sorting)
		if(sorting) then
			if((type(sorting) == "string") and SORTING_METHODS[sorting]) then 
				self.SortDebuffs = SORTING_METHODS[sorting];
			else
				self.SortDebuffs = SORTING_METHODS["TIME_REMAINING"];
			end
		end 
	end

	debuffs:SetFrameLevel(10)
	frame.Debuffs = debuffs

	if (barsAvailable) then
		frame.AuraBarsAvailable = true;
		local auraBars = CreateFrame("Frame", frame:GetName().."AuraBars", frame)
		auraBars:SetSize(210, 100)
		auraBars.___unitkey = unit;
		auraBars.___aurakey = "auras";
		auraBars.PostUpdateBar = PostUpdateBar
		if(BoolFilters[unit]) then
			auraBars.FilterAura = CommonAuraFilter;
		else
			auraBars.FilterAura = DetailedAuraFilter;
		end
		auraBars.SetSorting = function(self, sorting)
			if(sorting) then
				if((type(sorting) == "string") and SORTING_METHODS[sorting]) then 
					self.SortAuraBars = SORTING_METHODS[sorting];
				else
					self.SortAuraBars = SORTING_METHODS["TIME_REMAINING"];
				end
			end 
		end
		frame.AuraBars = auraBars
	end

	-- if(barsAvailable) then
	-- 	frame.AuraBarsAvailable = true;
	-- 	buffs.PostCreateBar = PostCreateAuraBars;
	-- 	buffs.PostBarUpdate = PostBarUpdate;
	-- 	debuffs.PostCreateBar = PostCreateAuraBars;
	-- 	debuffs.PostBarUpdate = PostBarUpdate;
	-- end
end
--[[
##########################################################
AURA WATCH
##########################################################
]]--
local PreForcedUpdate = function(self)
	local unit = self.___key;
	if not SV.db.UnitFrames[unit] then return end
	local db = SV.db.UnitFrames[unit].auraWatch;
	if not db then return end;
	if(unit == "pet" or unit == "raidpet") then
		self.watchFilter = SV.db.Filters.PetBuffWatch
	else
		self.watchFilter = SV.db.Filters.BuffWatch
	end
	self.watchEnabled = db.enable;
	self.watchSize = db.size;
end

function MOD:CreateAuraWatch(frame, unit)
	local watch = CreateFrame("Frame", nil, frame)
	watch:SetFrameLevel(frame:GetFrameLevel() + 25)
	watch:SetAllPoints(frame);
	watch.___key = unit;
	watch.watchEnabled = true;
	watch.presentAlpha = 1;
	watch.missingAlpha = 0;
	if(unit == "pet" or unit == "raidpet") then
		watch.watchFilter = SV.db.Filters.PetBuffWatch
	else
		watch.watchFilter = SV.db.Filters.BuffWatch
	end

	watch.PreForcedUpdate = PreForcedUpdate
	return watch
end
--[[
##########################################################
CUSTOM EVENT UPDATES
##########################################################
]]--
local function UpdateAuraMediaLocals()
	BUFFS_COLOR = oUF_SVUI.colors.buff_bars or DEFAULT_BUFFS_COLOR;
	DEBUFFS_COLOR = oUF_SVUI.colors.debuff_bars or DEFAULT_DEBUFFS_COLOR;
	AURA_STATUSBAR = LSM:Fetch("statusbar", SV.db.UnitFrames.auraBarStatusbar);
end
SV.Events:On("UNITFRAME_COLORS_UPDATED", UpdateAuraMediaLocals, true);

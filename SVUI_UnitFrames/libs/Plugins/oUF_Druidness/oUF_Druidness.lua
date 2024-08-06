if(select(2, UnitClass('player')) ~= 'DRUID') then return end
--GLOBAL NAMESPACE
local _G = _G;
--LUA
local unpack        = _G.unpack;
local select        = _G.select;
local assert        = _G.assert;
local error         = _G.error;
local print         = _G.print;
local pairs         = _G.pairs;
local next          = _G.next;
local tostring      = _G.tostring;
local type  		= _G.type;
--STRING
local string        = _G.string;
local format        = string.format;
--MATH
local math          = _G.math;
local floor         = math.floor
local ceil          = math.ceil
--TABLE
local table         = _G.table;
local wipe          = _G.wipe;
--BLIZZARD API
local BEAR_FORM       		= DRUID_BEAR_FORM;
local CAT_FORM 				= DRUID_CAT_FORM;
local SPELL_POWER_MANA      = SPELL_POWER_MANA;
local UnitClass         	= _G.UnitClass;
local UnitPower         	= _G.UnitPower;
local UnitReaction         	= _G.UnitReaction;
local UnitPowerMax         	= _G.UnitPowerMax;
local UnitIsPlayer      	= _G.UnitIsPlayer;
local UnitPlayerControlled  = _G.UnitPlayerControlled;
local GetShapeshiftFormID 	= _G.GetShapeshiftFormID;

local _, ns = ...
local oUF = ns.oUF or oUF

local ECLIPSE_BAR_SOLAR_BUFF_ID = 48517
local ECLIPSE_BAR_LUNAR_BUFF_ID = 48518
local MOONKIN_FORM = DRUID_MOONKIN_FORM_1
local ALERTED = false;
local TextColors = {
	[1]={1,0.1,0.1},
	[2]={1,0.5,0.1},
	[3]={1,1,0.1},
	[4]={0.5,1,0.1},
	[5]={0.1,1,0.1}
};

local UpdateAura = function(self, event, unit)
	if(unit and unit ~= "player") then return end
	local chicken = self.Druidness.Chicken
	if(not chicken) then return end
	
	local solar = C_UnitAuras.GetPlayerAuraBySpellID(ECLIPSE_BAR_SOLAR_BUFF_ID)
	local lunar = C_UnitAuras.GetPlayerAuraBySpellID(ECLIPSE_BAR_LUNAR_BUFF_ID)

	if solar and lunar then
		chicken.inEclipse = "both"
	elseif solar then
		chicken.inEclipse = "solar"
	elseif lunar then
		chicken.inEclipse = "lunar"
	else
		chicken.inEclipse = false
	end

	if(chicken.PostUpdateAura) then
		return chicken:PostUpdateAura()
	end
end

local ProxyShow = function(self)
	if(not self.isEnabled) then return end
	self:Show()
end

local function CatOverMana(mana, form)
	if UnitPower("player", Enum.PowerType.ComboPoints) > 0 then
		return form == CAT_FORM
	elseif form and mana.ManaBar:GetValue() < UnitPowerMax('player', Enum.PowerType.Mana) then
		return false
	else
		return form == CAT_FORM or form == BEAR_FORM
	end
end

local UpdateVisibility = function(self, event)
	local bar = self.Druidness
	local chicken = bar.Chicken
	local cat = bar.Cat
	local mana = bar.Mana
	local form = GetShapeshiftFormID()

	local specID = GetSpecializationInfo(GetSpecialization())

	if specID == 102 then --balance
		--always show since power bar will never change show mana even out of moonkin form
		mana:Show()
		cat:Hide()
	elseif specID == 103 or specID == 104 then --feral and guardian
		if (CatOverMana(mana, form)) then
			cat:Show()
			mana:Hide()
		else
			mana:Show()
			cat:Hide()
		end
	elseif form == CAT_FORM or form == BEAR_FORM  then
		mana:Show()
	else
		mana:Hide()
	end

	-- if form then
	-- 	if form == MOONKIN_FORM then
	-- 		mana:Show()
	-- 		cat:Hide()
	-- 	elseif form == CAT_FORM then
	-- 		if mana.ManaBar:GetValue() < UnitPowerMax('player', Enum.PowerType.Mana) then
	-- 			mana:Show()
	-- 			cat:Hide()
	-- 		else
	-- 			cat:Show()
	-- 			mana:Hide()
	-- 		end
	-- 	end
	-- else
	-- 	local specID = GetSpecializationInfo(GetSpecialization())
	-- 	if specID == 102 then --balance
	-- 		mana:Show()
	-- 	else
	-- 		mana:Hide()
	-- 	end
	-- end

	-- if(form) then
	-- 	if form == MOONKIN_FORM then
	-- 		chicken:Show()
	-- 		mana:Hide()
	-- 		cat:Hide()
	-- 		self:RegisterEvent('UNIT_AURA', UpdateAura)
	-- 	else
	-- 		chicken:Hide()
	-- 		self:UnregisterEvent('UNIT_AURA', UpdateAura)

	-- 		if (form == BEAR_FORM or form == CAT_FORM) then
	-- 			if(CatOverMana(mana, form)) then
	-- 				cat:Show()
	-- 			else
	-- 				cat:Hide()
	-- 			end
	-- 		else
	-- 			cat:Hide()
	-- 			mana:Hide()
	-- 		end
	-- 	end

	-- 	if form == CAT_FORM then
	-- 		mana:Hide()
	-- 		cat:ProxyShow()
	-- 	else
	-- 		cat:Hide()
	-- 	end
	-- 	-- if (form == BEAR_FORM or form == CAT_FORM) then
	-- 	-- 	if(CatOverMana(mana, form) or GetSpecializationInfo(GetSpecialization()) == 103) then
	-- 	-- 		cat:ProxyShow()
	-- 	-- 	else
	-- 	-- 		if(GetSpecializationInfo(GetSpecialization()) == 103) then
	-- 	-- 			cat:ProxyShow()
	-- 	-- 		else
	-- 	-- 			cat:Hide()
	-- 	-- 		end
	-- 	-- 	end
	-- 	-- else
	-- 	-- 	if(GetSpecializationInfo(GetSpecialization()) == 103) then
	-- 	-- 		cat:ProxyShow()
	-- 	-- 	else
	-- 	-- 		cat:Hide()
	-- 	-- 	end
	-- 	-- 	mana:Hide()
	-- 	-- end
	-- else
	-- 	mana:Hide()
	-- 	local specID = GetSpecializationInfo(GetSpecialization())
	-- 	if specID == 102 then --balance
	-- 		chicken:Show()
	-- 		self:RegisterEvent('UNIT_AURA', UpdateAura)
	-- 	else
	-- 		chicken:Hide()
	-- 		self:UnregisterEvent('UNIT_AURA', UpdateAura)
	-- 	end
		
	-- 	if specID == 103 then --feral
	-- 		cat:ProxyShow()
	-- 	else
	-- 		cat:Hide()
	-- 	end
	-- end
end

local UpdatePower = function(self, event, unit, powerType)
	if(self.unit ~= unit) then return end
	local bar = self.Druidness

	if(bar.Mana and bar.Mana.ManaBar) then
		local mana = bar.Mana
		if(mana.PreUpdate) then
			mana:PreUpdate(unit)
		end
		local min, max = UnitPower('player', Enum.PowerType.Mana), UnitPowerMax('player', Enum.PowerType.Mana)

		mana.ManaBar:SetMinMaxValues(0, max)
		mana.ManaBar:SetValue(min)

		local r, g, b, t
		if(mana.colorPower) then
			t = self.colors.power["MANA"]
		elseif(mana.colorClass and UnitIsPlayer(unit)) or
			(mana.colorClassNPC and not UnitIsPlayer(unit)) or
			(mana.colorClassPet and UnitPlayerControlled(unit) and not UnitIsPlayer(unit)) then
			local _, class = UnitClass(unit)
			t = self.colors.class[class]
		elseif(mana.colorReaction and UnitReaction(unit, 'player')) then
			t = self.colors.reaction[UnitReaction(unit, "player")]
		elseif(mana.colorSmooth) then
			r, g, b = self.ColorGradient(min / max, unpack(mana.smoothGradient or self.colors.smooth))
		end

		if(t) then
			r, g, b = t[1], t[2], t[3]
		end

		if(b) then
			mana.ManaBar:SetStatusBarColor(r, g, b)

			local bg = mana.bg
			if(bg) then
				local mu = bg.multiplier or 1
				bg:SetVertexColor(r * mu, g * mu, b * mu)
			end
		end

		if(mana.PostUpdatePower) then
			mana:PostUpdatePower(unit, min, max)
		end
	end

	UpdateVisibility(self)
end

local UpdateComboPoints = function(self, event, unit)
	if(unit == 'pet') then return end
	local bar = self.Druidness;
	local cpoints = bar.Cat;

	if(bar.PreUpdate) then
		bar:PreUpdate()
	end

	local current = 0
	if(UnitHasVehicleUI'player') then
		current = UnitPower("vehicle", Enum.PowerType.ComboPoints);
	else
		current = UnitPower("player", Enum.PowerType.ComboPoints);
	end
	if(cpoints) then
		local MAX_COMBO_POINTS = UnitPowerMax("player", Enum.PowerType.ComboPoints);
		for i=1, MAX_COMBO_POINTS do
			if(i <= current) then
				if cpoints[i] then
					cpoints[i]:Show()
					if(bar.PointShow) then
						bar.PointShow(cpoints[i])
					end
				end
			else
				if cpoints[i] then
					cpoints[i]:Hide()
					if(bar.PointHide) then
						bar.PointHide(cpoints[i], i)
					end
				end
			end
		end
	end

	if(bar.PostUpdateComboPoints) then
		return bar:PostUpdateComboPoints(current)
	end
end

local Update = function(self, ...)
	UpdatePower(self, ...)
	UpdateAura(self, ...)
	UpdateComboPoints(self, ...)
	return UpdateVisibility(self, ...)
end

local ForceUpdate = function(element)
	return Update(element.__owner, 'ForceUpdate', element.__owner.unit, 'LUNAR_POWER')
end

local function Enable(self)
	local bar = self.Druidness

	if(bar) then
		local mana = bar.Mana;
		local cat = bar.Cat;
		-- local chicken = bar.Chicken
		-- chicken.__owner = self
		-- chicken.ForceUpdate = ForceUpdate

		-- if chicken.AstralBar and chicken.AstralBar:IsObjectType('StatusBar') and not chicken.AstralBar:GetStatusBarTexture() then
		-- 	chicken.AstralBar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
		-- end

		mana.ProxyShow = ProxyShow;
		cat.ProxyShow = ProxyShow;

		self:RegisterEvent('UNIT_POWER_FREQUENT', UpdatePower)
		-- self:RegisterEvent('PLAYER_TALENT_UPDATE', UpdateVisibility, true)
		self:RegisterEvent('UPDATE_SHAPESHIFT_FORM', UpdateVisibility, true)
		self:RegisterEvent('PLAYER_TARGET_CHANGED', UpdateComboPoints, true)
		self:RegisterEvent('UNIT_DISPLAYPOWER', UpdateComboPoints, true)
		self:RegisterEvent('UNIT_MAXPOWER', UpdateComboPoints, true)
		self:RegisterUnitEvent('UNIT_DISPLAYPOWER', "player")
		self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
		self:RegisterUnitEvent("UNIT_MAXPOWER", "player")

		self:SetScript("OnUpdate", UpdateComboPoints)

		-- ForceUpdate(chicken)

		UpdateVisibility(self)
		return true
	end
end

local function Disable(self)
	local bar = self.Druidness

	if(bar) then
		-- local chicken = bar.Chicken
		local mana = bar.Mana
		-- chicken:Hide()
		mana:Hide()

		self:RegisterEvent('UNIT_POWER_FREQUENT', UpdatePower)
		-- self:UnregisterEvent('PLAYER_TALENT_UPDATE', UpdateVisibility)
		self:UnregisterEvent('UPDATE_SHAPESHIFT_FORM', UpdateVisibility)
		self:UnregisterEvent('UNIT_COMBO_POINTS', UpdateComboPoints)
		self:UnregisterEvent('PLAYER_TARGET_CHANGED', UpdateComboPoints)
		self:UnregisterEvent('UNIT_DISPLAYPOWER', UpdateComboPoints)
		self:UnregisterEvent('UNIT_MAXPOWER', UpdateComboPoints)
	end
end

oUF:AddElement('Druidness', Update, Enable, Disable)

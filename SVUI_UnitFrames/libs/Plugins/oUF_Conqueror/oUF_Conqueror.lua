if(select(2, UnitClass('player')) ~= 'WARRIOR') then return end
--GLOBAL NAMESPACE
local _G = _G;
--LUA
local unpack        = _G.unpack;
local select        = _G.select;
local assert        = _G.assert;
--BLIZZARD API
-- local UnitDebuff      	= _G.UnitDebuff;
local UnitBuff			= C_UnitAuras.GetBuffDataByIndex

local parent, ns = ...
local oUF = ns.oUF

local ENRAGE_ID = 184362 --12880;
local IGNORE_ID = 190456
local IGNORE_AMOUNT = 0

local playerGUID

local function TruncateString(value)
	if value >= 1e9 then
		return ("%.1fb"):format(value / 1e9):gsub("%.?0 + ([kmb])$", "%1")
	elseif value >= 1e6 then
		return ("%.1fm"):format(value / 1e6):gsub("%.?0 + ([kmb])$", "%1")
	elseif value >= 1e3 or value <= -1e3 then
		return ("%.1fk"):format(value / 1e3):gsub("%.?0 + ([kmb])$", "%1")
	else
		return value
	end
end

local ResetConqueror = function(self)
	local bar = self.Conqueror;
	local enrage = bar.Enrage;
	local statusBar = enrage.bar;
	IGNORE_AMOUNT = 0;

	statusBar.start = 0
	statusBar.duration = 0
	statusBar:SetValue(0)
	enrage:Hide()
	statusBar:SetScript("OnUpdate", nil)
end

local GetResources = {
	[1] = function(self, event, ...)
		return 0, 0, true
	end,
	[2] = function(self, event, ...)
		if(event == 'UNIT_AURA') then
			local unit = ...;
			if(unit == 'player') then
				local enrage = C_UnitAuras.GetPlayerAuraBySpellID(ENRAGE_ID)
				if enrage then
					return floor (enrage.expirationTime), enrage.duration
				end
			end
		end
		return 0, 0, true;
	end,
	[3] = function(self, event, ...)
		if(event == 'COMBAT_LOG_EVENT_UNFILTERED') then
			local _, eventType, _, srcGUID, _, _, _, destGUID, _, _, _, spellID, _, _, _, amount = CombatLogGetCurrentEventInfo()
			if(srcGUID == playerGUID) then
				if (eventType:find("_AURA_APPLIED") or eventType:find("_AURA_REFRESH")) and spellID == IGNORE_ID then
					IGNORE_AMOUNT = amount
				elseif eventType:find("_AURA_REMOVED") and spellID == IGNORE_ID then
					IGNORE_AMOUNT = 0
				end
			end
		elseif(event == 'UNIT_AURA') then
			local unit = ...;
			if(unit == 'player') then
				local IP = C_UnitAuras.GetPlayerAuraBySpellID(IGNORE_ID)
				if IP then
					return floor (IP.expirationTime), IP.duration
				end
			end
		end
		return 0, 0, true;
	end,
}

local function getEnrageAmount()

	local enrage = C_UnitAuras.GetPlayerAuraBySpellID(ENRAGE_ID)
	if enrage then
		return floor (enrage.expirationTime), enrage.duration
	end

	-- for i = 1, 40 do
	-- 	-- local _, _, _, count, _, duration, expires, _, _, _, spellID = UnitBuff("player", i)
	-- 	local auraData = UnitBuff("player", i)
	-- 	if not auraData then break end
	-- 	local count = auraData.applications
	-- 	local duration = auraData.duration
	-- 	local expires = auraData.expirationTime
	-- 	local spellID = auraData.spellId
	-- 	if(spellID and spellID == ENRAGE_ID) then
	-- 		return floor(expires), duration
	-- 	end
	-- end
	return 0,0
end

local function getIgnorePainAmount(self, event, ...)
	if(event == 'COMBAT_LOG_EVENT_UNFILTERED') then
		local _, eventType, _, srcGUID, _, _, _, destGUID, _, _, _, spellID, _, _, amount = CombatLogGetCurrentEventInfo()
		if(srcGUID == playerGUID) then
			if spellID == IGNORE_ID then
				print(eventType, amount)
			end
			if(eventType:find("_DAMAGE")) then
				if(spellID == IGNITE_ID) then
					DAMAGETOTAL = amount
				elseif(spellID == COMBUSTION_ID) then
					DAMAGETOTAL = 0
				end
			end
		end
	elseif(event == 'UNIT_AURA') then
		local unit = ...;
		if(unit == 'player') then
			local IP = C_UnitAuras.GetPlayerAuraBySpellID(IGNORE_ID)
			if IP then
				return floor (IP.expirationTime), IP.duration
			end
		end
	end
end

local BarOnUpdate = function(self, elapsed)
	if not self.duration then return end
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed >= 0.5 then
		local timeLeft = (self.duration - GetTime())
		if timeLeft > 0 then
			self:SetValue(timeLeft)
		else
			self.start = nil
			self.duration = nil
			self:SetValue(0)
			self:Hide()
			self:SetScript("OnUpdate", nil)
		end
	end		
end

local IgnoreOnUpdate = function(self, elapsed)
	if not self.duration then return end
	self.elapsed = (self.elapsed or 0) + elapsed
	-- if self.elapsed >= 0.5 then
		local timeLeft = (self.duration - self.elapsed)
		if timeLeft > 0 then
			self:SetValue(timeLeft)
			
			self.text:SetText(("%s"):format(TruncateString(IGNORE_AMOUNT)))
		else
			IGNORE_AMOUNT = 0;
			self.start = 0;
			self.duration = 5;
			self.elapsed = 0;
			self:SetValue(0);
			self.text:SetText('0')
			self:SetScript("OnUpdate", nil);
			self:FadeOut();
		end
	-- end
end

local EnrageOnUpdate = function(self, elapsed)
	if not self.duration then return end
	self.elapsed = (self.elapsed or 0) + elapsed
	-- if self.elapsed >= 0.5 then
		local timeLeft = (self.duration - self.elapsed)
		if timeLeft > 0 then
			self:SetValue(timeLeft)
			self.text:SetText(("%.1f"):format(timeLeft))
		else
			self.start = 0;
			self.duration = 0;
			self.elapsed = 0;
			self:SetValue(0);
			self.text:SetText('')
			self:SetScript("OnUpdate", nil);
			self:FadeOut();
		end
	-- end		
end

local Update = function(self, event, ...)
	local bar = self.Conqueror
	local spec = bar.CurrentSpec;
	if(not spec) then return end

	if(bar.PreUpdate) then bar:PreUpdate(event) end

	local start, duration, reset = GetResources[spec](self, event, ...)

	if not reset then
		local enrage = bar.Enrage
		local statusBar = enrage.bar
		if not enrage:IsShown() then enrage:Show() end
		if duration and start and (start > statusBar.start) then
			statusBar.start = start
			statusBar.duration = duration
			statusBar.elapsed = 0
			statusBar:SetMinMaxValues(0, duration)
			statusBar:SetValue(duration)
			if spec == 2 then
				statusBar:SetScript("OnUpdate", EnrageOnUpdate)
			else
				statusBar:SetScript("OnUpdate", IgnoreOnUpdate)
			end
			statusBar:FadeIn()
		end	
	end

	
	-- local spec = GetSpecialization()
	-- if not playerGUID then playerGUID = UnitGUID("player") end



	-- if((not bar.CurrentSpec) or (bar.CurrentSpec ~= spec)) then
	-- 	if spec then
	-- 		bar.CurrentSpec = spec
	-- 		if spec == 3 then
	-- 			self:RegisterEvent('UNIT_AURA', getIgnorePainAmount, true)
	-- 			self:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED', getIgnorePainAmount, true)
	-- 		elseif spec == 2 then
	-- 			self:RegisterEvent('UNIT_AURA', getEnrageAmount, true)
	-- 			self:UnregisterEvent('COMBAT_LOG_EVENT_UNFILTERED', getIgnorePainAmount, true)
	-- 		end
	-- 	end
	-- end

	-- if(enrage:IsShown()) then
	-- 	local start, duration = getEnrageAmount()
	-- 	if(duration and start and (start ~= enrage.start)) then
	-- 		enrage.bar:SetMinMaxValues(0, duration)
	-- 		enrage.bar:SetValue(duration)

	-- 		enrage.elapsed = 0;
	-- 		enrage.start = start
	-- 		enrage.duration = duration
	-- 		enrage:SetScript('OnUpdate', EnrageOnUpdate)
	-- 		enrage:FadeIn();
	-- 	end
	-- end
	
	if(bar.PostUpdate) then
		return bar:PostUpdate(event)
	end
end

local Proxy = function(self, ...)
	local bar = self.Conqueror
	local spec = GetSpecialization()
	if(not playerGUID) then
		playerGUID = UnitGUID('player')
	end
	if((not bar.CurrentSpec) or (bar.CurrentSpec ~= spec)) then
		ResetConqueror(self);
		if(spec) then
			bar.CurrentSpec = spec;
			if(spec == 3) then
				if(not bar.Enrage:IsShown()) then 
					bar.Enrage:Show()
				end
				self:RegisterEvent('UNIT_AURA', Update)
				self:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED', Update, true)
				--print("Switch To Protec")
			elseif(spec == 2) then
				self:RegisterEvent('UNIT_AURA', Update)
				self:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED', Update, true)
				if(not bar.Enrage:IsShown()) then 
					bar.Enrage:Show()
				end
				bar.Enrage.bar:SetValue(0)
				--print("Switch To Fury")
			-- elseif(spec == 1) then
			-- 	self:RegisterEvent('UNIT_AURA', Update)
			-- 	self:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED', Update, true)
			-- 	--print("Switch To Arm")
			end
			if(bar.PostTalentUpdate) then bar:PostTalentUpdate(spec) end
		else
			self:UnregisterEvent('UNIT_AURA', Update)
			self:UnregisterEvent('COMBAT_LOG_EVENT_UNFILTERED', Update)
		end
	end
	return Update(self, ...)
end

local Path = function(self, ...)
	return (self.Conqueror.Override or Proxy)(self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, 'ForceUpdate')
end

local Enable = function(self)
	local bar = self.Conqueror

	if(bar) then
		bar.__owner = self
		bar.ForceUpdate = ForceUpdate

		self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", Path)
		self:RegisterEvent("PLAYER_ENTERING_WORLD", Path)

		local enrage = bar.Enrage;
		if(enrage.bar:IsObjectType'Texture' and not enrage.bar:GetTexture()) then
			enrage.bar:SetTexture[[Interface\TargetingFrame\UI-StatusBar]]
		end
		enrage.bar:SetMinMaxValues(0, 100)
		enrage.bar:SetValue(0)
		enrage:FadeOut()

		return true
	end
end

local Disable = function(self)
	local bar = self.Conqueror

	if (bar) then
		self:UnregisterEvent('UNIT_AURA', Path)
		self:UnregisterEvent("PLAYER_SPECIALIZATION_CHANGED", Path)
		self:UnregisterEvent("PLAYER_ENTERING_WORLD", Path)

		bar:Hide()
	end
end

oUF:AddElement('Conqueror', Path, Enable, Disable)

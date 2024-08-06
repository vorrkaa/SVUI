--GLOBAL NAMESPACE
local _G = _G;
--LUA
local unpack        = unpack;
local select        = _G.select;
local assert        = _G.assert;
local type         	= _G.type;
--BLIZZARD API
local GetTime       		= _G.GetTime;
local GetSpecialization 	= _G.GetSpecialization;
local GetSpellInfo			= C_Spell.GetSpellInfo
local GetSpellCooldown		= C_Spell.GetSpellCooldown
local GetSpellBaseCooldown = GetSpellBaseCooldown

if select(2, UnitClass('player')) ~= "HUNTER" then return end

local _, ns = ...
local oUF = oUF or ns.oUF
if not oUF then return end

local EXPLOSIVE_TRAP_ID = 236776
local IMPLOSIVE_TRAP_ID = 462031

local TRAP_MASTERY_ID = 63458;
local TRAP_MASTERY = IsSpellKnown(TRAP_MASTERY_ID);
local ENHANCED_TRAPS_ID = 157751;
local ENHANCED_TRAPS = IsSpellKnown(ENHANCED_TRAPS_ID);

local IMPROVED_TRAPS_ID = 343247;
local IMPROVED_TRAPS = IsPlayerSpell(ENHANCED_TRAPS_ID);

local FIRE_TRAP = GetSpellInfo(236776) or GetSpellInfo(462031)
local FIRE_TRAP_NAME = FIRE_TRAP.name
--local FIRE_TRAP = GetSpellInfo(13813);
local FROST_TRAP = GetSpellInfo(187650).name;
local TAR_TRAP = GetSpellInfo(187698).name;
--local SNAKE_TRAP, SNAKE_RANK, SNAKE_ICON = GetSpellInfo(34600);

local FIRE_COLOR = { 1, 0.25, 0 };
local FROST_COLOR = { 0.5, 1, 1 };
--local ICE_COLOR = {0.1,0.9,1};
-- local TAR_COLOR = { 0, 0, 0 };
local TAR_COLOR = { 0.1, 0.9, 1 };
-- local SNAKE_COLOR = {0.2,0.8,0};
--/script print(IsSpellKnown(34600))
--/script print(IsSpellKnown(13809))
local TRAP_IDS = { 
	[1] = FIRE_TRAP_NAME,
	[2] = TAR_TRAP,
	[3] = FROST_TRAP, 
};
local TRAP_COLORS = {
	[1] = FIRE_COLOR,
	[2] = TAR_COLOR,
	[3] = FROST_COLOR, 
};

local HAS_SNAKE_TRAP = false;

local function UpdateTrap(self, elapsed)
	if not self.duration then return end
	self.elapsed = (self.elapsed or 0) + elapsed	
	local timeLeft = (self.duration - (self.duration - (GetTime() - self.start))) * 1000
	if timeLeft < self.duration then
		self:SetValue(timeLeft)
		self:SetStatusBarColor(unpack(TRAP_COLORS[self.colorIndex]))
	else
		self:SetStatusBarColor(0.9,0.9,0.9)
		self.elapsed = 0
		self.start = nil
		self.duration = nil
		self:SetScript("OnUpdate", nil)
		self:Update(true)
	end

end

local function UpdateSnakeTrap(self, elapsed)
	if not self.duration then return end
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed >= 0.5 then
		local timeLeft = (self.duration - (self.duration - (GetTime() - self.start))) * 1000
		if timeLeft < self.duration then
			self:SetValue(timeLeft)
			self:SetStatusBarColor(unpack(TRAP_COLORS[self.colorIndex]))
		else
			self:SetStatusBarColor(0.9,0.9,0.9)
			self.elapsed = 0
			self.start = nil
			self.duration = nil
			self:SetScript("OnUpdate", nil)
			self:Update(true, HAS_SNAKE_TRAP)
		end
	end		
end

local UpdateFireTrap = function(spellId)

	if spellId == EXPLOSIVE_TRAP_ID then
		FIRE_TRAP = GetSpellInfo(EXPLOSIVE_TRAP_ID)
	elseif spellId ==IMPLOSIVE_TRAP_ID then
		FIRE_TRAP = GetSpellInfo(IMPLOSIVE_TRAP_ID)
	end

	FIRE_TRAP_NAME = FIRE_TRAP.name
	TRAP_IDS[1] = FIRE_TRAP_NAME
end

local Update = function(self, event, ...)
	if not event then return end

	local bar = self.HunterTraps
	
	if(event ~= "UNIT_SPELLCAST_SUCCEEDED") then
		IMPROVED_TRAPS = IsPlayerSpell(IMPROVED_TRAPS_ID);
	end

	if(bar.PreUpdate) then bar:PreUpdate(event) end

	local name, start, duration, isReady, enable;
	local unit, _, spellID = ...

	if(unit and (self.unit ~= unit)) then
		return 
	end

	if(spellID) then

		UpdateFireTrap(spellID)

		name = GetSpellInfo(spellID).name
		local cd = GetSpellCooldown(spellID)
		-- start, isReady, enable = GetSpellCooldown(spellID)
		start = cd.startTime
		isReady =  cd.duration
		enable = cd.isEnabled
		
		duration = GetSpellBaseCooldown(spellID)
		if(duration and duration > 0) then
			if (IMPROVED_TRAPS) then
		 		duration = duration - 5000
		 	end
		end
	end

	if bar:IsShown() then
		for i = 1, 3 do
			if(name and TRAP_IDS[i] == name and enable == true) then
				bar[i]:SetStatusBarColor(unpack(TRAP_COLORS[i]))
				bar[i]:Show()
				if((start and start > 0) and (duration and duration > 0)) then
					bar[i]:SetMinMaxValues(0, duration)
					bar[i]:SetValue(0)
					bar[i].start = start
					bar[i].duration = duration
					-- if(i == 3) then
					-- 	bar[i]:SetScript('OnUpdate', UpdateSnakeTrap)
					-- 	bar[i]:Update(false, HAS_SNAKE_TRAP)
					-- else
						bar[i]:SetScript('OnUpdate', UpdateTrap)
						bar[i]:Update()
					-- end
				end
			end
		end		
	end
	
	if(bar.PostUpdate) then
		return bar:PostUpdate(event)
	end
end

local Path = function(self, ...)
	return (self.HunterTraps.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self, unit)
	local bar = self.HunterTraps

	if(bar) then
		self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", Path)
		self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", Path)
		self:RegisterEvent("PLAYER_ENTERING_WORLD", Path)
		bar.__owner = self
		bar.ForceUpdate = ForceUpdate

		local barWidth, barHeight = bar:GetSize()
		local trapSize = barWidth * 0.25

		-- local ice_icon = select(3, GetSpellInfo(13809));
		-- local ice_icon = GetSpellInfo(13809).iconID;
		-- if(ice_icon == SNAKE_ICON) then
		-- 	TRAP_IDS[3] = SNAKE_TRAP
		-- 	TRAP_COLORS[3] = SNAKE_COLOR
		-- 	HAS_SNAKE_TRAP = true
		-- else
		-- 	TRAP_IDS[3] = ICE_TRAP
		-- 	TRAP_COLORS[3] = ICE_COLOR
		-- 	HAS_SNAKE_TRAP = false
		-- end

		for i = 1, 3 do
			if not bar[i] then
				bar[i] = CreateFrame("Statusbar", nil, bar)
				bar[i]:SetPoint("LEFT", bar, "LEFT", (trapSize * (i - 1)), 0)
				bar[i]:SetSize(trapSize,trapSize)
			end

			bar[i].colorIndex = i;

			if not bar[i]:GetStatusBarTexture() then
				bar[i]:SetStatusBarTexture([=[Interface\TargetingFrame\UI-StatusBar]=])
			end

			bar[i]:SetFrameLevel(bar:GetFrameLevel() + 1)
			bar[i]:GetStatusBarTexture():SetHorizTile(false)
			bar[i]:SetStatusBarColor(0.9,0.9,0.9)
			
			if bar[i].bg then
				bar[i].bg:SetAllPoints()
			end

			bar[i]:SetMinMaxValues(0, 1)
			bar[i]:SetValue(1)
			bar[i]:Update(true, HAS_SNAKE_TRAP)
		end
		
		return true;
	end	
end

local function Disable(self,unit)
	local bar = self.HunterTraps

	if(bar) then
		self:UnregisterEvent("PLAYER_SPECIALIZATION_CHANGED", Path)
		self:UnregisterEvent('UNIT_SPELLCAST_SUCCEEDED', Path)
		self:UnregisterEvent("PLAYER_ENTERING_WORLD", Path)
		bar:Hide()
	end
end
			
oUF:AddElement("HunterTraps",Path,Enable,Disable)
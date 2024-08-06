--GLOBAL NAMESPACE
local _G = _G;
--LUA
local unpack        = _G.unpack;
local select        = _G.select;
--BLIZZARD API
local GameTooltip   = _G.GameTooltip;
local MAX_TOTEMS 	= _G.MAX_TOTEMS;
local TotemFrame 	= _G.TotemFrame;

local class = select(2, UnitClass('player'))
if(class ~= 'SHAMAN') then return end

local parent, ns = ...
local oUF = ns.oUF

local Update = function(self, event)
	local maelstrom = self.Maelstrom
	local bar = maelstrom.Bar
	local current = UnitPower("player", Enum.PowerType.Maelstrom);
	local max = UnitPowerMax("player", Enum.PowerType.Maelstrom);

	if(maelstrom.PreUpdate) then maelstrom:PreUpdate() end
	bar:SetMinMaxValues(0,max)
	bar:SetValue(current)
	if(bar.text) then
		bar.text:SetText(current)
	end
	if(maelstrom.PostUpdate) then
		return maelstrom:PostUpdate(current)
	end
end

local Path = function(self, ...)
	return (self.Maelstrom.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, 'ForceUpdate')
end

local function UpddateVisibility(self)

	if (self.Maelstrom) then
		local specID = GetSpecializationInfo(GetSpecialization())
		if specID ~= 262 then
			self.Maelstrom:Hide()
		else
			self.Maelstrom:Show()
			self:RefreshClassBar()
			Path(self)
		end
	end
end

local Enable = function(self)
	local maelstrom = self.Maelstrom

	if(maelstrom and maelstrom.Bar) then
		local bar = maelstrom.Bar
		bar.__owner = self
		bar.ForceUpdate = ForceUpdate

		bar:SetMinMaxValues(0, UnitPowerMax("player", Enum.PowerType.Maelstrom))
		bar:SetValue(0)

		self:RegisterEvent('UNIT_DISPLAYPOWER', Path, true)
		self:RegisterUnitEvent('UNIT_DISPLAYPOWER', "player")
		self:RegisterEvent('UNIT_POWER_FREQUENT', Path, true)
		self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
		self:RegisterEvent('UNIT_MAXPOWER', Path, true)
		self:RegisterUnitEvent("UNIT_MAXPOWER", "player")

		self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", UpddateVisibility)
		self:RegisterEvent("PLAYER_ENTERING_WORLD", UpddateVisibility)
		

		return true
	end
end

local Disable = function(self)
	if(self.Maelstrom) then
		self.Maelstrom:Hide()
		self:UnregisterEvent('PLAYER_ENTERING_WORLD', Path)
		self:UnregisterEvent('UNIT_DISPLAYPOWER', Path)
		self:UnregisterEvent('PLAYER_TARGET_CHANGED', Path)
		self:UnregisterEvent('UNIT_POWER_FREQUENT', Path)
		self:UnregisterEvent('UNIT_MAXPOWER', Path)

		self:UnregisterEvent("PLAYER_SPECIALIZATION_CHANGED", UpddateVisibility)
		self:UnregisterEvent("PLAYER_ENTERING_WORLD", UpddateVisibility)
	end
end
			
oUF:AddElement("Maelstrom", Path, Enable, Disable)

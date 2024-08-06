--GLOBAL NAMESPACE
local _G = _G;
--LUA
local unpack        = _G.unpack;
local select        = _G.select;
local assert        = _G.assert;
--MATH
local math          = _G.math;
local floor         = math.floor
--BLIZZARD API
local UnitPower     	= _G.UnitPower;
local UnitPowerMax 		= _G.UnitPowerMax;
local UnitHasVehicleUI 	= _G.UnitHasVehicleUI;
local GetSpecialization = _G.GetSpecialization;

if select(2, UnitClass('player')) ~= "EVOKER" then return end

local _, ns = ...
local oUF = ns.oUF or oUF

assert(oUF, 'oUF_Essence was unable to locate oUF install')

local essenceColor = {
	{1, 1, 1},
	{1, 1, 1},
	{1, 1, 1},
}

local function updateEssence(bar)

end

local Update = function(self, event, unit, powerType)
	local essence = self.Essence;

	if(essence.PreUpdate) then essence:PreUpdate(unit) end

	if UnitHasVehicleUI("player") then
		essence:Hide()
	else
		essence:Show()
	end

	local spec = GetSpecialization()

	if spec then
		local colors = essenceColor[spec]
		local numEssences = UnitPower("player", Enum.PowerType.Essence);
        
        essence.MaxCount = UnitPowerMax("player", Enum.PowerType.Essence);

		if not essence:IsShown() then
			essence:Show()
		end

		if((not essence.CurrentSpec) or (essence.CurrentSpec ~= spec and essence.UpdateTextures)) then
			essence:UpdateTextures(spec)
		end

        if essence.fillingPoint then
            essence.fillingPoint:SetScript("OnUpdate", nil)
            essence.fillingPoint:SetValue(0)
            essence.fillingPoint = nil
        end

        -- full essence
        for i= 1, numEssences do
            essence.bars[i]:Show()
			essence.bars[i]:SetStatusBarColor(unpack(colors))
            essence.bars[i]:SetValue(1)

            if(essence.bars[i].Update) then
                essence.bars[i]:Update(1)
            end
        end

        --out essence
        for i = numEssences + 2, essence.MaxCount do
            essence.bars[i]:Show()
			essence.bars[i]:SetStatusBarColor(unpack(colors))
            essence.bars[i]:SetValue(0)
            if(essence.bars[i].Update) then
                essence.bars[i]:Update(0)
            end
        end

        for i = essence.MaxCount + 1, #essence.bars do
            essence.bars[i]:Hide()
        end

        local isAtMax = numEssences == essence.MaxCount
        local fillingPoint = essence.bars[numEssences + 1]

        if (not isAtMax and fillingPoint) then
            essence.fillingPoint = fillingPoint

            fillingPoint:Show()
            fillingPoint:SetStatusBarColor(unpack(colors))

            fillingPoint:SetScript("OnUpdate", function(f, elapsed)
                local partial = UnitPartialPower(unit, Enum.PowerType.Essence)/1000
                fillingPoint:SetValue(partial)
                if(fillingPoint.Update) then
                    fillingPoint:Update(partial)
                end
            end)
        end
	else
		if essence:IsShown() then essence:Hide() end;
	end

	if(essence.PostUpdate) then
		return essence:PostUpdate(unit, spec)
	end
end

local Path = function(self, ...)
	return (self.Essence.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit, 'ESSENCE')
end

local function Enable(self, unit)
	if(unit ~= 'player') then return end

	local essence = self.Essence
	if(essence) then
		essence.__owner = self
		essence.ForceUpdate = ForceUpdate

		self:RegisterEvent('UNIT_POWER_UPDATE', Path)
		-- self:RegisterEvent("PLAYER_TALENT_UPDATE", Path)
		-- self:RegisterEvent("PLAYER_ENTERING_WORLD", Path)
		-- self:RegisterEvent('UNIT_DISPLAYPOWER', Path)
		self:RegisterEvent("UNIT_POWER_FREQUENT", Path)
		self:RegisterEvent("UNIT_MAXPOWER", Path)
        -- self:RegisterEvent('UNIT_POWER_POINT_CHARGE', Path)
		-- self:RegisterUnitEvent('UNIT_DISPLAYPOWER', "player")
		-- self:RegisterUnitEvent("UNIT_POWER_FREQUENT", "player")
		-- self:RegisterUnitEvent("UNIT_MAXPOWER", "player")

		for i = 1, #essence.bars do
			if not essence.bars[i]:GetStatusBarTexture() then
				essence.bars[i]:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
			end

			essence.bars[i]:SetFrameLevel(essence:GetFrameLevel() + 1)
			essence.bars[i]:GetStatusBarTexture():SetHorizTile(false)
            
            essence.bars[i]:SetMinMaxValues(0, 1)
		end

		return true
	end
end

local function Disable(self)
	local bar = self.Essence
	if(bar) then
		self:UnregisterEvent('UNIT_POWER_UPDATE')
		self:UnregisterEvent("UNIT_POWER_FREQUENT")
		self:UnregisterEvent("UNIT_MAXPOWER")
		-- self:UnregisterEvent("PLAYER_TALENT_UPDATE", Path)
		-- self:UnregisterEvent("PLAYER_ENTERING_WORLD", Path)
        -- self:UnregisterEvent('UNIT_POWER_POINT_CHARGE', Path)
		-- self:UnregisterUnitEvent('UNIT_DISPLAYPOWER')
		bar:Hide()
	end
end

oUF:AddElement('Essence', Path, Enable, Disable)

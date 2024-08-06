--[[
##########################################################
S V U I   By: Vorka
##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
]]--

--[[ GLOBALS ]]--
local _G = _G;
local unpack    = _G.unpack;
local select    = _G.select;
local pairs     = _G.pairs;
local ipairs    = _G.ipairs;
local type      = _G.type;
local error     = _G.error;
local pcall     = _G.pcall;
local tostring  = _G.tostring;
local tonumber  = _G.tonumber;
local assert 	= _G.assert;
local math 		= _G.math;
--[[ MATH METHODS ]]--
local random,floor = math.random, math.floor;
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
if(SV.class ~= "EVOKER") then return end

--4219041 --[[9fx_drakemountemerald_buff_4219041]]
--[[
##########################################################
LOCALS
##########################################################
]]--

local ORB_BG = [[Interface\Addons\SVUI_UnitFrames\assets\Class\ORB-BG]]
local ORB_OVERLAY = [[Interface\Addons\SVUI_UnitFrames\assets\Class\ORB]]
local specTextures = {
	[[Interface\Addons\SVUI_UnitFrames\assets\Class\DRUID-SUN]],
	[[Interface\Addons\SVUI_UnitFrames\assets\Class\MAGE-CHARGE]],
	[[Interface\Addons\SVUI_UnitFrames\assets\Class\SHAMAN-EARTH]],
}

SV.SpecialFX:Register("nature", 167214, -12, 12, 12, -12, 0.3, 0.01, 0.01) --[[Spells\wrath_precast_hand.m2]]

local specEffect = {
	"fire", "nature", "earth"
}
local effectAlpha = {
	1, 0.25, 1
}
--[[
##########################################################
POSITIONING
##########################################################
]]--
local OnMove = function()
	SV.db.UnitFrames.player.classbar.detachFromFrame = true
end

local Reposition = function(self)
	local db = SV.db.UnitFrames.player
	local essenceBar = self.Essence;
	local max = UnitPowerMax("player", Enum.PowerType.Essence)
	-- local max = self.MaxClassPower;
	local size = db.classbar.height
	local width = size * max;
	local dbOffset = (size * 0.15)
	essenceBar.Holder:SetSize(width, size)
    if(not db.classbar.detachFromFrame) then
    	SV:ResetAnchors(L["Classbar"], true)
    end
    local holderUpdate = essenceBar.Holder:GetScript('OnSizeChanged')
    if holderUpdate then
        holderUpdate(essenceBar.Holder)
    end

    essenceBar:ClearAllPoints()
    essenceBar:SetAllPoints(essenceBar.Holder)

	for i = 1, 6 do
		essenceBar.bars[i]:ClearAllPoints()
		essenceBar.bars[i]:SetHeight(size)
		essenceBar.bars[i]:SetWidth(size)
		if(i == 1) then
			essenceBar.bars[i]:SetPoint("LEFT", essenceBar)
		else
			essenceBar.bars[i]:SetPoint("LEFT", essenceBar.bars[i - 1], "RIGHT", -2, 0)
		end

		if i > max then
			essenceBar.bars[i]:Hide()
		else
			essenceBar.bars[i]:Show()
		end
	end
	
	self.MaxClassPower = max
end

--[[
##########################################################
CUSTOM HANDLERS
##########################################################
]]--
local UpdateTextures = function(self, spec)
	local max = self.MaxCount;
	for i = 1, max do
		self.bars[i]:SetStatusBarTexture(specTextures[spec])
		self.bars[i]:GetStatusBarTexture():SetHorizTile(false)
		self.bars[i].overlay:SetTexture(ORB_OVERLAY)
		-- self.bars[i].overlay:SetVertexColor(unpack(colors[2]))
		self.bars[i].bg:SetTexture(ORB_BG)
		-- self.bars[i].bg:SetVertexColor(unpack(colors[1]))
		self.bars[i].FX:SetEffect(specEffect[spec])
		self.bars[i].FX:SetAlpha(effectAlpha[spec])
	end
	self.CurrentSpec = spec
end

local EssenceUpdate = function(self, value)
	if (value and value == 1) then
		if(self.overlay) then
			self.overlay:Show()
			SV.Animate:Flash(self.overlay,1,true)
		end
		if(not self.FX:IsShown()) then
			self.FX:Show()
		end
		self.FX:UpdateEffect()
	else
		if(self.overlay) then
			SV.Animate:StopFlash(self.overlay)
			self.overlay:Hide()
		end
		self.FX:Hide()
	end
end

-- local onEvent = function(self, event, unit, powerType)

-- 	if unit ~= "player" then return end

--     local max = self.MaxCount
--     self.MaxCount = UnitPowerMax("player", Enum.PowerType.Essence)

--     if max == self.MaxCount then return end

--     if max > self.MaxCount then
-- 		print ("HIDE", max)
--         self.bars[max]:Hide()
--     else
-- 		print ("SHOW", MaxCount)
--         self.bars[self.MaxCount]:Show()
--     end
-- end
--[[
##########################################################
EVOKER
##########################################################
]]--
function MOD:CreateClassBar(playerFrame)
	local max = UnitPowerMax("player", Enum.PowerType.Essence)
	local spec = GetSpecialization()

	local essenceBar = CreateFrame("Frame", nil, playerFrame)
	essenceBar:SetFrameLevel(playerFrame.TextGrip:GetFrameLevel() + 30)

	-- essenceBar:RegisterEvent("UNIT_MAXPOWER")
    -- essenceBar:SetScript("OnEvent", onEvent)

	-- local moon = CreateFrame('Frame', nil, essenceBar)
	-- moon:SetFrameLevel(essenceBar:GetFrameLevel() + 2)
	-- moon:SetSize(40, 40)
	-- moon:SetPoint("TOPLEFT", essenceBar, "TOPLEFT", -4, 300)
	-- SV.SpecialFX:SetFXFrame(moon, "nature")
	-- moon.FX:SetFrameLevel(essenceBar:GetFrameLevel() - 2)

	-- moon[1] = moon:CreateTexture(nil, "BACKGROUND", nil, 1)
	-- moon[1]:SetSize(40, 40)
	-- moon[1]:SetPoint("CENTER")
	-- moon[1]:SetTexture("Interface\\AddOns\\SVUI_UnitFrames\\assets\\Class\\VORTEX")
	-- moon[1]:SetBlendMode("ADD")
	-- moon[1]:SetVertexColor(0, 0.5, 1, 0.15)
	-- SV.Animate:Orbit(moon[1], 10, false)

	-- moon[2] = moon:CreateTexture(nil, "OVERLAY", nil, 2)
	-- moon[2]:SetSize(40, 40)
	-- moon[2]:SetPoint("CENTER")
	-- moon[2]:SetTexture("Interface\\AddOns\\SVUI_UnitFrames\\assets\\Class\\DRUID-SUN")
	-- moon[1]:Hide()
	
	-- moon[1]:Hide()
	-- moon[1].anim:Finish()
	-- moon.FX:Hide()

	-- C_Timer.After(10, function()
		
	-- 		moon[1]:Show()
	-- 		moon[1].anim:Play()
	-- 		moon.FX:Show()
	-- 		moon.FX:UpdateEffect()
		
	-- end)

	essenceBar.bars = {}
    for i = 1, 6 do

		essenceBar.bars[i] = CreateFrame("StatusBar", nil, essenceBar)
		essenceBar.bars[i].noupdate = true;
		essenceBar.bars[i]:SetOrientation("VERTICAL")
		essenceBar.bars[i]:SetStatusBarTexture(specTextures[spec])
		essenceBar.bars[i]:GetStatusBarTexture():SetHorizTile(false)

		SV.SpecialFX:SetFXFrame(essenceBar.bars[i], specEffect[spec])
		essenceBar.bars[i].FX:SetFrameLevel(essenceBar.bars[i]:GetFrameLevel() - 2)
		essenceBar.bars[i].FX:SetAlpha(effectAlpha[spec])
		
		essenceBar.bars[i].bg = essenceBar.bars[i]:CreateTexture(nil,'BACKGROUND',nil,1)
		essenceBar.bars[i].bg:SetAllPoints(essenceBar.bars[i])
		essenceBar.bars[i].bg:SetTexture(ORB_BG)
		essenceBar.bars[i].bg:SetVertexColor(0.25,0.5,0.5)
		SV.Animate:Orbit(essenceBar.bars[i].bg, 10, false)

		essenceBar.bars[i].overlay = essenceBar.bars[i]:CreateTexture(nil,'OVERLAY', nil, 2)
		essenceBar.bars[i].overlay:SetAllPoints(essenceBar.bars[i])
		essenceBar.bars[i].overlay:SetTexture(ORB_OVERLAY)
		essenceBar.bars[i].overlay:SetBlendMode("BLEND")
		essenceBar.bars[i].overlay:Hide()

		essenceBar.bars[i].Update = EssenceUpdate
        if i > max then
            essenceBar.bars[i]:Hide()
        end
	end

    essenceBar.UpdateTextures = UpdateTextures;
    essenceBar.MaxCount = max

	local classBarHolder = CreateFrame("Frame", "Player_ClassBar", essenceBar)
	classBarHolder:SetPoint("TOPLEFT", playerFrame, "BOTTOMLEFT", 0, -2)
	essenceBar:SetPoint("TOPLEFT", classBarHolder, "TOPLEFT", 0, 0)
	essenceBar.Holder = classBarHolder
	SV:NewAnchor(essenceBar.Holder, L["Classbar"], OnMove)

	playerFrame.MaxClassPower = max;
	playerFrame.RefreshClassBar = Reposition;
	playerFrame.Essence = essenceBar
	return 'Essence'
end
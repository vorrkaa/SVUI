--[[
##############################################################################
S V U I  By: Failcoder               #
##############################################################################
########################################################## 
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
local _G            = _G;
local unpack        = _G.unpack;
local select        = _G.select;
local assert        = _G.assert;
local type          = _G.type;
local error         = _G.error;
local pcall         = _G.pcall;
local print         = _G.print;
local ipairs        = _G.ipairs;
local pairs         = _G.pairs;
local next          = _G.next;
local rawset        = _G.rawset;
local rawget        = _G.rawget;
local tostring      = _G.tostring;
local tonumber      = _G.tonumber;
local tinsert       = _G.tinsert;
local tremove       = _G.tremove;
local twipe         = _G.wipe;
--STRING
local string        = string;
local format        = string.format;
local sub           = string.sub;
--MATH
local math          = math;
--TABLE
local table         = table;
local tsort         = table.sort;
local tremove       = table.remove;
--[[ MATH METHODS ]]--
local abs, ceil, floor = math.abs, math.ceil, math.floor; -- Basic
local parsefloat = math.parsefloat; -- Uncommon

local CreateFrame           = _G.CreateFrame;
local InCombatLockdown      = _G.InCombatLockdown;
local GameTooltip           = _G.GameTooltip;
local UnitClass             = _G.UnitClass;
local UnitIsPlayer          = _G.UnitIsPlayer;
local UnitReaction          = _G.UnitReaction;
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

SV.SpecialFX:Register("overlay_castbar", 382335, 2, -2, -2, 2, 0.95, -1, 0) --[[Spells\Eastern_plaguelands_beam_effect.m2]]
SV.SpecialFX:Register("underlay_castbar", 522099, 1, -1, -1, 1, 0.9, 0, 0) --[[Spells\Xplosion_twilight_impact_noflash.m2]]

local PipColor = {
	{ r = 0.847, g = 0.117, b = 0.074 }, 	--DK supercolors
	{ r = 1,     g = 0.513, b = 0 },		--Druid
	{ r = 1,     g = 0.894, b = 0.117 },	--Rogue
	{ r = 0.25,  g = 0.75,  b = 0.64  },	--Evoker
	{ r = 0.015, g = 0.886, b = 0.38 },		--Monk
}
--[[ 
########################################################## 
LOCAL VARIABLES
##########################################################
]]--
local ticks = {}
local function SpellName(id)
	-- local name, _, _, _, _, _, _, _, _ = C_Spell.GetSpellInfo(id) 	
	local spellInfo = C_Spell.GetSpellInfo(id)
	local name = ""
	if spellInfo then
		name = spellInfo.name
	end
	if not name then
		name = "Voodoo Doll";
	end
	return name
end

local CustomTickData = {
	--TODO : Update here
	["ChannelTicks"] = {
		-- Racials
		[291944]	= 6, -- Regeneratin (Zandalari)
		-- Evoker
		[356995]	= 4, -- Disintegrate
		--Warlock
		[198590] = 5, 	--"Drain Soul"
		[234153] = 5, 	-- "Drain Life"
		[755] = 6, 		-- "Health Funnel"
		[417537] = 4, 	--"Oblivion"
		--Druid
		[44203] = 4, -- "Tranquility"
		--Priest
		[15407] = 3, -- "Mind Flay"
		[129197] = 3, -- "Mind Flay (Insanity)"
		[48045] = 5, -- "Mind Sear"
		[47757] = 2, -- "Penance (heal)"
		[47758] = 2, -- "Penance (dps)"
		[400171] = 2, -- "Penance (Dark Reprimand, heal)"
		[373129] = 2, -- "Penance (Dark Reprimand, dps)"
		[64902] = 4, -- Symbol of Hope (Mana Hymn)
		[64843] = 4, -- Divine Hymn
		--Mage
		[5143] = 5, -- "Arcane Missiles"
		[205021] = 8, -- "Ray of Frost"
		[12051] = 4, -- "Evocation"
		--Monk
		[113656] = 9, -- "Fists of Fury"
		-- DK
		[206931]	= 3, -- Blooddrinker
		-- DH
		[198013]	= 10, -- Eye Beam
		[212084]	= 10, -- Fel Devastation
		-- Hunter
		[120360]	= 15, -- Barrage
		[257044]	= 7, -- Rapid Fire
	},
	--Spells that chain, second step
	["ChainChannelTicks"] = { 
		-- Evoker
		[356995]	= 4, -- Disintegrate
	},
	-- Window to chain time (in seconds); usually the channel duration
	["ChainChannelTime"] = {
		-- Evoker
		[356995]	= 3, -- Disintegrate
	},
	["ChannelTicksSize"] = {
	  --Warlock
		[198590] = 2, 	--"Drain Soul"
	  	[234153] = 1, 	-- "Drain Life"
		[417537] = 1, 	-- "Oblivion"
	},
	["HastedChannelTicks"] = {
	},
	["AuraChannelTicks"] = {
		-- Priest
		[47757]		= { filter = 'HELPFUL', spells = { [373183] = 6 } }, -- Harsh Discipline: Penance (heal)
		[47758]		= { filter = 'HELPFUL', spells = { [373183] = 6 } }, -- Harsh Discipline: Penance (dps)
	}
}
--[[ 
########################################################## 
LOCAL FUNCTIONS
##########################################################
]]--
local function HideTicks()
	for i=1,#ticks do 
		ticks[i]:Hide()
	end 
end 

local function SetCastTicks(bar,count,mod)
	mod = mod or 0;
	HideTicks()
	if count and count <= 0 then return end 
	local barWidth = bar:GetWidth()
	local offset = barWidth / count + mod;
	local sizeTick = CustomTickData.ChannelTicksSize[bar.spellID] or 1
	for i=1,count do 
		if not ticks[i] then 
			ticks[i] = bar:CreateTexture(nil,'OVERLAY')
			ticks[i]:SetTexture(SV.media.statusbar.lazer)
			ticks[i]:SetVertexColor(0,0,0,0.8)
			ticks[i]:SetHeight(bar:GetHeight())
		end 
		ticks[i]:SetWidth(sizeTick)
		ticks[i]:ClearAllPoints()
		ticks[i]:SetPoint("RIGHT", bar, "LEFT", offset * i, 0)
		ticks[i]:Show()
	end 
end 

local Fader_OnEvent = function(self, event, arg)
	if arg ~= "player" then return end
	local isTradeskill = self:GetParent().recipecount
	if(isTradeskill and isTradeskill > 0) then return end;
	if event == "UNIT_SPELLCAST_START" then 
		self.fails = nil;
		self.isokey = nil;
		self.ischanneling = nil;
		self:SetAlpha(0)
		self.mask:SetAlpha(1)
		if self.anim:IsPlaying() then 
			self.anim:Stop()
		end
	elseif event == "UNIT_SPELLCAST_CHANNEL_START" then 
		self:SetAlpha(0)
		self.mask:SetAlpha(1)
		if self.anim:IsPlaying() then 
			self.anim:Stop()
		end 
		self.iscasting = nil;
		self.fails = nil;
		self.isokey = nil 
	elseif event == "UNIT_SPELLCAST_SUCCEEDED" then 
		self.fails = nil;
		self.isokey = true;
		self.fails_a = nil 
	elseif event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_FAILED_QUIET" then 
		self.fails = true;
		self.isokey = nil;
		self.fails_a = nil 
	elseif event == "UNIT_SPELLCAST_INTERRUPTED" then
		self.fails = nil;
		self.isokey = nil;
		self.fails_a = true 
	elseif event == "UNIT_SPELLCAST_STOP" then 
		if self.fails or self.fails_a then 
			self:SetBackdropColor(1, 0.2, 0.2, 0.5)
			self.txt:SetText(SPELL_FAILED_FIZZLE)
			self.txt:SetTextColor(1, 0.8, 0, 0.5)
		elseif self.isokey then 
			self:SetBackdropColor(0.2, 1, 0.2, 0.5)
			self.txt:SetText(SUCCESS)
			self.txt:SetTextColor(0.5, 1, 0.4, 0.5)
		end 
		self.mask:SetAlpha(0)
		self:SetAlpha(0)
		if not self.anim:IsPlaying() then 
			self.anim:Play()
		end 
	elseif event == "UNIT_SPELLCAST_CHANNEL_STOP" then 
		self.mask:SetAlpha(0)
		self:SetAlpha(0)
		if self.fails_a then 
			self:SetBackdropColor(1, 0.2, 0.2, 0.5)
			self.txt:SetText(SPELL_FAILED_FIZZLE)
			self.txt:SetTextColor(0.5, 1, 0.4, 0.5)
			if not self.anim:IsPlaying() then 
				self.anim:Play()
			end 
		end 
	end 
end

local function SetCastbarFading(castbar, texture)
	local fader = CreateFrame("Frame", nil, castbar, "BackdropTemplate")
	fader:SetFrameLevel(2)
	fader:InsetPoints(castbar)
	fader:SetBackdrop({bgFile = texture})
	fader:SetBackdropColor(0, 0, 0, 0)
	fader:SetAlpha(0)
	fader:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED")
	fader:RegisterEvent("UNIT_SPELLCAST_START")
	fader:RegisterEvent("UNIT_SPELLCAST_STOP")
	fader:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	fader:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
	fader:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
	fader:RegisterEvent("UNIT_SPELLCAST_FAILED")
	fader:RegisterEvent("UNIT_SPELLCAST_FAILED_QUIET")
	fader:RegisterEvent("UNIT_SPELLCAST_EMPOWER_START")
	fader:RegisterEvent("UNIT_SPELLCAST_EMPOWER_STOP")
	fader.mask = CreateFrame("Frame", nil, castbar, "BackdropTemplate")
	fader.mask:SetBackdrop({bgFile = texture})
	fader.mask:InsetPoints(castbar)
	fader.mask:SetFrameLevel(2)
	fader.mask:SetBackdropColor(0, 0, 0, 0)
	fader.mask:SetAlpha(0)
	fader.txt = fader:CreateFontString(nil, "OVERLAY")
	fader.txt:SetFont(SV.media.font.alert, 16)
	fader.txt:SetAllPoints(fader)
	fader.txt:SetJustifyH("CENTER")
	-- fader.txt:SetJustifyV("CENTER")
	fader.txt:SetJustifyV("MIDDLE")
	fader.txt:SetText("")
	fader.anim = fader:CreateAnimationGroup("Flash")
	fader.anim.fadein = fader.anim:CreateAnimation("ALPHA", "FadeIn")
	fader.anim.fadein:SetFromAlpha(0)
    fader.anim.fadein:SetToAlpha(1)
	fader.anim.fadein:SetOrder(1)
	fader.anim.fadeout1 = fader.anim:CreateAnimation("ALPHA", "FadeOut")
	fader.anim.fadeout1:SetFromAlpha(1)
    fader.anim.fadeout1:SetToAlpha(0.75)
	fader.anim.fadeout1:SetOrder(2)
	fader.anim.fadeout2 = fader.anim:CreateAnimation("ALPHA", "FadeOut")
	fader.anim.fadeout1:SetFromAlpha(0.75)
    fader.anim.fadeout1:SetToAlpha(0.25)
	fader.anim.fadeout2:SetOrder(3)
	fader.anim.fadein:SetDuration(0)
	fader.anim.fadeout1:SetDuration(.8)
	fader.anim.fadeout2:SetDuration(.4)
	fader:SetScript("OnEvent", Fader_OnEvent)
end 

local CustomCastDelayText = function(self, value)
	if not self.TimeFormat then return end 
	if self.channeling then 
		if self.TimeFormat == "CURRENT" then 
			self.Time:SetText(("%.1f |cffaf5050%.1f|r"):format(abs(value - self.max), self.delay))
		elseif self.TimeFormat == "CURRENTMAX" then 
			self.Time:SetText(("%.1f / %.1f |cffaf5050%.1f|r"):format(value, self.max, self.delay))
		elseif self.TimeFormat == "REMAINING" then 
			self.Time:SetText(("%.1f |cffaf5050%.1f|r"):format(value, self.delay))
		end 
	else 
		if self.TimeFormat == "CURRENT" then 
			self.Time:SetText(("%.1f |cffaf5050%s %.1f|r"):format(value, "+", self.delay))
		elseif self.TimeFormat == "CURRENTMAX" then 
			self.Time:SetText(("%.1f / %.1f |cffaf5050%s %.1f|r"):format(value, self.max, "+", self.delay))
		elseif self.TimeFormat == "REMAINING"then 
			self.Time:SetText(("%.1f |cffaf5050%s %.1f|r"):format(abs(value - self.max), "+", self.delay))
		end 
	end 
end

local CustomTimeText = function(self, value)
	if not self.TimeFormat then return end 
	if self.channeling then 
		if self.TimeFormat == "CURRENT" then 
			self.Time:SetText(("%.1f"):format(abs(value - self.max)))
		elseif self.TimeFormat == "CURRENTMAX" then 
			self.Time:SetText(("%.1f / %.1f"):format(value, self.max))
			self.Time:SetText(("%.1f / %.1f"):format(abs(value - self.max), self.max))
		elseif self.TimeFormat == "REMAINING" then 
			self.Time:SetText(("%.1f"):format(value))
		end 
	else 
		if self.TimeFormat == "CURRENT" then 
			self.Time:SetText(("%.1f"):format(value))
		elseif self.TimeFormat == "CURRENTMAX" then 
			self.Time:SetText(("%.1f / %.1f"):format(value, self.max))
		elseif self.TimeFormat == "REMAINING" then 
			self.Time:SetText(("%.1f"):format(abs(value - self.max)))
		end 
	end 
end 

local CustomCastTimeUpdate = function(self, duration)
	if(self.recipecount and self.recipecount > 0 and self.maxrecipe and self.maxrecipe > 1) then
		self.Text:SetText(self.recipecount .. "/" .. self.maxrecipe .. ": " .. self.previous)
	end
	if(self.Time) then
		if(self.delay ~= 0) then
			if(self.CustomDelayText) then
				self:CustomDelayText(duration)
			else
				self.Time:SetFormattedText("%.1f|cffff0000-%.1f|r", duration, self.delay)
			end
		else
			if(self.CustomTimeText) then
				self:CustomTimeText(duration)
			else
				self.Time:SetFormattedText("%.1f", duration)
			end
		end
	end
	if(self.Spark) then
		local xOffset = 0
		local yOffset = 0
		if self.Spark.xOffset then
			xOffset = self.Spark.xOffset
			yOffset = self.Spark.yOffset
		end
		if(self:GetReverseFill()) then
			self.Spark:SetPoint("CENTER", self, "RIGHT", -((duration / self.max) * self:GetWidth() + xOffset), yOffset)
		else
			self.Spark:SetPoint("CENTER", self, "LEFT", ((duration / self.max) * self:GetWidth() + xOffset), yOffset)
		end
	end
end

local function ResetAttributes(self)
	self.unitName = nil
	self.previous = nil

	self.castid = nil
	self.casting = nil
	self.channeling = nil
	self.empowering = nil

	self.tradeskill = nil
	self.recipecount = nil
	self.maxrecipe = 1

	self.notInterruptible = nil
	self.spellID = nil
	self.numStages = nil
	self.curStage = nil
	self.spellName = nil

	table.wipe(self.stagePoints)

	for _, pip in next, self.Pips do
		pip:Hide()
	end

	self:SetValue(1)
	self:Hide()
end

local CustomCastBarUpdate = function(self, elapsed)
	self.lastUpdate = (self.lastUpdate or 0) + elapsed

	if not (self.casting or self.channeling or self.empowering) then

		if (self.holdTime > 0) then
			self.holdTime = self.holdTime - elapsed
		else
			ResetAttributes(self)
			self:Hide()
		end

		-- self.unitName = nil
		-- self.previous = nil
		-- self.casting = nil
		-- self.castid = nil
		-- self.channeling = nil
		-- self.tradeskill = nil
		-- self.recipecount = nil
		-- self.maxrecipe = 1
		-- self:SetValue(1)
		-- self:Hide()
		return
	end

	if(self.Spark and self.Spark[1]) then self.Spark[1]:Hide(); self.Spark[1].overlay:Hide() end
	if(self.Spark and self.Spark[2]) then self.Spark[2]:Hide(); self.Spark[2].overlay:Hide() end

	if(self.casting) then
		if self.Spark then 
			if self.Spark.iscustom then 
				self.Spark.xOffset = -12
				self.Spark.yOffset = 0 
			end
			if(self.Spark[1]) then
				self.Spark[1]:Show()
				self.Spark[1].overlay:Show()
				if not self.Spark[1].anim:IsPlaying() then self.Spark[1].anim:Play() end
			end
		end

		local duration = self.duration + self.lastUpdate

		if(duration >= self.max) then
			-- self.previous = nil
			-- self.casting = nil
			-- self.tradeskill = nil
			-- self.recipecount = nil
			-- self.maxrecipe = 1
			ResetAttributes(self)
			self:Hide()

			if(self.PostCastStop) then self:PostCastStop(self.__owner.unit) end
			return
		end
			
		CustomCastTimeUpdate(self, duration)

		self.duration = duration
		self:SetValue(duration)
	elseif(self.channeling) then
		if self.Spark then 
			if self.Spark.iscustom then 
				self.Spark.xOffset = 12
				self.Spark.yOffset = 4 
			end
			if(self.Spark[2]) then 
				self.Spark[2]:Show()
				self.Spark[2].overlay:Show()
				if not self.Spark[2].anim:IsPlaying() then self.Spark[2].anim:Play() end
			end
		end
		local duration = self.duration - self.lastUpdate

		if(duration <= 0) then
			self.channeling = nil
			self.previous = nil
			self.casting = nil
			self.tradeskill = nil
			self.recipecount = nil
			self.maxrecipe = 1
			self:Hide()

			if(self.PostChannelStop) then self:PostChannelStop(self.__owner.unit) end
			return
		end
	
		CustomCastTimeUpdate(self, duration)

		self.duration = duration
		self:SetValue(duration)
	elseif (self.empowering) then
		if self.Spark then 
			if self.Spark.iscustom then 
				self.Spark.xOffset = 12
				self.Spark.yOffset = 4 
			end
			if(self.Spark[2]) then 
				self.Spark[2]:Show()
				self.Spark[2].overlay:Show()
				if not self.Spark[2].anim:IsPlaying() then self.Spark[2].anim:Play() end
			end
		end
		local duration = self.duration + self.lastUpdate

		local old = self.curStage
		for i = old + 1, self.numStages do
			if(self.stagePoints[i]) then
				if(duration > self.stagePoints[i]) then
					self.curStage = i
					if(self.curStage ~= old) then
						-- self:PostUpdateStage(i)
						if(self.PostUpdateStage) then self:PostUpdateStage(self.__owner.unit, i) end
						return
					end
				else
					break
				end
			end
		end
		CustomCastTimeUpdate(self, duration)
		self.duration = duration
		self:SetValue(duration)
	end
	
	self.lastUpdate = 0
end 

local CustomChannelUpdate = function(self, unit, hasTicks, chainTicks)
	
	if not(unit == "player" or unit == "vehicle") then return end 
	if hasTicks then

		-- local activeTicks = CustomTickData.ChannelTicks[index]
		local activeTicks = CustomTickData.ChannelTicks[self.spellID]
		if activeTicks then
			local hasteTick = CustomTickData.HastedChannelTicks[self.spellID]
			local sizeTick = CustomTickData.ChannelTicksSize[self.spellID] or 1

			-- if chainTicks then
			-- 	local now = GetTime()
			-- 	local seconds = CustomTickData.ChainChannelTime[self.spellID]
			-- 	local match = seconds and self.chainTime and self.chainTick == self.spellID

			-- 	if match and (now - seconds) < self.chainTime then
			-- 		activeTicks = chainTicks
			-- 	end

			-- 	self.chainTime = now
			-- 	self.chainTick = self.spellID
			-- else
			-- 	self.chainTime = nil
			-- 	self.chainTick = nil
			-- end

			
			local haste = UnitSpellHaste("player") * 0.01;
			local total = 0;
			if hasteTick then
				local mod1 = 1 / activeTicks;
				local mod2 = mod1 / 2;
				if haste >= mod2 then total = total + 1 end 
				local calc1 = tonumber(parsefloat(mod2 + mod1, 2))
				while haste >= calc1 do 
					calc1 = tonumber(parsefloat(mod2 + mod1 * total, 2))
					if haste >= calc1 then 
						total = total + 1 
					end 
				end 
				-- local sizeMod = sizeTick / 1 + haste;
				-- local calc2 = self.max - sizeMod * activeTicks + total;
				-- if self.chainChannel then 
				-- 	self.extraTickRatio = calc2 / sizeMod;
				-- 	self.chainChannel = nil 
				-- end 
				-- SetCastTicks(self, activeTicks + total, self.extraTickRatio)
			else
				-- local haste = UnitSpellHaste("player") * 0.01;
				-- local sizeMod = sizeTick / 1 + haste;
				-- local calc2 = self.max - sizeMod * activeTicks;
				-- if self.chainChannel then 
				-- 	self.extraTickRatio = calc2 / sizeMod;
				-- 	self.chainChannel = nil 
				-- end 
				-- SetCastTicks(self, activeTicks, self.extraTickRatio)
			end

			local sizeMod = sizeTick / 1 + haste;
			local calc2 = self.max - sizeMod * activeTicks + total;
			if chainTicks then 
				self.extraTickRatio = calc2 / sizeMod;
			else
				self.extraTickRatio = nil
			end 
			SetCastTicks(self, activeTicks + total, self.extraTickRatio)
		else
			HideTicks()
		end

		-- if activeTicks and CustomTickData.ChannelTicksSize[self.spellID] and CustomTickData.HastedChannelTicks[self.spellID] then 
		-- 	local mod1 = 1 / activeTicks;
		-- 	local haste = UnitSpellHaste("player") * 0.01;
		-- 	local mod2 = mod1 / 2;
		-- 	local total = 0;
		-- 	if haste >= mod2 then total = total + 1 end 
		-- 	local calc1 = tonumber(parsefloat(mod2 + mod1, 2))
		-- 	while haste >= calc1 do 
		-- 		calc1 = tonumber(parsefloat(mod2 + mod1 * total, 2))
		-- 		if haste >= calc1 then 
		-- 			total = total + 1 
		-- 		end 
		-- 	end 
		-- 	local activeSize = CustomTickData.ChannelTicksSize[self.spellID]
		-- 	local sizeMod = activeSize / 1 + haste;
		-- 	local calc2 = self.max - sizeMod * activeTicks + total;
		-- 	if self.chainChannel then 
		-- 		self.extraTickRatio = calc2 / sizeMod;
		-- 		self.chainChannel = nil 
		-- 	end 
		-- 	SetCastTicks(self, activeTicks + total, self.extraTickRatio)
		-- elseif activeTicks and CustomTickData.ChannelTicksSize[self.spellID] then 
		-- 	local haste = UnitSpellHaste("player") * 0.01;
		-- 	local activeSize = CustomTickData.ChannelTicksSize[self.spellID]
		-- 	local sizeMod = activeSize / 1 + haste;
		-- 	local calc2 = self.max - sizeMod * activeTicks;
		-- 	if self.chainChannel then 
		-- 		self.extraTickRatio = calc2 / sizeMod;
		-- 		self.chainChannel = nil 
		-- 	end 
		-- 	SetCastTicks(self, activeTicks, self.extraTickRatio)
		-- elseif activeTicks then 
		-- 	SetCastTicks(self, activeTicks)
		-- else 
		-- 	HideTicks()
		-- end 
	else 
		HideTicks()
	end 
end 

local CustomInterruptible = function(self, unit, useClass)
	local colors = oUF_SVUI.colors
	local r, g, b = self.CastColor[1], self.CastColor[2], self.CastColor[3]
	if useClass then 
		local colorOverride;
		if UnitIsPlayer(unit) then 
			local _, class = UnitClass(unit)
			colorOverride = colors.class[class]
		elseif UnitReaction(unit, "player") then 
			colorOverride = colors.reaction[UnitReaction(unit, "player")]
		end 
		if colorOverride then 
			r, g, b = colorOverride[1], colorOverride[2], colorOverride[3]
		end 
	end 
	if self.interrupt and unit ~= "player" and UnitCanAttack("player", unit) then 
		r, g, b = colors.interrupt[1], colors.interrupt[2], colors.interrupt[3]
	end 
	self:SetStatusBarColor(r, g, b)
	if self.bg:IsShown() then 
		self.bg:SetVertexColor(r * 0.2, g * 0.2, b * 0.2)
	end 
	
	if(self.Spark and self.Spark[1]) then
		r, g, b = self.SparkColor[1], self.SparkColor[2], self.SparkColor[3]
		self.Spark[1]:SetVertexColor(r, g, b)
		self.Spark[2]:SetVertexColor(r, g, b)
	end
end 

local function PostUpdatePips(element, numStages)
	local reverse = element:GetReverseFill()
	local pips = element.Pips

	for i=1, numStages do

		if i == numStages then
			local first = pips[1]
			local anchor = pips[numStages]
			if reverse then
				first.texture:SetPoint("RIGHT", element, "LEFT", 0, 0)
				first.texture:SetPoint("LEFT", anchor, 3, 0)
			else
				first.texture:SetPoint("LEFT", element, "RIGHT", 0, 0)
				first.texture:SetPoint("RIGHT", anchor, -3, 0)
			end
		end

		if i ~= 1 then
			local anchor = pips[i-1]
			if reverse then
				pips[i].texture:SetPoint("RIGHT", -3, 0)
				pips[i].texture:SetPoint("LEFT", anchor, 3, 0)
			else
				pips[i].texture:SetPoint("LEFT", 3, 0)
				pips[i].texture:SetPoint("RIGHT", anchor, -3, 0)
			end
		end
		
	end
end

local function CreatePip(self, stage)
	local pip = CreateFrame('Frame', nil, self, 'CastingBarFrameStagePipTemplate')

	pip:RemoveTextures()
	pip.texture = pip:CreateTexture(nil, "ARTWORK", nil, 2)
	pip.texture:SetPoint("BOTTOM", self.bg)
	pip.texture:SetPoint("TOP", self.bg)
	pip.texture:SetTexture([[Interface\AddOns\SVUI_!Core\assets\statusbars\GRADIENT]])

	--[[
	Elvui settings for animation
	]]--
	-- pip.pipStart = 1.0 -- alpha on hit
	-- pip.pipAlpha = 0.3 -- alpha on init
	-- pip.pipFaded = 0.6 -- alpha when passed
	-- pip.pipTimer = 0.4 -- fading time to passed

	local color
	if self.numStages == 3 and stage >= 2 then
		--Skip Orange color to have stage color RED > YELLOW > GREEN
		color = PipColor[stage + 1]
	else
		color = PipColor[stage]
	end
	pip.texture:SetVertexColor(color.r, color.g, color.b, color.a)

	return pip
end
--[[ 
########################################################## 
BUILD FUNCTION
##########################################################
]]--
function MOD:CreateCastbar(frame, reversed, moverName, ryu, useFader, isBoss, hasModel)
	local colors = oUF_SVUI.colors;

	local castbar = CreateFrame("StatusBar", frame:GetName().."CastBar", frame)
	castbar.CreatePip = CreatePip
	castbar.OnUpdate = CustomCastBarUpdate;
	castbar.CustomDelayText = CustomCastDelayText;
	castbar.CustomTimeText = CustomTimeText;
	castbar.PostCastStart = MOD.PostCastStart;
	-- castbar.PostChannelStart = MOD.PostCastStart;
	castbar.PostCastStop = MOD.PostCastStop;
	-- castbar.PostChannelStop = MOD.PostCastStop;

	castbar.PostCastUpdate = MOD.PostChannelUpdate;
	castbar.PostCastInterruptible = MOD.PostCastInterruptible;
	-- castbar.PostCastNotInterruptible = MOD.PostCastNotInterruptible;

	-- castbar.PostCastFail

	castbar.PostUpdatePips = PostUpdatePips
	-- castbar.PostUpdateStage

	castbar:SetClampedToScreen(true)
	castbar:SetFrameLevel(2)


	castbar.SafeZone = castbar:CreateTexture(nil, "OVERLAY")

	local cbName = frame:GetName().."Castbar"
	local castbarHolder = CreateFrame("Frame", cbName, castbar)

	local organizer = CreateFrame("Frame", nil, castbar)
	organizer:SetFrameStrata("HIGH")

	local iconHolder = CreateFrame("Frame", nil, organizer)
	iconHolder:SetStyle("!_Frame", "Inset", false)
	organizer.Icon = iconHolder

	local buttonIcon = iconHolder:CreateTexture(nil, "BORDER")
	buttonIcon:InsetPoints()
	buttonIcon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
	castbar.Icon = buttonIcon;
	local shieldIcon = iconHolder:CreateTexture(nil, "ARTWORK")
	shieldIcon:SetPoint("TOPLEFT", buttonIcon, "TOPLEFT", -7, 7)
	shieldIcon:SetPoint("BOTTOMRIGHT", buttonIcon, "BOTTOMRIGHT", 7, -8)
	shieldIcon:SetTexture("Interface\\Addons\\SVUI_UnitFrames\\assets\\Castbar\\SHIELD")
	castbar.Shield = shieldIcon;

	castbar.Time = organizer:CreateFontString(nil, "OVERLAY")
	castbar.Time:SetDrawLayer("OVERLAY", 7)

	castbar.Text = organizer:CreateFontString(nil, "OVERLAY")
	castbar.Text:SetDrawLayer("OVERLAY", 7)

	castbar.Organizer = organizer
	
	local bgFrame = CreateFrame("Frame", castbar:GetName().."Bg", castbar)
	local hadouken = CreateFrame("Frame", castbar:GetName().."Hadouken", castbar)

	if ryu then
		castbar.Time:SetFontObject(SVUI_Font_Aura)
		castbar.Time:SetTextColor(1, 1, 1)
		castbar.Text:SetFontObject(SVUI_Font_Caps)
		castbar.Text:SetTextColor(1, 1, 1, 0.75)
		castbar.Text:SetWordWrap(false)

		castbar:SetStatusBarTexture(SV.media.statusbar.lazer)

		bgFrame:InsetPoints(castbar, -2, 10)
		bgFrame:SetFrameLevel(bgFrame:GetFrameLevel() - 1)

	  	castbar.SafeZone:SetTexture(SV.media.statusbar.lazer)
		castbar.noupdate = true;
		castbar.pewpew = true
		hadouken.iscustom = true;
		hadouken:SetHeight(50)
		hadouken:SetWidth(50)
		hadouken:SetAlpha(0.9)

		castbarHolder:SetPoint("TOP", frame, "BOTTOM", 0, isBoss and -4 or -35)

		if reversed then 
			hadouken:SetPoint("CENTER", castbar:GetStatusBarTexture(), "LEFT", 0, 0)

			castbar:SetReverseFill(true)
			hadouken[1] = hadouken:CreateTexture(nil, "ARTWORK")
			hadouken[1]:SetAllPoints(hadouken)
			hadouken[1]:SetBlendMode("ADD")
			hadouken[1]:SetTexture("Interface\\Addons\\SVUI_UnitFrames\\assets\\Castbar\\HADOUKEN-REVERSED")
			hadouken[1]:SetVertexColor(colors.spark[1],colors.spark[2],colors.spark[3])
			hadouken[1].overlay = hadouken:CreateTexture(nil, "OVERLAY")
			hadouken[1].overlay:SetHeight(50)
			hadouken[1].overlay:SetWidth(50)
			hadouken[1].overlay:SetPoint("CENTER", hadouken)
			hadouken[1].overlay:SetBlendMode("ADD")
			hadouken[1].overlay:SetTexture("Interface\\Addons\\SVUI_UnitFrames\\assets\\Castbar\\SKULLS-REVERSED")
			hadouken[1].overlay:SetVertexColor(1, 1, 1)

			SV.Animate:Sprite4(hadouken[1],false,false,true)

			hadouken[2] = hadouken:CreateTexture(nil, "ARTWORK")
			hadouken[2]:InsetPoints(hadouken, 4, 4)
			hadouken[2]:SetBlendMode("ADD")
			hadouken[2]:SetTexture("Interface\\Addons\\SVUI_UnitFrames\\assets\\Castbar\\CHANNEL-REVERSED")
			hadouken[2]:SetVertexColor(colors.spark[1],colors.spark[2],colors.spark[3])
			hadouken[2].overlay = hadouken:CreateTexture(nil, "OVERLAY")
			hadouken[2].overlay:SetHeight(50)
			hadouken[2].overlay:SetWidth(50)
			hadouken[2].overlay:SetPoint("CENTER", hadouken)
			hadouken[2].overlay:SetBlendMode("ADD")
			hadouken[2].overlay:SetTexture("Interface\\Addons\\SVUI_UnitFrames\\assets\\Castbar\\CHANNEL-REVERSED")
			hadouken[2].overlay:SetVertexColor(1, 1, 1)

			SV.Animate:Sprite4(hadouken[2],false,false,true)

			castbar:SetPoint("BOTTOMLEFT", castbarHolder, "BOTTOMLEFT", 1, 1)
			organizer:SetPoint("LEFT", castbar, "RIGHT", 4, 0)

			castbar.Time:SetPoint("RIGHT", castbar, "LEFT", -4, 0)
		else
			hadouken:SetPoint("CENTER", castbar:GetStatusBarTexture(), "RIGHT", 0, 0)

			hadouken[1] = hadouken:CreateTexture(nil, "ARTWORK")
			hadouken[1]:SetAllPoints(hadouken)
			hadouken[1]:SetBlendMode("ADD")
			hadouken[1]:SetTexture("Interface\\Addons\\SVUI_UnitFrames\\assets\\Castbar\\HADOUKEN")
			hadouken[1]:SetVertexColor(colors.spark[1],colors.spark[2],colors.spark[3])
			hadouken[1].overlay = hadouken:CreateTexture(nil, "OVERLAY")
			hadouken[1].overlay:SetHeight(50)
			hadouken[1].overlay:SetWidth(50)
			hadouken[1].overlay:SetPoint("CENTER", hadouken)
			hadouken[1].overlay:SetBlendMode("ADD")
			hadouken[1].overlay:SetTexture("Interface\\Addons\\SVUI_UnitFrames\\assets\\Castbar\\HADOUKEN")
			hadouken[1].overlay:SetVertexColor(1, 1, 1)

			SV.Animate:Sprite4(hadouken[1],false,false,true)

			hadouken[2] = hadouken:CreateTexture(nil, "ARTWORK")
			hadouken[2]:InsetPoints(hadouken, 4, 4)
			hadouken[2]:SetBlendMode("ADD")
			hadouken[2]:SetTexture("Interface\\Addons\\SVUI_UnitFrames\\assets\\Castbar\\CHANNEL")
			hadouken[2]:SetVertexColor(colors.spark[1],colors.spark[2],colors.spark[3])
			hadouken[2].overlay = hadouken:CreateTexture(nil, "OVERLAY")
			hadouken[2].overlay:SetHeight(50)
			hadouken[2].overlay:SetWidth(50)
			hadouken[2].overlay:SetPoint("CENTER", hadouken)
			hadouken[2].overlay:SetBlendMode("ADD")
			hadouken[2].overlay:SetTexture("Interface\\Addons\\SVUI_UnitFrames\\assets\\Castbar\\CHANNEL")
			hadouken[2].overlay:SetVertexColor(1, 1, 1)

			SV.Animate:Sprite4(hadouken[2],false,false,true)
			
			castbar:SetPoint("BOTTOMRIGHT", castbarHolder, "BOTTOMRIGHT", -1, 1)
			organizer:SetPoint("RIGHT", castbar, "LEFT", -4, 0)

			castbar.Time:SetPoint("LEFT", castbar, "RIGHT", 4, 0)
		end

		-- castbar.Time:SetPoint("CENTER", organizer, "CENTER", 0, 0)
		-- castbar.Time:SetJustifyH("CENTER")

		castbar.Text:SetAllPoints(castbar)
	else
		castbar.Time:SetFontObject(SVUI_Font_Aura)
		castbar.Time:SetTextColor(1, 1, 1, 0.9)
		castbar.Time:SetPoint("RIGHT", castbar, "LEFT", -1, 0)

		castbar.Text:SetFontObject(SVUI_Font_Caps)
		castbar.Text:SetTextColor(1, 1, 1, 0.9)
		castbar.Text:SetAllPoints(castbar)
		castbar.Text:SetWordWrap(false)

		castbar.pewpew = false

		castbar:SetStatusBarTexture(SV.media.statusbar.glow)
		castbarHolder:SetPoint("TOP", frame, "BOTTOM", 0, -4)
		castbar:InsetPoints(castbarHolder, 2, 2)

		bgFrame:SetAllPoints(castbarHolder)
		bgFrame:SetFrameLevel(bgFrame:GetFrameLevel() - 1)


		castbar.SafeZone:SetTexture(SV.media.statusbar.default)

		if reversed then 
			castbar:SetReverseFill(true)
			organizer:SetPoint("LEFT", castbar, "RIGHT", 6, 0)
		else
			organizer:SetPoint("RIGHT", castbar, "LEFT", -6, 0)
		end
	end

	if(hasModel) then
		SV.SpecialFX:SetFXFrame(bgFrame, "underlay_castbar")
		bgFrame.FX:SetFrameLevel(0)
  		SV.SpecialFX:SetFXFrame(castbar, "overlay_castbar", nil, bgFrame)
  	end

	castbar.bg = bgFrame:CreateTexture(nil, "BACKGROUND", nil, -2)
	castbar.bg:SetAllPoints(bgFrame)
	castbar.bg:SetTexture(SV.media.statusbar.default)
  	castbar.bg:SetVertexColor(0,0,0,0.5)
	
	local borderB = bgFrame:CreateTexture(nil,"OVERLAY")
	borderB:SetColorTexture(0,0,0)
	borderB:SetPoint("BOTTOMLEFT")
	borderB:SetPoint("BOTTOMRIGHT")
	borderB:SetHeight(2)

	local borderT = bgFrame:CreateTexture(nil,"OVERLAY")
	borderT:SetColorTexture(0,0,0)
	borderT:SetPoint("TOPLEFT")
	borderT:SetPoint("TOPRIGHT")
	borderT:SetHeight(2)

	local borderL = bgFrame:CreateTexture(nil,"OVERLAY")
	borderL:SetColorTexture(0,0,0)
	borderL:SetPoint("TOPLEFT")
	borderL:SetPoint("BOTTOMLEFT")
	borderL:SetWidth(2)

	local borderR = bgFrame:CreateTexture(nil,"OVERLAY")
	borderR:SetColorTexture(0,0,0)
	borderR:SetPoint("TOPRIGHT")
	borderR:SetPoint("BOTTOMRIGHT")
	borderR:SetWidth(2)

	castbar:SetStatusBarColor(colors.casting[1],colors.casting[2],colors.casting[3])
	castbar.SafeZone:SetVertexColor(0.1, 1, 0.2, 0.5)

	castbar.Spark = hadouken;
	castbar.Holder = castbarHolder;

	castbar.CastColor = oUF_SVUI.colors.casting
	castbar.SparkColor = oUF_SVUI.colors.spark

	if moverName then
		castbar.Holder.snapOffset = -6
		SV:NewAnchor(castbar.Holder, moverName)
	end 
	
	if useFader then
		SetCastbarFading(castbar, SV.media.statusbar.lazer)
	end 

	castbar.TimeFormat = "REMAINING"
	return castbar 
end 
--[[ 
########################################################## 
UPDATE
##########################################################
]]--
function MOD:PostCastStart(unit)
	if unit == "vehicle" then unit = "player" end
	local db = SV.db.UnitFrames
	if(not db or not(db and db[unit] and db[unit].castbar)) then return end
	local unitDB = db[unit].castbar

	if unitDB.displayTarget and self.curTarget then 
		self.Text:SetText(sub(self.spellName.." --> "..self.curTarget, 0, floor(32 / 245 * self:GetWidth() / db.fontSize * 12)))
	else 
		self.Text:SetText(sub(self.spellName, 0, floor(32 / 245 * self:GetWidth() / db.fontSize * 12)))
	end 
	self.unit = unit;
	if unit == "player" or unit == "target" then 
		CustomChannelUpdate(self, unit, CustomTickData.ChannelTicks[self.spellID], CustomTickData.ChainChannelTicks[self.spellID])
		CustomInterruptible(self, unit, db.castClassColor)
	end 
end 

function MOD:PostCastStop(unit, ...)
	self.chainChannel = nil;
	self.prevSpellCast = nil 
end 

function MOD:PostChannelUpdate(unit)
	if unit == "vehicle" then unit = "player" end 
	local db = SV.db.UnitFrames[unit];
	if(not db or not db.castbar or not(unit == "player")) then return end 
	CustomChannelUpdate(self, unit, db.castbar.ticks)
end 

function MOD:PostCastInterruptible(unit)

	if self.notInterruptible then
		local castColor = self.CastColor;
		self:SetStatusBarColor(castColor[1], castColor[2], castColor[3])
		if(self.Spark and self.Spark[1]) then
			local sparkColor = self.SparkColor;
			self.Spark[1]:SetVertexColor(sparkColor[1], sparkColor[2], sparkColor[3])
			self.Spark[2]:SetVertexColor(sparkColor[1], sparkColor[2], sparkColor[3])
		end
	else
		if unit == "vehicle" or unit == "player" then return end 
		CustomInterruptible(self, unit, SV.db.UnitFrames.castClassColor)
	end

	-- if unit == "vehicle" or unit == "player" then return end 
	-- CustomInterruptible(self, unit, SV.db.UnitFrames.castClassColor)
end 

function MOD:PostCastNotInterruptible(unit)
	local castColor = self.CastColor;
	self:SetStatusBarColor(castColor[1], castColor[2], castColor[3])
	if(self.Spark and self.Spark[1]) then
		local sparkColor = self.SparkColor;
		self.Spark[1]:SetVertexColor(sparkColor[1], sparkColor[2], sparkColor[3])
		self.Spark[2]:SetVertexColor(sparkColor[1], sparkColor[2], sparkColor[3])
	end
end 
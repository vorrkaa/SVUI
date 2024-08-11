--[[
##########################################################
S V U I   By: Failcoder
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
local tinsert 	= _G.tinsert;
local string 	= _G.string;
local math 		= _G.math;
local table 	= _G.table;
--[[ STRING METHODS ]]--
local format = string.format;
--[[ MATH METHODS ]]--
local abs, ceil, floor, round = math.abs, math.ceil, math.floor, math.round;
--[[ TABLE METHODS ]]--
local tremove, twipe = table.remove, table.wipe;
--BLIZZARD API
local CreateFrame           = _G.CreateFrame;
local InCombatLockdown      = _G.InCombatLockdown;
local GameTooltip           = _G.GameTooltip;
local hooksecurefunc        = _G.hooksecurefunc;
local IsAltKeyDown          = _G.IsAltKeyDown;
local IsShiftKeyDown        = _G.IsShiftKeyDown;
local IsControlKeyDown      = _G.IsControlKeyDown;
local IsModifiedClick       = _G.IsModifiedClick;
local PlaySound             = _G.PlaySound;
local PlaySoundKitID        = _G.PlaySoundKitID;
local GetTime               = _G.GetTime;
local GetCriteriaInfo            = C_ScenarioInfo.GetCriteriaInfo;
local GetWorldElapsedTimers = _G.GetWorldElapsedTimers;
local GetInstanceInfo 		= _G.GetInstanceInfo;
local GetWorldElapsedTime 	= _G.GetWorldElapsedTime;
local SecondsToTime 		= _G.SecondsToTime;
local GetChallengeModeMapTimes 	= _G.GetChallengeModeMapTimes;
local GENERIC_FRACTION_STRING 	= _G.GENERIC_FRACTION_STRING;
local CHALLENGE_MEDAL_GOLD   	= _G.CHALLENGE_MEDAL_GOLD;
local CHALLENGE_MEDAL_SILVER    = _G.CHALLENGE_MEDAL_SILVER;
local CHALLENGE_MEDAL_TEXTURES  = _G.CHALLENGE_MEDAL_TEXTURES;
local CHALLENGE_MODE_COMPLETE_TIME_EXPIRED = _G.CHALLENGE_MODE_COMPLETE_TIME_EXPIRED;
local LE_WORLD_ELAPSED_TIMER_TYPE_CHALLENGE_MODE = _G.LE_WORLD_ELAPSED_TIMER_TYPE_CHALLENGE_MODE;
local LE_WORLD_ELAPSED_TIMER_TYPE_PROVING_GROUND = _G.LE_WORLD_ELAPSED_TIMER_TYPE_PROVING_GROUND;
local LE_WORLD_ELAPSED_TIMER_TYPE_NONE = LE_WORLD_ELAPSED_TIMER_TYPE_NONE
--[[
##########################################################
GET ADDON DATA
##########################################################
]]--
local SV = _G['SVUI']
local L = SV.L
local LSM = _G.LibStub("LibSharedMedia-3.0")
local MOD = SV.QuestTracker;
--[[
##########################################################
LOCALS
##########################################################
]]--
local ROW_WIDTH = 300;
local ROW_HEIGHT = 24;
local INNER_HEIGHT = ROW_HEIGHT - 4;
local LARGE_ROW_HEIGHT = ROW_HEIGHT * 2;
local LARGE_INNER_HEIGHT = LARGE_ROW_HEIGHT - 4;
local LINE_FAILED_ICON = [[Interface\ICONS\Ability_Blackhand_Marked4Death]];
local LINE_SCENARIO_ICON = [[Interface\ICONS\Icon_Scenarios]];
local LINE_CHALLENGE_ICON = [[Interface\ICONS\Achievement_ChallengeMode_Platinum]];
local COLORS = {
	{ 0.015, 0.886, 0.38 }, --green
	{ 1, 0.894, 0.117 }, --yellow
	{ 0.847, 0.117, 0.074 }, --red
}
--[[
##########################################################
SCRIPT HANDLERS
##########################################################
]]--
local TimerBar_OnUpdate = function(self, elapsed)
	local statusbar = self.Bar
	statusbar.elapsed = statusbar.elapsed + elapsed;
	local currentTime = statusbar.duration - statusbar.elapsed
	local timeString = SecondsToTime(currentTime)
	local r,g,b = MOD:GetTimerTextColor(statusbar.duration, statusbar.elapsed)
	if(statusbar.elapsed <= statusbar.duration) then
		statusbar:SetValue(currentTime);
		statusbar.TimeLeft:SetText(timeString);
		statusbar.TimeLeft:SetTextColor(r,g,b);
	else
		self:StopTimer()
	end
end
--[[
##########################################################
TRACKER FUNCTIONS
##########################################################
]]--
---@param frame FontString Wave
local function setScenarioDeathCount(frame)
	local count, timeLost = C_ChallengeMode.GetDeathCount()
	if timeLost and timeLost > 0 and count and count > 0 then
		frame:SetText(("%i (%i)"):format(timeLost, count))
		frame:Show()
	else
		frame:Hide()
	end
end

---@param self Frame Scenario
---@param title string
---@param currentStage number
---@param numStages number
local SetScenarioData = function(self, title, currentStage, numStages)
	local objective_rows = 0
	local fill_height = 0
	local header = self.Header
	local mythic_txt = ""

	local stageName, stageDescription, numObjectives = C_Scenario.GetStepInfo()

	header.HasData = true
	local _, _, difficulty, _, _, _, _, mapID = GetInstanceInfo()

	--Mythic Keystone
	if (difficulty == 8) then
		local cmLevel, affixes, empowered = C_ChallengeMode.GetActiveKeystoneInfo();
		local damageMod, healthMod = C_ChallengeMode.GetPowerLevelDamageHealthMod(cmLevel);

		local cmID = C_ChallengeMode.GetActiveChallengeMapID();
		if(cmID) then
			local _, _, _, texture = C_ChallengeMode.GetMapUIInfo(cmID);
			header.ScenarioIcon:SetTexture(texture)

			local affixScores, bestOverAllScore = C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(cmID)
			if affixScores then
				header.TitleContainer.Score:SetText(("%i - %s"):format(affixScores.level, SecondsToTime(affixScores.durationSec)))
			end
		end


		for i, affixID in ipairs(affixes) do
			local affixName, affixDesc, affixTexture = C_ChallengeMode.GetAffixInfo(affixID);
			mythic_txt = mythic_txt.." - "..affixName;

			header.TitleContainer.Affixes[i]:SetTexture(affixTexture)
		end
		--header.TitleContainer.Title:SetText("|cFFFFFF00"..title .. ' +' .. cmLevel .. "|cFFFFFFFF" .. mythic_txt)
		header.TitleContainer.Title:SetText("|cFFFFFF00"..title .. ' +' .. cmLevel .. "|r")

	elseif (currentStage ~= 0) then
		header.TitleContainer.Title:SetText('Stage ' .. currentStage .. ' - ' .. "|cFFFFFF00"..title)
		header.ScenarioIcon:SetTexture(LINE_SCENARIO_ICON)
	else
		header.TitleContainer.Title:SetText('')
		header.TitleContainer.Title:SetText("|cFFFFFF00"..title)

		header.ScenarioIcon:SetTexture(LINE_SCENARIO_ICON)
	end

	local objective_block = header.Objectives;
	for i = 1, numObjectives do
		--local description, criteriaType, completed, quantity, totalQuantity, flags, assetID, quantityString, criteriaID, duration, elapsed, failed, kills = GetCriteriaInfo(i);

		local scenarioInfo = GetCriteriaInfo(i)
		local description = scenarioInfo.description
		local completed = scenarioInfo.completed
		local duration = scenarioInfo.duration
		local elapsed = scenarioInfo.elapsed
		local failed = scenarioInfo.failed

		if(duration > 0 and elapsed <= duration and not (failed or completed)) then
			objective_rows = objective_block:SetTimer(objective_rows, duration, elapsed);
			fill_height = fill_height + (INNER_HEIGHT + 2);
		end
		if(description and description ~= '') then
			if scenarioInfo.isWeightedProgress == true then
				objective_rows = objective_block:SetInfo(objective_rows, description, completed, failed, scenarioInfo.quantity, scenarioInfo.totalQuantity)
			else
				objective_rows = objective_block:SetInfo(objective_rows, description, completed, failed)
			end

			fill_height = fill_height + (INNER_HEIGHT + 2);
		end
	end

	if(objective_rows > 0) then

		objective_block:SetHeight(fill_height);
		objective_block:FadeIn();
	end

	fill_height = fill_height + (LARGE_ROW_HEIGHT + 2) + LARGE_ROW_HEIGHT --Offset for vertical time bar + affixes txt
	header:SetHeight(fill_height);

	MOD.Docklet.ScrollFrame.ScrollBar:SetValue(0)
end

local UnsetScenarioData = function(self)
	local header = self.Header
	header:SetHeight(1)
	header.TitleContainer.Title:SetText('')
	header.TitleContainer.Score:SetText('')
	self.Timer.Bar.Wave:SetText('')
	self.Timer.Bar.TimeLeft:SetTextColor(1, 1, 1)
	header.ScenarioIcon:SetTexture(LINE_SCENARIO_ICON)
	for i=1, 4 do
		header.TitleContainer.Affixes[i]:SetTexture('')
	end
	header.HasData = false;
	header.Objectives:Reset()
	self:SetHeight(1);
	self:SetAlpha(0);
end

local RefreshScenarioHeight = function(self)
	if(not self.Header.HasData) then
		self:Unset();
	else
		--local h1 = self.Timer:GetHeight()
		local h2 = self.Header:GetHeight()
		self:SetHeight(h2 + 2);
		self:FadeIn();
	end
end
--[[
##########################################################
TIMER FUNCTIONS
##########################################################
]]--
local MEDAL_TIMES = {};
local LAST_MEDAL;

---@param self Frame Scenario.Timer
---@param elapsed number
---@param duration number
---@param medalIndex number
---@param currWave number for proving grounds
---@param maxWave number for proving grounds
local StartTimer = function(self, elapsed, duration, medalIndex, currWave, maxWave)
	self:SetWidth(INNER_HEIGHT)
	self:FadeIn()
	self.Bar.duration = duration or 1
	self.Bar.elapsed = elapsed or 0
	self.Bar:SetMinMaxValues(0, self.Bar.duration)
	self.Bar:SetValue(self.Bar.elapsed)
	self:SetScript("OnUpdate", TimerBar_OnUpdate)

	--local blockHeight = MOD.Headers["Scenario"].Block:GetHeight();
	--MOD.Headers["Scenario"].Block:SetHeight(blockHeight + INNER_HEIGHT + 4);

	if (medalIndex < 4) then
		self.Bar.Wave:SetFormattedText(GENERIC_FRACTION_STRING, currWave, maxWave);
	else
		self.Bar.Wave:SetText(currWave);
	end
end

---@param self Frame Scenario.Timer
local StopTimer = function(self)
	local timerWidth = self:GetWidth()
	self:SetWidth(1);
	self:SetAlpha(0);
	self.Bar.duration = 1
	self.Bar.elapsed = 0
	self.Bar.playedSound = false
	self.Bar.timeLimit = nil
	self.Bar:SetMinMaxValues(0, self.Bar.duration);
	self.Bar:SetValue(0);
	self:SetScript("OnUpdate", nil);

end

---@param self Frame Scenario.Timer
---@param elapsed number
---@param maxTime number Time to validate key
local SetChallengeMedals = function(self, elapsed, maxTime)

	self:SetWidth(INNER_HEIGHT)
	self:FadeIn();
	local bar = self.Bar
	bar.timeLimit = maxTime
	bar:SetMinMaxValues(0, maxTime)
	bar:SetValue(elapsed)
	bar.elapsed = elapsed

	local height = bar:GetHeight()
	local chests = bar.Chests

	local cmID = C_ChallengeMode.GetActiveChallengeMapID()
	if cmID then

		MEDAL_TIMES[1] = maxTime * 0.6; -- 3 chest
		MEDAL_TIMES[2] = maxTime * 0.8; -- 2 chest
		MEDAL_TIMES[3] = maxTime -- 1 chest

		chests[1].Spark:ClearAllPoints()
		chests[1].Spark:SetPoint("TOP", bar, "TOP", 0, -height * 0.6)

		chests[2].Spark:ClearAllPoints()
		chests[2].Spark:SetPoint("TOP", bar, "TOP", 0, -height * 0.8)

		chests[3].Spark:ClearAllPoints()
		chests[3].Spark:SetPoint("TOP", bar, "TOP", 0, -height)
	else
		for i=1, 3 do
			chests[i]:ClearAllPoints()
		end

		for i = 1, select("#", maxTime) do
			MEDAL_TIMES[i] = select(i, maxTime)
		end
	end

	self:UpdateMedals(elapsed)
end

---@param self Frame Scenario.Timer
---@param elapsed number
local UpdateChallengeMedals = function(self, elapsed)
	local isDeplete = elapsed > MEDAL_TIMES[ #MEDAL_TIMES ]
	local bar = self.Bar;
	local timeLeft = bar.timeLimit - elapsed

	for i = #MEDAL_TIMES, 1, -1 do
		bar.Chests[i].Medal:SetDesaturated(elapsed > MEDAL_TIMES[i])

		if elapsed < MEDAL_TIMES[i] then
			bar:SetStatusBarColor(unpack(COLORS[i]))
		end
	end

	bar.elapsed = elapsed
	if timeLeft <= 10 and not bar.playedSound then
		PlaySound(34154)
		bar.playedSound = true
	end

	if isDeplete then
		bar.TimeLeft:SetTextColor(0.847, 0.117, 0.074)
		bar.TimeLeft:SetText(SecondsToTime(elapsed))
		bar:SetValue(0)
	else
		bar.TimeLeft:SetText(SecondsToTime(timeLeft))
		bar:SetValue(timeLeft)
	end

	setScenarioDeathCount(bar.Wave)

end

---@param self Frame Scenario.Timer
---@param elapsed number
local UpdateChallengeTimer = function(self, elapsed)
	local bar = self.Bar

	if bar.timeLimit then
		self:UpdateMedals(elapsed)
	end
end

local UpdateAllTimers = function(self, ...)
	for i = 1, select("#", ...) do
		local timerID = select(i, ...);
		local _, elapsedTime, type = GetWorldElapsedTime(timerID);

		if (type == LE_WORLD_ELAPSED_TIMER_TYPE_CHALLENGE_MODE) then
			local cmID = C_ChallengeMode.GetActiveChallengeMapID();
			if(cmID) then
				local _, _, maxTime = C_ChallengeMode.GetMapUIInfo(cmID);

				self:SetMedals(elapsedTime, maxTime);
				return;
			end
		elseif (type == LE_WORLD_ELAPSED_TIMER_TYPE_PROVING_GROUND) then
			local diffID, currWave, maxWave, duration = C_Scenario.GetProvingGroundsInfo()
			if (duration > 0) then
				self:StartTimer(elapsedTime, duration, diffID, currWave, maxWave)
				return;
			end
		elseif type ~= LE_WORLD_ELAPSED_TIMER_TYPE_NONE then
			--a simple update
			if self.Bar.timeLimit then
				self:UpdateMedals(self.Bar.elapsed + ...)
			end
		end
	end

end

---@param self Frame Scenario
local function InitData(self)
	self.Header.Objectives:Reset()
	local title, currentStage, numStages, flags, _, _, _, xp, money = C_Scenario.GetInfo();

	if title then
		if currentStage > numStages then
			self.Timer:StopTimer()
			self.Header.HasData = false
		else
			self:Set(title, currentStage, numStages)
			if(currentStage > 1) then
				PlaySound(PlaySoundKitID and "UI_Scenario_Stage_End" or 31757);
			end
		end
	end
end

---@param self Frame Scenario
---@param event string event
---@param ... any payload for the event
local RefreshScenarioObjective = function(self, event, ...)

	if(C_Scenario.IsInScenario()) then

		if(event == "PLAYER_ENTERING_WORLD" or event ==  "CHALLENGE_MODE_START") then
			if not self.Header.HasData then
				InitData(self)
				if (select(3, GetInstanceInfo()) == 8) then
					self.Timer:SetScript("OnUpdate", UpdateAllTimers)
				end
				self:RefreshHeight()
			end
			self.Timer:UpdateTimers(GetWorldElapsedTimers())
		elseif(event == "WORLD_STATE_TIMER_START"  or event ==  "CHALLENGE_MODE_RESET") then
			self.Timer:UpdateTimers(...)
			-- MM+
			if (select(3, GetInstanceInfo()) == 8) then
				self.Timer:SetScript("OnUpdate", UpdateAllTimers)
			end
		elseif(event == "WORLD_STATE_TIMER_STOP" or event ==  "CHALLENGE_MODE_COMPLETED") then
			self.Timer:StopTimer()
		elseif(event == "PROVING_GROUNDS_SCORE_UPDATE") then
			local score = ...
			self.Header.TitleContainer.Score:SetText(score)
		elseif event == "CHALLENGE_MODE_DEATH_COUNT_UPDATED" then
			setScenarioDeathCount(self.Timer.Bar.Wave)
		elseif(event == "SCENARIO_COMPLETED" or event == 'SCENARIO_UPDATE' or event == 'SCENARIO_CRITERIA_UPDATE') then
			if(event == "SCENARIO_COMPLETED") then
				self.Timer:StopTimer()
			else
				self.Header.Objectives:Reset()
				local title, currentStage, numStages, flags, _, _, _, xp, money = C_Scenario.GetInfo();

				if title then
					if currentStage > numStages then
						self.Timer:StopTimer()
						self.Header.HasData = false
					else
						self:Set(title, currentStage, numStages)
						if(currentStage > 1) then
							PlaySound(PlaySoundKitID and "UI_Scenario_Stage_End" or 31757);
						end
					end
				end

			end
		end

	else
		self.Timer:StopTimer()
		self.Header.HasData = false
	end

	self:RefreshHeight()
end

--[[
##########################################################
CORE FUNCTIONS
##########################################################
]]--
function MOD:UpdateScenarioObjective(event, ...)
	self.Headers["Scenario"]:Refresh(event, ...)
	self:UpdateDimensions();
end

local function UpdateScenarioLocals(...)
	ROW_WIDTH, ROW_HEIGHT, INNER_HEIGHT, LARGE_ROW_HEIGHT, LARGE_INNER_HEIGHT = ...;
end

function MOD:InitializeScenarios()
	local scrollChild = self.Docklet.ScrollFrame.ScrollChild;

	local scenario = CreateFrame("Frame", nil, scrollChild)
	scenario:SetHeight(ROW_HEIGHT);
	scenario:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, 0);
	scenario:SetPoint("TOPRIGHT", scrollChild, "TOPRIGHT", 0, 0);

	scenario.Set = SetScenarioData
	scenario.Unset = UnsetScenarioData
	scenario.Refresh = RefreshScenarioObjective
	scenario.RefreshHeight = RefreshScenarioHeight

	--[[
		Construction of the Window

		Header as parent
			Badge as border Icon
			ScenarioIcon
			TitleContainer
				Title
				Score

		TimerBar
		TimerText
		MedalSparks
		MedalIcons

	]]--

	--HEADER
	local header = CreateFrame("Frame", nil, scenario)
	header:SetPoint("TOPLEFT", scenario, "TOPLEFT", 2, -2)
	header:SetPoint("TOPRIGHT", scenario, "TOPRIGHT", -2, -2)
	header:SetHeight(1)
	header:SetStyle("Frame", "Lite")

	local badge = CreateFrame("Frame", nil, header)
	badge:SetPoint("TOPLEFT", header, "TOPLEFT", 4, -4);
	badge:SetSize((LARGE_INNER_HEIGHT - 4), (LARGE_INNER_HEIGHT - 4));
	badge:SetStyle("!_Frame", "Inset")

	local scenarioIcon = badge:CreateTexture(nil,"OVERLAY")
	scenarioIcon:InsetPoints(badge);
	scenarioIcon:SetTexture(LINE_SCENARIO_ICON)
	scenarioIcon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))

	local titleContainer = CreateFrame("Frame", nil, header)
	titleContainer:SetPoint("TOPLEFT", badge, "TOPRIGHT", 4, -1);
	titleContainer:SetPoint("TOPRIGHT", header, "TOPRIGHT", -4, 0);
	titleContainer:SetHeight(INNER_HEIGHT);
	titleContainer:SetStyle("Frame")

	local title = titleContainer:CreateFontString(nil,"OVERLAY")
	title:SetFontObject(SVUI_Font_Quest_Header)
	title:SetJustifyH('LEFT')
	title:SetJustifyV('TOP')
	title:SetText('')
	title:SetPoint("TOPLEFT", titleContainer, "TOPLEFT", 4, 0);
	title:SetPoint("BOTTOMLEFT", titleContainer, "BOTTOMLEFT", 4, 0);

	local score = titleContainer:CreateFontString(nil,"OVERLAY")
	score:SetFontObject(SVUI_Font_Quest)
	score:SetJustifyH('RIGHT')
	score:SetJustifyV('TOP')
	score:SetTextColor(1,1,0)
	score:SetText('')
	score:SetPoint("TOPRIGHT", titleContainer, "TOPRIGHT", -2, 0);
	score:SetPoint("BOTTOMRIGHT", titleContainer, "BOTTOMRIGHT", -2, 0);

	local affixes = {}
	for i=1,4 do
		affixes[i] = titleContainer:CreateTexture(nil, "OVERLAY")
		affixes[i]:SetSize(24, 24)
		affixes[i]:SetTexCoord(unpack(SVUI_ICON_COORDS))
		if i == 1 then
			affixes[i]:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
		else
			affixes[i]:SetPoint("LEFT", affixes[i-1], "RIGHT", 0, 0)
		end
	end

	titleContainer.Title = title
	titleContainer.Score = score
	titleContainer.Affixes = affixes

	header.Badge = badge
	header.ScenarioIcon = scenarioIcon
	header.TitleContainer = titleContainer

	--TIMER

	local timer = CreateFrame("Frame", nil, header)
	timer:SetPoint("TOPLEFT", badge, "BOTTOMLEFT", 0, -4);
	timer:SetPoint("TOPRIGHT", badge, "BOTTOMRIGHT", 0, -4);
	timer:SetPoint("BOTTOM", scenario, "BOTTOM", 0, 20)
	--timer:SetWidth(INNER_HEIGHT)
	--timer:SetHeight(INNER_HEIGHT);
	timer:SetStyle("!_Frame", "Bar");

	timer.StartTimer = StartTimer;
	timer.StopTimer = StopTimer;
	timer.UpdateTimers = UpdateAllTimers;
	timer.SetMedals = SetChallengeMedals;
	timer.UpdateMedals = UpdateChallengeMedals;
	timer.UpdateChallenges = UpdateChallengeTimer;

	local bar = CreateFrame("StatusBar", nil, timer);
	bar:SetAllPoints(timer);
	bar:SetStatusBarTexture(SV.media.statusbar.default)
	bar:SetStatusBarColor( 0.5, 0, 1) --1,0.15,0.08
	--bar:SetStatusBarColor( 1,0.15,0.08 )
	bar:SetMinMaxValues(0, 1)
	bar:SetValue(0)
	bar:SetOrientation("VERTICAL")
	--bar:SetReverseFill(true)

	local overlay = bar:CreateTexture(nil, "OVERLAY", nil, 2)
	overlay:SetTexture([[Interface\AddOns\SVUI_!Core\assets\backgrounds\pattern\PATTERN12]])
	overlay:SetAllPoints(true)
	overlay:SetBlendMode("BLEND")
	overlay:SetGradient("VERTICAL", CreateColor(1, 1, 1, 0.25), CreateColor(1,1,1,0.75))
	bar.Overlay = overlay

	local wave = bar:CreateFontString(nil,"OVERLAY")
	wave:SetPoint("TOPLEFT", bar, "TOPLEFT", 0, -4);
	wave:SetPoint("TOPRIGHT", bar, "TOPRIGHT", 0, -4);
	wave:SetFontObject(SVUI_Font_Quest);
	wave:SetJustifyH('CENTER')
	wave:SetTextColor(1,1,0)
	wave:SetText('')

	local timeLeft = bar:CreateFontString(nil,"OVERLAY");
	timeLeft:SetPoint("BOTTOM", header, "BOTTOM", 0, 10);
	timeLeft:SetFontObject(SVUI_Font_Quest_Number);
	timeLeft:SetTextColor(1,1,1)
	timeLeft:SetText('')

	local chests = {}
	--Sparks and Medals
	local spark, medal
	for i=1, 3 do
		spark = bar:CreateTexture(nil,"OVERLAY")
		spark:SetWidth((LARGE_INNER_HEIGHT - 4))
		spark:SetHeight(1)
		spark:SetColorTexture(1, 1, 1)

		medal = bar:CreateTexture(nil, "OVERLAY")
		medal:SetSize(INNER_HEIGHT*1.5, INNER_HEIGHT*1.5)
		medal:SetPoint("LEFT", spark, "RIGHT", -2, 0)
		medal:SetTexCoord(unpack(SVUI_ICON_COORDS))
		medal:SetTexture(CHALLENGE_MEDAL_TEXTURES[4 - i]) --bronze is 1st index, we want gold as 1st ...

		chests[i] = {
			["Spark"] = spark,
			["Medal"] = medal,
		}
	end

	bar.Wave = wave
	bar.TimeLeft = timeLeft
	bar.Chests = chests

	timer.Bar = bar
	timer:SetAlpha(0)

	local objectives = MOD.NewObjectiveHeader(header);
	objectives:SetPoint("LEFT", timer, "RIGHT", 12, 0)
	objectives:SetPoint("RIGHT", header, "RIGHT", -4, 0)
	objectives:SetHeight(1);

	header.Objectives = objectives
	header.HasData = false;

	scenario.Timer = timer;
	scenario.Header = header;

	self.Headers["Scenario"] = scenario;

	self.Headers["Scenario"]:RefreshHeight()

	self:RegisterEvent("PLAYER_ENTERING_WORLD", self.UpdateScenarioObjective);
	self:RegisterEvent("PROVING_GROUNDS_SCORE_UPDATE", self.UpdateScenarioObjective);
	self:RegisterEvent("WORLD_STATE_TIMER_START", self.UpdateScenarioObjective);
	self:RegisterEvent("WORLD_STATE_TIMER_STOP", self.UpdateScenarioObjective);
	self:RegisterEvent("SCENARIO_UPDATE", self.UpdateScenarioObjective);
	self:RegisterEvent("SCENARIO_CRITERIA_UPDATE", self.UpdateScenarioObjective);
	self:RegisterEvent("SCENARIO_COMPLETED", self.UpdateScenarioObjective);

	self:RegisterEvent("CHALLENGE_MODE_START", self.UpdateScenarioObjective);
	self:RegisterEvent("CHALLENGE_MODE_COMPLETED", self.UpdateScenarioObjective);
	self:RegisterEvent("CHALLENGE_MODE_RESET", self.UpdateScenarioObjective);
	self:RegisterEvent("CHALLENGE_MODE_DEATH_COUNT_UPDATED", self.UpdateScenarioObjective)

	SV.Events:On("QUEST_UPVALUES_UPDATED", UpdateScenarioLocals, true);
end

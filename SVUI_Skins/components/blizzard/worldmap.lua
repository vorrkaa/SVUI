--[[
##############################################################################
S V U I   By: Failcoder
##############################################################################
--]]
--[[ GLOBALS ]]--
local _G = _G;
local unpack  = _G.unpack;
local select  = _G.select;
--[[ ADDON ]]--
local SV = _G['SVUI'];
local L = SV.L;
local MOD = SV.Skins;
local Schema = MOD.Schema;
--[[
##########################################################
HELPERS
##########################################################
]]--
local function AdjustMapLevel()
  if InCombatLockdown()then return end
    local WorldMapFrame = _G.WorldMapFrame;
    WorldMapFrame:SetFrameStrata("HIGH");
    WorldMapTooltip:SetFrameStrata("TOOLTIP");
    WorldMapFrame:SetFrameLevel(1)
    QuestScrollFrame.DetailFrame:SetFrameLevel(2)
end

local function WorldMap_SmallView()
  local WorldMapFrame = _G.WorldMapFrame;
  WorldMapFrame.Panel:ClearAllPoints()
  WorldMapFrame.Panel:WrapPoints(WorldMapFrame, 4, 4)
  if(SVUI_WorldMapCoords) then
    SVUI_WorldMapCoords:SetPoint("BOTTOMLEFT", WorldMapFrame, "BOTTOMLEFT", 5, 5)
  end
end

local function WorldMap_FullView()
  local WorldMapFrame = _G.WorldMapFrame;
  WorldMapFrame.Panel:ClearAllPoints()
  local w, h = WorldMapDetailFrame:GetSize()
  WorldMapFrame.Panel:SetSize(w + 24, h + 98)
  WorldMapFrame.Panel:SetPoint("TOP", WorldMapFrame, "TOP", 0, 0)
  if(SVUI_WorldMapCoords) then
    SVUI_WorldMapCoords:SetPoint("BOTTOMLEFT", WorldMapFrame, "BOTTOMLEFT", 5, 5)
  end
end

local function StripQuestMapFrame()
    local WorldMapFrame = _G.WorldMapFrame;

    WorldMapFrame.BorderFrame:RemoveTextures(true);
    
    WorldMapFrame.NavBar:RemoveTextures(true);
    WorldMapFrame.NavBar.overlay:RemoveTextures(true);

    
    QuestMapFrame:RemoveTextures(true)
    QuestMapFrame.VerticalSeparator:Hide()
    QuestMapFrame.DetailsFrame:RemoveTextures(true)
    -- QuestMapFrame.DetailsFrame.BackButton:RemoveTextures(true)
    QuestMapFrame.DetailsFrame.BackFrame:RemoveTextures(true)
    QuestMapFrame.DetailsFrame.ShareButton:RemoveTextures(true)
    QuestMapFrame.DetailsFrame.TrackButton:RemoveTextures(true)
    QuestMapFrame.DetailsFrame.RewardsFrameContainer.RewardsFrame:RemoveTextures(true)
    QuestMapFrame.DetailsFrame.BorderFrame:RemoveTextures(true)
    QuestMapFrame.DetailsFrame.AbandonButton:RemoveTextures(true)
    QuestMapFrame.DetailsFrame:SetStyle("Frame", "Paper")
    QuestMapFrame.DetailsFrame.BackFrame.BackButton:SetStyle("Button")
    QuestMapFrame.DetailsFrame.AbandonButton:SetStyle("Button")
    QuestMapFrame.DetailsFrame.ShareButton:SetStyle("Button")
    QuestMapFrame.DetailsFrame.TrackButton:SetStyle("Button")
    SV.API:Set("ScrollBar", QuestMapDetailsScrollFrame)
    QuestMapDetailsScrollFrame:ClearAllPoints()
    QuestMapDetailsScrollFrame:SetPoint("TOPLEFT", QuestMapFrame.DetailsFrame, "TOPLEFT", 5, -43)
    QuestMapDetailsScrollFrame:SetPoint("BOTTOMRIGHT", QuestMapFrame.DetailsFrame.RewardsFrameContainer, "TOPRIGHT", -4, 10)
    QuestMapDetailsScrollFrame.ScrollBar:ClearAllPoints()
    QuestMapDetailsScrollFrame.ScrollBar:SetPoint("TOPLEFT", QuestMapDetailsScrollFrame, "TOPRIGHT", 13, 47)
    QuestMapDetailsScrollFrame.ScrollBar:SetPoint("BOTTOMLEFT", QuestMapDetailsScrollFrame, "BOTTOMRIGHT", 13, -20)
  
    SV.API:Set("ScrollBar", QuestScrollFrame)
    
    SV.API:Set("Skin", QuestMapFrame.DetailsFrame.RewardsFrameContainer.RewardsFrame, 0, -10, 0, 0)
    
    QuestScrollFrame.BorderFrame:RemoveTextures(true)
    QuestScrollFrame.Background:Hide()
    QuestScrollFrame.Edge:SetAlpha(0)
    
    QuestScrollFrame.Contents.Separator.Divider:Hide()
    -- QuestScrollFrame.Contents.BackGround:Hide()
    -- QuestScrollFrame.Contents.TopFiligree:Hide()
    -- QuestScrollFrame.Contents:SetStyle("Frame", "Blackout")
    -- SV.API:Set("Frame", QuestScrollFrame.Contents)
    

    -- QuestScrollFrame.DetailFrame.BottomDetail:Hide()
    -- QuestScrollFrame.DetailFrame:RemoveTextures(true)

    -- QuestMapFrame.DetailsFrame.CompleteQuestFrame.CompleteButton:SetStyle("Button")
    -- QuestMapFrame.DetailsFrame.CompleteQuestFrame:RemoveTextures(true)
    -- QuestMapFrame.DetailsFrame.CompleteQuestFrame.CompleteButton:RemoveTextures(true)


    local detailWidth = QuestMapFrame.DetailsFrame.RewardsFrameContainer:GetWidth()
    local detailHeight = WorldMapFrame.ScrollContainer:GetHeight()
    QuestMapFrame.DetailsFrame:ClearAllPoints()
    -- QuestMapFrame.DetailsFrame:SetPoint("BOTTOMRIGHT", QuestMapFrame, "BOTTOMRIGHT", 4, -50)
    QuestMapFrame.DetailsFrame:SetPoint("TOPLEFT", WorldMapFrame.ScrollContainer, "TOPRIGHT", 5, -4)
    QuestMapFrame.DetailsFrame:SetPoint("BOTTOMRIGHT", QuestMapFrame, "BOTTOMRIGHT", -20, 2)
    QuestMapFrame.DetailsFrame:SetWidth(detailWidth)
    -- QuestMapFrame.DetailsFrame:SetSize(detailWidth, detailHeight)
end

local function UpdateQuestLog()
  for header in QuestScrollFrame.campaignHeaderFramePool:EnumerateActive() do
		if header.IsSkinned then return end

    if header.TopFiligree then
      header.TopFiligree:Hide()
    end

    header:DisableDrawLayer("BACKGROUND")
    -- if header.Background then
      -- header.Background:SetTexture("")
    -- end

    header:SetAlpha(.8)

    header.HighlightTexture:SetAllPoints(header.Background)
    header.HighlightTexture:SetAlpha(0)

    header.IsSkinned = true
	end

  --SV.media.statusbar.default

  for header in QuestScrollFrame.headerFramePool:EnumerateActive() do
		if header.IsSkinned then return end

    header:RemoveTextures()
    header:SetAlpha(.8)

    header.IsSkinned = true
	end

  for header in QuestScrollFrame.objectiveFramePool:EnumerateActive() do
		if header.IsSkinned then return end

    header:RemoveTextures()
    header:SetAlpha(.8)

    header.IsSkinned = true
	end

end

--[[
##########################################################
WORLDMAP MODR
##########################################################
]]--
local function WorldMapStyle()
    --print('test WorldMapStyle')
    if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.worldmap ~= true then return end

    SV.API:Set("Window", WorldMapFrame, true, true)
    SV.API:Set("ScrollBar", QuestScrollFrame)
    SV.API:Set("ScrollBar", WorldMapQuestScrollFrame)
    SV.API:Set("ScrollBar", WorldMapQuestDetailScrollFrame, 4)
    SV.API:Set("ScrollBar", WorldMapQuestRewardScrollFrame, 4)

    -- QuestScrollFrame.DetailFrame:SetStyle("Frame", "Blackout")
    
    WorldMapFrame.BorderFrame.NineSlice:RemoveTextures(true);
    WorldMapFrame.BorderFrame.TitleContainer.TitleText:SetFontObject(SVUI_Font_Header)
    WorldMapFrameCloseButton:SetFrameLevel(999)

    SV.API:Set("CloseButton", WorldMapFrameCloseButton)
    SV.API:Set("DropDown", WorldMapLevelDropDown)
    SV.API:Set("DropDown", WorldMapZoneMinimapDropDown)
    SV.API:Set("DropDown", WorldMapContinentDropDown)
    SV.API:Set("DropDown", WorldMapZoneDropDown)
    SV.API:Set("DropDown", WorldMapShowDropDown)
 
    --print('test WorldMapStyle 3')
    StripQuestMapFrame()

    -- Movable Window
    WorldMapFrame:SetMovable(true)
    WorldMapFrame:EnableMouse(true)
    WorldMapFrame:RegisterForDrag("LeftButton")
    WorldMapFrame:SetScript("OnDragStart", WorldMapFrame.StartMoving)
    WorldMapFrame:SetScript("OnDragStop", WorldMapFrame.StopMovingOrSizing)

    hooksecurefunc('QuestLogQuests_Update', UpdateQuestLog)
end

--[[ TODO
SplashFrame
]]--

--[[
##########################################################
MOD LOADING
##########################################################
]]--
MOD:SaveCustomStyle("WORLDMAP", WorldMapStyle)


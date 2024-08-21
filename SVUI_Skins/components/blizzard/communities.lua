--[[
##########################################################
Created by Vorka
##########################################################
]]--

--[[
##########################################################
LUA DATA
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack  = _G.unpack;
local select  = _G.select;
--[[ STRING METHODS ]]--

--[[ MATH METHODS ]]--

--[[ TABLE METHODS ]]--

--[[
##########################################################
WOW DATA
##########################################################
]]--

--[[
##########################################################
ADDON DATA
##########################################################
]]--
local SV = _G['SVUI'];
local L = SV.L;
local MOD = SV.Skins;
local Schema = MOD.Schema;
--[[
##########################################################
LOCAL DATA
##########################################################
]]--
local IconRoles = [[Interface\AddOns\SVUI_UnitFrames\assets\UNIT-ROLES]];
local RoleIconData = {
    [Enum.LFGRole.Tank] = { 0, 0.5, 0, 0.5},
    [Enum.LFGRole.Healer] = { 0, 0.5, 0.5, 1},
    [Enum.LFGRole.Damage] = { 0.5, 1, 0, 0.5},
}
--[[
##########################################################
CORE FUNCTIONS
##########################################################
]]--
local function skinTab(frame)
    local Icon = frame.Icon
    local IconOverlay = frame.IconOverlay
    for _, region in ipairs({frame:GetRegions()}) do
        if region ~= Icon and region ~= IconOverlay then
            region:Die()
        end
    end
end

local function CommunitiesStyle()

    if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.communities ~= true then return end

    local frame = CommunitiesFrame
    frame:RemoveTextures(true)
    frame.NineSlice:Hide()
    frame:SetStyle("Frame", "Window")
    frame.Inset:RemoveTextures(true)
    frame.Inset.NineSlice:Hide()
    frame.Inset:SetStyle("!_Frame", "Window2")
    frame.Inset:SetPanelColor("darkest")

    frame.TitleContainer.TitleText:SetFontObject(SVUI_Font_Header)

    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    SV.API:Set("CloseButton", frame.CloseButton)

    local portrait = frame.PortraitContainer
    portrait:RemoveTextures(true)
    --frame.PortraitOverlay:Hide()
    frame.PortraitOverlay.Show = frame.PortraitOverlay.Hide

    -- [[ BUTTONS ]]--

    frame.InviteButton:SetStyle("Button")
    frame.GuildLogButton:SetStyle("Button")
    frame.CommunitiesControlFrame.CommunitiesSettingsButton:SetStyle("Button")
    frame.CommunitiesControlFrame.GuildControlButton:SetStyle("Button")
    frame.CommunitiesControlFrame.GuildRecruitmentButton:SetStyle("Button")

    -- [[ MEMBERLIST ]]--

    local memberList = frame.MemberList
    memberList.InsetFrame:RemoveTextures(true)
    memberList.InsetFrame.NineSlice:Hide()
    memberList.ShowOfflineButton:SetStyle("CheckButton")
    memberList.ColumnDisplay:RemoveTextures()
    hooksecurefunc(memberList.ColumnDisplay, "LayoutColumns", function(s)
        for _, child in ipairs({s:GetChildren()}) do
            if child:IsObjectType("Button") and not child.skinned then
                child:RemoveTextures()
                child.skinned = true
            end
        end
    end)

    -- [[ APPLICANTS ]]--

    local applicant = frame.ApplicantList
    applicant.InsetFrame:RemoveTextures(true)
    applicant.InsetFrame.NineSlice:Hide()
    applicant.ColumnDisplay:RemoveTextures()
    hooksecurefunc(applicant, "RefreshLayout", function(a)
        for _, child in ipairs({a.ColumnDisplay:GetChildren()}) do
            if child:IsObjectType("Button") and not child.skinned then
                child:RemoveTextures()
                child.skinned = true
            end
        end
    end)

    -- [[ COMMUNITIES LIST ]]--

    local communitiesList = frame.CommunitiesList
    communitiesList:RemoveTextures(true)
    communitiesList.FilligreeOverlay:RemoveTextures()
    communitiesList.InsetFrame:RemoveTextures(true)
    communitiesList.InsetFrame.NineSlice:Hide()

    -- [[ CHAT ]]--

    local chat = frame.Chat
    chat.InsetFrame:RemoveTextures(true)
    chat.InsetFrame.NineSlice:Hide()
    JumpToUnreadButton:SetStyle("Button")

    frame.ChatEditBox:RemoveTextures()
    frame.ChatEditBox:SetStyle("EditBox")

    --frame.CommunitiesCalendarButton

    -- [[ TAB ]]--

    skinTab(frame.ChatTab)
    skinTab(frame.RosterTab)
    frame.RosterTab:ClearAllPoints()
    frame.RosterTab:SetPoint("TOPLEFT", frame.ChatTab, "BOTTOMLEFT", 0, -2)
    skinTab(frame.GuildBenefitsTab)
    frame.GuildBenefitsTab:ClearAllPoints()
    frame.GuildBenefitsTab:SetPoint("TOPLEFT", frame.RosterTab, "BOTTOMLEFT", 0, -2)
    skinTab(frame.GuildInfoTab)
    frame.GuildInfoTab:ClearAllPoints()
    frame.GuildInfoTab:SetPoint("TOPLEFT", frame.GuildBenefitsTab, "BOTTOMLEFT", 0, -2)

    frame.NotificationSettingsDialog:RemoveTextures(true)
    frame.NotificationSettingsDialog:SetStyle("!_Frame", "Window2")
    frame.NotificationSettingsDialog:SetPanelColor("darkest")

    frame.NotificationSettingsDialog.Selector:RemoveTextures()
    frame.NotificationSettingsDialog.Selector.OkayButton:SetStyle("Button")
    frame.NotificationSettingsDialog.Selector.CancelButton:SetStyle("Button")

    -- [[ PERKS ]]--
    local perks = frame.GuildBenefitsFrame
    perks:RemoveTextures()

    perks.FactionFrame.Bar:RemoveTextures()
    perks.FactionFrame.Bar.Progress:SetTexture(SV.media.statusbar.default)

    perks.Perks:RemoveTextures()
    hooksecurefunc(perks.Perks.ScrollBox, "Update", function(scrollFrame)
        for i, elementFrame in scrollFrame:EnumerateFrames() do
            if not elementFrame.skinned then
                local icon = elementFrame.Icon:GetTexture()
                elementFrame:RemoveTextures()
                elementFrame.Icon:SetTexture(icon)
                elementFrame.Icon:SetTexCoord(unpack(SVUI_ICON_COORDS))
                elementFrame.skinned = true
            end
        end
    end)
    perks.Rewards:RemoveTextures()
    hooksecurefunc(perks.Rewards.ScrollBox, "Update", function(scrollFrame)
        for i, elementFrame in scrollFrame:EnumerateFrames() do
            if not elementFrame.skinned then
                local icon = elementFrame.Icon:GetTexture()
                elementFrame:RemoveTextures()
                elementFrame.Icon:SetTexture(icon)
                elementFrame.Icon:SetTexCoord(unpack(SVUI_ICON_COORDS))
                elementFrame.skinned = true
            end
        end
    end)

    -- [[ GUILD INFO ]]--
    local guildInfo = frame.GuildDetailsFrame
    guildInfo:RemoveTextures()
    guildInfo.Info:RemoveTextures()
    guildInfo.News:RemoveTextures()

    -- [[ COMMUNITY FINDER FRAME ]]--
    local finderFrame = frame.CommunityFinderFrame
    finderFrame.InsetFrame:RemoveTextures(true)
    finderFrame.InsetFrame.NineSlice:Hide()
    finderFrame.InsetFrame:SetStyle("!_Frame", "Window2")
    finderFrame.InsetFrame:SetPanelColor("darkest")

    finderFrame.OptionsList.Search:SetStyle("Button")
    finderFrame.OptionsList.DpsRoleFrame.Icon:SetTexture(IconRoles)
    finderFrame.OptionsList.DpsRoleFrame.Icon:SetTexCoord(unpack(RoleIconData[Enum.LFGRole.Damage]))
    finderFrame.OptionsList.HealerRoleFrame.Icon:SetTexture(IconRoles)
    finderFrame.OptionsList.HealerRoleFrame.Icon:SetTexCoord(unpack(RoleIconData[Enum.LFGRole.Healer]))
    finderFrame.OptionsList.TankRoleFrame.Icon:SetTexture(IconRoles)
    finderFrame.OptionsList.TankRoleFrame.Icon:SetTexCoord(unpack(RoleIconData[Enum.LFGRole.Tank]))

    skinTab(finderFrame.ClubFinderSearchTab)
    skinTab(finderFrame.ClubFinderPendingTab)
    finderFrame.ClubFinderPendingTab:ClearAllPoints()
    finderFrame.ClubFinderPendingTab:SetPoint("TOPLEFT", finderFrame.ClubFinderSearchTab, "BOTTOMLEFT", 0, -2)

    -- [[ GUILD FINDER FRAME ]]--
    finderFrame = frame.GuildFinderFrame
    finderFrame.InsetFrame:RemoveTextures(true)
    finderFrame.InsetFrame.NineSlice:Hide()
    finderFrame.InsetFrame:SetStyle("!_Frame", "Window2")
    finderFrame.InsetFrame:SetPanelColor("darkest")

    finderFrame.OptionsList.Search:SetStyle("Button")
    finderFrame.OptionsList.DpsRoleFrame.Icon:SetTexture(IconRoles)
    finderFrame.OptionsList.DpsRoleFrame.Icon:SetTexCoord(unpack(RoleIconData[Enum.LFGRole.Damage]))
    finderFrame.OptionsList.HealerRoleFrame.Icon:SetTexture(IconRoles)
    finderFrame.OptionsList.HealerRoleFrame.Icon:SetTexCoord(unpack(RoleIconData[Enum.LFGRole.Healer]))
    finderFrame.OptionsList.TankRoleFrame.Icon:SetTexture(IconRoles)
    finderFrame.OptionsList.TankRoleFrame.Icon:SetTexCoord(unpack(RoleIconData[Enum.LFGRole.Tank]))

    skinTab(finderFrame.ClubFinderSearchTab)
    skinTab(finderFrame.ClubFinderPendingTab)
    finderFrame.ClubFinderPendingTab:ClearAllPoints()
    finderFrame.ClubFinderPendingTab:SetPoint("TOPLEFT", finderFrame.ClubFinderSearchTab, "BOTTOMLEFT", 0, -2)
end
--[[
##########################################################
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle("Blizzard_Communities", CommunitiesStyle)
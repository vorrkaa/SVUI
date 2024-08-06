--[[
##############################################################################
S V U I   By: Vorka
##############################################################################
--]]
--[[ GLOBALS ]]--
local _G = _G;
local unpack  	= unpack;
local select  	= _G.select;
local ipairs  	= _G.ipairs;
local pairs   	= _G.pairs;
local type 		= _G.type;
--[[ ADDON ]]--
local SV = _G['SVUI'];
local L = SV.L;
local MOD = SV.Skins;
local Schema = MOD.Schema;
local IconCoords = _G.SVUI_ICON_COORDS
--[[
##########################################################
HELPERS
##########################################################
]]--
local ProfessionFrameList = {
    "PrimaryProfession1",
    "PrimaryProfession2",
    "SecondaryProfession1",
    "SecondaryProfession2",
    "SecondaryProfession3",
}

local function _hook_ProfessionsBookFrame_Update()
    local frame
    local prof1, prof2 = GetProfessions()
    local nf1, nf2

    for _, name in ipairs(ProfessionFrameList) do
        frame = _G[name]
        frame.missingHeader:SetTextColor(0.847, 0.117, 0.074)
        frame.missingText:SetTextColor(1, 1, 1)

        frame.SpellButton1.IconTexture:SetTexCoord(unpack(IconCoords))
        frame.SpellButton2.IconTexture:SetTexCoord(unpack(IconCoords))

        nf1 = ("%sNameFrame"):format(frame.SpellButton1:GetName())
        if _G[nf1] then
            _G[nf1]:Die()
        end
        nf2 = ("%sNameFrame"):format(frame.SpellButton2:GetName())
        if _G[nf2] then
            _G[nf2]:Die()
        end
    end

    PrimaryProfession1IconBorder:Die()
    PrimaryProfession2IconBorder:Die()

    if prof1 then
        PrimaryProfession1.icon:SetTexture(select(2, GetProfessionInfo(prof1)))
    else
        PrimaryProfession1.icon:SetTexture([[Interface\\Icons\\INV_Scroll_04]])
    end
    PrimaryProfession1.icon:SetTexCoord(unpack(IconCoords))

    if prof2 then
        PrimaryProfession2.icon:SetTexture(select(2, GetProfessionInfo(prof2)))
    else
        PrimaryProfession2.icon:SetTexture([[Interface\\Icons\\INV_Scroll_04]])
    end
    PrimaryProfession2.icon:SetTexCoord(unpack(IconCoords))
end
--[[
##########################################################
PROFESSION MODR
##########################################################
]]--
local function ProfessionStyle()
    if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.profession ~= true then return end

    local holder = ProfessionsBookFrame

    holder.TitleContainer.TitleText:SetFontObject(SVUI_Font_Header)
    holder:RemoveTextures(true)
    holder.NineSlice:Hide()
    holder:SetStyle("Frame", "Window")

    holder:SetMovable(true)
    holder:EnableMouse(true)
    holder:RegisterForDrag("LeftButton")
    holder:SetScript("OnDragStart", holder.StartMoving)
    holder:SetScript("OnDragStop", holder.StopMovingOrSizing)

    holder.Inset:RemoveTextures(true)
    holder.Inset:SetStyle("!_Frame", "Window2")
    holder.Inset:SetPanelColor("darkest")
    holder.Inset.NineSlice:RemoveTextures(true)

    hooksecurefunc("ProfessionsBookFrame_Update", _hook_ProfessionsBookFrame_Update)
end

--[[
##########################################################
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle("Blizzard_ProfessionsBook", ProfessionStyle)
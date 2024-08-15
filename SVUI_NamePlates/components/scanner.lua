--[[
Created by Vorka
]]--

--[[
##########################################################
LUA DATA
##########################################################
]]--
--[[ GLOBALS ]]--
local _G=_G
local unpack = unpack
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
local SV = _G['SVUI']
local L = SV.L
local LSM = _G.LibStub("LibSharedMedia-3.0")
local MOD = SV.NamePlates;
if(not MOD) then return end;
local Schema = MOD.Schema;
--[[
##########################################################
LOCAL DATA
##########################################################
]]--
local dungeonCache
local ScannerFrame = CreateFrame('Frame', "SVUI_DungeonScanner", UIParent)

local ignoreNPC = {
    229296, -- Orb of Ascendance M+ affix
}
--[[
##########################################################
CORE FUNCTIONS
##########################################################
]]--

--[[
Scanner Functions
]]--

function ScannerFrame:EnableCollect()

    local name, instanceType, _, _, _, _, _, instanceID, _, _ = GetInstanceInfo()

    if not dungeonCache[name] then
        dungeonCache[name] = {
            ["InstanceID"] = instanceID,
            ["NPC"] = {
                --["Name"] = NPC_ID
            }
        }
    end

    self.dungeonName = name
    self.enable = true
end

function ScannerFrame:IsCollecting()
    return self.enable
end

function ScannerFrame:DisableCollect()
    self.enable = false
end

function ScannerFrame:NAME_PLATE_UNIT_ADDED(unit)

    local npc = dungeonCache[self.dungeonName].NPC
    local name = UnitName(unit)

    if name and not npc[name] then
        local guid = UnitGUID(unit)
        local npcId = guid and select(6, strsplit("-", guid)) or nil
        if not ignoreNPC[npcId] then
            npc[name] = npcId
            MOD:UpdateNPCOptions()
        end
    end
end

function ScannerFrame:OnEvent(event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        if IsInInstance() then
            self:EnableCollect()
        else
            self:DisableCollect()
        end
    elseif self:IsCollecting() then
        self[event](self, ...)
    end
end

function MOD:DisableDungeonScanner()
    ScannerFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
    ScannerFrame:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
    ScannerFrame:UnregisterEvent("FORBIDDEN_NAME_PLATE_UNIT_ADDED")
    ScannerFrame:SetScript("OnEvent", nil)
end

function MOD:EnableDungeonScanner()
    dungeonCache = MOD.public.dungeonCache
    ScannerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    ScannerFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    ScannerFrame:SetScript("OnEvent", ScannerFrame.OnEvent)
end
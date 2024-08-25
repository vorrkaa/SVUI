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

local function initDungeonCache()
    return {
        ["overrideName"] = true, --help to localized name in other locale than english by overriding unitName from existing ID
        [670] = {
            ["Name"] = "Grim Batol",
            ["NPC"] = {
                --["NPC_ID"] = UnitName -- in english
                [40319] = "Drahga Shadowburner",
                [224609]= "Twilight Destroyer",
                [40177] = "Forgemaster Throngus",
                [224853] = "Mutated Hatchling",
                [224240] = "Twilight Flamerender",
                [224276] = "Twilight Enforcer",
                [39450] = "Trogg Dweller",
                [40167] = "Twilight Beguiler",
                [39390] = "Twilight Drake",
                [39392] = "Faceless Corruptor",
                [224152] = "Twilight Brute",
                [224271] = "Twilight Warlock",
                [39625] = "General Umbriss",
                [40166] = "Molten Giant",
                [224219] = "Twilight Earthcaller",
                [40320] = "Valiona",
                [40484] = "Erudax",
                [224221] = "Twilight Overseer",
                [224249] = "Twilight Lavabender",
            }
        },
        [1822] = {
            ["Name"] = "Siege of Boralus",
            ["NPC"] = {
                [141495] = "Kul Tiran Footman",
                [141284] = "Kul Tiran Wavetender",
                [128649] = "Sergeant Bainbridge",
                [141285] = "Kul Tiran Marksman",
                [128969] = "Ashvane Commander",
                [138465] = "Ashvane Cannoneer",
                [129372] = "Blacktar Bomber",
                [135258] = "Irontide Curseblade",
                [144160] = "Chopper Redhook",
                [137511] = "Bilge Rat Cutthroat",
                [137517] = "Ashvane Destroyer",
                [138255] = "Ashvane Spotter",
                [138464] = "Ashvane Deckhand",
                [129208] = "Dread Captain Lockwood",
                [135245] = "Bilge Rat Demolisher",
                [128651] = "Hadal Darkfathom",
                [137614] = "Demolishing Terror",
                [137521] = "Irontide Powdershot",
                [141566] = "Scrimshaw Gutter",
                [141938] = "Ashvane Sniper",
                [129369] = "Irontide Raider",
                [137405] = "Gripping Terror",
                [137516] = "Ashvane Invader",
                [129370] = "Irontide Waveshaper",
                [129366] = "Bilge Rat Buccaneer",
                [141283] = "Kul Tiran Halberd",
                [129367] = "Bilge Rat Tempest",
                [138019] = "Kul Tiran Vanguard",
                [132481] = "Unknown",
                [135241] = "Bilge Rat Pillager",
                [128652] = "Viq'Goth",
            }
        },
        [2286] = {
            ["Name"] = "The Necrotic Wake",
            ["NPC"] = {
                [163619] = "Zolramus Bonecarver",
                [163620] = "Rotspew",
                [165872] = "Flesh Crafter",
                [165197] = "Skeletal Monstrosity",
                [165138] = "Blight Bag",
                [164578] = "Stitchflesh's Creation",
                [173044] = "Stitching Assistant",
                [166302] = "Corpse Harvester",
                [165137] = "Zolramus Gatekeeper",
                [165222] = "Zolramus Bonemender",
                [162729] = "Patchwerk Soldier",
                [163128] = "Zolramus Sorcerer",
                [163157] = "Amarth",
                [163618] = "Zolramus Necromancer",
                [163621] = "Goregrind",
                [163126] = "Brittlebone Mage",
                [162691] = "Blightbone",
                [166079] = "Brittlebone Crossbowman",
                [172981] = "Kyrian Stitchwerk",
                [163122] = "Brittlebone Warrior",
                [163622] = "Goregrind Bits",
                [171500] = "Shuffling Corpse",
                [163623] = "Rotspew Leftovers",
                [167731] = "Separation Assistant",
                [166264] = "Spare Parts",
                [165824] = "Nar'zudah",
                [165911] = "Loyal Creation",
                [162693] = "Nalthor the Rimebinder",
                [173016] = "Corpse Collector",
                [162689] = "Surgeon Stitchflesh",
                [163121] = "Stitched Vanguard",
                [165919] = "Skeletal Marauder",
            }
        },
    }
end
--[[
Scanner Functions
]]--

function ScannerFrame:SetInstanceInCache()
    local name, instanceType, _, _, _, _, _, instanceID, _, _ = GetInstanceInfo()

    if not dungeonCache[instanceID] then
        dungeonCache[instanceID] = {
            ["Name"] = name,
            ["NPC"] = {
                --["NPC_ID"] = UnitName -- in english
            }
        }
    end

    self.instanceID = instanceID
end

function ScannerFrame:EnableCollect()
    self.enable = true
end

function ScannerFrame:IsCollecting()
    return self.enable
end

function ScannerFrame:DisableCollect()
    self.enable = false
end

function ScannerFrame:NAME_PLATE_UNIT_ADDED(unit)

    local npc = dungeonCache[self.instanceID].NPC
    local guid = UnitGUID(unit)
    local npcId = guid and select(6, strsplit("-", guid)) or nil

    if npcId and not ignoreNPC[npcId]  then

        if not npc[npcId] or dungeonCache.overrideName then
            npc[npcId] = UnitName(unit)
        end
        MOD:UpdateNPCOptions()
    end

end

function ScannerFrame:OnEvent(event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        if IsInInstance() then
            self:SetInstanceInCache()
        end
    elseif self:IsCollecting() then
        self[event](self, ...)
    end
end

function MOD:DisableDungeonScanner()
    if self.enable then return end

    --ScannerFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
    ScannerFrame:UnregisterEvent("NAME_PLATE_UNIT_ADDED")
    ScannerFrame:UnregisterEvent("FORBIDDEN_NAME_PLATE_UNIT_ADDED")
    ScannerFrame:SetScript("OnEvent", nil)
end

function MOD:EnableDungeonScanner()
    if not self.enable then return end

    DevTool:AddData("EnableDungeonScanner", "EnableDungeonScanner")

    dungeonCache = self.public.Dungeons.Cache
    --ScannerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    ScannerFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    ScannerFrame:SetScript("OnEvent", ScannerFrame.OnEvent)
end

function MOD:LoadDungeonData()

    if not self.public then self.public = {} end
    if not self.public.Dungeons then self.public.Dungeons = {} end
    if not self.public.Dungeons.Cache then self.public.Dungeons.Cache = initDungeonCache() end
    if not self.public.Dungeons.NPCMapping then self.public.Dungeons.NPCMapping = {} end

end

function MOD:IsCollecting()
    return ScannerFrame:IsCollecting()
end

function MOD:ActiveDungeonScanner(active)

    if (active == self:IsCollecting()) then return end

    if active == true then
        ScannerFrame:EnableCollect()
        self:EnableDungeonScanner()

        if IsInInstance() then
            --Activation while in a dungeon
            ScannerFrame:SetInstanceInCache()
        end

        print ("SV Dungeon NPC Scanner is now enabled")
    else
        ScannerFrame:DisableCollect()
        self:DisableDungeonScanner()

        print ("SV Dungeon NPC Scanner is now disabled")
    end
end
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

--[[
##########################################################
LOCAL DATA
##########################################################
]]--

--[[
##########################################################
CORE FUNCTIONS
##########################################################
]]--
if(select(2, UnitClass("player")) ~= 'EVOKER') then return end;

local SV = select(2, ...)

--[[ EVOKER FILTERS ]]--

--373267 -- Lifebind



SV.defaults.Filters["BuffWatch"] = {
    ["366155"] = { -- Reversion
        ["enable"] = true,
        ["id"] = 366155,
        ["point"] = "BOTTOMLEFT",
        ["color"] = {["r"] = 0.2, ["g"] = 0.7, ["b"] = 0.2},
        ["anyUnit"] = false,
        ["onlyShowMissing"] = false,
        ['style'] = 'coloredIcon',
        ['displayText'] = false,
        ['textColor'] = {["r"] = 1, ["g"] = 1, ["b"] = 1},
        ['textThreshold'] = -1,
        ['xOffset'] = 0,
        ['yOffset'] = 0
    },
    ["367364"] = {-- Echo Reversion
        ["enable"] = true,
        ["id"] = 367364,
        ["point"] = "BOTTOMLEFT",
        ["color"] = {["r"] = 0.2, ["g"] = 0.7, ["b"] = 0.2},
        ["anyUnit"] = true,
        ["onlyShowMissing"] = false,
        ['style'] = 'coloredIcon',
        ['displayText'] = false,
        ['textColor'] = {["r"] = 1, ["g"] = 1, ["b"] = 1},
        ['textThreshold'] = -1,
        ['xOffset'] = 10,
        ['yOffset'] = 0
    },
    ["355941"] = { -- Dream Breath
        ["enable"] = true,
        ["id"] = 355941,
        ["point"] = "BOTTOMRIGHT",
        ["color"] = {["r"] = 0.4, ["g"] = 0.8, ["b"] = 0.2},
        ["anyUnit"] = false,
        ["onlyShowMissing"] = false,
        ['style'] = 'coloredIcon',
        ['displayText'] = false,
        ['textColor'] = {["r"] = 1, ["g"] = 1, ["b"] = 1},
        ['textThreshold'] = -1,
        ['xOffset'] = 0,
        ['yOffset'] = 0
    },
    ["376788"] = { -- Echo Dream Breath
        ["enable"] = true,
        ["id"] = 376788,
        ["point"] = "BOTTOMRIGHT",
        ["color"] = {["r"] = 0.2, ["g"] = 0.8, ["b"] = 0.2},
        ["anyUnit"] = false,
        ["onlyShowMissing"] = false,
        ['style'] = 'coloredIcon',
        ['displayText'] = false,
        ['textColor'] = {["r"] = 1, ["g"] = 1, ["b"] = 1},
        ['textThreshold'] = -1,
        ['xOffset'] = -10,
        ['yOffset'] = 0
    },
    ["364343"] = { -- Echo
        ["enable"] = true,
        ["id"] = 364343,
        ["point"] = "BOTTOM",
        ["color"] = {["r"] = 0.89, ["g"] = 0.09, ["b"] = 0.05},
        ["anyUnit"] = false,
        ["onlyShowMissing"] = false,
        ['style'] = 'coloredIcon',
        ['displayText'] = false,
        ['textColor'] = {["r"] = 1, ["g"] = 1, ["b"] = 1},
        ['textThreshold'] = -1,
        ['xOffset'] = 0,
        ['yOffset'] = 0
    },
    ["373862"] = { -- Temporal Anomaly
        ["enable"] = true,
        ["id"] = 373862,
        ["point"] = "RIGHT",
        ["color"] = {["r"] = 0.7, ["g"] = 0.4, ["b"] = 0.4},
        ["anyUnit"] = true,
        ["onlyShowMissing"] = false,
        ['style'] = 'coloredIcon',
        ['displayText'] = false,
        ['textColor'] = {["r"] = 1, ["g"] = 1, ["b"] = 1},
        ['textThreshold'] = -1,
        ['xOffset'] = 0,
        ['yOffset'] = 0
    },
    ["409896"] = { -- Spiritbloom hot
        ["enable"] = true,
        ["id"] = 409896,
        ["point"] = "TOPRIGHT",
        ["color"] = {["r"] = 0.7, ["g"] = 0.4, ["b"] = 0.4},
        ["anyUnit"] = true,
        ["onlyShowMissing"] = false,
        ['style'] = 'coloredIcon',
        ['displayText'] = false,
        ['textColor'] = {["r"] = 1, ["g"] = 1, ["b"] = 1},
        ['textThreshold'] = -1,
        ['xOffset'] = 0,
        ['yOffset'] = 0
    },
    ["357170"] = { -- Time Dilation
        ["enable"] = true,
        ["id"] = 357170,
        ["point"] = "LEFT",
        ["color"] = {["r"] = 0.7, ["g"] = 0.4, ["b"] = 0.4},
        ["anyUnit"] = true,
        ["onlyShowMissing"] = false,
        ['style'] = 'coloredIcon',
        ['displayText'] = false,
        ['textColor'] = {["r"] = 1, ["g"] = 1, ["b"] = 1},
        ['textThreshold'] = -1,
        ['xOffset'] = 0,
        ['yOffset'] = 0
    },
    ["360827"] = { -- Blistering Scales
        ["enable"] = true,
        ["id"] = 360827,
        ["point"] = "BOTTOMLEFT",
        ["color"] = {["r"] = 0.7, ["g"] = 0.4, ["b"] = 0.4},
        ["anyUnit"] = true,
        ["onlyShowMissing"] = false,
        ['style'] = 'coloredIcon',
        ['displayText'] = false,
        ['textColor'] = {["r"] = 1, ["g"] = 1, ["b"] = 1},
        ['textThreshold'] = 5,
        ['xOffset'] = 0,
        ['yOffset'] = 0
    },
    ["395296"] = { -- Ebon Might
        ["enable"] = true,
        ["id"] = 395296,
        ["point"] = "BOTTOMRIGHT",
        ["color"] = {["r"] = 0.4, ["g"] = 0.7, ["b"] = 0.4},
        ["anyUnit"] = true,
        ["onlyShowMissing"] = false,
        ['style'] = 'coloredIcon',
        ['displayText'] = false,
        ['textColor'] = {["r"] = 1, ["g"] = 1, ["b"] = 1},
        ['textThreshold'] = -1,
        ['xOffset'] = 0,
        ['yOffset'] = 0
    },
    ["410089"] = { -- Prescience
        ["enable"] = true,
        ["id"] = 410089,
        ["point"] = "RIGHT",
        ["color"] = {["r"] = 0.4, ["g"] = 0.4, ["b"] = 0.7},
        ["anyUnit"] = true,
        ["onlyShowMissing"] = false,
        ['style'] = 'coloredIcon',
        ['displayText'] = false,
        ['textColor'] = {["r"] = 1, ["g"] = 1, ["b"] = 1},
        ['textThreshold'] = -1,
        ['xOffset'] = 0,
        ['yOffset'] = 0
    },
};
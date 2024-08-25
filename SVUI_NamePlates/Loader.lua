--[[
##########################################################
S V U I   By: Failcoder
##########################################################
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--GLOBAL NAMESPACE
local _G = _G;
--LUA
local unpack = _G.unpack;
local select = _G.select;
local assert = _G.assert;

local SV = _G["SVUI"]
local L = SV.L
local name, obj = ...;
local MOD = SV:NewModule(name, obj, "SVUI_Public_Nameplates", "SVUI_Private_Nameplates")
local Schema = MOD.Schema;

local positionTable = {
    TOPLEFT = "TOPLEFT",
    LEFT = "LEFT",
    BOTTOMLEFT = "BOTTOMLEFT",
    RIGHT = "RIGHT",
    TOPRIGHT = "TOPRIGHT",
    BOTTOMRIGHT = "BOTTOMRIGHT",
    CENTER = "CENTER",
    TOP = "TOP",
    BOTTOM = "BOTTOM",
    RIGHTTOP = "RIGHTTOP",
    LEFTTOP = "LEFTTOP",
    RIGHTBOTTOM = "RIGHTBOTTOM",
    LEFTBOTTOM = "LEFTBOTTOM"
};

local activeFilter, filters;

MOD.media = {}
MOD.media.healthBar = [[Interface\BUTTONS\WHITE8X8]];
MOD.media.castBar = [[Interface\AddOns\SVUI_!Core\assets\statusbars\GRADIENT]];
MOD.media.comboIcon = [[Interface\AddOns\SVUI_NamePlates\assets\COMBO-POINT]];
MOD.media.topArt = [[Interface\AddOns\SVUI_NamePlates\assets\PLATE-TOP]];
MOD.media.bottomArt = [[Interface\AddOns\SVUI_NamePlates\assets\PLATE-BOTTOM]];
MOD.media.rightArt = [[Interface\AddOns\SVUI_NamePlates\assets\PLATE-RIGHT]];
MOD.media.leftArt = [[Interface\AddOns\SVUI_NamePlates\assets\PLATE-LEFT]];
MOD.media.roles = [[Interface\AddOns\SVUI_NamePlates\assets\PLATE-ROLES]];

SV:AssignMedia("font", "platename", "SVUI Caps Font", 9, "OUTLINE");
SV:AssignMedia("font", "platenumber", "SVUI Caps Font", 9, "OUTLINE");
SV:AssignMedia("font", "plateaura", "SVUI Caps Font", 9, "OUTLINE");
SV:AssignMedia("globalfont", "platename", "SVUI_Font_NamePlate");
SV:AssignMedia("globalfont", "platenumber", "SVUI_Font_NamePlate_Number");
SV:AssignMedia("globalfont", "plateaura", "SVUI_Font_NamePlate_Aura");
SV:AssignMedia("template", "Nameplate", "SVUI_StyleTemplate_Nameplate");

SV.defaults[Schema] = {
    ["themed"] = true,
    ["filter"] = {},
    ["barTexture"] = "SVUI MultiColorBar",
    ["font"] = DIALOGUE_FONT,
    ["fontSize"] = 10,
    ["fontOutline"] = "OUTLINE",
    ["comboPoints"] = true,
    ["levelText"] = true,
    ["nonTargetAlpha"] = 0.6,
    ["combatHide"] = false,
    ["colorNameByValue"] = true,
    ["showthreat"] = true,
    ["targetcount"] = true,
    ["findHealers"] = true,
    ["pointer"] = {
        ["enable"] = true,
        ["colorMatchHealthBar"] = true,
        ["color"] = { 0.9, 1, 0.9 },
        ["useArrowEffect"] = true,
    },
    ["healthBar"] = {
        ["lowThreshold"] = 0.4,
        ["width"] = 120,
        ["height"] = 10,
        ["text"] = {
            ["enable"] = true,
            ["format"] = "CURRENT_PERCENT",
            ["xOffset"] = 0,
            ["yOffset"] = 0,
            ["attachTo"] = "LEFT",
        },
        ["nameplateNotSelectedAlpha"] = 0.8,
    },
    ["castBar"] = {
        ["height"] = 8,
        ["color"] = { 1, 0.81, 0 },
        ["noInterrupt"] = { 1, 0.25, 0.25 },
        ["text"] = {
            ["enable"] = false,
            ["xOffset"] = 2,
            ["yOffset"] = 0,
        },
    },
    ["raidHealIcon"] = {
        ["xOffset"] = -4,
        ["yOffset"] = 6,
        ["size"] = 36,
        ["attachTo"] = "LEFT",
    },
    ["auras"] = {
        ["font"] = "SVUI Number Font",
        ["fontSize"] = 7,
        ["fontOutline"] = "OUTLINE",
        ["numAuras"] = 5,
        ["additionalFilter"] = "CC"
    },
    ["reactions"] = {
        ["tapped"] = { 0.6, 0.6, 0.6 },
        ["friendlyNPC"] = { 0.31, 0.45, 0.63 },
        ["friendlyPlayer"] = { 0.29, 0.68, 0.3 },
        ["neutral"] = { 0.85, 0.77, 0.36 },
        ["enemy"] = { 0.78, 0.25, 0.25 },
    },
    ["threat"] = {
        ["enable"] = false,
        ["goodScale"] = 1,
        ["badScale"] = 1,
        ["goodColor"] = { 0.29, 0.68, 0.3 },
        ["badColor"] = { 0.78, 0.25, 0.25 },
        ["goodTransitionColor"] = { 0.85, 0.77, 0.36 },
        ["badTransitionColor"] = { 0.94, 0.6, 0.06 },
    },
    --["targetScale"] = {
    --    ["base"] = 1,
    --    ["target"] = 1.15,
    --},
};

--[name] = color
local colors = {
    ["HUNTER"] = CreateColor(0.454, 0.698, 0),
    ["WARLOCK"] = CreateColor(0.286, 0, 0.788),
    ["PRIEST"] = CreateColor(0.976, 1, 0.839),
    ["PALADIN"] = CreateColor(0.956, 0.207, 0.733),
    ["MAGE"] = CreateColor(0, 0.796, 1),
    ["ROGUE"] = CreateColor(1, 0.894, 0.117),
    ["DRUID"] = CreateColor(1, 0.513, 0),
    ["SHAMAN"] = CreateColor(0, 0.38, 1),
    ["WARRIOR"] = CreateColor(0.698, 0.36, 0.152),
    ["DEATHKNIGHT"] = CreateColor(0.847, 0.117, 0.074),
    ["MONK"] = CreateColor(0.015, 0.886, 0.38),
    --["DEMONHUNTER"] = CreateColor(0.286, 0, 0.788),
    ["EVOKER"] = CreateColor(0.25, 0.75, 0.64),
    ["HUNTER2"] = CreateColor(0.67, 0.83, 0.045),
    ["WARLOCK2"] = CreateColor(0.58, 0.51, 0.79),
    --["PRIEST2"] = CreateColor(1, 1, 1),
    ["PALADIN2"] = CreateColor(0.96, 0.55, 0.73),
    --["MAGE2"] = CreateColor(0.41, 0.80, 0.94),
    --["ROGUE2"] = CreateColor(1, 0.96, 0.41),
    --["DRUID2"] = CreateColor(1, 0.49, 0.04),
    --["SHAMAN2"] = CreateColor(0, 0.44, 0.87),
    ["WARRIOR2"] = CreateColor(0.78, 0.61, 0.43),
    --["DEATHKNIGHT2"] = CreateColor(0.77, 0.12, 0.23),
    --["MONK2"] = CreateColor(0.33, 0.54, 0.52),
    ["DEMONHUNTER2"] = CreateColor(0.64, 0.19, 0.79),
    ["EVOKER2"] = CreateColor(0.20, 0.58, 0.5),

}

---@param sorted boolean
---@return table associative table of [ ColorName, colored ColorName ]
function MOD:GetColoredSelector(sorted)
    --we need to sort before coloration in string
    local t = self:GetColorsByKeys(sorted)
    local tColors = {}

    for i, color in ipairs(t) do
        tColors[color] = WrapTextInColor(color, colors[color])
    end

    return tColors
end

---@param sorted boolean
---@return table list of colorName
function MOD:GetColorsByKeys(sorted)
    local t = {}
    for k, _ in pairs(colors) do
        tinsert(t, k)
    end

    if sorted then
        table.sort(t)
    end

    return t
end

---@param colorName string
---@return ColorMixin nilable
function MOD:GetColor(colorName)
    return colors[colorName] or nil
end

---@return table associative array of ColorName, ColorMixin
function MOD:GetColors()
    return colors
end

local function UpdateFilterGroupOptions()
    if not activeFilter or not SV.db['NamePlates']['filter'][activeFilter] then
        SV.Options.args[Schema].args.Filters.args.filterGroup = nil;
        return
    end
    SV.Options.args[Schema].args.Filters.args.filterGroup = {
        type = "group",
        name = activeFilter,
        guiInline = true,
        order = -10,
        get = function(d)
            return SV.db["NamePlates"]["filter"][activeFilter][d[#d]]
        end,
        set = function(d, e)
            SV.db["NamePlates"]["filter"][activeFilter][d[#d]] = e;
            MOD:PlateIteration("AssertFiltering")
            MOD:UpdateAllPlates()
            UpdateFilterGroupOptions()
        end,
        args = {
            enable = {
                type = "toggle",
                order = 1,
                name = L["Enable"],
                desc = L["Use this filter."]
            },
            hide = {
                type = "toggle",
                order = 2,
                name = L["Hide"],
                desc = L["Prevent any nameplate with this unit name from showing."]
            },
            customColor = {
                type = "toggle",
                order = 3,
                name = L["Custom Color"],
                desc = L["Disable threat coloring for this plate and use the custom color."]
            },
            color = {
                type = "color",
                order = 4,
                name = L["Color"],
                get = function(key)
                    local color = SV.db["NamePlates"]["filter"][activeFilter][key[#key]]
                    if color then
                        return color[1], color[2], color[3], color[4]
                    end
                end,
                set = function(key, r, g, b)
                    SV.db["NamePlates"]["filter"][activeFilter][key[#key]] = {}
                    local color = SV.db["NamePlates"]["filter"][activeFilter][key[#key]]
                    if color then
                        color = { r, g, b };
                        UpdateFilterGroupOptions()
                        MOD:PlateIteration("CheckFilterAndHealers")
                        MOD:UpdateAllPlates()
                    end
                end
            },
            customScale = {
                type = "range",
                name = L["Custom Scale"],
                desc = L["Set the scale of the nameplate."],
                min = 0.67,
                max = 2,
                step = 0.01
            }
        }
    }
end
local function UpdateNPCOptions()

    if not SV.Options.args[Schema] then
        print ("|cFFFF0000 Trying to Update NPC but Nameplates is not loaded yet|r")
        return
    end

    local dungeonCache = MOD.public.Dungeons.Cache
    local npcColorMapping = MOD.public.Dungeons.NPCMapping

    SV.Options.args[Schema].args.commonGroup.args.NPCMapping = {
        type = "group",
        order = 10,
        name = L['NPC Mapping'],
        childGroups = "select",
        get = function(d)
            return npcColorMapping[d[#d]]
        end,
        set = function(d, e)
            npcColorMapping[d[#d]] = e
            MOD:UpdateAllPlates()
        end,
        args = {
            intro = {
                order = 1,
                type = "description",
                name = "Select a dungeon to change the colorization of specific npc", ---@todo localized
            },
        }
    }

    local array = SV.Options.args[Schema].args.commonGroup.args.NPCMapping.args
    local i = 1
    local j
    for dungeon, cache in pairs(dungeonCache) do
        if not npcColorMapping[dungeon] then
            npcColorMapping[dungeon] = {}
        end
        if type(cache) == "table" then
            array[cache.Name] = {
                type = "group",
                name = cache.Name,
                order = i,
                get = function(k)
                    return npcColorMapping[dungeon][k[#k]]
                end,
                set = function(k, v)
                    npcColorMapping[dungeon][k[#k]] = v
                    MOD:UpdateAllPlates()
                end,
                args = {}
            }

            j = 1
            for npcID, npcName in pairs(cache.NPC) do
                if not npcColorMapping[dungeon][npcID] then
                    npcColorMapping[dungeon][npcID] = {}
                end
                array[cache.Name].args[npcName] = {
                    name = npcName,
                    type = "group",
                    order = order,
                    --guiInline  = true,
                    get = function(k)
                        return npcColorMapping[dungeon][npcID][k[#k]]
                    end,
                    set = function(k, v)
                        npcColorMapping[dungeon][npcID][k[#k]] = v
                        MOD:UpdateAllPlates()
                    end,
                    args = {
                        enable = {
                            type = "toggle",
                            order = 1,
                            name = L["Enable"],
                            desc = L["Override Nameplate color"]
                        },
                        id = {
                            type = "description",
                            name = L["NPC ID: "]..npcID,
                            fontSize = "medium",
                            width = "normal",
                            order = 2,
                        },
                        color = {
                            type = "select",
                            name = L["Color"],
                            order = 4,
                            values = MOD:GetColoredSelector(true)
                        },
                        texture = {
                            type = "select",
                            dialogControl = "LSM30_Statusbar",
                            order = 6,
                            name = L["StatusBar Texture"],
                            desc = L["Main statusbar texture."],
                            values = AceVillainWidgets.statusbar
                        }
                    }
                }
                j = j + 1
            end
            i = i + 1
        end
    end

end

function MOD:UpdateNPCOptions()
    UpdateNPCOptions()
end

function MOD:LoadOptions()
    local plateFonts = {
        ["platename"] = {
            order = 1,
            name = "Nameplate Names",
            desc = "Used on nameplates for unit names."
        },
        ["platenumber"] = {
            order = 2,
            name = "Nameplate Numbers",
            desc = "Used on nameplates for health and level numbers."
        },
        ["plateaura"] = {
            order = 3,
            name = "Nameplate Auras",
            desc = "Used on nameplates for aura texts."
        },
    };

    SV:GenerateFontOptionGroup("NamePlate", 5, "Fonts used in name plates.", plateFonts)

    SV.Options.args[Schema] = {
        type = "group",
        name = Schema,
        childGroups = "tab",
        args = {
            commonGroup = {
                order = 1,
                type = 'group',
                name = L['NamePlate Options'],
                childGroups = "tree",
                args = {
                    intro = {
                        order = 1,
                        type = 'description',
                        name = L["NAMEPLATE_DESC"],
                        width = 'full'
                    },
                    common = {
                        order = 1,
                        type = "group",
                        name = L["General"],
                        get = function(d)
                            return SV.db[Schema][d[#d]]
                        end,
                        set = function(d, e)
                            MOD:ChangeDBVar(e, d[#d]);
                            MOD:UpdateAllPlates()
                        end,
                        args = {
                            themed = {
                                type = "toggle",
                                order = 1,
                                name = L["Super Styled"],
                                desc = L["This will enable/disable the extra fancy styling around elite/rare plates."],
                                set = function(d, e)
                                    MOD:ChangeDBVar(e, d[#d])
                                    SV:StaticPopup_Show("RL_CLIENT")
                                end
                            },
                            -- combatHide = {
                            -- 	type = "toggle",
                            -- 	order = 2,
                            -- 	name = L["Combat Toggle"],
                            -- 	desc = L["Toggle the nameplates to be invisible outside of combat and visible inside combat."],
                            -- 	set = function(d,e)MOD:ChangeDBVar(e,d[#d]);MOD:CombatToggle();SV:StaticPopup_Show("RL_CLIENT");end
                            -- },
                            comboPoints = {
                                type = "toggle",
                                order = 3,
                                name = L["Combo Points on Enemy"],
                                desc = L["Display combo points on enemy nameplates"],
                                set = function(d, e)
                                    MOD:ChangeDBVar(e, d[#d]);
                                    MOD:ComboToggle();
                                    SV:StaticPopup_Show("RL_CLIENT");
                                end
                            },
                            -- colorNameByValue = {
                            -- 	type = "toggle",
                            -- 	order = 4,
                            -- 	name = L["Color Name By Health Value"],
                            -- 	width = 'full',
                            -- },
                            -- showthreat = {
                            -- 	type = "toggle",
                            -- 	order = 5,
                            -- 	name = L["Threat Text"],
                            -- 	desc = L["Display threat level as text on targeted,	boss or mouseover nameplate."]
                            -- },
                            barTexture = {
                                type = "select",
                                dialogControl = "LSM30_Statusbar",
                                order = 6,
                                name = L["StatusBar Texture"],
                                desc = L["Main statusbar texture."],
                                values = AceVillainWidgets.statusbar
                            },
                            levelText = {
                                type = "toggle",
                                name = L["Show level"],
                            }
                            -- nonTargetAlpha = {
                            -- 	type = "range",
                            -- 	order = 7,
                            -- 	name = L["Non-Target Alpha"],
                            -- 	desc = L["Alpha of nameplates that are not your current target."],
                            -- 	width = 'full',
                            -- 	min = 0,
                            -- 	max = 1,
                            -- 	step = 0.01,
                            -- 	isPercent = true
                            -- },
                            -- spacer1 = {
                            -- 	order = 8,
                            -- 	type = "description",
                            -- 	name = "",
                            -- 	width = "full",
                            -- },
                            -- reactions = {
                            -- 	order = 9,
                            -- 	type = "group",
                            -- 	name = L["Reaction Coloring"],
                            -- 	guiInline = true,
                            -- 	get = function(key)
                            -- 		local color = SV.db[Schema].reactions[key[#key]]
                            -- 		if color then
                            -- 			return color[1],color[2],color[3],color[4]
                            -- 		end
                            -- 	end,
                            -- 	set = function(key,r,g,b)
                            -- 		local color = {r,g,b}
                            -- 		MOD:ChangeDBVar(color, key[#key], "reactions")
                            -- 		MOD:UpdateAllPlates()
                            -- 	end,
                            -- 	args = {
                            -- 		friendlyNPC = {
                            -- 			type = "color",
                            -- 			order = 1,
                            -- 			name = L["Friendly NPC"],
                            -- 			hasAlpha = false
                            -- 		},
                            -- 		friendlyPlayer = {
                            -- 			name = L["Friendly Player"],
                            -- 			order = 2,
                            -- 			type = "color",
                            -- 			hasAlpha = false
                            -- 		},
                            -- 		neutral = {
                            -- 			name = L["Neutral"],
                            -- 			order = 3,
                            -- 			type = "color",
                            -- 			hasAlpha = false
                            -- 		},
                            -- 		enemy = {
                            -- 			name = L["Enemy"],
                            -- 			order = 4,
                            -- 			type = "color",
                            -- 			hasAlpha = false
                            -- 		},
                            -- 		tapped = {
                            -- 			name = L["Tagged NPC"],
                            -- 			order = 5,
                            -- 			type = "color",
                            -- 			hasAlpha = false
                            -- 		},
                            -- 	}
                            -- },
                            -- threat = {
                            -- 	type = "group",
                            -- 	name = L["Threat Coloring"],
                            -- 	guiInline = true,
                            -- 	order = 10,
                            -- 	args = {
                            -- 		enable = {
                            -- 			type = "toggle",
                            -- 			order = 1,
                            -- 			name = L["Enable Threat Coloring"],
                            -- 			width = "full",
                            -- 			get = function(key)return SV.db[Schema].threat.enable end,
                            -- 			set = function(key,value) SV.db[Schema].threat.enable = value; MOD:UpdateAllPlates() end,
                            -- 		},
                            -- 		goodColor = {
                            -- 			type = "color",
                            -- 			order = 2,
                            -- 			name = L["Good Threat"],
                            -- 			hasAlpha = false,
                            -- 			disabled = function(key) return not SV.db[Schema].threat.enable end,
                            -- 			get = function(key)
                            -- 				local color = SV.db[Schema].threat.goodColor
                            -- 				if color then
                            -- 					return color[1],color[2],color[3],color[4]
                            -- 				end
                            -- 			end,
                            -- 			set = function(key,r,g,b)
                            -- 				SV.db[Schema].threat.goodColor = {r,g,b}
                            -- 				MOD:UpdateAllPlates()
                            -- 			end,
                            -- 		},
                            -- 		badColor = {
                            -- 			name = L["Bad Threat"],
                            -- 			order = 3,
                            -- 			type = "color",
                            -- 			hasAlpha = false,
                            -- 			disabled = function(key) return not SV.db[Schema].threat.enable end,
                            -- 			get = function(key)
                            -- 				local color = SV.db[Schema].threat.badColor
                            -- 				if color then
                            -- 					return color[1],color[2],color[3],color[4]
                            -- 				end
                            -- 			end,
                            -- 			set = function(key,r,g,b)
                            -- 				SV.db[Schema].threat.badColor = {r,g,b}
                            -- 				MOD:UpdateAllPlates()
                            -- 			end,
                            -- 		},
                            -- 		goodTransitionColor = {
                            -- 			name = L["Good Threat Transition"],
                            -- 			order = 4,
                            -- 			type = "color",
                            -- 			hasAlpha = false,
                            -- 			disabled = function(key) return not SV.db[Schema].threat.enable end,
                            -- 			get = function(key)
                            -- 				local color = SV.db[Schema].threat.goodTransitionColor
                            -- 				if color then
                            -- 					return color[1],color[2],color[3],color[4]
                            -- 				end
                            -- 			end,
                            -- 			set = function(key,r,g,b)
                            -- 				SV.db[Schema].threat.goodTransitionColor = {r,g,b}
                            -- 				MOD:UpdateAllPlates()
                            -- 			end,
                            -- 		},
                            -- 		badTransitionColor = {
                            -- 			name = L["Bad Threat Transition"],
                            -- 			order = 5,
                            -- 			type = "color",
                            -- 			hasAlpha = false,
                            -- 			disabled = function(key) return not SV.db[Schema].threat.enable end,
                            -- 			get = function(key)
                            -- 				local color = SV.db[Schema].threat.badTransitionColor
                            -- 				if color then
                            -- 					return color[1],color[2],color[3],color[4]
                            -- 				end
                            -- 			end,
                            -- 			set = function(key,r,g,b)
                            -- 				SV.db[Schema].threat.badTransitionColor = {r,g,b}
                            -- 				MOD:UpdateAllPlates()
                            -- 			end,
                            -- 		},
                            -- 	}
                            -- },
                            -- scaling = {
                            -- 	type = "group",
                            -- 	name = L["Threat Scaling"],
                            -- 	guiInline = true,
                            -- 	order = 11,
                            -- 	disabled = function(key) return not SV.db[Schema].threat.enable end,
                            -- 	args = {
                            -- 		goodScale = {
                            -- 			type = "range",
                            -- 			name = L["Good"],
                            -- 			order = 1,
                            -- 			min = 0.5,
                            -- 			max = 1.5,
                            -- 			step = 0.01,
                            -- 			width = 'full',
                            -- 			isPercent = true,
                            -- 			get = function(key)return SV.db[Schema].threat.goodScale end,
                            -- 			set = function(key,value) SV.db[Schema].threat.goodScale = value; MOD:UpdateAllPlates() end,
                            -- 		},
                            -- 		badScale = {
                            -- 			type = "range",
                            -- 			name = L["Bad"],
                            -- 			order = 1,
                            -- 			min = 0.5,
                            -- 			max = 1.5,
                            -- 			step = 0.01,
                            -- 			width = 'full',
                            -- 			isPercent = true,
                            -- 			get = function(key)return SV.db[Schema].threat.badScale end,
                            -- 			set = function(key,value) SV.db[Schema].threat.badScale = value; MOD:UpdateAllPlates() end,
                            -- 		}
                            -- 	}
                            -- },
                            --scaling = {
                            --    type = "group",
                            --    name = L["Target Scaling"],
                            --    guiInline = true,
                            --    order = 11,
                            --    args = {
                            --        base = {
                            --            type = "range",
                            --            name = L["Base"],
                            --            order = 1,
                            --            min = 0.5,
                            --            max = 2,
                            --            step = 0.01,
                            --            width = 'full',
                            --            isPercent = true,
                            --            get = function(key)
                            --                return SV.db[Schema].targetScale.base
                            --            end,
                            --            set = function(key, value)
                            --                SV.db[Schema].targetScale.base = value;
                            --                MOD:UpdateAllPlates()
                            --            end,
                            --        },
                            --        target = {
                            --            type = "range",
                            --            name = L["Target"],
                            --            order = 1,
                            --            min = 1,
                            --            max = 2,
                            --            step = 0.01,
                            --            width = 'full',
                            --            isPercent = true,
                            --            get = function(key)
                            --                return SV.db[Schema].targetScale.target
                            --            end,
                            --            set = function(key, value)
                            --                SV.db[Schema].targetScale.target = value;
                            --                MOD:UpdateAllPlates()
                            --            end,
                            --        }
                            --    }
                            --}
                        }
                    },
                    cvar = {
                        type = "group",
                        order = 4,
                        name = L["CVar"],
                        get = function(d)
                            return SV.db[Schema].CVar[d[#d]]
                        end,
                        set = function(d, e)
                            MOD:ChangeDBVar(e, d[#d], "CVar");
                            MOD:UpdateAllPlates()
                        end,
                        args = {
                            nameplateOverlapH = {
                                type = "range",
                                name = L["nameplateOverlapH"],
                                order = 1,
                                min = 0.2,
                                max = 2.5,
                                step = 0.05,
                                width = "double",
                                --usedecimals = true,
                                desc = "The space between each nameplate horizontally when stacking is enabled.\n\n|cFFFFFFFFDefault: 0.8|r",
                                get = function()
                                    return tonumber(GetCVar("nameplateOverlapH"))
                                end,
                                set = function(key, value)
                                    if (not InCombatLockdown()) then
                                        SetCVar("nameplateOverlapH", value)
                                    end
                                end,
                            },
                            nameplateOverlapV = {
                                type = "range",
                                name = L["nameplateOverlapV"],
                                order = 2,
                                min = 0.2,
                                max = 2.5,
                                step = 0.05,
                                width = "double",
                                --usedecimals = true,
                                desc = "The space between each nameplate vertically when stacking is enabled.\n\n|cFFFFFFFFDefault Blizzard: 1.1|r",
                                get = function()
                                    return tonumber(GetCVar("nameplateOverlapV"))
                                end,
                                set = function(key, value)
                                    if (not InCombatLockdown()) then
                                        SetCVar("nameplateOverlapV", value)
                                    end
                                end,
                            },
                            nameplateGlobalScale = {
                                type = "range",
                                name = L["nameplateGlobalScale"],
                                order = 3,
                                min = 0.75,
                                max = 2,
                                step = 0.05,
                                width = "double",
                                --usedecimals = true,
                                --isPercent = true,
                                desc = "Scale all nameplates.\n\n|cFFFFFFFFDefault: 1|r",
                                get = function()
                                    return tonumber(GetCVar("nameplateGlobalScale"))
                                end,
                                set = function(key, value)
                                    if (not InCombatLockdown()) then
                                        SetCVar("nameplateGlobalScale", value)
                                    end
                                end,
                            },
                            nameplateMinScale = {
                                type = "range",
                                name = L["nameplateMinScale"],
                                order = 4,
                                min = 0.3,
                                max = 2,
                                step = 0.1,
                                width = "double",
                                --usedecimals = true,
                                --isPercent = true,
                                desc = "Scale applied when the nameplate is far away.\n\n|cFFFFFFFFDefault: 0.8|r",
                                get = function()
                                    return tonumber(GetCVar("nameplateMinScale"))
                                end,
                                set = function(key, value)
                                    if (not InCombatLockdown()) then
                                        SetCVar("nameplateMinScale", value)
                                    end
                                end,
                            },
                            nameplateShowEnemyTotems = {
                                type = "toggle",
                                name = L["nameplateShowEnemyTotems"],
                                order = 8,
                                desc = "Show enemy totems",
                                width = "double",
                                get = function()
                                    return GetCVar("nameplateShowEnemyTotems") == "1"
                                end,
                                set = function(key, value)
                                    if (not InCombatLockdown()) then
                                        SetCVar("nameplateShowEnemyTotems", math.abs(tonumber(GetCVar("nameplateShowEnemyTotems")) - 1))
                                    end
                                end,
                            },
                            nameplateShowEnemyPets = {
                                type = "toggle",
                                name = L["nameplateShowEnemyPets"],
                                order = 9,
                                desc = "Show enemy pets",
                                width = "double",
                                get = function()
                                    return GetCVar("nameplateShowEnemyPets") == "1"
                                end,
                                set = function(key, value)
                                    if (not InCombatLockdown()) then
                                        SetCVar("nameplateShowEnemyPets", math.abs(tonumber(GetCVar("nameplateShowEnemyPets")) - 1))
                                    end
                                end,
                            },
                            nameplateSelectedAlpha = {
                                type = "range",
                                name = L["nameplateSelectedAlpha"],
                                order = 5,
                                min = 0.2,
                                max = 1,
                                step = 0.01,
                                width = "double",
                                --usedecimals = true,
                                --isPercent = true,
                                desc = "Alpha applied when the nameplate is selected.\n\n|cFFFFFFFFDefault: 1|r",
                                get = function()
                                    return tonumber(GetCVar("nameplateSelectedAlpha"))
                                end,
                                set = function(key, value)
                                    if (not InCombatLockdown()) then
                                        SetCVar("nameplateSelectedAlpha", value)
                                    end
                                end,
                            },
                        }
                    },
                    healthBar = {
                        type = "group",
                        order = 2,
                        name = L["Health Bar"],
                        get = function(d)
                            return SV.db[Schema].healthBar[d[#d]]
                        end,
                        set = function(d, e)
                            MOD:ChangeDBVar(e, d[#d], "healthBar");
                            MOD:UpdateAllPlates()
                        end,
                        args = {
                            width = {
                                type = "range",
                                order = 1,
                                name = L["Width"],
                                desc = L["Controls the width of the nameplate"],
                                type = "range",
                                min = 100,
                                max = 200,
                                step = 1
                            },
                            height = {
                                type = "range",
                                order = 2,
                                name = L["Height"],
                                desc = L["Controls the height of the nameplate"],
                                type = "range",
                                min = 4,
                                max = 30,
                                step = 1
                            },
                            nameplateNotSelectedAlpha = {
                                type = "range",
                                name = L["nameplateNotSelectedAlpha"],
                                order = 3,
                                min = 0.2,
                                max = 1,
                                step = 0.01,
                                width = "double",
                                --usedecimals = true,
                                isPercent = true,
                                desc = "Alpha applied when the nameplate is not selected.\n\n|cFFFFFFFFDefault: 1|r",
                            },
                            -- lowThreshold = {
                            -- 	type = "range",
                            -- 	order = 3,
                            -- 	name = L["Low Health Threshold"],
                            -- 	desc = L["Color the border of the nameplate yellow when it reaches this point,it will be colored red when it reaches half this value."],
                            -- 	isPercent = true,
                            -- 	min = 0,
                            -- 	max = 1,
                            -- 	step = 0.01
                            -- },
                             fontGroup = {
                             	order = 4,
                             	type = "group",
                             	name = L["Texts"],
                             	guiInline = true,
                             	get = function(d)return SV.db[Schema].healthBar.text[d[#d]]end,
                             	set = function(d,e)MOD:ChangeDBVar(e,d[#d],"healthBar","text");MOD:UpdateAllPlates()end,
                             	args = {
                             		enable = {
                             			type = "toggle",
                             			name = L["Enable"],
                             			order = 1
                             		},
                             		attachTo = {
                             			type = "select",
                             			order = 2,
                             			name = L["Attach To"],
                             			values = {
                             				TOPLEFT = "TOPLEFT",
                             				LEFT = "LEFT",
                             				BOTTOMLEFT = "BOTTOMLEFT",
                             				RIGHT = "RIGHT",
                             				TOPRIGHT = "TOPRIGHT",
                             				BOTTOMRIGHT = "BOTTOMRIGHT",
                             				CENTER = "CENTER",
                             				TOP = "TOP",
                             				BOTTOM = "BOTTOM"
                             			}
                             		},
                             		format = {
                             			type = "select",
                             			order = 3,
                             			name = L["Format"],
                             			values = {
                             				["CURRENT_MAX_PERCENT"] = L["Current - Max | Percent"],
                             				["CURRENT_PERCENT"] = L["Current - Percent"],
                             				["CURRENT_MAX"] = L["Current - Max"],
                             				["CURRENT"] = L["Current"],
                             				["PERCENT"] = L["Percent"],
                             				["DEFICIT"] = L["Deficit"]
                             			}
                             		},
                             		xOffset = {
                             			type = "range",
                             			order = 4,
                             			name = L["X-Offset"],
                             			min = -150,
                             			max = 150,
                             			step = 1
                             		},
                             		yOffset = {
                             			type = "range",
                             			order = 5,
                             			name = L["Y-Offset"],
                             			min = -150,
                             			max = 150,
                             			step = 1
                             		}
                             	}
                            }
                        }
                    },
                    castBar = {
                        type = "group",
                        order = 3,
                        name = L["Cast Bar"],
                        get = function(d)
                            return SV.db[Schema].castBar[d[#d]]
                        end,
                        set = function(d, e)
                            MOD:ChangeDBVar(e, d[#d], "castBar");
                            MOD:UpdateAllPlates()
                        end,
                        args = {
                            height = {
                                type = "range",
                                order = 1,
                                name = L["Height"],
                                type = "range",
                                min = 4,
                                max = 30,
                                step = 1
                            },
                            colors = {
                                order = 100,
                                type = "group",
                                name = L["Colors"],
                                guiInline = true,
                                get = function(key)
                                    local color = SV.db[Schema].castBar[key[#key]]
                                    if color then
                                        return color[1], color[2], color[3], color[4]
                                    end
                                end,
                                set = function(key, r, g, b)
                                    local color = { r, g, b }
                                    MOD:ChangeDBVar(color, key[#key], "castBar")
                                    MOD:UpdateAllPlates()
                                end,
                                args = {
                                    color = {
                                        type = "color",
                                        order = 1,
                                        name = L["Can Interrupt"],
                                        hasAlpha = false
                                    },
                                    noInterrupt = {
                                        name = "No Interrupt",
                                        order = 2,
                                        type = "color",
                                        hasAlpha = false
                                    }
                                }
                            }
                        }
                    },
                    -- pointer = {
                    -- 	type = "group",
                    -- 	order = 4,
                    -- 	name = L["Target Indicator"],
                    -- 	get = function(d)return SV.db[Schema].pointer[d[#d]]end,
                    -- 	set = function(d,e) MOD:ChangeDBVar(e,d[#d],"pointer"); _G.WorldFrame.elapsed = 3; MOD:UpdateAllPlates() end,
                    -- 	args = {
                    -- 		enable = {
                    -- 			order = 1,
                    -- 			type = "toggle",
                    -- 			name = L["Enable"]
                    -- 		},
                    -- 		useArrowEffect = {
                    -- 			order = 2,
                    -- 			type = "toggle",
                    -- 			name = L["Use 3D Arrow"]
                    -- 		},
                    -- 		colorMatchHealthBar = {
                    -- 			order = 3,
                    -- 			type = "toggle",
                    -- 			name = L["Color By Healthbar"],
                    -- 			desc = L["Match the color of the healthbar."],
                    -- 			set = function(key, value)
                    -- 				MOD:ChangeDBVar(value, key[#key], "pointer");
                    -- 				if value then
                    -- 					_G.WorldFrame.elapsed = 3
                    -- 				end
                    -- 			end
                    -- 		},
                    -- 		color = {
                    -- 			type = "color",
                    -- 			name = L["Color"],
                    -- 			order = 4,
                    -- 			disabled = function()return SV.db[Schema].pointer.colorMatchHealthBar end,
                    -- 			get = function(key)
                    -- 				local color = SV.db[Schema].pointer[key[#key]]
                    -- 				if color then
                    -- 					return color[1],color[2],color[3],color[4]
                    -- 				end
                    -- 			end,
                    -- 			set = function(key,r,g,b)
                    -- 				local color = {r,g,b}
                    -- 				MOD:ChangeDBVar(color, key[#key], "pointer")
                    -- 				MOD:UpdateAllPlates()
                    -- 			end,
                    -- 		}
                    -- 	}
                    -- },
                    -- raidHealIcon = {
                    -- 	type = "group",
                    -- 	order = 5,
                    -- 	name = L["Raid Icon"],
                    -- 	get = function(d)return SV.db[Schema].raidHealIcon[d[#d]]end,
                    -- 	set = function(d,e)MOD:ChangeDBVar(e,d[#d],"raidHealIcon")MOD:UpdateAllPlates()end,
                    -- 	args = {
                    -- 		attachTo = {
                    -- 			type = "select",
                    -- 			order = 1,
                    -- 			name = L["Attach To"],
                    -- 			values = positionTable
                    -- 		},
                    -- 		xOffset = {
                    -- 			type = "range",
                    -- 			order = 2,
                    -- 			name = L["X-Offset"],
                    -- 			min = -150,
                    -- 			max = 150,
                    -- 			step = 1
                    -- 		},
                    -- 		yOffset = {
                    -- 			type = "range",
                    -- 			order = 3,
                    -- 			name = L["Y-Offset"],
                    -- 			min = -150,
                    -- 			max = 150,
                    -- 			step = 1
                    -- 		},
                    -- 		size = {
                    -- 			order = 4,
                    -- 			type = "range",
                    -- 			name = L["Size"],
                    -- 			width = "full",
                    -- 			min = 10,
                    -- 			max = 200,
                    -- 			step = 1
                    -- 		},
                    -- 	}
                    -- },
                    -- auras = {
                    -- 	type = "group",
                    -- 	order = 4,
                    -- 	name = L["Auras"],
                    -- 	get = function(d)return SV.db[Schema].auras[d[#d]]end,
                    -- 	set = function(d,e)MOD:ChangeDBVar(e,d[#d],"auras")MOD:UpdateAllPlates()end,
                    -- 	args = {
                    -- 		numAuras = {
                    -- 			type = "range",
                    -- 			order = 1,
                    -- 			name = L["Number of Auras"],
                    -- 			min = 2,
                    -- 			max = 8,
                    -- 			step = 1
                    -- 		},
                    -- 		additionalFilter = {
                    -- 			type = "select",
                    -- 			order = 2,
                    -- 			name = L["Additional Filter"],
                    -- 			values = function()
                    -- 				filters = {}
                    -- 				filters[""] = _G.NONE;
                    -- 				for j in pairs(SV.db.Filters.Custom) do
                    -- 					filters[j] = j
                    -- 				end
                    -- 				return filters
                    -- 			end
                    -- 		},
                    -- 		configureButton = {
                    -- 			order = 4,
                    -- 			name = L["Configure Selected Filter"],
                    -- 			type = "execute",
                    -- 			width = "full",
                    -- 			func = function()ns:SetToFilterConfig(SV.db[Schema].auras.additionalFilter)end
                    -- 		},
                    -- 		fontGroup = {
                    -- 			order = 100,
                    -- 			type = "group",
                    -- 			guiInline = true,
                    -- 			name = L["Fonts"],
                    -- 			args = {
                    -- 				font = {
                    -- 					type = "select",
                    -- 					dialogControl = "LSM30_Font",
                    -- 					order = 4,
                    -- 					name = L["Font"],
                    -- 					values = AceVillainWidgets.font
                    -- 				},
                    -- 				fontSize = {
                    -- 					order = 5,
                    -- 					name = L["Font Size"],
                    -- 					type = "range",
                    -- 					min = 6,
                    -- 					max = 22,
                    -- 					step = 1
                    -- 				},
                    -- 				fontOutline = {
                    -- 					order = 6,
                    -- 					name = L["Font Outline"],
                    -- 					desc = L["Set the font outline."],
                    -- 					type = "select",
                    -- 					values = {
                    -- 						["NONE"] = L["None"],
                    -- 						["OUTLINE"] = "OUTLINE",
                    -- 						["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
                    -- 						["THICKOUTLINE"] = "THICKOUTLINE"
                    -- 					}
                    -- 				}
                    -- 			}
                    -- 		}
                    -- 	}
                    -- },
                    -- filters = {
                    -- 	type = "group",
                    -- 	order = 5,
                    -- 	name = L["Filters"],
                    -- 	args = {
                    -- 		addname = {
                    -- 			type = "input",
                    -- 			order = 1,
                    -- 			name = L["Add Name"],
                    -- 			get = function(d)return""end,
                    -- 			set = function(d,e)
                    -- 				if SV.db["NamePlates"]["filter"][e]then
                    -- 					SV:AddonMessage(L["Filter already exists!"])
                    -- 					return
                    -- 				end
                    -- 				SV.db["NamePlates"]["filter"][e] = {
                    -- 					["enable"] = true,
                    -- 					["hide"] = false,
                    -- 					["customColor"] = false,
                    -- 					["customScale"] = 1,
                    -- 					["color"] = {
                    -- 						g = 104/255,
                    -- 						h = 138/255,
                    -- 						i = 217/255
                    -- 					}
                    -- 				}
                    -- 				UpdateFilterGroupOptions()
                    -- 				MOD:UpdateAllPlates()
                    -- 			end
                    -- 		},
                    -- 		deletename = {
                    -- 			type = "input",
                    -- 			order = 2,
                    -- 			name = L["Remove Name"],
                    -- 			get = function(d)return""end,
                    -- 			set = function(d,e)
                    -- 				if SV.db["NamePlates"]["filter"][e] then
                    -- 					SV.db["NamePlates"]["filter"][e].enable = false;
                    -- 					SV:AddonMessage(L["You can't remove a default name from the filter,disabling the name."])
                    -- 				else
                    -- 					SV.db["NamePlates"]["filter"][e] = nil;
                    -- 					SV.Options.args[Schema].args.Filters.args.filterGroup = nil
                    -- 				end
                    -- 				UpdateFilterGroupOptions()
                    -- 				MOD:UpdateAllPlates()
                    -- 			end
                    -- 		},
                    -- 		selectFilter = {
                    -- 			order = 3,
                    -- 			type = "select",
                    -- 			name = L["Select Filter"],
                    -- 			get = function(d)return activeFilter end,
                    -- 			set = function(d,e)activeFilter = e;UpdateFilterGroupOptions()end,
                    -- 			values = function()
                    -- 				filters = {}
                    -- 				if(SV.db["NamePlates"]["filter"]) then
                    -- 					for j in pairs(SV.db["NamePlates"]["filter"])do
                    -- 						filters[j] = j
                    -- 					end
                    -- 				end
                    -- 				return filters
                    -- 			end
                    -- 		}
                    -- 	}
                    -- }
                }
            }
        }
    }

    self:UpdateNPCOptions()
end

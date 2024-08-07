--[[
##########################################################
Created by Vorka

Helper to analyze CPU Usage of the UI
Hook all plugin and module functions to GetFunctionCPUUsage
##########################################################
]]--

--[[
##########################################################
LUA DATA
##########################################################
]]--
--[[ GLOBALS ]]--
local CoreName, CoreObject = ...
local _G        = _G
local unpack    = unpack
local select    = select
local assert    = assert
local type      = type
local error     = error
local pcall     = pcall
--[[ STRING METHODS ]]--
local string    = string
local format    = string.format
local find      = string.find
local lower     = string.lower
local match     = string.match
local gsub      = string.gsub
--[[ MATH METHODS ]]--
local floor     = math.floor
local abs       = math.abs
local min       = math.min
local max       = math.max
--[[ TABLE METHODS ]]--
local tinsert   = tinsert
local tremove   = tremove
local tcopy     = table.copy
local twipe     = table.wipe
local tsort     = table.sort
local tconcat   = table.concat
local tprint    = table.tostring
--[[
##########################################################
WOW DATA
##########################################################
]]--
local DevTools_Dump         = _G.DevTools_Dump
local DevTools_RunDump      = _G.DevTools_RunDump
--[[
##########################################################
ADDON DATA
##########################################################
]]--
local SV            = _G["SVUI"]
local SVUILib       = Librarian("Registry")
local L             = SV.L
local ScriptError   = SV.ScriptError

SV.CPU              = {}
local CPU           = SV.CPU
--[[
##########################################################
LOCAL DATA
##########################################################
]]--
CPU.Window = CreateFrame("Frame")
CPU.Window:RegisterEvent("ADDON_LOADED")
CPU.Window:SetScript("OnEvent", function(self, event, ...)
    CPU[event](CPU, ...)
end)
CPU.peaks = {}
CPU.usage = {}

local addons = {}
local timerHandler
local filteredUsage = {}

local function round(num, decimals)
    local mult = 10^(decimals or 0)

    return floor(num * mult + 0.5) / mult
end

function CPU:Print(msg, ...)
    print("|cff00D1FF SVUI|r "..msg, ...)
end

function CPU:PrintCPUUsage(nbRow)
    nbRow = nbRow or #filteredUsage + 1

    for i, v in ipairs(filteredUsage) do
        if i < nbRow then
            if DevTool then
                DevTool:AddData(CPU.usage[v[1]], v[1])
            else
                self:Print("Top CPU Usage:", v[1], CPU.usage[v[1]])
            end
        end
    end
end

function CPU:ADDON_LOADED(addon)

    if GetCVar("scriptProfile") == 0 then return end

    if addon == CoreName then
        self.loadedTime = GetTime()

        addons[#addons+1] = addon
        if not self.loaded then
            self:HookFunctions(addon)
            self:UpdateFunctions(addon)
            self.loaded = true
        end

        self:Print("Addon loaded into the memory", addon)
    elseif match(addon, "SVUI") then
        addons[#addons+1] = addon
        self:HookFunctions(addon)
        self:UpdateFunctions(addon)
    end
end

function GetFunctionCPUUsage(addonName, key, func, tName)

    local svData
    if addonName == CoreName then
        svData = SV
    else
        svData = SV[tName]
    end
    local k = format("%s: %s", addonName, key)

    if not CPU.usage[k] then
        CPU.usage[k] = {
            usage = 0,
            calls = 0
        }
    else
        return CPU.usage[k].usage, CPU.usage[k].calls, svData[key]
    end

    local item = CPU.usage[k]

    svData[key] = function(...)
        local t = debugprofilestop()
        local retOk, ret1, ret2, ret3, ret4, ret5, ret6, ret7, ret8 = pcall(func, ...)
        item.usage = debugprofilestop()-t
        item.calls = 1 + (item.calls or 0)
        if retOk then
            return ret1, ret2, ret3, ret4, ret5, ret6, ret7, ret8
        else
            return nil
        end
    end

    return item.usage, item.calls, svData[key]
end

function CPU:HookFunction(addonName, key, func, name)

    local usage, calls, fct = GetFunctionCPUUsage(addonName, key, func, name)
    usage = max(0, usage)

    local k = format("%s: %s", addonName, key)
    local item = CPU.usage[k]

    item.peaks = self.peaks[fct] and self.peaks[fct].ms or 0
    item.usagePerCall = item.usage / max (1, item.calls)
    item.ratio = (item.usage / max(1, GetAddOnCPUUsage(addonName)))
    item.addonUsage = GetAddOnCPUUsage(addonName)
end

function CPU:HookFunctions(addon)

    if addon == CoreName then
        for key, func in pairs(SV) do
            if type(func) == "function" then
                self:HookFunction(addon, key, func)
            end
        end
    else
        local name = C_AddOns.GetAddOnMetadata(addon, "X-SVUIName")
        if name and SV[name] then
            for key, func in pairs(SV[name]) do
                if type(func) == "function" then
                    self:HookFunction(addon, key, func, name)
                end
            end
        end
    end

end

function CPU:UpdateFunction(addonName, key, func, name)
    local usage, calls, fct = GetFunctionCPUUsage(addonName, key, func, name)
    usage = max(0, usage)

    local peaks = self.peaks[fct]
    if not peaks then
        self.peaks[fct] = {
            ms = 0
        }
        peaks = self.peaks[fct]
    end

    if peaks.last then
        local times = calls - peaks.past
        local diff = times > 0 and ((usage - peaks.last) / times)
        if diff and (diff > peaks.ms) then
            peaks.ms = diff
        end
    end

    peaks.last = usage
    peaks.past = calls

    local k = format("%s: %s", addonName, key)
    local item = CPU.usage[k]

    item.peaks = peaks.ms
    item.usagePerCall = usage / max(1, calls)
    item.ratio = usage / max(1, GetAddOnCPUUsage(addonName))
    item.addonUsage = GetAddOnCPUUsage(addonName)

end

function CPU:UpdateFunctions(addon)
    UpdateAddOnCPUUsage(addon)

    if addon == CoreName then
        for key, func in pairs(SV) do
            if type(func) == "function" then
                self:UpdateFunction(addon, key, func)
            end
        end
    else
        local name = C_AddOns.GetAddOnMetadata(addon, "X-SVUIName")
        if SV[name] then
            for key, func in pairs(SV[name]) do
                if type(func) == "function" then
                    self:UpdateFunction(addon, key, func, name)
                end
            end
        end
    end
end

function CPU:Filter(mod)

    twipe(filteredUsage)

    for k, v in pairs(CPU.usage) do
        if mod then
            if mod == k and (v.usage > 0 or v.calls > 0) then
                filteredUsage[#filteredUsage+1] = { k, v.ratio }
            end
        elseif v.usage > 0 or v.calls > 0 then
            filteredUsage[#filteredUsage+1] = { k, v.ratio }
        end
    end

    tsort(filteredUsage, function (a, b)
        if a and b then
            return a[2] > b[2]
        end
    end)
end

local function initCPUUsage(arg)

    if arg == "on" and not timerHandler then

        if GetCVarBool("scriptProfile") == false then
            SetCVar("scriptProfile", true)
            ReloadUI()
        end

        timerHandler = C_Timer.NewTicker(1, function()
            for _, addon in ipairs(addons) do
                CPU:UpdateFunctions(addon)
            end
        end)

    elseif arg == "off" and timerHandler and not timerHandler:IsCancelled() then
        timerHandler:Cancel()
        timerHandler = nil

        SetCVar("scriptProfile", false)

    elseif arg == "print" then
        CPU:Filter()
        CPU:PrintCPUUsage()
    end
end

_G.SlashCmdList["SVUI_CPU_USAGE"] = initCPUUsage
_G.SLASH_SVUI_CPU_USAGE1 = "/svcpu"
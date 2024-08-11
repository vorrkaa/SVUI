--[[
##########################################################
S V U I   By: Failcoder
########################################################## 
LOCALIZED LUA FUNCTIONS
##########################################################
]]--
--[[ GLOBALS ]]--
local _G = _G;
local unpack 		= _G.unpack;
local select 		= _G.select;
local asset 		= assert
local IsAddOnLoaded	= C_AddOns.IsAddOnLoaded
--[[ 
########################################################## 
GET ADDON DATA
##########################################################
]]--
local SV = _G["SVUI"];
local L = SV.L;
local MOD = SV.Skins;
local Schema = MOD.Schema;
--[[ 
########################################################## 
BIGWIGS
##########################################################
]]--
local FreeBG
local BigWigsLoaded

local function freestyle(bar)
	bar.candyBarBackdrop:Hide()
	local height = bar:Get("bigwigs:restoreheight")
	if height then
		bar:SetHeight(height)
	end

	local tex = bar:Get("bigwigs:restoreicon")
	if tex then
		bar:SetIcon(tex)
		bar:Set("bigwigs:restoreicon", nil)

		bar.candyBarIconFrameBackdrop:Hide()
	end

	--if not FreeBG then FreeBG = {} end
	--local bg = bar:Get("bigwigs:elvui:barbg")
	--if bg then
	--	bg:ClearAllPoints()
	--	bg:SetParent(SV.Screen)
	--	bg:Hide()
	--	FreeBG[#FreeBG + 1] = bg
	--end
	--
	--local ibg = bar:Get("bigwigs:elvui:iconbg")
	--if ibg then
	--	ibg:ClearAllPoints()
	--	ibg:SetParent(SV.Screen)
	--	ibg:Hide()
	--	FreeBG[#FreeBG + 1] = ibg
	--end
	bar.candyBarIconFrame.SetWidth = bar.candyBarIconFrame.OldSetWidth
	bar.candyBarBar.SetPoint = bar.candyBarBar.OldSetPoint
	bar.candyBarIconFrame:ClearAllPoints()
	bar.candyBarIconFrame:SetPoint("TOPLEFT")
	bar.candyBarIconFrame:SetPoint("BOTTOMLEFT")
	bar.candyBarIconFrame:SetTexCoord(0.1,0.9,0.1,0.9)
	bar.candyBarBar:ClearAllPoints()
	bar.candyBarBar:SetPoint("TOPRIGHT")
	bar.candyBarBar:SetPoint("BOTTOMRIGHT")
	bar.candyBarBackground:SetAllPoints()
	bar.candyBarDuration:ClearAllPoints()
	bar.candyBarDuration:SetPoint("RIGHT", bar.candyBarBar, "RIGHT", -2, 0)
	bar.candyBarLabel:ClearAllPoints()
	bar.candyBarLabel:SetPoint("LEFT", bar.candyBarBar, "LEFT", 2, 0)
	bar.candyBarLabel:SetPoint("RIGHT", bar.candyBarBar, "RIGHT", -2, 0)
end

local function applystyle(bar)
	--if not FreeBG then FreeBG = {} end
	--bar:SetHeight(20)
	--local bg = nil
	--if #FreeBG > 0 then
	--	bg = tremove(FreeBG)
	--else
	--	bg = CreateFrame("Frame")
	--end
	--bg:SetStyle("!_Frame", 'Transparent', true)
	--bg:SetParent(bar)
	--bg:WrapPoints(bar)
	--bg:SetFrameLevel(bar:GetFrameLevel() - 1)
	--bg:SetFrameStrata(bar:GetFrameStrata())
	--bg:Show()
	--bar:Set("bigwigs:svui:barbg", bg)

	local height = bar:GetHeight()
	bar:Set("bigwigs:restoreheight", height)
	bar:SetHeight(height/2)

	local bd = bar.candyBarBackdrop
	bd:SetBackdrop(SVUI_CoreStyle_BarBackdropInfo)
	local r, g, b = SVUI_BackdropColorBlack:GetRGB()
	bd:SetBackdropColor(r, g, b, 0.5)
	bd:SetBackdropBorderColor(r, g, b, 1)
	bd:ClearAllPoints()
	bd:WrapPoints(bar)
	bd:Show()

	local ibg = nil
	if bar.candyBarIconFrame:GetTexture() then
		--if #FreeBG > 0 then
		--	ibg = tremove(FreeBG)
		--else
		--	ibg = CreateFrame("Frame")
		--end
		--ibg:SetParent(bar)
		--ibg:SetStyle("!_Frame", 'Transparent', true)
		--ibg:SetBackdropColor(0, 0, 0, 0)
		--ibg:WrapPoints(bar.candyBarIconFrame)
		--ibg:SetFrameLevel(bar:GetFrameLevel() - 1)
		--ibg:SetFrameStrata(bar:GetFrameStrata())
		--ibg:Show()
		--bar:Set("bigwigs:svui:iconbg", ibg)
		bar:Set("bigwigs:restoreicon", bar.candyBarIconFrame:GetTexture())

		local iconBd = bar.candyBarIconFrameBackdrop
		iconBd:SetBackdrop(SVUI_CoreStyle_BarBackdropInfo)
		iconBd:SetBackdropColor(r, g, b, 0.5)
		iconBd:SetBackdropBorderColor(r, g, b, 1)

		iconBd:WrapPoints(bar.candyBarIconFrame)
		iconBd:Show()
	end

	--[[
		["SVUI_Font_Number"] = "number",
	["SVUI_Font_Number_Huge"] = "number_big",
	["SVUI_Font_Header"] = "header",
	]]--
	bar.candyBarLabel:SetJustifyH("LEFT")
	bar.candyBarLabel:ClearAllPoints()
	bar.candyBarLabel:SetPoint("LEFT", bar, "LEFT", 4, 0)
	bar.candyBarLabel:SetFontObject(SVUI_Font_Header)

	bar.candyBarDuration:SetJustifyH("RIGHT")
	bar.candyBarDuration:ClearAllPoints()
	bar.candyBarDuration:SetPoint("RIGHT", bar, "RIGHT", -4, 0)
	bar.candyBarDuration:SetFontObject(SVUI_Font_Number_Huge)

	bar.candyBarBar:ClearAllPoints()
	bar.candyBarBar:SetAllPoints(bar)
	bar.candyBarBar:SetStatusBarTexture(SV.media.statusbar.default)

	bar.candyBarBar.OldSetPoint = bar.candyBarBar.SetPoint
	bar.candyBarBar.SetPoint = SV.fubar

	bar.candyBarIconFrame.OldSetWidth = bar.candyBarIconFrame.SetWidth
	bar.candyBarIconFrame.SetWidth = SV.fubar
	bar.candyBarIconFrame:ClearAllPoints()
	bar.candyBarIconFrame:SetPoint("BOTTOMRIGHT", bar, "BOTTOMLEFT", -1, 0)
	bar.candyBarIconFrame:SetSize(height, height)
	bar.candyBarIconFrame:SetTexCoord(0.1,0.9,0.1,0.9)
end

local function StyleBigWigs(event, addon)

	local styleName = SV.NameID

	if event == 'PLAYER_ENTERING_WORLD' then
		if BigWigsLoader then
			BigWigsLoader.RegisterMessage(styleName, "BigWigs_FrameCreated", function(event, frame, name)
				if name == "QueueTimer" then
					frame:RemoveTextures()
					frame:SetStyle("!_Frame", 'Transparent', true)
					frame:SetStatusBarTexture(SV.media.statusbar.default)
					frame:ClearAllPoints()
					frame:SetPoint('TOP', frame:GetParent(), 'BOTTOM', 0, 0)
					frame:SetHeight(16)
				end
			end)
		end
		return
	end

	if IsAddOnLoaded("BigWigs") or (event == "ADDON_LOADED" and addon == "BigWigs") then
		BigWigsAPI:RegisterBarStyle(styleName, {
			apiVersion = 1,
			version = 1,
			barHeight = 20,
			fontSizeNormal = 10,
			fontSizeEmphasized = 12,
			GetSpacing = function(bar)
				return bar:GetHeight() + 4
			end,
			ApplyStyle = applystyle,
			BarStopped = freestyle,
			GetStyleName = function() return styleName end,
		})

		BigWigsAPI:SetBarStyle(styleName)
		MOD:SafeEventRemoval("BigWigs", "ADDON_LOADED")
		MOD:SafeEventRemoval("BigWigs", "PLAYER_ENTERING_WORLD")
	end

end

MOD:SaveAddonStyle("BigWigs", StyleBigWigs, nil, true)
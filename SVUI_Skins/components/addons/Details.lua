--[[
##############################################################################
S V U I   By: Failcoder
##############################################################################
--]]
--[[ GLOBALS ]]--
local _G = _G;
local unpack  = _G.unpack;
local select  = _G.select;
local ipairs  = _G.ipairs;
local pairs   = _G.pairs;
--[[ ADDON ]]--
local SV = _G['SVUI'];
local L = SV.L;
local MOD = SV.Skins;
local Schema = MOD.Schema;
--[[
##########################################################
STYLE (IN DEVELOPMENT)
##########################################################
]]--
local Details = nil
local Instances = {}
local MaxInstance = 2
local colors = {
	[1] = { 0.847, 0.117, 0.074 },
	[2] = { 0.25, 0.75, 0.64 },
	[3] = { 0, 0.796, 1 },
}

local function SkinWindow(window, width, height)

	if not window then return end

	local id = window:GetId()
	local bodyFrame = _G['Details_WindowFrame'..id]
	local baseframe = window.baseframe

	if not window:IsEnabled() then
		window:EnableInstance()
	end

	window:SetSize(width, height)
	
	

	window:UngroupInstance()
	if not window.IsEmbedded then
		baseframe:ClearAllPoints()
		if id == 2 then
			baseframe:SetPoint("TOPLEFT", Instances[1].baseframe, "TOPRIGHT", 2, 0)
		else
			baseframe:SetPoint("BOTTOMLEFT", SVUI_DockBottomRight, "TOPLEFT", 1, 2)
		end

		window:SaveMainWindowPosition()
	end
	if id == 2 then
		window:MakeInstanceGroup({1})
	end
	window:LockInstance(true)

	window:SetBackdropTexture('None')
	window:InstanceColor(1, 1, 1, 0, nil, true)
	window:AttributeMenu(nil, nil, nil, "SVUI Default Font", 13, colors[id])
	window:SetBarSettings(20, "SVUI BasicBar", true, nil, nil, nil, nil, nil, nil, true)
	-- instance:SetBarTextSettings (size, font, fixedcolor, leftcolorbyclass, rightcolorbyclass, leftoutline, rightoutline, customrighttextenabled, customrighttext, percentage_type, showposition, customlefttextenabled, customlefttext, translittest)
	window:SetBarTextSettings(12, "SVUI Default Font", nil, false, false, true, true, true, "{data2} - {data1} [{data3}]", 1, false, false, nil, true)
	window:HideStatusBar()
	
	window:SetAutoHideMenu(true)
	
end

local function StyleDetails()
	assert(_G._detalhes, "AddOn Not Loaded");

	Details = _G._detalhes
	local detailsHeightOffset = 30
	local baseWidth = SV.Dock.BottomRight.Window:GetWidth()
	local baseHeight = SV.Dock.BottomRight.Window:GetHeight() - 4 - detailsHeightOffset
	local maxInstance = SV.db.Skins.details.maxInstance or MaxInstance
	local width = (baseWidth - 2) / maxInstance

	if Details.CreateEventListener then
		local listener = Details:CreateEventListener()
		listener:RegisterEvent("DETAILS_INSTANCE_OPEN")
		listener:RegisterEvent("DETAILS_INSTANCE_CLOSE")

		function listener:OnDetailsEvent (event, ...)
			if (event == "DETAILS_INSTANCE_CLOSE") then
				local instance = select (1, ...)
				if (_G.DetailsOptionsWindow and _G.DetailsOptionsWindow:IsShown()) then
					Details:Msg("You just closed a window Embed on SVUI, if wasn't intended click on Reopen.") --> need localization
				end
			elseif (event == "DETAILS_INSTANCE_OPEN") then
				local instance = select(1, ...)
				print ("DETAILS_INSTANCE_OPEN", ...)
				if instance.IsEmbedded then
					if (#Instances >= 2) then
						Instances[1]:UngroupInstance()
						Instances[2]:UngroupInstance()
						Instances[1].baseframe:ClearAllPoints()
						Instances[2].baseframe:ClearAllPoints()
						Instances[1]:RestoreMainWindowPosition()
						Instances[2]:RestoreMainWindowPosition()
						Instances[2]:MakeInstanceGroup({1})
					end
				end
			end
		end
	end

	wipe (Instances)
	for _, instance in Details:ListInstances() do
		SkinWindow(instance, width, baseHeight )
		tinsert(Instances, instance)
	end
	if (Details:GetMaxInstancesAmount() < maxInstance) then
		Details:SetMaxInstancesAmount(maxInstance)
	end
	local instancesAmount = Details:GetNumInstancesAmount()

	for i = instancesAmount + 1, maxInstance do
		local instance = Details:CreateInstance(i)
		if (type(instance) == "table") then
			tinsert(Instances, instance)
			SkinWindow( instance, width, baseHeight )
		end
	end


	-- for i=1, 10 do
	-- 	local baseframe = _G['DetailsBaseFrame'..i];

	-- 	if(baseframe) then
	-- 		local bgframe = _G['Details_WindowFrame'..i];
	-- 		baseframe:RemoveTextures();
	-- 		if(bgframe) then
	-- 			bgframe:RemoveTextures();
	-- 			bgframe:SetStyle("Frame", "Transparent");
	-- 		else
	-- 			baseframe:SetStyle("Frame", "Transparent");
	-- 		end
	-- 	end
	-- end
end
--[[
##########################################################
MOD LOADING
##########################################################
]]--
MOD:SaveAddonStyle("Details", StyleDetails)

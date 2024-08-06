--[[
##############################################################################
S V U I   By: Failcoder
##############################################################################
--]]
--[[ GLOBALS ]]--
local _G = _G;
local unpack  = _G.unpack;
local select  = _G.select;
local pairs   = _G.pairs;
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
local AuctionSortLinks = {
	"BrowseQualitySort",
	"BrowseLevelSort",
	"BrowseDurationSort",
	"BrowseHighBidderSort",
	"BrowseCurrentBidSort",
	"BidQualitySort",
	"BidLevelSort",
	"BidDurationSort",
	"BidBuyoutSort",
	"BidStatusSort",
	"BidBidSort",
	"AuctionsQualitySort",
	"AuctionsDurationSort",
	"AuctionsHighBidderSort",
	"AuctionsBidSort"
}
local AuctionBidButtons = {
	"BrowseBidButton",
	"BidBidButton",
	"BrowseBuyoutButton",
	"BidBuyoutButton",
	"BrowseCloseButton",
	"BidCloseButton",
	"BrowseSearchButton",
	"AuctionsCreateAuctionButton",
	"AuctionsCancelAuctionButton",
	"AuctionsCloseButton",
	"BrowseResetButton",
	"AuctionsStackSizeMaxButton",
	"AuctionsNumStacksMaxButton",
}

local AuctionTextFields = {
	"BrowseName",
	"BrowseMinLevel",
	"BrowseMaxLevel",
	"BrowseBidPriceGold",
	"BidBidPriceGold",
	"AuctionsStackSizeEntry",
	"AuctionsNumStacksEntry",
	"StartPriceGold",
	"BuyoutPriceGold",
	"BrowseBidPriceSilver",
	"BrowseBidPriceCopper",
	"BidBidPriceSilver",
	"BidBidPriceCopper",
	"StartPriceSilver",
	"StartPriceCopper",
	"BuyoutPriceSilver",
	"BuyoutPriceCopper"
}
--[[
##########################################################
AUCTIONFRAME MODR
##########################################################
]]--
local _hook_FilterButton_SetUp = function(button)
	if(button) then
		local normalTexture = _G[button:GetName().."NormalTexture"];
		normalTexture:SetTexture("")
		if(not button.Panel) then
			button:RemoveTextures(true)
			button:SetStyle("!_Button")
			button.Panel.CanBeRemoved = true
		end
	end
end

local function styleListIcon(parent)
	if not parent.tableBuilder then return end

	for i = 1, 22 do
		local row = parent.tableBuilder.rows[i]
		if row then
			for j = 1, 4 do
				local cell = row.cells and row.cells[j]
				if cell and cell.Icon then
					if not cell.skinned then

						cell.Icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))

						if cell.IconBorder then
							cell.IconBorder:Die()
						end

						cell.skinned = true
					end
				end
			end
		end
	end
end

local function styleHeaderContainer(parent)
	for _, header in next, { parent.HeaderContainer:GetChildren() } do

		if not header.skinned then
			header:DisableDrawLayer('BACKGROUND')
			-- child.Middle:Die()
			-- child.Left:Die()
			-- child.Right:Die()
			header:SetStyle("!_Button")
			header.skinned = true
		end
	end

	styleListIcon(parent)
end

local function AuctionStyle()
	--MOD.Debugging = true
	if(SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.auctionhouse ~= true) then return end

	local holder = AuctionHouseFrame

	holder:RemoveTextures(true)
	holder.NineSlice:Hide()

	-- SV.API:Set("Window", AuctionHouseFrame, false, true, 1, 2, -8)
	holder:SetStyle("Frame", "Window", false, true, 1, 2, -8)
	holder:SetMovable(true)
    holder:EnableMouse(true)
    holder:RegisterForDrag("LeftButton")
    holder:SetScript("OnDragStart", holder.StartMoving)
    holder:SetScript("OnDragStop", holder.StopMovingOrSizing)

	holder.TitleContainer.TitleText:SetFontObject(SVUI_Font_Header)
	holder.PortraitContainer:RemoveTextures(true)

	local categoriesList = holder.CategoriesList
	categoriesList:RemoveTextures()
	SV.API:Set("ScrollBar", categoriesList)
	categoriesList.NineSlice:Hide()

	local searchBar = holder.SearchBar
	searchBar.SearchButton:SetStyle("Button")

	holder.MoneyFrameInset:RemoveTextures(true)
	holder.MoneyFrameInset:Hide()
	holder.MoneyFrameBorder:RemoveTextures(true)

	--[[
	BROWSE RESULTS FRAME
	]]--
	local resultsFrame = holder.BrowseResultsFrame.ItemList
	resultsFrame:RemoveTextures()
	SV.API:Set("ScrollBar", resultsFrame)
	resultsFrame.NineSlice:Hide()
	hooksecurefunc(resultsFrame, "RefreshScrollFrame", styleHeaderContainer)

	--[[
	AUCTIONS FRAME
	]]--
	local auctionsFrame = holder.AuctionsFrame
	auctionsFrame:RemoveTextures()
	
	local auctionsList = auctionsFrame.AllAuctionsList
	auctionsList:RemoveTextures()
	SV.API:Set("ScrollBar", auctionsList)
	auctionsList.NineSlice:Hide()
	hooksecurefunc(auctionsList, "RefreshScrollFrame", styleHeaderContainer)
	-- styleHeaderContainer(auctionsList.HeaderContainer)

	local summaryList = auctionsFrame.SummaryList
	summaryList:RemoveTextures()
	SV.API:Set("ScrollBar", summaryList)
	summaryList.NineSlice:Hide()

	local bidsList = auctionsFrame.BidsList
	bidsList:RemoveTextures()
	SV.API:Set("ScrollBar", bidsList)
	bidsList.NineSlice:Hide()
	hooksecurefunc(bidsList, "RefreshScrollFrame", styleHeaderContainer)

	for _, n in ipairs( {"copper", "gold", "silver"} ) do
		SV.API:Set("EditBox", auctionsFrame.BidFrame.BidAmount[n])
	end

	auctionsFrame.BidFrame.BidButton:SetStyle("Button")
	auctionsFrame.BuyoutFrame.BuyoutButton:SetStyle("Button")
	auctionsFrame.CancelAuctionButton:SetStyle("Button")
	--[[
	SELL FRAME
	]]--
	local itemSellList = holder.ItemSellList
	itemSellList:RemoveTextures()
	SV.API:Set("ScrollBar", itemSellList)
	itemSellList.NineSlice:Hide()
	hooksecurefunc(itemSellList, "RefreshScrollFrame", styleHeaderContainer)

	local itemSellFrame = holder.ItemSellFrame
	itemSellFrame:RemoveTextures()
	itemSellFrame:SetStyle("!_Frame", "Window2")
	itemSellFrame:SetPanelColor("darkest")
	itemSellFrame.NineSlice:Hide()
	SV.API:Set("EditBox", itemSellFrame.PriceInput.MoneyInputFrame.CopperBox)
	SV.API:Set("EditBox", itemSellFrame.PriceInput.MoneyInputFrame.SilverBox)
	SV.API:Set("EditBox", itemSellFrame.PriceInput.MoneyInputFrame.GoldBox)
	SV.API:Set("EditBox", itemSellFrame.SecondaryPriceInput.MoneyInputFrame.CopperBox)
	SV.API:Set("EditBox", itemSellFrame.SecondaryPriceInput.MoneyInputFrame.SilverBox)
	SV.API:Set("EditBox", itemSellFrame.SecondaryPriceInput.MoneyInputFrame.GoldBox)
	SV.API:Set("EditBox", itemSellFrame.QuantityInput.InputBox)
	itemSellFrame.QuantityInput.MaxButton:SetStyle("Button")
	itemSellFrame.PostButton:SetStyle("Button")
	
	itemSellFrame.ItemDisplay:RemoveTextures()
	itemSellFrame.ItemDisplay.NineSlice:Hide()
	
	--itemSellFrame.BuyoutModeCheckButton

	-- BrowseFilterScrollFrameScrollBar:RemoveTextures()
	-- BrowseScrollFrameScrollBar:RemoveTextures()
	-- AuctionsScrollFrameScrollBar:RemoveTextures()
	-- BidScrollFrameScrollBar:RemoveTextures()

	-- SV.API:Set("CloseButton", AuctionHouseFrame.CloseButton)
	-- SV.API:Set("ScrollBar", AuctionsScrollFrame)

	-- SV.API:Set("DropDown", BrowseDropDown)
	-- SV.API:Set("DropDown", PriceDropDown)
	-- SV.API:Set("DropDown", DurationDropDown)
	-- SV.API:Set("ScrollBar", BrowseFilterScrollFrame)
	-- SV.API:Set("ScrollBar", BrowseScrollFrame)
	-- IsUsableCheckButton:SetStyle("CheckButton")
	-- ShowOnPlayerCheckButton:SetStyle("CheckButton")

	-- ExactMatchCheckButton:RemoveTextures()
	-- ExactMatchCheckButton:SetStyle("CheckButton")
	-- ExactMatchCheckButtonText:ClearAllPoints()
	-- ExactMatchCheckButtonText:SetPoint("LEFT", ExactMatchCheckButton, "RIGHT", 6, 0)
	-- --SideDressUpFrame:SetPoint("LEFT", AuctionFrame, "RIGHT", 16, 0)

	-- AuctionProgressFrame:RemoveTextures()
	-- AuctionProgressFrame:SetStyle("!_Frame", "Transparent", true)
	-- AuctionProgressFrameCancelButton:SetStyle("Button")
	-- AuctionProgressFrameCancelButton:SetStyle("!_Frame", "Default")
	-- AuctionProgressFrameCancelButton:SetHitRectInsets(0, 0, 0, 0)
	-- AuctionProgressFrameCancelButton:GetNormalTexture():InsetPoints()
	-- AuctionProgressFrameCancelButton:GetNormalTexture():SetTexCoord(0.67, 0.37, 0.61, 0.26)
	-- AuctionProgressFrameCancelButton:SetSize(28, 28)
	-- AuctionProgressFrameCancelButton:SetPoint("LEFT", AuctionProgressBar, "RIGHT", 8, 0)
	-- AuctionProgressBar.Icon:SetTexCoord(0.67, 0.37, 0.61, 0.26)

	-- local AuctionProgressBarBG = CreateFrame("Frame", nil, AuctionProgressBar.Icon:GetParent())
	-- AuctionProgressBarBG:WrapPoints(AuctionProgressBar.Icon)
	-- AuctionProgressBarBG:SetStyle("!_Frame", "Default")
	-- AuctionProgressBar.Icon:SetParent(AuctionProgressBarBG)

	-- AuctionProgressBar.Text:ClearAllPoints()
	-- AuctionProgressBar.Text:SetPoint("CENTER")
	-- AuctionProgressBar:RemoveTextures()
	-- AuctionProgressBar:SetStyle("Frame", "Default")
	-- AuctionProgressBar:SetStatusBarTexture(SV.media.statusbar.default)
	-- AuctionProgressBar:SetStatusBarColor(1, 1, 0)

	-- SV.API:Set("PageButton", BrowseNextPageButton)
	-- SV.API:Set("PageButton", BrowsePrevPageButton)

	-- for _,gName in pairs(AuctionBidButtons) do
	-- 	if(_G[gName]) then
	-- 		_G[gName]:RemoveTextures()
	-- 		_G[gName]:SetStyle("Button")
	-- 	end
	-- end

	-- AuctionsCloseButton:SetPoint("BOTTOMRIGHT", AuctionFrameAuctions, "BOTTOMRIGHT", 66, 10)
	-- AuctionsCancelAuctionButton:SetPoint("RIGHT", AuctionsCloseButton, "LEFT", -4, 0)

	-- BidBuyoutButton:SetPoint("RIGHT", BidCloseButton, "LEFT", -4, 0)
	-- BidBidButton:SetPoint("RIGHT", BidBuyoutButton, "LEFT", -4, 0)

	-- BrowseBuyoutButton:SetPoint("RIGHT", BrowseCloseButton, "LEFT", -4, 0)
	-- BrowseBidButton:SetPoint("RIGHT", BrowseBuyoutButton, "LEFT", -4, 0)

	-- AuctionsItemButton:RemoveTextures()
	-- AuctionsItemButton:SetStyle("Button")
	-- AuctionsItemButton:SetScript("OnUpdate", function()
	-- 	if AuctionsItemButton:GetNormalTexture()then
	-- 		AuctionsItemButton:GetNormalTexture():SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
	-- 		AuctionsItemButton:GetNormalTexture():InsetPoints()
	-- 	end
	-- end)

	-- for _,frame in pairs(AuctionSortLinks)do
	-- 	_G[frame.."Left"]:Die()
	-- 	_G[frame.."Middle"]:Die()
	-- 	_G[frame.."Right"]:Die()
	-- end

	-- SV.API:Set("Tab", _G["AuctionFrameTab1"])
	-- SV.API:Set("Tab", _G["AuctionFrameTab2"])
	-- SV.API:Set("Tab", _G["AuctionFrameTab3"])

	-- AuctionFrameBrowse.bg1 = CreateFrame("Frame", nil, AuctionFrameBrowse)
	-- AuctionFrameBrowse.bg1:SetPoint("TOPLEFT", 20, -103)
	-- AuctionFrameBrowse.bg1:SetPoint("BOTTOMRIGHT", -575, 40)
	-- AuctionFrameBrowse.bg1:SetStyle("!_Frame", "Inset")

	-- BrowseNoResultsText:SetParent(AuctionFrameBrowse.bg1)
	-- BrowseSearchCountText:SetParent(AuctionFrameBrowse.bg1)

	-- BrowseSearchButton:SetPoint("TOPRIGHT", AuctionFrameBrowse, "TOPRIGHT", 25, -34)
	-- BrowseResetButton:SetPoint("TOPRIGHT", BrowseSearchButton, "TOPLEFT", -4, 0)

	-- AuctionFrameBrowse.bg1:SetFrameLevel(AuctionFrameBrowse.bg1:GetFrameLevel()-1)
	-- BrowseFilterScrollFrame:SetHeight(300)
	-- AuctionFrameBrowse.bg2 = CreateFrame("Frame", nil, AuctionFrameBrowse)
	-- AuctionFrameBrowse.bg2:SetStyle("!_Frame", "Inset")
	-- AuctionFrameBrowse.bg2:SetPoint("TOPLEFT", AuctionFrameBrowse.bg1, "TOPRIGHT", 4, 0)
	-- AuctionFrameBrowse.bg2:SetPoint("BOTTOMRIGHT", AuctionFrame, "BOTTOMRIGHT", -8, 40)
	-- AuctionFrameBrowse.bg2:SetFrameLevel(AuctionFrameBrowse.bg2:GetFrameLevel() - 1)

	-- hooksecurefunc("FilterButton_SetUp", _hook_FilterButton_SetUp)

	-- for _,field in pairs(AuctionTextFields) do
	-- 	--_G[field]:RemoveTextures()
	-- 	_G[field]:SetStyle("Editbox", 2, 2)
	-- 	_G[field]:SetTextInsets(-1, -1, -2, -2)
	-- end

	-- BrowseNameText:ClearAllPoints()
	-- BrowseNameText:SetPoint("BOTTOMLEFT", AuctionFrame, "TOPLEFT", 30, -47)
	-- BrowseLevelText:ClearAllPoints()
	-- BrowseLevelText:SetPoint("BOTTOMLEFT", AuctionFrame, "TOPLEFT", 190, -47)
	-- BrowseNameSearchIcon:ClearAllPoints()
	-- BrowseNameSearchIcon:SetPoint("RIGHT", BrowseName, "LEFT", -2, -2)
	-- BrowseMinLevel:ClearAllPoints()
	-- BrowseMinLevel:SetPoint("LEFT", BrowseName, "RIGHT", 18, 0)
	-- BrowseLevelHyphen:ClearAllPoints()
	-- BrowseLevelHyphen:SetPoint("LEFT", BrowseMinLevel, "RIGHT", 5, 0)
	-- BrowseMaxLevel:ClearAllPoints()
	-- BrowseMaxLevel:SetPoint("LEFT", BrowseMinLevel, "RIGHT", 16, 0)
	-- BrowseDropDownName:ClearAllPoints()
	-- BrowseDropDownName:SetPoint("BOTTOMLEFT", BrowseLevelText, "BOTTOMRIGHT", 18, 0)
	-- BrowseDropDown:ClearAllPoints()
	-- BrowseDropDown:SetPoint("TOPLEFT", BrowseLevelText, "BOTTOMRIGHT", -2, 0)
	-- AuctionsStackSizeEntry.Panel:SetAllPoints()
	-- AuctionsNumStacksEntry.Panel:SetAllPoints()

	-- for h = 1, NUM_BROWSE_TO_DISPLAY do
	-- 	local button = _G["BrowseButton"..h];
	-- 	local buttonItem = _G["BrowseButton"..h.."Item"];
	-- 	local buttonTex = _G["BrowseButton"..h.."ItemIconTexture"];

	-- 	if(button and (not button.Panel)) then
	-- 		button:RemoveTextures()
	-- 		button:SetStyle("Button")
	-- 		button.Panel:ClearAllPoints()
	-- 		button.Panel:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
	-- 		button.Panel:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 5)

	-- 		if(buttonItem) then
	-- 			buttonItem:RemoveTextures()
	-- 			buttonItem:SetStyle("Icon")
	-- 			if(buttonTex) then
	-- 				buttonTex:SetParent(buttonItem.Panel)
	-- 				buttonTex:InsetPoints(buttonItem.Panel, 2, 2)
	-- 				buttonTex:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
	-- 				buttonTex:SetDesaturated(false)
	-- 			end

	-- 			local highLight = button:GetHighlightTexture()
	-- 			highLight:ClearAllPoints()
	-- 			highLight:SetPoint("TOPLEFT", buttonItem, "TOPRIGHT", 2, -2)
	-- 			highLight:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 7)
	-- 			button:GetPushedTexture():SetAllPoints(highLight)
	-- 			_G["BrowseButton"..h.."Highlight"] = highLight
	-- 		end
	-- 	end
	-- end

	-- for h = 1, NUM_AUCTIONS_TO_DISPLAY do
	-- 	local button = _G["AuctionsButton"..h];
	-- 	local buttonItem = _G["AuctionsButton"..h.."Item"];
	-- 	local buttonTex = _G["AuctionsButton"..h.."ItemIconTexture"];

	-- 	if(button) then
	-- 		if(buttonTex) then
	-- 			buttonTex:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
	-- 			buttonTex:InsetPoints()
	-- 			buttonTex:SetDesaturated(false)
	-- 		end

	-- 		button:RemoveTextures()
	-- 		button:SetStyle("Button")

	-- 		if(buttonItem) then
	-- 			buttonItem:SetStyle("Button")
	-- 			buttonItem.Panel:SetAllPoints()
	-- 			buttonItem:HookScript("OnUpdate", function()
	-- 				buttonItem:GetNormalTexture():Die()
	-- 			end)

	-- 			local highLight = button:GetHighlightTexture()
	-- 			_G["AuctionsButton"..h.."Highlight"] = highLight
	-- 			highLight:ClearAllPoints()
	-- 			highLight:SetPoint("TOPLEFT", buttonItem, "TOPRIGHT", 2, 0)
	-- 			highLight:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 5)
	-- 			button:GetPushedTexture():SetAllPoints(highLight)
	-- 		end
	-- 	end
	-- end

	-- for h = 1, NUM_BIDS_TO_DISPLAY do
	-- 	local button = _G["BidButton"..h];
	-- 	local buttonItem = _G["BidButton"..h.."Item"];
	-- 	local buttonTex = _G["BidButton"..h.."ItemIconTexture"];

	-- 	if(button) then
	-- 		if(buttonTex) then
	-- 			buttonTex:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
	-- 			buttonTex:InsetPoints()
	-- 			buttonTex:SetDesaturated(false)
	-- 		end

	-- 		button:RemoveTextures()
	-- 		button:SetStyle("Button")

	-- 		if(buttonItem) then
	-- 			buttonItem:SetStyle("Button")
	-- 			buttonItem.Panel:SetAllPoints()
	-- 			buttonItem:HookScript("OnUpdate", function()
	-- 				buttonItem:GetNormalTexture():Die()
	-- 			end)

	-- 			local highLight = button:GetHighlightTexture()
	-- 			_G["BidButton"..h.."Highlight"] = highLight
	-- 			highLight:ClearAllPoints()
	-- 			highLight:SetPoint("TOPLEFT", buttonItem, "TOPRIGHT", 2, 0)
	-- 			highLight:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 5)
	-- 			button:GetPushedTexture():SetAllPoints(highLight)
	-- 		end
	-- 	end
	-- end

	-- BrowseScrollFrame:SetHeight(300)
	-- AuctionFrameBid.bg = CreateFrame("Frame", nil, AuctionFrameBid)
	-- AuctionFrameBid.bg:SetStyle("!_Frame", "Inset")
	-- AuctionFrameBid.bg:SetPoint("TOPLEFT", 22, -72)
	-- AuctionFrameBid.bg:SetPoint("BOTTOMRIGHT", 66, 39)
	-- AuctionFrameBid.bg:SetFrameLevel(AuctionFrameBid.bg:GetFrameLevel()-1)
	-- BidScrollFrame:SetHeight(332)
	-- AuctionsScrollFrame:SetHeight(336)
	-- AuctionFrameAuctions.bg1 = CreateFrame("Frame", nil, AuctionFrameAuctions)
	-- AuctionFrameAuctions.bg1:SetStyle("!_Frame", "Inset")
	-- AuctionFrameAuctions.bg1:SetPoint("TOPLEFT", 15, -70)
	-- AuctionFrameAuctions.bg1:SetPoint("BOTTOMRIGHT", -545, 35)
	-- AuctionFrameAuctions.bg1:SetFrameLevel(AuctionFrameAuctions.bg1:GetFrameLevel() - 2)
	-- AuctionFrameAuctions.bg2 = CreateFrame("Frame", nil, AuctionFrameAuctions)
	-- AuctionFrameAuctions.bg2:SetStyle("!_Frame", "Inset")
	-- AuctionFrameAuctions.bg2:SetPoint("TOPLEFT", AuctionFrameAuctions.bg1, "TOPRIGHT", 3, 0)
	-- AuctionFrameAuctions.bg2:SetPoint("BOTTOMRIGHT", AuctionFrame, -8, 35)
	-- AuctionFrameAuctions.bg2:SetFrameLevel(AuctionFrameAuctions.bg2:GetFrameLevel() - 2)
end
--[[
##########################################################
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle("Blizzard_AuctionHouseUI", AuctionStyle)

--[[
##############################################################################
S V U I   By: Failcoder
##############################################################################
--]]
--[[ GLOBALS ]]--
local _G = _G;
local unpack  = _G.unpack;
local select  = _G.select;
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
local FAV_ICON = SV.media.icon.star
local NORMAL_COLOR = {r = 1, g = 1, b = 1}
local SELECTED_COLOR = {r = 1, g = 1, b = 0}
local WARDROBE_NUM_ROWS = 3;
local WARDROBE_NUM_COLS = 6;
local WARDROBE_SLOT_ICONS = { 
	[[Interface\ICONS\INV_Helmet_03]], 
	[[Interface\ICONS\INV_Shoulder_09]], 
	[[Interface\ICONS\INV_Misc_Cape_19]], 
	[[Interface\ICONS\INV_Chest_Chain]], 
	[[Interface\ICONS\INV_Shirt_White_01]], 
	[[Interface\ICONS\INV_MISC_TABARDSUMMER01]], 
	[[Interface\ICONS\INV_Bracer_05]], 
	[[Interface\ICONS\INV_Gauntlets_24]], 
	[[Interface\ICONS\INV_Belt_24]], 
	[[Interface\ICONS\INV_Pants_09]], 
	[[Interface\ICONS\INV_BOOTS_09]], 
	[[Interface\ICONS\INV_Sword_04]], 
	[[Interface\ICONS\INV_Shield_06]] 
};

local function PetJournal_UpdateMounts()
	for b = 1, #MountJournal.ListScrollFrame.buttons do 
		local d = _G["MountJournalListScrollFrameButton"..b]
		local e = _G["MountJournalListScrollFrameButton"..b.."Name"]
		if d.selectedTexture:IsShown() then
			if(e) then e:SetTextColor(1, 1, 0) end
			if d.Panel then
				d:SetBackdropBorderColor(1, 1, 0)
			end 
			if d.IconShadow then
				d.IconShadow:SetBackdropBorderColor(1, 1, 0)
			end 
		else
			if(e) then e:SetTextColor(1, 1, 1) end
			if d.Panel then
				d:SetBackdropBorderColor(0,0,0,1)
			end 
			if d.IconShadow then
				d.IconShadow:SetBackdropBorderColor(0,0,0,1)
			end 
		end 
	end 
end 

local function PetJournal_UpdatePets()

	if not PetJournal.isSkinned then

		local scrollFrame = PetJournal.ScrollBox;
		local buttons = scrollFrame:GetFrames();

		local button
		for i=1, #buttons do
			button = buttons[i]

			-- SV.API:Set("ItemButton", button)
			
			local fg = CreateFrame("Frame", nil, button.dragButton)
			fg:SetAllPoints(button.dragButton.favorite)
			fg:SetFrameLevel(button.dragButton:GetFrameLevel() + 30)
			button.dragButton.favorite:SetParent(fg)
			button.dragButton.favorite:SetTexture(SV.media.icon.star)

			button.icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
			button.iconBorder:Hide()

			button.dragButton.levelBG:Hide()
			hooksecurefunc(button.dragButton.levelBG, 'Show', function (self) self:Hide() end)
			hooksecurefunc(button.dragButton.levelBG, 'SetShown', function (self, show) self:Hide() end)
			button.dragButton.level:SetFontObject(SVUI_Font_Number)
			if button.petID then
				local rarity = select(5, C_PetJournal.GetPetStats(button.petID))
				local color = ITEM_QUALITY_COLORS[rarity-1] or NORMAL_COLOR
				-- button:SetBackdropBorderColor(0, 0, 0, 1)
				-- if (button.selectedTexture:IsShown() and button.Panel) then
				-- 	button:SetBackdropBorderColor(1, 1, 0, 1)
				-- end
				button.name:SetTextColor(color.r, color.g, color.b)
			end
		end

		PetJournal.isSkinned = true
	end

	-- local u = PetJournal.ScrollBox:GetFrames();
	-- local isWild = PetJournal.isWild;
	-- for b = 1, #u do 
	-- 	local v = u[b].index;
	-- 	if not v then
	-- 		break 
	-- 	end 
	-- 	local d = _G["PetJournalListScrollFrameButton"..b]
	-- 	local e = _G["PetJournalListScrollFrameButton"..b.."Name"]
	-- 	local levelText = _G["PetJournalListScrollFrameButton"..b.."Level"]
	-- 	local w, x, y, z, level, favorite, A, B, C, D, E, F, G, H, I = C_PetJournal.GetPetInfoByIndex(v, isWild)
	-- 	if w ~= nil then 
	-- 		local J, K, L, M, N = C_PetJournal.GetPetStats(w)
	-- 		local color = NORMAL_COLOR
	-- 		if(N) then 
	-- 			color = ITEM_QUALITY_COLORS[N-1]
	-- 		end
	-- 		if not d.SetBackdropBorderColor then
	-- 			d = mixin(d, BackdropTemplateMixin)
	-- 		end
	-- 		d:SetBackdropBorderColor(0,0,0,1)
	-- 		if(d.selectedTexture:IsShown() and d.Panel) then
	-- 			d:SetBackdropBorderColor(1,1,0,1)
	-- 			if d.IconShadow then
	-- 				d.IconShadow:SetBackdropBorderColor(1,1,0)
	-- 			end
	-- 		else
	-- 			if d.IconShadow then
	-- 				d.IconShadow:SetBackdropBorderColor(color.r, color.g, color.b)
	-- 			end
	-- 		end

	-- 		e:SetTextColor(color.r, color.g, color.b)
	-- 	end
	-- end 
end 

local function WardrobeFrameUpdateSlots(...)
	if (not WardrobeCollectionFrame or not WardrobeCollectionFrame.ModelsFrame or not WardrobeCollectionFrame.ModelsFrame.SlotsFrame or not WardrobeCollectionFrame.ModelsFrame.SlotsFrame.Buttons) then return end
	local slotButtons = WardrobeCollectionFrame.ModelsFrame.SlotsFrame.Buttons;
	for i = 1, #slotButtons do
		local button = slotButtons[i];
		local icon = WARDROBE_SLOT_ICONS[i];
		if (not button.Panel and icon) then
			SV.API:Set("IconButton", button, icon)
		end
	end
end

local function WardrobeFrameUpdateModels(...)
	if (not WardrobeCollectionFrame or not WardrobeCollectionFrame.ModelsFrame) then return end
	for r = 1, WARDROBE_NUM_ROWS do
		for c = 1, WARDROBE_NUM_COLS do
			model = WardrobeCollectionFrame.ModelsFrame["ModelR"..r.."C"..c];
			model:RemoveTextures(true);
			model:SetStyle("!_ShadowBox", 'Model');
		end
	end
end
--[[ 
########################################################## 
FRAME MODR
##########################################################
]]--
local function CollectionsJournalStyle()
	if SV.db.Skins.blizzard.enable ~= true or SV.db.Skins.blizzard.mounts ~= true then return end 

	SV.API:Set("Window", CollectionsJournal, true, true)

	CollectionsJournalPortrait:Hide()
	CollectionsJournal.TitleContainer:ClearAllPoints()
	CollectionsJournal.TitleContainer:SetPoint("TOPLEFT", CollectionsJournal, 24, -1)
	CollectionsJournal.TitleContainer:SetPoint("TOPRIGHT", CollectionsJournal, -24, -1)
	CollectionsJournal.TitleContainer.TitleText:SetFontObject(SVUI_Font_Header)

	SV.API:Set("Tab", CollectionsJournalTab1)
	SV.API:Set("Tab", CollectionsJournalTab2)
	SV.API:Set("CloseButton", CollectionsJournalCloseButton)

	MountJournal:RemoveTextures()
	MountJournal.LeftInset:RemoveTextures()
	MountJournal.LeftInset:Hide()
	MountJournal.RightInset:RemoveTextures()
	MountJournal.RightInset:Hide()
	MountJournal.MountDisplay:RemoveTextures()
	MountJournal.MountDisplay.ShadowOverlay:RemoveTextures()
	MountJournal.MountCount:RemoveTextures()
	--MountJournalListScrollFrameScrollBar:RemoveTextures()
	MountJournalMountButton:RemoveTextures()
	MountJournalMountButton:SetStyle("Button")
	MountJournalSearchBox:SetStyle("Editbox")
	local texture = MountJournal.SummonRandomFavoriteButton.texture:GetTexture()
	SV.API:Set("IconButton", MountJournal.SummonRandomFavoriteButton, texture)

	MountJournal.ToggleDynamicFlightFlyoutButton.Border:Hide()

	SV.API:Set("ScrollBar", MountJournal)
	MountJournal.MountDisplay.ModelScene:SetStyle("!_Frame", "Model")
	MountJournal.MountDisplay.ModelScene.TogglePlayer:RemoveTextures()
	SV.API:Set("CheckButton", MountJournal.MountDisplay.ModelScene.TogglePlayer)

	-- local buttons = MountJournal.ScrollBox.ScrollTarget:GetChildren()
	-- for i = 1, #buttons do
	-- 	local button = buttons[i]
	-- 	if(button) then
	-- 		SV.API:Set("ItemButton", button)
	-- 		local bar = _G["SVUI_MountSelectBar"..i]
	-- 		if(bar) then bar:SetParent(button.Panel) end
	-- 		if(button.favorite) then
	-- 			local fg = CreateFrame("Frame", nil, button)
	-- 			fg:SetAllPoints(favorite)
	-- 			fg:SetFrameLevel(button:GetFrameLevel() + 30)
	-- 			button.favorite:SetParent(fg)
	-- 			button.favorite:SetTexture(SV.media.icon.star)
	-- 		end
	-- 	end
	-- end

	--[[ PET ]]--
	PetJournal:RemoveTextures()
	PetJournal.LeftInset:RemoveTextures()
	PetJournal.LeftInset:Hide()

	local scrollFrame = PetJournal.ScrollBox;
	local scrollBar = PetJournal.ScrollBar

	scrollFrame:HookScript("OnMouseWheel", PetJournal_UpdatePets)
	hooksecurefunc("PetJournal_UpdatePetList", PetJournal_UpdatePets)
	hooksecurefunc(scrollBar, "Update", PetJournal_UpdatePets)

	PetJournalSummonButton:RemoveTextures()
	PetJournalSummonButton:SetStyle("Button")
	PetJournalFindBattle:RemoveTextures()
	PetJournalFindBattle:SetStyle("Button")

	for i = 1, 3 do 
		local button = _G["PetJournalLoadoutPet" .. i .. "HelpFrame"]
		button:RemoveTextures()
	end 

	PetJournalTutorialButton:Die()
	PetJournal.PetCount:RemoveTextures()
	PetJournalSearchBox:SetStyle("Editbox")
	-- PetJournalFilterButton:RemoveTextures(true)
	-- PetJournalFilterButton:SetStyle("Button")
	--PetJournalListScrollFrameScrollBar:RemoveTextures()
	SV.API:Set("ScrollBar", PetJournal)

	PetJournal.PetCard:RemoveTextures()
	PetJournal.PetCardInset:RemoveTextures()
	PetJournal.PetCardInset:Hide()
	SV.API:Set("ModelScene", PetJournal.PetCard.ModelScene)
	-- PetJournal.PetCard.xpBar:RemoveTextures()
	PetJournal.PetCard.xpBar:SetStatusBarTexture(SV.media.statusbar.default)
	PetJournal.PetCard.HealthFrame.healthBar:SetStatusBarTexture(SV.media.statusbar.default)
	PetJournal.PetCard.PetInfo.levelBG:Hide()

	hooksecurefunc(PetJournal.PetCard.PetInfo.levelBG, 'Show', function (self) self:Hide() end)
	hooksecurefunc(PetJournal.PetCard.PetInfo.levelBG, 'SetShown', function (self, show) self:Hide() end)
	PetJournal.PetCard.PetInfo.level:SetFontObject(SVUI_Font_Number)
	PetJournal.PetCard.PetInfo.icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
	
	local spell
	for i=1, 6 do
		spell = _G["PetJournalPetCardSpell"..i]
		spell.icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
	end

	local regions = { PetJournal.AchievementStatus:GetRegions() }
	for i = 1, #regions do
		local region = regions[i]
		if region:GetObjectType() == "Texture" and region ~= PetJournal.AchievementStatus.icon and region ~= PetJournal.AchievementStatus.highlight then
			region:SetTexture("")
		end
	end

	PetJournal.loadoutBorder:RemoveTextures()
	SV.API:Set("Inset", PetJournal.loadoutBorder)

	for i = 1, 3 do 
		spell = _G["PetJournalLoadoutPet"..i]
		spell:RemoveTextures()
	end

	texture = PetJournal.HealPetButton.texture:GetTexture()
	SV.API:Set("IconButton", PetJournal.HealPetButton, texture)
	texture = PetJournal.SummonRandomFavoritePetButton.texture:GetTexture()
	SV.API:Set("IconButton", PetJournal.SummonRandomFavoritePetButton, texture)

	-- PetJournalPetCard:SetStyle("!_Frame", "Premium")
	-- SV.API:Set("", PetJournalPetCard)

	--TODO: Refacto this
	-- for i = 1, #PetJournal.listScroll.buttons do 
	-- 	local button = _G["PetJournalListScrollFrameButton" .. i]
	-- 	local favorite = _G["PetJournalListScrollFrameButton" .. i .. "Favorite"]
	-- 	SV.API:Set("ItemButton", button)
	-- 	if(not button.Riser) then
	-- 		local fg = CreateFrame("Frame", nil, button)
	-- 		fg:SetAllPoints(button)
	-- 		fg:SetFrameLevel(button:GetFrameLevel() + 30)
	-- 		button.Riser = fg
	-- 	end
	-- 	if(favorite) then
	-- 		favorite:SetParent(button.Riser)
	-- 		button.dragButton.favorite:SetParent(button.Riser)
	-- 		favorite:SetTexture(SV.media.icon.star)
	-- 		favorite:SetTexCoord(0,1,0,1)
	-- 	end
		
	-- 	button.dragButton.levelBG:SetAlpha(0)
	-- 	button.dragButton.level:SetParent(button.Riser)
	-- 	--button.dragButton.level:SetDrawLayer("OVERLAY", 7)
	-- 	button.petTypeIcon:SetParent(button.Panel)
	-- end 

	-- hooksecurefunc('PetJournal_UpdatePetList', PetJournal_UpdatePets)
	-- PetJournalListScrollFrame:HookScript("OnVerticalScroll", PetJournal_UpdatePets)
	-- PetJournalListScrollFrame:HookScript("OnMouseWheel", PetJournal_UpdatePets)
	-- PetJournalAchievementStatus:DisableDrawLayer('BACKGROUND')
	-- SV.API:Set("!_ItemButton", PetJournalHealPetButton)
	-- PetJournalHealPetButton.texture:SetTexture([[Interface\Icons\spell_magic_polymorphrabbit]])
	-- PetJournalLoadoutBorder:RemoveTextures()

	-- for b = 1, 3 do
	-- 	local pjPet = _G['PetJournalLoadoutPet'..b]
	-- 	pjPet:RemoveTextures()
	-- 	pjPet.petTypeIcon:SetPoint('BOTTOMLEFT', 2, 2)
	-- 	pjPet.dragButton:WrapPoints(_G['PetJournalLoadoutPet'..b..'Icon'])
	-- 	pjPet.hover = true;
	-- 	pjPet.pushed = true;
	-- 	pjPet.checked = true;
	-- 	SV.API:Set("ItemButton", pjPet, true)
	-- 	pjPet.setButton:RemoveTextures()
	-- 	_G['PetJournalLoadoutPet'..b..'HealthFrame'].healthBar:RemoveTextures()
	-- 	_G['PetJournalLoadoutPet'..b..'HealthFrame'].healthBar:SetStyle("Frame", 'Default')
	-- 	_G['PetJournalLoadoutPet'..b..'HealthFrame'].healthBar:SetStatusBarTexture(SV.media.statusbar.default)
	-- 	_G['PetJournalLoadoutPet'..b..'XPBar']:RemoveTextures()
	-- 	_G['PetJournalLoadoutPet'..b..'XPBar']:SetStyle("Frame", 'Default')
	-- 	_G['PetJournalLoadoutPet'..b..'XPBar']:SetStatusBarTexture(SV.media.statusbar.default)
	-- 	_G['PetJournalLoadoutPet'..b..'XPBar']:SetFrameLevel(_G['PetJournalLoadoutPet'..b..'XPBar']:GetFrameLevel()+2)
	-- 	for v = 1, 3 do 
	-- 		local s = _G['PetJournalLoadoutPet'..b..'Spell'..v]
	-- 		SV.API:Set("ItemButton", s)
	-- 		s.FlyoutArrow:SetTexture([[Interface\Buttons\ActionBarFlyoutButton]])
	-- 		_G['PetJournalLoadoutPet'..b..'Spell'..v..'Icon']:InsetPoints(s)
	-- 		s.Panel:SetFrameLevel(s:GetFrameLevel() + 1)
	-- 		_G['PetJournalLoadoutPet'..b..'Spell'..v..'Icon']:SetParent(s.Panel)
	-- 	end 
	-- end 

	-- PetJournalSpellSelect:RemoveTextures()

	-- for b = 1, 2 do 
	-- 	local Q = _G['PetJournalSpellSelectSpell'..b]
	-- 	SV.API:Set("ItemButton", Q)
	-- 	_G['PetJournalSpellSelectSpell'..b..'Icon']:InsetPoints(Q)
	-- 	_G['PetJournalSpellSelectSpell'..b..'Icon']:SetDrawLayer('BORDER')
	-- end 

	-- PetJournalPetCard:RemoveTextures()
	-- SV.API:Set("ItemButton", PetJournalPetCard, true)
	-- PetJournalPetCardInset:RemoveTextures()
	-- PetJournalPetCardPetInfo.levelBG:SetAlpha(0)
	-- PetJournalPetCardPetInfoIcon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
	-- SV.API:Set("ItemButton", PetJournalPetCardPetInfo, true)

	-- local fg = CreateFrame("Frame", nil, PetJournalPetCardPetInfo)
	-- fg:SetSize(40,40)
	-- fg:SetPoint("TOPLEFT", PetJournalPetCardPetInfo, "TOPLEFT", -1, 1)
	-- fg:SetFrameLevel(PetJournalPetCardPetInfo:GetFrameLevel() + 30)

	-- PetJournalPetCardPetInfo.favorite:SetParent(fg)
	-- PetJournalPetCardPetInfo.Panel:WrapPoints(PetJournalPetCardPetInfoIcon)
	-- PetJournalPetCardPetInfoIcon:SetParent(PetJournalPetCardPetInfo.Panel)

	-- local R = PetJournalPrimaryAbilityTooltip;
	-- R.Background:SetTexture("")
	-- if R.Delimiter1 then
	-- 	R.Delimiter1:SetTexture("")
	-- 	R.Delimiter2:SetTexture("")
	-- end

	-- R.BorderTop:SetTexture("")
	-- R.BorderTopLeft:SetTexture("")
	-- R.BorderTopRight:SetTexture("")
	-- R.BorderLeft:SetTexture("")
	-- R.BorderRight:SetTexture("")
	-- R.BorderBottom:SetTexture("")
	-- R.BorderBottomRight:SetTexture("")
	-- R.BorderBottomLeft:SetTexture("")
	-- R:SetStyle("!_Frame", "Transparent", true)

	-- for b = 1, 6 do 
	-- 	local S = _G['PetJournalPetCardSpell'..b]
	-- 	S:SetFrameLevel(S:GetFrameLevel() + 2)
	-- 	S:DisableDrawLayer('BACKGROUND')
	-- 	S:SetStyle("Frame", 'Transparent')
	-- 	S.Panel:SetAllPoints()
	-- 	S.icon:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))
	-- 	S.icon:InsetPoints(S.Panel)
	-- end

	-- PetJournalPetCardHealthFrame.healthBar:RemoveTextures()
	-- PetJournalPetCardHealthFrame.healthBar:SetStyle("Frame", 'Default')
	-- PetJournalPetCardHealthFrame.healthBar:SetStatusBarTexture(SV.media.statusbar.default)
	-- PetJournalPetCardXPBar:RemoveTextures()
	-- PetJournalPetCardXPBar:SetStyle("Frame", 'Default')
	-- PetJournalPetCardXPBar:SetStatusBarTexture(SV.media.statusbar.default)

	SV.API:Set("Tab", CollectionsJournalTab3)
	SV.API:Set("Tab", CollectionsJournalTab4)

	--[[ TOY ]]--

	ToyBox:RemoveTextures()
	ToyBox.searchBox:SetStyle("Editbox")
	-- ToyBoxFilterButton:RemoveTextures(true)
	-- ToyBoxFilterButton:SetStyle("Button")
	ToyBox.iconsFrame:RemoveTextures()
	ToyBox.iconsFrame:SetStyle("!_Frame", 'Model')
	ToyBox.progressBar:RemoveTextures()
	ToyBox.progressBar:SetStatusBarTexture([[Interface\BUTTONS\WHITE8X8]])
	--ToyBox.progressBar:SetStyle("Frame", "Bar", true, 2, 2, 2)
	SV.API:Set("PageButton", ToyBox.PagingFrame.PrevPageButton, false, true)
	SV.API:Set("PageButton", ToyBox.PagingFrame.NextPageButton)

	--[[ HEIRLOOMS ]]--

	HeirloomsJournal:RemoveTextures()
	HeirloomsJournal.SearchBox:SetStyle("Editbox")
	-- HeirloomsJournalFilterButton:RemoveTextures(true)
	-- HeirloomsJournalFilterButton:SetStyle("Button")
	HeirloomsJournal.iconsFrame:RemoveTextures()
	HeirloomsJournal.iconsFrame:SetStyle("!_Frame", 'Model')

	HeirloomsJournal.progressBar:RemoveTextures()
	HeirloomsJournal.progressBar:SetStatusBarTexture([[Interface\BUTTONS\WHITE8X8]])
	HeirloomsJournal.progressBar:SetStyle("Frame", "Bar", true, 2, 2, 2)
	SV.API:Set("PageButton", HeirloomsJournal.PagingFrame.PrevPageButton, false, true)
	SV.API:Set("PageButton", HeirloomsJournal.PagingFrame.NextPageButton)

	SV.API:Set("DropDown", HeirloomsJournalClassDropDown)

	-- MountJournalFilterButton:RemoveTextures(true)
	-- MountJournalFilterButton:SetStyle("Button")

	-- MountJournal.SummonRandomFavoriteButton:RemoveTextures()
	-- MountJournal.SummonRandomFavoriteButton:SetStyle("ActionSlot")
	-- MountJournal.SummonRandomFavoriteButton.texture:SetTexture([[Interface\ICONS\ACHIEVEMENT_GUILDPERK_MOUNTUP]])
	-- MountJournal.SummonRandomFavoriteButton.texture:SetTexCoord(unpack(_G.SVUI_ICON_COORDS))

	for i = 1, 18 do
		local gName = ("ToySpellButton%d"):format(i)
		local button = _G[gName]
		if(button) then
			button:SetStyle("Button")
		end
	end

	SV.API:Set("Tab", CollectionsJournalTab5)

	--[[ WARDROBE ]]--

	SV.API:Set("Window", WardrobeFrame, true, true, 1, 3, 3)

	WardrobeTransmogFrame:RemoveTextures()
	WardrobeTransmogFrame.Inset:RemoveTextures()
	WardrobeTransmogFrame.Inset:Hide()
	WardrobeTransmogFrame.ModelScene:SetStyle("!_Frame", 'Model')
	-- WardrobeTransmogFrame.OutfitHelpBox:SetStyle("!_Frame", 'Premium')
	WardrobeTransmogFrame.ApplyButton:SetStyle("Button")
	-- WardrobeTransmogFrame.SpecButton:SetStyle("Button")
	SV.API:Set("DropDown", WardrobeTransmogFrame.SpecDropDown)
	SV.API:Set("DropDown", WardrobeTransmogFrame.OutfitDropDown)

	WardrobeCollectionFrame:RemoveTextures()
	SV.API:Set("Window", WardrobeCollectionFrame, true, true, 1, 3, 3)
	WardrobeCollectionFrame.ItemsCollectionFrame:RemoveTextures()
	WardrobeCollectionFrame.ItemsCollectionFrame.NineSlice:Hide()

	WardrobeCollectionFrameSearchBox:SetStyle("Editbox")
	WardrobeCollectionFrame.FilterButton:RemoveTextures(true)
	WardrobeCollectionFrame.FilterButton:SetStyle("Button")
	--WardrobeCollectionFrame.ModelsFrame:RemoveTextures()
	--WardrobeCollectionFrame.ModelsFrame:SetStyle("!_Frame", 'Premium')
	SV.API:Set("DropDown", WardrobeCollectionFrameWeaponDropDown)

	WardrobeCollectionFrame.progressBar:RemoveTextures()
	WardrobeCollectionFrame.progressBar:SetStatusBarTexture(SV.media.statusbar.default)
	WardrobeCollectionFrame.progressBar:SetStyle("Frame", "Bar", true, 2, 2, 2)
	SV.API:Set("PageButton", WardrobeCollectionFrame.ItemsCollectionFrame.PagingFrame.PrevPageButton, false, true)
	SV.API:Set("PageButton", WardrobeCollectionFrame.ItemsCollectionFrame.PagingFrame.NextPageButton)

	WardrobeFrameUpdateModels()
	WardrobeFrameUpdateSlots()
	--hooksecurefunc("WardrobeCollectionFrame_OnShow", WardrobeFrameUpdateModels)
end 
--[[ 
########################################################## 
MOD LOADING
##########################################################
]]--
MOD:SaveBlizzardStyle("Blizzard_Collections", CollectionsJournalStyle)

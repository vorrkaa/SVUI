--[[
# Element: AuraBars

Handles creation and updating of aura buttons.

## Widget

AuraBars   - A Frame to hold `Button`s representing both buffs and debuffs.

## Notes

At least one of the above widgets must be present for the element to work.

## Options

.disableMouse             - Disables mouse events (boolean)
.disableCooldown          - Disables the cooldown spiral (boolean)
.size                     - Aura button size. Defaults to 16 (number)
.width                    - Aura button width. Takes priority over `size` (number)
.height                   - Aura button height. Takes priority over `size` (number)
.onlyShowPlayer           - Shows only auras created by player/vehicle (boolean)
.showStealableBuffs       - Displays the stealable texture on buffs that can be stolen (boolean)
.spacing                  - Spacing between each button. Defaults to 0 (number)
.['spacing-y']            - Vertical spacing between each button. Takes priority over `spacing` (number)
.['growth-y']             - Vertical growth direction. Defaults to 'UP' (string)
.initialAnchor            - Anchor point for the aura buttons. Defaults to 'BOTTOMLEFT' (string)
.filter                   - Custom filter list for auras to display. Defaults to 'HELPFUL' for buffs and 'HARMFUL' for
                            debuffs (string)
.tooltipAnchor            - Anchor point for the tooltip. Defaults to 'ANCHOR_BOTTOMRIGHT', however, if a frame has
                            anchoring restrictions it will be set to 'ANCHOR_CURSOR' (string)
.reanchorIfVisibleChanged - Reanchors aura buttons when the number of visible auras has changed (boolean)

## Options AuraBars

.numBuffs     - The maximum number of buffs to display. Defaults to 32 (number)
.numDebuffs   - The maximum number of debuffs to display. Defaults to 40 (number)
.numTotal     - The maximum number of auras to display. Prioritizes buffs over debuffs. Defaults to the sum of
                .numBuffs and .numDebuffs (number)
.gap          - Controls the creation of an invisible button between buffs and debuffs. Defaults to false (boolean)
.buffFilter   - Custom filter list for buffs to display. Takes priority over `filter` (string)
.debuffFilter - Custom filter list for debuffs to display. Takes priority over `filter` (string)

## Attributes

button.caster         - the unit who cast the aura (string)
button.filter         - the filter list used to determine the visibility of the aura (string)
button.isHarmful      - indicates if the button holds a debuff (boolean)
button.auraInstanceID - unique ID for the current aura being tracked by the button (number)

## Examples

    -- Position and size
    local AuraBars = CreateFrame('Frame', nil, self)
    AuraBars:SetPoint('RIGHT', self, 'LEFT')
    AuraBars:SetSize(200, 16 * 16)

    -- Register with oUF
    self.AuraBars = AuraBars
--]]

local _, ns = ...
local oUF = ns.oUF

local function UpdateTooltip(self)
	if(GameTooltip:IsForbidden()) then return end

	if(self.isHarmful) then
		GameTooltip:SetUnitDebuffByAuraInstanceID(self:GetParent().__owner.unit, self.auraInstanceID)
	else
		GameTooltip:SetUnitBuffByAuraInstanceID(self:GetParent().__owner.unit, self.auraInstanceID)
	end
end

local function onEnter(self)
	if(GameTooltip:IsForbidden() or not self:IsVisible()) then return end

	-- Avoid parenting GameTooltip to frames with anchoring restrictions,
	-- otherwise it'll inherit said restrictions which will cause issues with
	-- its further positioning, clamping, etc
	GameTooltip:SetOwner(self, self:GetParent().__restricted and 'ANCHOR_CURSOR' or self:GetParent().tooltipAnchor)
	self:UpdateTooltip()
end

local function onLeave()
	if(GameTooltip:IsForbidden()) then return end

	GameTooltip:Hide()
end

local function CreateAuraBar(element, index)
	local button = CreateFrame('Button', element:GetDebugName() .. 'Button' .. index, element)

	local iconHolder = CreateFrame('Frame', nil, button, "BackdropTemplate")
	iconHolder:SetPoint('TOPLEFT', button, 'TOPLEFT', 0, 0)
	iconHolder:SetPoint('BOTTOMLEFT', button, 'BOTTOMLEFT', 0, 0)
	iconHolder:SetWidth(button:GetHeight())
	iconHolder:SetBackdrop({
        bgFile = [[Interface\BUTTONS\WHITE8X8]], 
        edgeFile = [[Interface\BUTTONS\WHITE8X8]], 
        tile = false, 
        tileSize = 0, 
        edgeSize = 1, 
        insets = 
        {
            left = 0, 
            right = 0, 
            top = 0, 
            bottom = 0, 
        }, 
    })
    iconHolder:SetBackdropColor(0,0,0,0.5)
    iconHolder:SetBackdropBorderColor(0,0,0)
	button.IconHolder = iconHolder
	
	local icon = iconHolder:CreateTexture(nil, 'BORDER')
	icon:SetTexCoord(.1, .9, .1, .9)
	icon:SetPoint("TOPLEFT", iconHolder, "TOPLEFT", 1, -1)
	icon:SetPoint("BOTTOMRIGHT", iconHolder, "BOTTOMRIGHT", -1, 1)
	-- icon:SetAllPoints()
	button.Icon = icon
	
	local count = iconHolder:CreateFontString(nil, 'OVERLAY', 'NumberFontNormal')
	count:SetPoint('BOTTOMRIGHT', iconHolder, 'BOTTOMRIGHT', -1, 0)
	button.Count = count

	local barHolder = CreateFrame('Frame', nil, button, "BackdropTemplate")
	barHolder:SetPoint('BOTTOMLEFT', iconHolder, 'BOTTOMRIGHT', element.gap, 0)
	barHolder:SetPoint('TOPRIGHT', button, 'TOPRIGHT', 0, 0)
	barHolder:SetBackdrop({
        bgFile = [[Interface\BUTTONS\WHITE8X8]], 
        edgeFile = [[Interface\BUTTONS\WHITE8X8]], 
        tile = false, 
        tileSize = 0, 
        edgeSize = 1, 
        insets = 
        {
            left = 0, 
            right = 0, 
            top = 0, 
            bottom = 0, 
        }, 
    })
    barHolder:SetBackdropColor(0,0,0,0.5)
    barHolder:SetBackdropBorderColor(0,0,0)
	button.BarHolder = barHolder

	-- the main bar
	local statusBar = CreateFrame("StatusBar", nil, barHolder)
	statusBar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar]])
	statusBar:SetAlpha(element.fgalpha or 1)
	statusBar:SetPoint("TOPLEFT", barHolder, "TOPLEFT", 1, -1)
	statusBar:SetPoint("BOTTOMRIGHT", barHolder, "BOTTOMRIGHT", -1, 1)
	button.StatusBar = statusBar

	local spark = statusBar:CreateTexture(nil, "OVERLAY", nil);
	spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]]);
	spark:SetWidth(12);
	spark:SetBlendMode("ADD");
	spark:SetPoint('CENTER', statusBar:GetStatusBarTexture(), 'RIGHT')
	statusBar.Spark = spark

	statusBar.SpellTime = statusBar:CreateFontString(nil, 'ARTWORK')
	statusBar.SpellName = statusBar:CreateFontString(nil, 'ARTWORK')

	button.UpdateTooltip = UpdateTooltip
	button:SetScript('OnEnter', onEnter)
	button:SetScript('OnLeave', onLeave)

	--[[ Callback: AuraBars:PostCreateAuraBar(button)
	Called after a new aura button has been created.

	* self   - the widget holding the aura buttons
	* button - the newly created aura button (Button)
	--]]
	if(element.PostCreateAuraBar) then 
		element:PostCreateAuraBar(button) 
	else
		statusBar.SpellTime:SetFont([[Fonts\FRIZQT__.TTF]], 10, "NONE")
		statusBar.SpellTime:SetTextColor(1 ,1, 1)
		statusBar.SpellTime:SetShadowOffset(1, -1)
	  	statusBar.SpellTime:SetShadowColor(0, 0, 0)
		statusBar.SpellTime:SetJustifyH('RIGHT')
		statusBar.SpellTime:SetJustifyV('MIDDLE')
		statusBar.SpellTime:SetPoint('RIGHT')
		statusBar.SpellName:SetFont([[Fonts\FRIZQT__.TTF]], 10, "NONE")
		statusBar.SpellName:SetTextColor(1, 1, 1)
		statusBar.SpellName:SetShadowOffset(1, -1)
	  	statusBar.SpellName:SetShadowColor(0, 0, 0)
		statusBar.SpellName:SetJustifyH('LEFT')
		statusBar.SpellName:SetJustifyV('MIDDLE')
		statusBar.SpellName:SetPoint('LEFT')
		statusBar.SpellName:SetPoint('RIGHT', statusBar.SpellTime, 'LEFT')
	end

	return button
end

local function SetPosition(element, from, to)
	local width = element.width or element.size or 200
	local height = element.height or element.size or 16
	local sizey = height + (element['spacing-y'] or element.spacing or 0)
	local anchor = element.initialAnchor or 'BOTTOMLEFT'
	local growthy = (element['growth-y'] == 'DOWN' and -1) or 1

	for i = from, to do
		local button = element[i]
		if not button then break end

		local row = i-1

		button:ClearAllPoints()
		button:SetPoint(anchor, element, anchor, element.spacing or 0, row * sizey * growthy)
	end


	-- local sizex = width + (element['spacing-x'] or element.spacing or 0)
	-- local growthx = (element['growth-x'] == 'LEFT' and -1) or 1
	-- local cols = math.floor(element:GetWidth() / sizex + 0.5)

	-- for i = from, to do
	-- 	local button = element[i]
	-- 	if(not button) then break end

	-- 	local col = (i - 1) % cols
	-- 	local row = math.floor((i - 1) / cols)

	-- 	button:ClearAllPoints()
	-- 	button:SetPoint(anchor, element, anchor, col * sizex * growthx, row * sizey * growthy)
	-- end
end

local function updateAura(element, unit, data, position)
	if(not data.name) then return end
	
	local timeNow = GetTime() --we need to do this first to be precise in time
	local bar = element[position]
	if(not bar) then
		--[[ Override: AuraBars:CreateAuraBar(position)
		Used to create an aura button at a given position.

		* self     - the widget holding the aura buttons
		* position - the position at which the aura button is to be created (number)

		## Returns

		* button - the button used to represent the aura (Button)
		--]]
		bar = (element.CreateAuraBar or CreateAuraBar) (element, position)

		table.insert(element, bar)
		element.createdBars = element.createdBars + 1
	end

	-- for tooltips
	bar.auraInstanceID = data.auraInstanceID
	bar.isHarmful = data.isHarmful

	if(bar.StatusBar) then
		if (data.duration == 0 and data.expirationTime == 0) then
			bar.StatusBar:SetMinMaxValues(0,1)
			bar.StatusBar:SetValue(1)
			bar.StatusBar.SpellTime:SetText('')
		else
			local value = data.expirationTime - timeNow
			bar.StatusBar:SetMinMaxValues(0,data.duration)
			bar.StatusBar:SetValue(value)
			bar.StatusBar.SpellTime:SetText(value)
		end
		bar.StatusBar.SpellName:SetText(data.applications > 1 and format("%s [%d]", data.name, data.applications) or data.name)
	end

	if(bar.Icon) then bar.Icon:SetTexture(data.icon) end
	if(bar.Count) then bar.Count:SetText(data.applications > 1 and data.applications or '') end

	local width = element.width or element.size or 200
	local height = element.height or element.size or 16
	bar:SetSize(width, height)
	
	bar.IconHolder:SetSize(height, height)

	bar:EnableMouse(not element.disableMouse)
	bar:Show()

	--[[ Callback: AuraBars:PostUpdateBar(unit, button, data, position)
	Called after the aura button has been updated.

	* self     - the widget holding the aura buttons
	* button   - the updated aura button (Button)
	* unit     - the unit for which the update has been triggered (string)
	* data     - the [UnitAuraInfo](https://wowpedia.fandom.com/wiki/Struct_UnitAuraInfo) object (table)
	* position - the actual position of the aura button (number)
	--]]
	if(element.PostUpdateBar) then
		element:PostUpdateBar(bar, unit, data, position)
	elseif (data.isHarmful) then
		bar.StatusBar:SetStatusBarColor(.9, 0, 0)
	else
		bar.StatusBar:SetStatusBarColor(.2, .6, 1)
	end
end

local function FilterAura(element, unit, data)
	if((element.onlyShowPlayer and data.isPlayerAura) or (not element.onlyShowPlayer and data.name)) then
		return true
	end
end

-- see AuraUtil.DefaultAuraCompare
local function SortAuraBars(a, b)
	if(a.isPlayerAura ~= b.isPlayerAura) then
		return a.isPlayerAura
	end

	if(a.canApplyAura ~= b.canApplyAura) then
		return a.canApplyAura
	end

	return a.auraInstanceID < b.auraInstanceID
end

local function processData(element, unit, data)
	if(not data) then return end

	data.isPlayerAura = data.sourceUnit and (UnitIsUnit('player', data.sourceUnit) or UnitIsOwnerOrControllerOfUnit('player', data.sourceUnit))

	--[[ Callback: AuraBars:PostProcessAuraData(unit, data)
	Called after the aura data has been processed.

	* self - the widget holding the aura buttons
	* unit - the unit for which the update has been triggered (string)
	* data - [UnitAuraInfo](https://wowpedia.fandom.com/wiki/Struct_UnitAuraInfo) object (table)

	## Returns

	* data - the processed aura data (table)
	--]]
	if(element.PostProcessAuraData) then
		data = element:PostProcessAuraData(unit, data)
	end

	return data
end

local function UpdateAuraBars(self, event, unit, updateInfo)
	if(self.unit ~= unit) then return end

	local isFullUpdate = not updateInfo or updateInfo.isFullUpdate

	local auras = self.AuraBars
	if(auras) then
		--[[ Callback: AuraBars:PreUpdate(unit, isFullUpdate)
		Called before the element has been updated.

		* self         - the widget holding the aura buttons
		* unit         - the unit for which the update has been triggered (string)
		* isFullUpdate - indicates whether the element is performing a full update (boolean)
		--]]
		if(auras.PreUpdate) then auras:PreUpdate(unit, isFullUpdate) end

		local buffsChanged = false
		local numBuffs = auras.numBuffs or 32
		local buffFilter = auras.buffFilter or auras.filter or 'HELPFUL'
		if(type(buffFilter) == 'function') then
			buffFilter = buffFilter(auras, unit)
		end

		local debuffsChanged = false
		local numDebuffs = auras.numDebuffs or 40
		local debuffFilter = auras.debuffFilter or auras.filter or 'HARMFUL'
		if(type(debuffFilter) == 'function') then
			debuffFilter = debuffFilter(auras, unit)
		end

		local numTotal = auras.numTotal or numBuffs + numDebuffs

		if(isFullUpdate) then
			auras.allBuffs = table.wipe(auras.allBuffs or {})
			auras.activeBuffs = table.wipe(auras.activeBuffs or {})
			buffsChanged = true

			local slots = {C_UnitAuras.GetAuraSlots(unit, buffFilter)}
			for i = 2, #slots do -- #1 return is continuationToken, we don't care about it
				local data = processData(auras, unit, C_UnitAuras.GetAuraDataBySlot(unit, slots[i]))
				auras.allBuffs[data.auraInstanceID] = data

				--[[ Override: AuraBars:FilterAura(unit, data)
				Defines a custom filter that controls if the aura button should be shown.

				* self - the widget holding the aura buttons
				* unit - the unit for which the update has been triggered (string)
				* data - [UnitAuraInfo](https://wowpedia.fandom.com/wiki/Struct_UnitAuraInfo) object (table)

				## Returns

				* show - indicates whether the aura button should be shown (boolean)
				--]]
				if((auras.FilterAura or FilterAura) (auras, unit, data)) then
					auras.activeBuffs[data.auraInstanceID] = true
				end
			end

			auras.allDebuffs = table.wipe(auras.allDebuffs or {})
			auras.activeDebuffs = table.wipe(auras.activeDebuffs or {})
			debuffsChanged = true

			slots = {C_UnitAuras.GetAuraSlots(unit, debuffFilter)}
			for i = 2, #slots do
				local data = processData(auras, unit, C_UnitAuras.GetAuraDataBySlot(unit, slots[i]))
				auras.allDebuffs[data.auraInstanceID] = data

				if((auras.FilterAura or FilterAura) (auras, unit, data)) then
					auras.activeDebuffs[data.auraInstanceID] = true
				end
			end
		else
			if(updateInfo.addedAuras) then
				for _, data in next, updateInfo.addedAuras do
					if(data.isHelpful and not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, data.auraInstanceID, buffFilter)) then
						data = processData(auras, unit, data)
						auras.allBuffs[data.auraInstanceID] = data

						if((auras.FilterAura or FilterAura) (auras, unit, data)) then
							auras.activeBuffs[data.auraInstanceID] = true
							buffsChanged = true
						end
					elseif(data.isHarmful and not C_UnitAuras.IsAuraFilteredOutByInstanceID(unit, data.auraInstanceID, debuffFilter)) then
						data = processData(auras, unit, data)
						auras.allDebuffs[data.auraInstanceID] = data

						if((auras.FilterAura or FilterAura) (auras, unit, data)) then
							auras.activeDebuffs[data.auraInstanceID] = true
							debuffsChanged = true
						end
					end
				end
			end

			if(updateInfo.updatedAuraInstanceIDs) then
				for _, auraInstanceID in next, updateInfo.updatedAuraInstanceIDs do
					if(auras.allBuffs[auraInstanceID]) then
						auras.allBuffs[auraInstanceID] = processData(auras, unit, C_UnitAuras.GetAuraDataByAuraInstanceID(unit, auraInstanceID))

						-- only update if it's actually active
						if(auras.activeBuffs[auraInstanceID]) then
							auras.activeBuffs[auraInstanceID] = true
							buffsChanged = true
						end
					elseif(auras.allDebuffs[auraInstanceID]) then
						auras.allDebuffs[auraInstanceID] = processData(auras, unit, C_UnitAuras.GetAuraDataByAuraInstanceID(unit, auraInstanceID))

						if(auras.activeDebuffs[auraInstanceID]) then
							auras.activeDebuffs[auraInstanceID] = true
							debuffsChanged = true
						end
					end
				end
			end

			if(updateInfo.removedAuraInstanceIDs) then
				for _, auraInstanceID in next, updateInfo.removedAuraInstanceIDs do
					if(auras.allBuffs[auraInstanceID]) then
						auras.allBuffs[auraInstanceID] = nil

						if(auras.activeBuffs[auraInstanceID]) then
							auras.activeBuffs[auraInstanceID] = nil
							buffsChanged = true
						end
					elseif(auras.allDebuffs[auraInstanceID]) then
						auras.allDebuffs[auraInstanceID] = nil

						if(auras.activeDebuffs[auraInstanceID]) then
							auras.activeDebuffs[auraInstanceID] = nil
							debuffsChanged = true
						end
					end
				end
			end
		end

		--[[ Callback: AuraBars:PostUpdateInfo(unit, buffsChanged, debuffsChanged)
		Called after the aura update info has been updated and filtered, but before sorting.

		* self           - the widget holding the aura buttons
		* unit           - the unit for which the update has been triggered (string)
		* buffsChanged   - indicates whether the buff info has changed (boolean)
		* debuffsChanged - indicates whether the debuff info has changed (boolean)
		--]]
		if(auras.PostUpdateInfo) then
			auras:PostUpdateInfo(unit, buffsChanged, debuffsChanged)
		end

		if(buffsChanged or debuffsChanged) then
			local numVisible

			if(buffsChanged) then
				-- instead of removing auras one by one, just wipe the tables entirely
				-- and repopulate them, multiple table.remove calls are insanely slow
				auras.sortedBuffs = table.wipe(auras.sortedBuffs or {})

				for auraInstanceID in next, auras.activeBuffs do
					table.insert(auras.sortedBuffs, auras.allBuffs[auraInstanceID])
				end

				--[[ Override: AuraBars:SortBuffs(a, b)
				Defines a custom sorting algorithm for ordering the auras.

				Defaults to [AuraUtil.DefaultAuraCompare](https://github.com/Gethe/wow-ui-source/search?q=DefaultAuraCompare).
				--]]
				--[[ Override: AuraBars:SortAuraBars(a, b)
				Defines a custom sorting algorithm for ordering the auras.

				Defaults to [AuraUtil.DefaultAuraCompare](https://github.com/Gethe/wow-ui-source/search?q=DefaultAuraCompare).

				Overridden by the more specific SortBuffs and/or SortDebuffs overrides if they are defined.
				--]]
				table.sort(auras.sortedBuffs, auras.SortBuffs or auras.SortAuraBars or SortAuraBars)

				numVisible = math.min(numBuffs, numTotal, #auras.sortedBuffs)

				for i = 1, numVisible do
					updateAura(auras, unit, auras.sortedBuffs[i], i)
				end
			else
				numVisible = math.min(numBuffs, numTotal, #auras.sortedBuffs)
			end

			-- do it before adding the gap because numDebuffs could end up being 0
			if(debuffsChanged) then
				auras.sortedDebuffs = table.wipe(auras.sortedDebuffs or {})

				for auraInstanceID in next, auras.activeDebuffs do
					table.insert(auras.sortedDebuffs, auras.allDebuffs[auraInstanceID])
				end

				--[[ Override: AuraBars:SortDebuffs(a, b)
				Defines a custom sorting algorithm for ordering the auras.

				Defaults to [AuraUtil.DefaultAuraCompare](https://github.com/Gethe/wow-ui-source/search?q=DefaultAuraCompare).
				--]]
				table.sort(auras.sortedDebuffs, auras.SortDebuffs or auras.SortAuraBars or SortAuraBars)
			end

			numDebuffs = math.min(numDebuffs, numTotal - numVisible, #auras.sortedDebuffs)

			if(auras.gap and numVisible > 0 and numDebuffs > 0) then
				-- adjust the number of visible debuffs if there's an overflow
				if(numVisible + numDebuffs == numTotal) then
					numDebuffs = numDebuffs - 1
				end

				-- double check and skip it if we end up with 0 after the adjustment
				if(numDebuffs > 0) then
					numVisible = numVisible + 1

					local button = auras[numVisible]
					if(not button) then
						button = (auras.CreateAuraBar or CreateAuraBar) (auras, numVisible)
						table.insert(auras, button)
						auras.createdBars = auras.createdBars + 1
					end

					-- prevent the button from displaying anything
					if(button.Cooldown) then button.Cooldown:Hide() end
					if(button.Icon) then button.Icon:SetTexture() end
					if(button.Overlay) then button.Overlay:Hide() end
					if(button.Stealable) then button.Stealable:Hide() end
					if(button.Count) then button.Count:SetText() end

					button:EnableMouse(false)
					button:Show()

					--[[ Callback: AuraBars:PostUpdateGapButton(unit, gapButton, position)
					Called after an invisible aura button has been created. Only used by AuraBars when the `gap` option is enabled.

					* self      - the widget holding the aura buttons
					* unit      - the unit that has the invisible aura button (string)
					* gapButton - the invisible aura button (Button)
					* position  - the position of the invisible aura button (number)
					--]]
					if(auras.PostUpdateGapButton) then
						auras:PostUpdateGapButton(unit, button, numVisible)
					end
				end
			end

			-- any changes to buffs will affect debuffs, so just redraw them even if nothing changed
			for i = 1, numDebuffs do
				updateAura(auras, unit, auras.sortedDebuffs[i], numVisible + i)
			end

			numVisible = numVisible + numDebuffs
			local visibleChanged = false

			if(numVisible ~= auras.visibleBars) then
				auras.visibleBars = numVisible
				visibleChanged = auras.reanchorIfVisibleChanged -- more convenient than auras.reanchorIfVisibleChanged and visibleChanged
			end

			for i = numVisible + 1, #auras do
				auras[i]:Hide()
			end

			if(visibleChanged or auras.createdBars > auras.anchoredBars) then
				--[[ Override: AuraBars:SetPosition(from, to)
				Used to (re-)anchor the aura buttons.
				Called when new aura buttons have been created or the number of visible buttons has changed if the
				`.reanchorIfVisibleChanged` option is enabled.

				* self - the widget that holds the aura buttons
				* from - the offset of the first aura button to be (re-)anchored (number)
				* to   - the offset of the last aura button to be (re-)anchored (number)
				--]]
				if(visibleChanged) then
					-- this is useful for when people might want centred auras, like nameplates
					(auras.SetPosition or SetPosition) (auras, 1, numVisible)
				else
					(auras.SetPosition or SetPosition) (auras, auras.anchoredBars + 1, auras.createdBars)
					auras.anchoredBars = auras.createdBars
				end
			end

			--[[ Callback: AuraBars:PostUpdate(unit)
			Called after the element has been updated.

			* self - the widget holding the aura buttons
			* unit - the unit for which the update has been triggered (string)
			--]]
			if(auras.PostUpdate) then auras:PostUpdate(unit) end
		end
	end

end

local function Update(self, event, unit, updateInfo)
	if(self.unit ~= unit) then return end

	UpdateAuraBars(self, event, unit, updateInfo)

	-- Assume no event means someone wants to re-anchor things. This is usually
	-- done by UpdateAllElements and :ForceUpdate.
	if(event == 'ForceUpdate' or not event) then
		local auras = self.AuraBars
		if(auras) then
			(auras.SetPosition or SetPosition) (auras, 1, auras.createdBars)
		end
	end
end

local function ForceUpdate(element)
	return Update(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self)
	if(self.AuraBars) then
		self:RegisterEvent('UNIT_AURA', UpdateAuraBars)

		local auras = self.AuraBars
		if(auras) then
			auras.__owner = self
			-- check if there's any anchoring restrictions
			auras.__restricted = not pcall(self.GetCenter, self)
			auras.ForceUpdate = ForceUpdate

			auras.gap				= auras.gap or 2
			auras.createdBars 		= auras.createdBars or 0
			auras.anchoredBars 		= 0
			auras.visibleBars 		= 0
			auras.tooltipAnchor 	= auras.tooltipAnchor or 'ANCHOR_BOTTOMRIGHT'

			auras:Show()
		end

		return true
	end
end

local function Disable(self)
	if(self.AuraBars) then
		self:UnregisterEvent('UNIT_AURA', UpdateAuraBars)

		if(self.AuraBars) then self.AuraBars:Hide() end
	end
end

oUF:AddElement('AuraBars', Update, Enable, Disable)

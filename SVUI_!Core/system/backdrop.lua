local CreateColor = CreateColor

---@type colorRGB
SVUI_BackdropColorBlack = CreateColor( 0, 0, 0 )
---@type colorRGB
SVUI_BackdropColorDarkGrey = CreateColor (0.1, 0.1, 0.1 )
---@type colorRGB
-- SVUI_BackdropColorGrey = { r=0.2, g=0.2, b=0.2 }
SVUI_BackdropColorGrey = CreateColor( 0.2, 0.2, 0.2 )
---@type colorRGB
SVUI_BackdropColorGrey2 = CreateColor ( 0.22, 0.21, 0.2 )
---@type colorRGB
SVUI_BackdropColorGreyBrown = CreateColor( 0.37, 0.32, 0.29 )
---@type colorRGB
SVUI_BackdropColorWhite = CreateColor( 1, 1, 1 )

---@type backdropInsets
local SVUI_BackdropInset = {
    left=0,
    right=0,
    top=0,
    bottom=0
}

---@type backdropInsets
local SVUI_BackdropInsetOne = {
    left=1,
    right=1,
    top=1,
    bottom=1
}

---@type backdropInsets
local SVUI_BackdropInsetTwo = {
    left=2,
    right=2,
    top=2,
    bottom=2
}

---@type backdropInfo
SVUI_DefaultButtonBackdropInfo = {
    bgFile= "Interface\\BUTTONS\\WHITE8X8",
    edgeFile= "Interface\\BUTTONS\\WHITE8X8",
    tile=false,
    edgeSize = 1,
    tileSize = 0,
    insets = SVUI_BackdropInset,
}

---@type backdropInfo
SVUI_NameplateStyle_BackdropInfo = {
    bgFile= "Interface\\BUTTONS\\WHITE8X8",
    edgeFile= "Interface\\BUTTONS\\WHITE8X8",
    tile=false,
    edgeSize = 1,
    tileSize = 0,
    insets = SVUI_BackdropInsetOne,
}

---@type backdropInfo
SVUI_CoreStyle_BackdropInfo = {
    bgFile= "Interface\\BUTTONS\\WHITE8X8",
    edgeFile= "Interface\\BUTTONS\\WHITE8X8",
    tile=false,
    edgeSize = 2,
    tileSize = 0,
    insets = SVUI_BackdropInset,
}

---@type backdropInfo
SVUI_CoreStyle_WindowBackdropInfo = {
    bgFile= "Interface\\BUTTONS\\WHITE8X8",
    edgeFile= "Interface\\BUTTONS\\WHITE8X8",
    tile=false,
    edgeSize = 2,
    tileSize = 0,
    insets = SVUI_BackdropInsetOne,
}

---@type backdropInfo
SVUI_ShadowTemplate_BackdropInfo = {
    edgeFile="Interface\\AddOns\\SVUI_!Core\\assets\\borders\\SHADOW",
    edgeSize=3,
    insets = SVUI_BackdropInset,
}

---@type backdropInfo
SVUI_ShadowGlow_BackdropInfo = {
    bgFile= "Interface\\BUTTONS\\WHITE8X8",
    edgeFile="Interface\\AddOns\\SVUI_!Core\\assets\\borders\\SHADOW",
    tile=false,
    edgeSize=2,
    tileSize = 0,
    insets = SVUI_BackdropInsetTwo,
}

---@type backdropInfo
SVUI_CoreStyle_DefaultBackdropInfo = {
    bgFile="Interface\\AddOns\\SVUI_!Core\\assets\\backgrounds\\DEFAULT",
    edgeFile="Interface\\BUTTONS\\WHITE8X8",
    tile=false,
    edgeSize=1,
    tileSize = 0,
    insets = SVUI_BackdropInset,
}

---@type backdropInfo
SVUI_CoreStyle_ButtonBackdropInfo = {
    bgFile="Interface\\AddOns\\SVUI_!Core\\assets\\backgrounds\\BUTTON",
    edgeFile="Interface\\BUTTONS\\WHITE8X8",
    tile=false,
    edgeSize=1,
    tileSize = 0,
    insets = SVUI_BackdropInset,
}

---@type backdropInfo
SVUI_CoreStyle_ActionSlotBackdropInfo = {
    bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile="Interface\\BUTTONS\\WHITE8X8",
    tile=false,
    edgeSize=1,
    tileSize = 0,
    insets = SVUI_BackdropInsetOne,
}

---@type backdropInfo
SVUI_StyleTemplate_ActionPanelBackdropInfo = {
    bgFile="Interface\\AddOns\\SVUI_!Core\\assets\\backgrounds\\EMPTY",
    edgeFile="Interface\\BUTTONS\\WHITE8X8",
    tile=false,
    edgeSize=2,
    tileSize = 0,
    insets = SVUI_BackdropInset,
}

---@type backdropInfo
SVUI_CoreStyle_IconBackdropInfo = {
    bgFile="Interface\\AddOns\\SVUI_!Core\\assets\\backgrounds\\EMPTY",
    edgeFile="Interface\\BUTTONS\\WHITE8X8",
    tile=false,
    edgeSize=1,
    tileSize = 0,
    insets = SVUI_BackdropInsetOne,
}

---@type backdropInfo
SVUI_CoreStyle_CheckButtonBackdropInfo = {
    bgFile="Interface\\AddOns\\SVUI_!Core\\assets\\buttons\\CHECK-BG",
    edgeFile="Interface\\AddOns\\SVUI_!Core\\assets\\borders\\DEFAULT",
    tile=false,
    edgeSize=1,
    tileSize = 0,
    insets = SVUI_BackdropInset,
}

---@type backdropInfo
SVUI_CoreStyle_InsetBackdropInfo = {
    bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile="Interface\\AddOns\\SVUI_!Core\\assets\\borders\\INSET",
    tile=false,
    edgeSize = 6,
    tileSize = 0,
    insets = SVUI_BackdropInset,
}

---@type backdropInfo
SVUI_CoreStyle_EditBoxBackdropInfo = {
    bgFile="Interface\\AddOns\\SVUI_!Core\\assets\\backgrounds\\EMPTY",
    edgeFile="Interface\\BUTTONS\\WHITE8X8",
    tile=true,
    edgeSize = 1,
    tileSize = 20,
    insets = SVUI_BackdropInset,
}

---@type backdropInfo
SVUI_CoreStyle_InnerGlowBackdropInfo = {
    bgFile="Interface\\AddOns\\SVUI_!Core\\assets\\backgrounds\\DEFAULT",
    edgeFile="Interface\\AddOns\\SVUI_!Core\\assets\\borders\\INSET",
    tile=false,
    edgeSize = 12,
    tileSize = 0,
    insets = SVUI_BackdropInset,
}

---@type backdropInfo
SVUI_CoreStyle_LiteBackdropInfo = {
    bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile="Interface\\BUTTONS\\WHITE8X8",
    tile=true,
    edgeSize = 1,
    tileSize = 20,
    insets = SVUI_BackdropInset,
}

---@type backdropInfo
SVUI_CoreStyle_BarBackdropInfo = {
    bgFile="Interface\\AddOns\\SVUI_!Core\\assets\\backgrounds\\DEFAULT",
    edgeFile="Interface\\AddOns\\SVUI_!Core\\assets\\borders\\DEFAULT",
    tile=false,
    edgeSize = 1,
    tileSize = 0,
    insets = SVUI_BackdropInset,
}

---@type backdropInfo
SVUI_CoreStyle_Pattern6BackdropInfo = {
    bgFile="Interface\\AddOns\\SVUI_!Core\\assets\\backgrounds\\pattern\\PATTERN6",
    edgeFile="Interface\\BUTTONS\\WHITE8X8",
    tile=false,
    edgeSize = 1,
    tileSize = 0,
    insets = SVUI_BackdropInset,
}

---@type backdropInfo
SVUI_CoreStyle_Pattern1BackdropInfo = {
    bgFile="Interface\\AddOns\\SVUI_!Core\\assets\\backgrounds\\pattern\\PATTERN1",
    edgeFile="Interface\\BUTTONS\\WHITE8X8",
    tile=false,
    edgeSize = 1,
    tileSize = 0,
    insets = SVUI_BackdropInset,
}

---@type backdropInfo
SVUI_CoreStyle_Art1BackdropInfo = {
    bgFile="Interface\\AddOns\\SVUI_!Core\\assets\\backgrounds\\art\\ART1",
    edgeFile="Interface\\BUTTONS\\WHITE8X8",
    tile=false,
    edgeSize = 2,
    tileSize = 0,
    insets = SVUI_BackdropInset,
}

---@type backdropInfo
SVUI_CoreStyle_ModelBackdropInfo = {
    bgFile="Interface\\AddOns\\SVUI_!Core\\assets\\backgrounds\\MODEL",
    edgeFile="Interface\\BUTTONS\\WHITE8X8",
    tile=false,
    edgeSize = 2,
    tileSize = 0,
    insets = SVUI_BackdropInset,
}

---@type backdropInfo
SVUI_CoreStyle_BlackoutBackdropInfo = {
    bgFile="Interface\\AddOns\\SVUI_!Core\\assets\\backgrounds\\DARK",
    edgeFile="Interface\\BUTTONS\\WHITE8X8",
    tile=false,
    edgeSize = 2,
    tileSize = 0,
    insets = SVUI_BackdropInsetOne,
}

---@type backdropInfo
SVUI_Theme_SimpleDefaultBackdropInfo = {
    bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile="Interface\\BUTTONS\\WHITE8X8",
    tile=false,
    edgeSize = 2,
    tileSize = 0,
    insets = SVUI_BackdropInset,
}

---@type backdropInfo
SVUI_Theme_SimpleDockButtonBackdropInfo = {
    bgFile="Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile="Interface\\BUTTONS\\WHITE8X8",
    tile=false,
    edgeSize = 1,
    tileSize = 0,
    insets = SVUI_BackdropInset,
}
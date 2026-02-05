--[[
    QUI Options - Character Pane Tab
    BuildCharacterPaneTab for General & QoL page
]]

local ADDON_NAME, ns = ...
local QUI = QUI
local GUI = QUI.GUI
local C = GUI.Colors

-- Import shared utilities
local Shared = ns.QUI_Options

local function BuildCharacterPaneTab(tabContent)
    local y = -10
    local FORM_ROW = 32
    local PADDING = Shared.PADDING
    local db = Shared.GetDB()

    -- Set search context for auto-registration
    GUI:SetSearchContext({tabIndex = 1, tabName = "General & QoL", subTabIndex = 7, subTabName = "Character Pane"})

    local char = db and db.character
    if not char then return end

    -- SECTION: Enable/Disable
    local enableHeader = GUI:CreateSectionHeader(tabContent, "Enable/Disable QUI Character Module")
    enableHeader:SetPoint("TOPLEFT", PADDING, y)
    y = y - enableHeader.gap

    local enableCheck = GUI:CreateFormCheckbox(tabContent, "QUI Character Module",
        "enabled", char, function(val)
            GUI:ShowConfirmation({
                title = "Reload Required",
                message = "Character Pane styling requires a UI reload to take effect.",
                acceptText = "Reload Now",
                cancelText = "Later",
                isDestructive = false,
                onAccept = function()
                    QUI:SafeReload()
                end,
            })
        end)
    enableCheck:SetPoint("TOPLEFT", PADDING, y)
    enableCheck:SetPoint("RIGHT", tabContent, "RIGHT", -PADDING, 0)
    y = y - FORM_ROW

    local enableInfo = GUI:CreateLabel(tabContent, "If you are using a dedicated character stats addon, toggle this off.", 10, C.textMuted)
    enableInfo:SetPoint("TOPLEFT", PADDING, y)
    enableInfo:SetPoint("RIGHT", tabContent, "RIGHT", -PADDING, 0)
    enableInfo:SetJustifyH("LEFT")
    y = y - 20

    -- Section Header
    local header = GUI:CreateSectionHeader(tabContent, "Character Pane Settings")
    header:SetPoint("TOPLEFT", PADDING, y)
    y = y - header.gap

    -- Description
    local desc = GUI:CreateLabel(tabContent, "Character Pane settings are now accessed from the Character Panel itself.\n\nOpen your Character Frame (C) and click the gear icon to access all settings.", 11, C.textMuted)
    desc:SetPoint("TOPLEFT", PADDING, y)
    desc:SetPoint("RIGHT", tabContent, "RIGHT", -PADDING, 0)
    desc:SetJustifyH("LEFT")
    desc:SetWordWrap(true)
    desc:SetHeight(50)
    y = y - 60

    -- INSPECT FRAME Section
    local inspectHeader = GUI:CreateSectionHeader(tabContent, "Inspect Frame")
    inspectHeader:SetPoint("TOPLEFT", PADDING, y)
    y = y - inspectHeader.gap

    local inspectDesc = GUI:CreateLabel(tabContent, "Apply overlays to the Inspect frame when inspecting other players. Use Lite Mode only for Blizzard UI for minimal centered iLvL numbers.", 11, C.textMuted)
    inspectDesc:SetPoint("TOPLEFT", PADDING, y)
    inspectDesc:SetPoint("RIGHT", tabContent, "RIGHT", -PADDING, 0)
    inspectDesc:SetJustifyH("LEFT")
    inspectDesc:SetWordWrap(true)
    inspectDesc:SetHeight(20)
    y = y - 28

    if char.inspectEnabled == nil then char.inspectEnabled = true end

    -- Initialize lite mode defaults
    if char.inspectLiteMode == nil then char.inspectLiteMode = false end
    if char.inspectLiteShowOverall == nil then char.inspectLiteShowOverall = true end
    if char.inspectLiteShowPerSlot == nil then char.inspectLiteShowPerSlot = true end
    if char.inspectLiteFontSize == nil then char.inspectLiteFontSize = 15 end
    if char.inspectLiteOverallFontSize == nil then char.inspectLiteOverallFontSize = 11 end
    if char.inspectLiteOverallOffsetX == nil then char.inspectLiteOverallOffsetX = 0 end
    if char.inspectLiteOverallOffsetY == nil then char.inspectLiteOverallOffsetY = -8 end

    -- Store widget refs for lite mode (enabled when inspect overlays OFF)
    local liteModeWidgets = {}

    -- Refresh callback for lite mode settings
    local function RefreshInspectLite()
        local shared = ns.QUI.CharacterShared
        if shared and shared.ScheduleUpdate then
            shared.ScheduleUpdate()
        end
    end

    -- Helper to update enable states based on inspect overlays toggle
    local function UpdateLiteModeWidgetStates()
        local overlaysOn = char.inspectEnabled
        -- Lite mode widgets: enabled when overlays OFF
        for _, widget in pairs(liteModeWidgets) do
            if widget and widget.SetEnabled then
                widget:SetEnabled(not overlaysOn)
            end
        end
        -- If overlays are enabled, turn off lite mode
        if overlaysOn and char.inspectLiteMode then
            char.inspectLiteMode = false
            if liteModeWidgets.liteToggle and liteModeWidgets.liteToggle.cb then
                liteModeWidgets.liteToggle.cb:SetChecked(false)
            end
        end
        -- If overlays are disabled, turn on lite mode
        if not overlaysOn and not char.inspectLiteMode then
            char.inspectLiteMode = true
            if liteModeWidgets.liteToggle and liteModeWidgets.liteToggle.cb then
                liteModeWidgets.liteToggle.cb:SetChecked(true)
            end
        end
    end

    local inspectEnabled = GUI:CreateFormCheckbox(tabContent, "Enable Inspect Overlays", "inspectEnabled", char, function()
        print("|cFF56D1FFQUI:|r Inspect overlay change requires /reload to take effect.")
        UpdateLiteModeWidgetStates()
    end)
    inspectEnabled:SetPoint("TOPLEFT", PADDING, y)
    inspectEnabled:SetPoint("RIGHT", tabContent, "RIGHT", -PADDING, 0)
    y = y - FORM_ROW

    local inspectLiteMode = GUI:CreateFormCheckbox(tabContent, "Enable Inspect iLvL Display", "inspectLiteMode", char, RefreshInspectLite)
    inspectLiteMode:SetPoint("TOPLEFT", PADDING, y)
    inspectLiteMode:SetPoint("RIGHT", tabContent, "RIGHT", -PADDING, 0)
    liteModeWidgets.liteToggle = inspectLiteMode
    y = y - FORM_ROW

    -- Show Overall Average iLvL
    local liteOverall = GUI:CreateFormCheckbox(tabContent, "Show Overall Average iLvL", "inspectLiteShowOverall", char, RefreshInspectLite)
    liteOverall:SetPoint("TOPLEFT", PADDING, y)
    liteOverall:SetPoint("RIGHT", tabContent, "RIGHT", -PADDING, 0)
    liteModeWidgets.showOverall = liteOverall
    y = y - FORM_ROW

    -- Overall iLvL Font Size
    local overallFontSize = GUI:CreateFormSlider(tabContent, "Overall iLvL Font Size", 8, 24, 1, "inspectLiteOverallFontSize", char, RefreshInspectLite)
    overallFontSize:SetPoint("TOPLEFT", PADDING, y)
    overallFontSize:SetPoint("RIGHT", tabContent, "RIGHT", -PADDING, 0)
    liteModeWidgets.overallFontSize = overallFontSize
    y = y - FORM_ROW

    -- Overall iLvL X Offset
    local overallOffsetX = GUI:CreateFormSlider(tabContent, "Overall iLvL X Offset", -100, 100, 1, "inspectLiteOverallOffsetX", char, RefreshInspectLite)
    overallOffsetX:SetPoint("TOPLEFT", PADDING, y)
    overallOffsetX:SetPoint("RIGHT", tabContent, "RIGHT", -PADDING, 0)
    liteModeWidgets.overallOffsetX = overallOffsetX
    y = y - FORM_ROW

    -- Overall iLvL Y Offset
    local overallOffsetY = GUI:CreateFormSlider(tabContent, "Overall iLvL Y Offset", -100, 100, 1, "inspectLiteOverallOffsetY", char, RefreshInspectLite)
    overallOffsetY:SetPoint("TOPLEFT", PADDING, y)
    overallOffsetY:SetPoint("RIGHT", tabContent, "RIGHT", -PADDING, 0)
    liteModeWidgets.overallOffsetY = overallOffsetY
    y = y - FORM_ROW

    -- Show Per-Slot iLvL
    local litePerSlot = GUI:CreateFormCheckbox(tabContent, "Show Per-Slot iLvL", "inspectLiteShowPerSlot", char, RefreshInspectLite)
    litePerSlot:SetPoint("TOPLEFT", PADDING, y)
    litePerSlot:SetPoint("RIGHT", tabContent, "RIGHT", -PADDING, 0)
    liteModeWidgets.showPerSlot = litePerSlot
    y = y - FORM_ROW

    -- Per-Slot Font Size
    local liteFontSize = GUI:CreateFormSlider(tabContent, "Per-Slot Font Size", 8, 24, 1, "inspectLiteFontSize", char, RefreshInspectLite)
    liteFontSize:SetPoint("TOPLEFT", PADDING, y)
    liteFontSize:SetPoint("RIGHT", tabContent, "RIGHT", -PADDING, 0)
    liteModeWidgets.perSlotFontSize = liteFontSize
    y = y - FORM_ROW

    -- Set initial enable/disable states
    UpdateLiteModeWidgetStates()

    y = y - 10

    -- Open Character Panel button
    local openBtn = GUI:CreateButton(tabContent, "Open Character Panel", 200, 32, function()
        -- Open character frame if not open
        if not CharacterFrame:IsShown() then
            ToggleCharacter("PaperDollFrame")
        end
        -- Show settings panel after a short delay
        C_Timer.After(0.1, function()
            local settingsPanel = _G["QUI_CharSettingsPanel"]
            if settingsPanel then
                settingsPanel:Show()
            end
        end)
    end)
    openBtn:SetPoint("TOPLEFT", PADDING, y)

    tabContent:SetHeight(math.abs(y) + 50)
end

-- Export
ns.QUI_CharacterOptions = {
    BuildCharacterPaneTab = BuildCharacterPaneTab
}

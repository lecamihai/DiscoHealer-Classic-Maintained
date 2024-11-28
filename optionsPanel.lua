local addonName, discoVars = ...

-- Initialize Options Panel
DiscoHealerOptionsPanel = {}
DiscoHealerOptionsPanel.panel = CreateFrame("FRAME", "DiscoHealerPanel", UIParent, "BackdropTemplate")
DiscoHealerOptionsPanel.panel.name = "DiscoHealer"

-- Register Options Panel with the new API
local category = Settings.RegisterCanvasLayoutCategory(DiscoHealerOptionsPanel.panel, "DiscoHealer")
Settings.RegisterAddOnCategory(category)

SLASH_DISCO1 = "/disco"
SlashCmdList["DISCO"] = function(msg)
    Settings.OpenToCategory("DiscoHealer")
end

local keybindModState = "nomodifier"

-- Refresh Function
DiscoHealerOptionsPanel.panel.refresh = function()
    DiscoHealerOptionsPanel.tempSettings = Disco_Copy(DiscoSettings)

    DiscoHealerOptionsPanel.panel.slider:SetValue(DiscoHealerOptionsPanel.tempSettings.frameSize)
    DiscoHealerOptionsPanel.panel.ShowPetSelector:SetChecked(DiscoHealerOptionsPanel.tempSettings.showPets)
    DiscoHealerOptionsPanel.panel.ShowHealthSelector:SetChecked(DiscoHealerOptionsPanel.tempSettings.showHealthText)
    DiscoHealerOptionsPanel.panel.arrangeByGroupSelector:SetChecked(DiscoHealerOptionsPanel.tempSettings.arrangeByGroup)
    DiscoHealerOptionsPanel.panel.prioritizeGroupSelector:SetChecked(DiscoHealerOptionsPanel.tempSettings.prioritizeGroup)
    DiscoHealerOptionsPanel.panel.audioCuesSelector:SetChecked(DiscoHealerOptionsPanel.tempSettings.audioCues)

    refreshKeybindTextBoxes()
end

-- Okay Function
DiscoHealerOptionsPanel.panel.okay = function()
    DiscoSettings = Disco_Copy(DiscoHealerOptionsPanel.tempSettings)

    if not InCombatLockdown() then
        generateMainDiscoFrame(discoVars.discoMainFrame)
        generateDiscoSubframes(discoVars.discoSubframes, discoVars.discoOverlaySubframes, discoVars.discoMainFrame)
        recreateAllSubFrames(discoVars.discoSubframes, discoVars.discoOverlaySubframes, discoVars.discoMainFrame, discoVars.allPartyMembers)
    end
end

-- Default Function
DiscoHealerOptionsPanel.panel.default = function()
    DiscoSettings = Disco_Copy(discoVars.defaultSettings)
    DiscoHealerOptionsPanel.panel.refresh()
end

function generateOptionsPanel()
    -- UI Scale Slider
    if not DiscoHealerOptionsPanel.panel.UIScaleTitle then DiscoHealerOptionsPanel.panel.UIScaleTitle = DiscoHealerOptionsPanel.panel:CreateFontString(nil, "OVERLAY", "GameFontNormal") end;
    DiscoHealerOptionsPanel.panel.UIScaleTitle:SetPoint("BOTTOM", DiscoHealerOptionsPanel.panel, "TOP", -250, -50)
    DiscoHealerOptionsPanel.panel.UIScaleTitle:SetText("UI Scale")

    if not DiscoHealerOptionsPanel.panel.UIScaleValue then DiscoHealerOptionsPanel.panel.UIScaleValue = DiscoHealerOptionsPanel.panel:CreateFontString(nil, "OVERLAY", "GameFontNormal") end;
    DiscoHealerOptionsPanel.panel.UIScaleValue:SetPoint("BOTTOM", DiscoHealerOptionsPanel.panel, "TOP", 0, -25)
    DiscoHealerOptionsPanel.panel.UIScaleValue:SetText((DiscoHealerOptionsPanel.tempSettings.frameSize * 100) .. "%")

    if not DiscoHealerOptionsPanel.panel.slider then DiscoHealerOptionsPanel.panel.slider = CreateFrame("Slider", "DiscoScaleSlider", DiscoHealerOptionsPanel.panel, "OptionsSliderTemplate") end;
    DiscoHealerOptionsPanel.panel.slider:SetWidth(200)
    DiscoHealerOptionsPanel.panel.slider:SetHeight(20)
    DiscoHealerOptionsPanel.panel.slider:SetMinMaxValues(0.5,3);
    DiscoHealerOptionsPanel.panel.slider:SetValue(DiscoHealerOptionsPanel.tempSettings.frameSize)
    DiscoHealerOptionsPanel.panel.slider:SetValueStep(0.1)
    DiscoHealerOptionsPanel.panel.slider:SetObeyStepOnDrag(true);
    DiscoHealerOptionsPanel.panel.slider:SetScript("OnValueChanged", function(self)
        local value = self:GetValue()
        DiscoHealerOptionsPanel.tempSettings.frameSize = value
        DiscoHealerOptionsPanel.panel.UIScaleValue:SetText(math.floor(DiscoHealerOptionsPanel.tempSettings.frameSize * 100) .. "%")
    end)
    DiscoHealerOptionsPanel.panel.slider:SetPoint("BOTTOM", DiscoHealerOptionsPanel.panel, "TOP", 0, -50)
    getglobal(DiscoHealerOptionsPanel.panel.slider:GetName() .. 'Low'):SetText("50%")
    getglobal(DiscoHealerOptionsPanel.panel.slider:GetName() .. 'High'):SetText("300%")

    -- Reset Position
    if not DiscoHealerOptionsPanel.panel.resetPosition then DiscoHealerOptionsPanel.panel.resetPosition = CreateFrame("Button", "DiscoPositionReset", DiscoHealerOptionsPanel.panel, "UIPanelButtonTemplate") end;
    DiscoHealerOptionsPanel.panel.resetPosition:SetSize(120 ,22) -- width, height
    DiscoHealerOptionsPanel.panel.resetPosition:SetText("Reset Position")
    DiscoHealerOptionsPanel.panel.resetPosition:SetPoint("BOTTOM", DiscoHealerOptionsPanel.panel, "TOP", -15, -155)
    DiscoHealerOptionsPanel.panel.resetPosition:SetScript("OnClick", function()
        discoVars.discoMainFrame:ClearAllPoints()
        discoVars.discoMainFrame:SetPoint("CENTER", UIParent, "CENTER")
    end)
    
    -- Audio Cues
    if not DiscoHealerOptionsPanel.panel.AudioCuesTitle then DiscoHealerOptionsPanel.panel.AudioCuesTitle = DiscoHealerOptionsPanel.panel:CreateFontString(nil, "OVERLAY", "GameFontNormal") end;
    DiscoHealerOptionsPanel.panel.AudioCuesTitle:SetPoint("BOTTOM", DiscoHealerOptionsPanel.panel, "TOP", 150, -100)
    DiscoHealerOptionsPanel.panel.AudioCuesTitle:SetText("Audio Cues")

    if not DiscoHealerOptionsPanel.panel.audioCuesSelector then DiscoHealerOptionsPanel.panel.audioCuesSelector = CreateFrame("CHECKBUTTON", "audioCuesCheckButton", DiscoHealerOptionsPanel.panel, "ChatConfigCheckButtonTemplate") end;
    DiscoHealerOptionsPanel.panel.audioCuesSelector:SetPoint("BOTTOM", DiscoHealerOptionsPanel.panel, "TOP", 210, -105)
    DiscoHealerOptionsPanel.panel.audioCuesSelector:SetScript("OnClick", 
    function()
        DiscoHealerOptionsPanel.tempSettings.audioCues = DiscoHealerOptionsPanel.panel.audioCuesSelector:GetChecked()
    end
    );

    -- Prioritize group
    if not DiscoHealerOptionsPanel.panel.prioritizeGroupTitle then DiscoHealerOptionsPanel.panel.prioritizeGroupTitle = DiscoHealerOptionsPanel.panel:CreateFontString(nil, "OVERLAY", "GameFontNormal") end;
    DiscoHealerOptionsPanel.panel.prioritizeGroupTitle:SetPoint("BOTTOM", DiscoHealerOptionsPanel.panel, "TOP", -30, -100)
    DiscoHealerOptionsPanel.panel.prioritizeGroupTitle:SetText("Prioritize group members")

    if not DiscoHealerOptionsPanel.panel.prioritizeGroupSelector then DiscoHealerOptionsPanel.panel.prioritizeGroupSelector = CreateFrame("CHECKBUTTON", "prioritizeGroupCheckButton", DiscoHealerOptionsPanel.panel, "ChatConfigCheckButtonTemplate") end;
    DiscoHealerOptionsPanel.panel.prioritizeGroupSelector:SetPoint("BOTTOM", DiscoHealerOptionsPanel.panel, "TOP", 70, -105)
    DiscoHealerOptionsPanel.panel.prioritizeGroupSelector:SetScript("OnClick", 
    function()
        DiscoHealerOptionsPanel.tempSettings.prioritizeGroup = DiscoHealerOptionsPanel.panel.prioritizeGroupSelector:GetChecked()
    end
    );

    -- Arrange by group
    if not DiscoHealerOptionsPanel.panel.arrangeByGroupTitle then DiscoHealerOptionsPanel.panel.arrangeByGroupTitle = DiscoHealerOptionsPanel.panel:CreateFontString(nil, "OVERLAY", "GameFontNormal") end;
    DiscoHealerOptionsPanel.panel.arrangeByGroupTitle:SetPoint("BOTTOM", DiscoHealerOptionsPanel.panel, "TOP", -230, -100)
    DiscoHealerOptionsPanel.panel.arrangeByGroupTitle:SetText("Arrange by group")

    if not DiscoHealerOptionsPanel.panel.arrangeByGroupSelector then DiscoHealerOptionsPanel.panel.arrangeByGroupSelector = CreateFrame("CHECKBUTTON", "arrangeByGroupCheckButton", DiscoHealerOptionsPanel.panel, "ChatConfigCheckButtonTemplate") end;
    DiscoHealerOptionsPanel.panel.arrangeByGroupSelector:SetPoint("BOTTOM", DiscoHealerOptionsPanel.panel, "TOP", -150, -105)
    DiscoHealerOptionsPanel.panel.arrangeByGroupSelector:SetScript("OnClick", 
    function()
        DiscoHealerOptionsPanel.tempSettings.arrangeByGroup = DiscoHealerOptionsPanel.panel.arrangeByGroupSelector:GetChecked()
    end
    );
    
    --  Show Pets
    if not DiscoHealerOptionsPanel.panel.ShowPetTitle then DiscoHealerOptionsPanel.panel.ShowPetTitle = DiscoHealerOptionsPanel.panel:CreateFontString(nil, "OVERLAY", "GameFontNormal") end;
    DiscoHealerOptionsPanel.panel.ShowPetTitle:SetPoint("BOTTOM", DiscoHealerOptionsPanel.panel, "TOP", -250, -150)
    DiscoHealerOptionsPanel.panel.ShowPetTitle:SetText("Show Pets")
    
    if not DiscoHealerOptionsPanel.panel.ShowPetSelector then DiscoHealerOptionsPanel.panel.ShowPetSelector = CreateFrame("CHECKBUTTON", "DiscoCheckButton", DiscoHealerOptionsPanel.panel, "ChatConfigCheckButtonTemplate") end;
    DiscoHealerOptionsPanel.panel.ShowPetSelector:SetPoint("BOTTOM", DiscoHealerOptionsPanel.panel, "TOP", -200, -155)
    DiscoHealerOptionsPanel.panel.ShowPetSelector:SetScript("OnClick", 
    function()
        DiscoHealerOptionsPanel.tempSettings.showPets = DiscoHealerOptionsPanel.panel.ShowPetSelector:GetChecked()
    end
    );

    -- Display missing health numbers
    if not DiscoHealerOptionsPanel.panel.ShowHealthTitle then DiscoHealerOptionsPanel.panel.ShowHealthTitle = DiscoHealerOptionsPanel.panel:CreateFontString(nil, "OVERLAY", "GameFontNormal") end;
    DiscoHealerOptionsPanel.panel.ShowHealthTitle:SetPoint("BOTTOM", DiscoHealerOptionsPanel.panel, "TOP", 160, -150)
    DiscoHealerOptionsPanel.panel.ShowHealthTitle:SetText("Show Health Numbers")
    
    if not DiscoHealerOptionsPanel.panel.ShowHealthSelector then DiscoHealerOptionsPanel.panel.ShowHealthSelector = CreateFrame("CHECKBUTTON", nil, DiscoHealerOptionsPanel.panel, "ChatConfigCheckButtonTemplate") end;
    DiscoHealerOptionsPanel.panel.ShowHealthSelector:SetPoint("BOTTOM", DiscoHealerOptionsPanel.panel, "TOP", 240, -155)
    DiscoHealerOptionsPanel.panel.ShowHealthSelector:SetScript("OnClick", 
    function()
        DiscoHealerOptionsPanel.tempSettings.showHealthText = DiscoHealerOptionsPanel.panel.ShowHealthSelector:GetChecked()
    end
    );

    -- Color Picker
    local selectedColor
    local selectedColorPicker
    local function colorPickerCallback(restore)
        local newR, newG, newB
        if restore then
            newR, newG, newB = unpack(restore)
        else
            -- Get the new color values from the color picker
            newR, newG, newB = ColorPickerFrame:GetColorRGB()
        end
    
        -- Update the selectedColor and the texture with the new values
        selectedColor.r, selectedColor.g, selectedColor.b = newR, newG, newB
        selectedColorPicker:SetColorTexture(newR, newG, newB)
    end
    
    local function showColorPicker(r, g, b, a, changedCallback)
        ColorPickerFrame:SetColorRGB(r, g, b)
        ColorPickerFrame.hasOpacity = false -- Set to true if you want opacity support
        ColorPickerFrame.opacity = a
        ColorPickerFrame.previousValues = {r, g, b, a}
        ColorPickerFrame.func = changedCallback
        ColorPickerFrame.opacityFunc = nil -- Not used since opacity is false
        ColorPickerFrame.cancelFunc = changedCallback
        ColorPickerFrame.swatchFunc = changedCallback -- This ensures the swatchFunc is correctly assigned
        ColorPickerFrame:Hide() -- Trigger OnShow
        ColorPickerFrame:Show()
    end

    DiscoHealerOptionsPanel.panel.colorPicker = CreateFrame("FRAME", "DiscoColorPicker", DiscoHealerOptionsPanel.panel)
    DiscoHealerOptionsPanel.panel.colorPicker:SetPoint("TOPLEFT", DiscoHealerOptionsPanel.panel ,"TOPLEFT", 0, 175)
    DiscoHealerOptionsPanel.panel.colorPicker:SetPoint("BOTTOMRIGHT", DiscoHealerOptionsPanel.panel ,"BOTTOMRIGHT", 0, 175)

    -- Low Priority
    DiscoHealerOptionsPanel.panel.colorPicker.lowPrioLabel = DiscoHealerOptionsPanel.panel.colorPicker:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    DiscoHealerOptionsPanel.panel.colorPicker.lowPrioLabel:SetPoint("CENTER", DiscoHealerOptionsPanel.panel.colorPicker, "LEFT", 65, -80)
    DiscoHealerOptionsPanel.panel.colorPicker.lowPrioLabel:SetText("Low Priority")

    DiscoHealerOptionsPanel.panel.colorPicker1 = CreateFrame("FRAME", "DiscoColorPicker1", DiscoHealerOptionsPanel.panel)
    DiscoHealerOptionsPanel.panel.colorPicker1:SetPoint("CENTER", DiscoHealerOptionsPanel.panel.colorPicker, "LEFT", 140, -80)
    DiscoHealerOptionsPanel.panel.colorPicker1:SetSize(40, 20)

    DiscoHealerOptionsPanel.panel.colorPicker1.bgTexture = DiscoHealerOptionsPanel.panel.colorPicker1:CreateTexture(nil, "BACKGROUND")
    DiscoHealerOptionsPanel.panel.colorPicker1.bgTexture:SetAllPoints(DiscoHealerOptionsPanel.panel.colorPicker1)
    DiscoHealerOptionsPanel.panel.colorPicker1.bgTexture:SetColorTexture(1, 0.8, 0)
    
    DiscoHealerOptionsPanel.panel.colorPicker1.texture = DiscoHealerOptionsPanel.panel.colorPicker1:CreateTexture(nil, "BORDER")
    DiscoHealerOptionsPanel.panel.colorPicker1.texture:SetPoint("TOPLEFT", DiscoHealerOptionsPanel.panel.colorPicker1 ,"TOPLEFT", 1, -1)
    DiscoHealerOptionsPanel.panel.colorPicker1.texture:SetPoint("BOTTOMRIGHT", DiscoHealerOptionsPanel.panel.colorPicker1 ,"BOTTOMRIGHT", -1, 1)
    DiscoHealerOptionsPanel.panel.colorPicker1.texture:SetColorTexture(DiscoHealerOptionsPanel.tempSettings.lowPrioRGB.r, DiscoHealerOptionsPanel.tempSettings.lowPrioRGB.g, DiscoHealerOptionsPanel.tempSettings.lowPrioRGB.b)
    
    DiscoHealerOptionsPanel.panel.colorPicker1:SetScript("OnMouseDown", function(self, button)
        selectedColor = DiscoHealerOptionsPanel.tempSettings.lowPrioRGB
        selectedColorPicker = DiscoHealerOptionsPanel.panel.colorPicker1.texture
        showColorPicker(DiscoHealerOptionsPanel.tempSettings.lowPrioRGB.r, DiscoHealerOptionsPanel.tempSettings.lowPrioRGB.g, DiscoHealerOptionsPanel.tempSettings.lowPrioRGB.b, nil, colorPickerCallback)
      end)

    -- Medium Priority
    DiscoHealerOptionsPanel.panel.colorPicker.medPrioLabel = DiscoHealerOptionsPanel.panel.colorPicker:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    DiscoHealerOptionsPanel.panel.colorPicker.medPrioLabel:SetPoint("CENTER", DiscoHealerOptionsPanel.panel.colorPicker, "LEFT", 265, -80)
    DiscoHealerOptionsPanel.panel.colorPicker.medPrioLabel:SetText("Medium Priority")

    DiscoHealerOptionsPanel.panel.colorPicker2 = CreateFrame("FRAME", "DiscoColorPicker2", DiscoHealerOptionsPanel.panel)
    DiscoHealerOptionsPanel.panel.colorPicker2:SetPoint("CENTER", DiscoHealerOptionsPanel.panel.colorPicker, "LEFT", 340, -80)
    DiscoHealerOptionsPanel.panel.colorPicker2:SetSize(40, 20)

    DiscoHealerOptionsPanel.panel.colorPicker2.bgTexture = DiscoHealerOptionsPanel.panel.colorPicker2:CreateTexture(nil, "BACKGROUND")
    DiscoHealerOptionsPanel.panel.colorPicker2.bgTexture:SetAllPoints(DiscoHealerOptionsPanel.panel.colorPicker2)
    DiscoHealerOptionsPanel.panel.colorPicker2.bgTexture:SetColorTexture(1, 0.8, 0)
    
    DiscoHealerOptionsPanel.panel.colorPicker2.texture = DiscoHealerOptionsPanel.panel.colorPicker2:CreateTexture(nil, "BORDER")
    DiscoHealerOptionsPanel.panel.colorPicker2.texture:SetPoint("TOPLEFT", DiscoHealerOptionsPanel.panel.colorPicker2 ,"TOPLEFT", 1, -1)
    DiscoHealerOptionsPanel.panel.colorPicker2.texture:SetPoint("BOTTOMRIGHT", DiscoHealerOptionsPanel.panel.colorPicker2 ,"BOTTOMRIGHT", -1, 1)
    DiscoHealerOptionsPanel.panel.colorPicker2.texture:SetColorTexture(DiscoHealerOptionsPanel.tempSettings.medPrioRGB.r, DiscoHealerOptionsPanel.tempSettings.medPrioRGB.g, DiscoHealerOptionsPanel.tempSettings.medPrioRGB.b)
    
    DiscoHealerOptionsPanel.panel.colorPicker2:SetScript("OnMouseDown", function(self, button)
        selectedColor = DiscoHealerOptionsPanel.tempSettings.medPrioRGB
        selectedColorPicker = DiscoHealerOptionsPanel.panel.colorPicker2.texture
        showColorPicker(DiscoHealerOptionsPanel.tempSettings.medPrioRGB.r, DiscoHealerOptionsPanel.tempSettings.medPrioRGB.g, DiscoHealerOptionsPanel.tempSettings.medPrioRGB.b, nil, colorPickerCallback)
      end)

    -- High Priority
    DiscoHealerOptionsPanel.panel.colorPicker.highPrioLabel = DiscoHealerOptionsPanel.panel.colorPicker:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    DiscoHealerOptionsPanel.panel.colorPicker.highPrioLabel:SetPoint("CENTER", DiscoHealerOptionsPanel.panel.colorPicker, "LEFT", 465, -80)
    DiscoHealerOptionsPanel.panel.colorPicker.highPrioLabel:SetText("High Priority")

    DiscoHealerOptionsPanel.panel.colorPicker3 = CreateFrame("FRAME", "DiscoColorPicker3", DiscoHealerOptionsPanel.panel)
    DiscoHealerOptionsPanel.panel.colorPicker3:SetPoint("CENTER", DiscoHealerOptionsPanel.panel.colorPicker, "LEFT", 540, -80)
    DiscoHealerOptionsPanel.panel.colorPicker3:SetSize(40, 20)

    DiscoHealerOptionsPanel.panel.colorPicker3.bgTexture = DiscoHealerOptionsPanel.panel.colorPicker3:CreateTexture(nil, "BACKGROUND")
    DiscoHealerOptionsPanel.panel.colorPicker3.bgTexture:SetAllPoints(DiscoHealerOptionsPanel.panel.colorPicker3)
    DiscoHealerOptionsPanel.panel.colorPicker3.bgTexture:SetColorTexture(1, 0.8, 0)
    
    DiscoHealerOptionsPanel.panel.colorPicker3.texture = DiscoHealerOptionsPanel.panel.colorPicker3:CreateTexture(nil, "BORDER")
    DiscoHealerOptionsPanel.panel.colorPicker3.texture:SetPoint("TOPLEFT", DiscoHealerOptionsPanel.panel.colorPicker3 ,"TOPLEFT", 1, -1)
    DiscoHealerOptionsPanel.panel.colorPicker3.texture:SetPoint("BOTTOMRIGHT", DiscoHealerOptionsPanel.panel.colorPicker3 ,"BOTTOMRIGHT", -1, 1)
    DiscoHealerOptionsPanel.panel.colorPicker3.texture:SetColorTexture(DiscoHealerOptionsPanel.tempSettings.highPrioRGB.r, DiscoHealerOptionsPanel.tempSettings.highPrioRGB.g, DiscoHealerOptionsPanel.tempSettings.highPrioRGB.b)
    
    DiscoHealerOptionsPanel.panel.colorPicker3:SetScript("OnMouseDown", function(self, button)
        selectedColor = DiscoHealerOptionsPanel.tempSettings.highPrioRGB
        selectedColorPicker = DiscoHealerOptionsPanel.panel.colorPicker3.texture
        showColorPicker(DiscoHealerOptionsPanel.tempSettings.highPrioRGB.r, DiscoHealerOptionsPanel.tempSettings.highPrioRGB.g, DiscoHealerOptionsPanel.tempSettings.highPrioRGB.b, nil, colorPickerCallback)
      end)
    
    -- Action Dropdown Selector
    if not DiscoHealerOptionsPanel.panel.actionTitle then DiscoHealerOptionsPanel.panel.actionTitle = DiscoHealerOptionsPanel.panel:CreateFontString(nil, "OVERLAY", "GameFontNormal") end;
    DiscoHealerOptionsPanel.panel.actionTitle:SetPoint("BOTTOM", DiscoHealerOptionsPanel.panel, "TOP", 0, -230)
    DiscoHealerOptionsPanel.panel.actionTitle:SetText("Keybinds")

    local function SpellSelectDropDownMenu(frame, level, menuList)
        local info = UIDropDownMenu_CreateInfo()
        
        if level == 1 then
            -- Function called when dropdown changed
            local function select(selection)
                UIDropDownMenu_SetText(frame, selection)
                if selection == "Target" then
                    frame.editBox:SetText("target")
                    frame.textChangedFunc()
                    frame.editBox:Hide()
                elseif selection == "Spell" then
                    frame.editBox:SetText("")
                    frame.textChangedFunc()
                    frame.editBox:Show()
                end
            end
            info.text, info.checked, info.func = "Target", frame.editBox:GetText() == "target", function() select("Target"); end
            UIDropDownMenu_AddButton(info)
            info.text, info.checked, info.func = "Spell", frame.editBox:GetText() ~= "target", function() select("Spell"); end
            UIDropDownMenu_AddButton(info)
        end
    end

    -- Spell Select Frame
    if not DiscoHealerOptionsPanel.panel.spellSelect then DiscoHealerOptionsPanel.panel.spellSelect = CreateFrame("FRAME", "DiscoSpellSelect", DiscoHealerOptionsPanel.panel); end
    DiscoHealerOptionsPanel.panel.spellSelect:SetPoint("TOPLEFT", DiscoHealerOptionsPanel.panel ,"TOPLEFT", 0, 35)
    DiscoHealerOptionsPanel.panel.spellSelect:SetPoint("BOTTOMRIGHT", DiscoHealerOptionsPanel.panel ,"BOTTOMRIGHT", 0, 35)

    -- Modifier Selector
    local updateKeybindModState = function()
        keybindModState = "nomodifier"
        if DiscoHealerOptionsPanel.panel.spellSelect.altModSelector:GetChecked() then keybindModState = keybindModState .. ",alt" end
        if DiscoHealerOptionsPanel.panel.spellSelect.ctrlModSelector:GetChecked() then keybindModState = keybindModState .. ",ctrl" end
        if DiscoHealerOptionsPanel.panel.spellSelect.shiftModSelector:GetChecked() then keybindModState = keybindModState .. ",shift" end
    end

    --  CTRL
    if not DiscoHealerOptionsPanel.panel.spellSelect.ctrlModTitle then DiscoHealerOptionsPanel.panel.spellSelect.ctrlModTitle = DiscoHealerOptionsPanel.panel.spellSelect:CreateFontString(nil, "OVERLAY", "GameFontNormal") end;
    DiscoHealerOptionsPanel.panel.spellSelect.ctrlModTitle:SetPoint("CENTER", DiscoHealerOptionsPanel.panel.spellSelect, "LEFT", 100, -10)
    DiscoHealerOptionsPanel.panel.spellSelect.ctrlModTitle:SetText("Ctrl")
    
    if not DiscoHealerOptionsPanel.panel.spellSelect.ctrlModSelector then DiscoHealerOptionsPanel.panel.spellSelect.ctrlModSelector = CreateFrame("CHECKBUTTON", nil, DiscoHealerOptionsPanel.panel.spellSelect, "ChatConfigCheckButtonTemplate") end;
    DiscoHealerOptionsPanel.panel.spellSelect.ctrlModSelector:SetPoint("CENTER", DiscoHealerOptionsPanel.panel.spellSelect, "LEFT", 130, -10)
    DiscoHealerOptionsPanel.panel.spellSelect.ctrlModSelector:SetScript("OnClick", 
    function()
        updateKeybindModState()
        refreshKeybindTextBoxes()
    end
    );

    --  Shift
    if not DiscoHealerOptionsPanel.panel.spellSelect.shiftModTitle then DiscoHealerOptionsPanel.panel.spellSelect.shiftModTitle = DiscoHealerOptionsPanel.panel.spellSelect:CreateFontString(nil, "OVERLAY", "GameFontNormal") end;
    DiscoHealerOptionsPanel.panel.spellSelect.shiftModTitle:SetPoint("CENTER", DiscoHealerOptionsPanel.panel.spellSelect, "LEFT", 300, -10)
    DiscoHealerOptionsPanel.panel.spellSelect.shiftModTitle:SetText("Shift")
    
    if not DiscoHealerOptionsPanel.panel.spellSelect.shiftModSelector then DiscoHealerOptionsPanel.panel.spellSelect.shiftModSelector = CreateFrame("CHECKBUTTON", nil, DiscoHealerOptionsPanel.panel.spellSelect, "ChatConfigCheckButtonTemplate") end;
    DiscoHealerOptionsPanel.panel.spellSelect.shiftModSelector:SetPoint("CENTER", DiscoHealerOptionsPanel.panel.spellSelect, "LEFT", 340, -10)
    DiscoHealerOptionsPanel.panel.spellSelect.shiftModSelector:SetScript("OnClick", 
    function()
        updateKeybindModState()
        refreshKeybindTextBoxes()
    end
    );

    --  Alt
    if not DiscoHealerOptionsPanel.panel.spellSelect.altModTitle then DiscoHealerOptionsPanel.panel.spellSelect.altModTitle = DiscoHealerOptionsPanel.panel.spellSelect:CreateFontString(nil, "OVERLAY", "GameFontNormal") end;
    DiscoHealerOptionsPanel.panel.spellSelect.altModTitle:SetPoint("CENTER", DiscoHealerOptionsPanel.panel.spellSelect, "LEFT", 500, -10)
    DiscoHealerOptionsPanel.panel.spellSelect.altModTitle:SetText("Alt")
    
    if not DiscoHealerOptionsPanel.panel.spellSelect.altModSelector then DiscoHealerOptionsPanel.panel.spellSelect.altModSelector = CreateFrame("CHECKBUTTON", nil, DiscoHealerOptionsPanel.panel.spellSelect, "ChatConfigCheckButtonTemplate") end;
    DiscoHealerOptionsPanel.panel.spellSelect.altModSelector:SetPoint("CENTER", DiscoHealerOptionsPanel.panel.spellSelect, "LEFT", 530, -10)
    DiscoHealerOptionsPanel.panel.spellSelect.altModSelector:SetScript("OnClick", 
    function()
        updateKeybindModState()
        refreshKeybindTextBoxes()
    end
    );

    -- Left Click
    DiscoHealerOptionsPanel.panel.spellSelect.box1Label = DiscoHealerOptionsPanel.panel.spellSelect:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    DiscoHealerOptionsPanel.panel.spellSelect.box1Label:SetPoint("CENTER", DiscoHealerOptionsPanel.panel.spellSelect, "LEFT", 65, -50)
    DiscoHealerOptionsPanel.panel.spellSelect.box1Label:SetText("Left Click")
    
    DiscoHealerOptionsPanel.panel.spellSelect.box1 = CreateFrame("EditBox", "DiscoSpellBox1", DiscoHealerOptionsPanel.panel.spellSelect, "InputBoxTemplate")
    DiscoHealerOptionsPanel.panel.spellSelect.box1:SetSize(320,20)
    DiscoHealerOptionsPanel.panel.spellSelect.box1:SetAutoFocus(false)
    DiscoHealerOptionsPanel.panel.spellSelect.box1:SetPoint("CENTER", DiscoHealerOptionsPanel.panel.spellSelect, "CENTER", 100, -50)

    if not DiscoHealerOptionsPanel.panel.spellSelect.box1Selector then DiscoHealerOptionsPanel.panel.spellSelect.box1Selector = CreateFrame("BUTTON", "DiscoActionDropdownMenu", DiscoHealerOptionsPanel.panel, "UIDropDownMenuTemplate"); end
    DiscoHealerOptionsPanel.panel.spellSelect.box1Selector.editBox = DiscoHealerOptionsPanel.panel.spellSelect.box1
    DiscoHealerOptionsPanel.panel.spellSelect.box1Selector:SetPoint("CENTER", DiscoHealerOptionsPanel.panel.spellSelect, "LEFT", 180, -50)
    DiscoHealerOptionsPanel.panel.spellSelect.box1Selector.textChangedFunc = function()
        if not DiscoHealerOptionsPanel.tempSettings.keybinds[keybindModState] then DiscoHealerOptionsPanel.tempSettings.keybinds[keybindModState] = {} end;
        DiscoHealerOptionsPanel.tempSettings.keybinds[keybindModState].leftMacro = DiscoHealerOptionsPanel.panel.spellSelect.box1:GetText()
    end;
    DiscoHealerOptionsPanel.panel.spellSelect.box1:SetScript("OnTextChanged", DiscoHealerOptionsPanel.panel.spellSelect.box1Selector.textChangedFunc)
    UIDropDownMenu_SetWidth(DiscoHealerOptionsPanel.panel.spellSelect.box1Selector, 65)
    UIDropDownMenu_Initialize(DiscoHealerOptionsPanel.panel.spellSelect.box1Selector, SpellSelectDropDownMenu)

    -- Right Click
    DiscoHealerOptionsPanel.panel.spellSelect.box2Label = DiscoHealerOptionsPanel.panel.spellSelect:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    DiscoHealerOptionsPanel.panel.spellSelect.box2Label:SetPoint("CENTER", DiscoHealerOptionsPanel.panel.spellSelect, "LEFT", 65, -75)
    DiscoHealerOptionsPanel.panel.spellSelect.box2Label:SetText("Right Click")
    
    DiscoHealerOptionsPanel.panel.spellSelect.box2 = CreateFrame("EditBox", "DiscoSpellBox2", DiscoHealerOptionsPanel.panel.spellSelect, "InputBoxTemplate")
    DiscoHealerOptionsPanel.panel.spellSelect.box2:SetSize(320,20)
    DiscoHealerOptionsPanel.panel.spellSelect.box2:SetAutoFocus(false)
    DiscoHealerOptionsPanel.panel.spellSelect.box2:SetPoint("CENTER", DiscoHealerOptionsPanel.panel.spellSelect, "CENTER", 100, -75)

    if not DiscoHealerOptionsPanel.panel.spellSelect.box2Selector then DiscoHealerOptionsPanel.panel.spellSelect.box2Selector = CreateFrame("BUTTON", "DiscoActionDropdownMenu", DiscoHealerOptionsPanel.panel, "UIDropDownMenuTemplate"); end
    DiscoHealerOptionsPanel.panel.spellSelect.box2Selector.editBox = DiscoHealerOptionsPanel.panel.spellSelect.box2
    DiscoHealerOptionsPanel.panel.spellSelect.box2Selector:SetPoint("CENTER", DiscoHealerOptionsPanel.panel.spellSelect, "LEFT", 180, -75)
    DiscoHealerOptionsPanel.panel.spellSelect.box2Selector.textChangedFunc = function()
        if not DiscoHealerOptionsPanel.tempSettings.keybinds[keybindModState] then DiscoHealerOptionsPanel.tempSettings.keybinds[keybindModState] = {} end;
        DiscoHealerOptionsPanel.tempSettings.keybinds[keybindModState].rightMacro = DiscoHealerOptionsPanel.panel.spellSelect.box2:GetText()
    end;
    DiscoHealerOptionsPanel.panel.spellSelect.box2:SetScript("OnTextChanged", DiscoHealerOptionsPanel.panel.spellSelect.box2Selector.textChangedFunc)
    UIDropDownMenu_SetWidth(DiscoHealerOptionsPanel.panel.spellSelect.box2Selector, 65)
    UIDropDownMenu_Initialize(DiscoHealerOptionsPanel.panel.spellSelect.box2Selector, SpellSelectDropDownMenu)

    -- MB4 (back)
    DiscoHealerOptionsPanel.panel.spellSelect.box3Label = DiscoHealerOptionsPanel.panel.spellSelect:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    DiscoHealerOptionsPanel.panel.spellSelect.box3Label:SetPoint("CENTER", DiscoHealerOptionsPanel.panel.spellSelect, "LEFT", 65, -100)
    DiscoHealerOptionsPanel.panel.spellSelect.box3Label:SetText("MB4 (back)")
    
    DiscoHealerOptionsPanel.panel.spellSelect.box3 = CreateFrame("EditBox", "DiscoSpellBox3", DiscoHealerOptionsPanel.panel.spellSelect, "InputBoxTemplate")
    DiscoHealerOptionsPanel.panel.spellSelect.box3:SetSize(320,20)
    DiscoHealerOptionsPanel.panel.spellSelect.box3:SetAutoFocus(false)
    DiscoHealerOptionsPanel.panel.spellSelect.box3:SetPoint("CENTER", DiscoHealerOptionsPanel.panel.spellSelect, "CENTER", 100, -100)

    if not DiscoHealerOptionsPanel.panel.spellSelect.box3Selector then DiscoHealerOptionsPanel.panel.spellSelect.box3Selector = CreateFrame("BUTTON", "DiscoActionDropdownMenu", DiscoHealerOptionsPanel.panel, "UIDropDownMenuTemplate"); end
    DiscoHealerOptionsPanel.panel.spellSelect.box3Selector.editBox = DiscoHealerOptionsPanel.panel.spellSelect.box3
    DiscoHealerOptionsPanel.panel.spellSelect.box3Selector:SetPoint("CENTER", DiscoHealerOptionsPanel.panel.spellSelect, "LEFT", 180, -100)
    DiscoHealerOptionsPanel.panel.spellSelect.box3Selector.textChangedFunc = function()
        if not DiscoHealerOptionsPanel.tempSettings.keybinds[keybindModState] then DiscoHealerOptionsPanel.tempSettings.keybinds[keybindModState] = {} end;
        DiscoHealerOptionsPanel.tempSettings.keybinds[keybindModState].mb4Macro = DiscoHealerOptionsPanel.panel.spellSelect.box3:GetText()
    end;
    DiscoHealerOptionsPanel.panel.spellSelect.box3:SetScript("OnTextChanged", DiscoHealerOptionsPanel.panel.spellSelect.box3Selector.textChangedFunc)
    UIDropDownMenu_SetWidth(DiscoHealerOptionsPanel.panel.spellSelect.box3Selector, 65)
    UIDropDownMenu_Initialize(DiscoHealerOptionsPanel.panel.spellSelect.box3Selector, SpellSelectDropDownMenu)

    -- MB5 (forward)
    DiscoHealerOptionsPanel.panel.spellSelect.box4Label = DiscoHealerOptionsPanel.panel.spellSelect:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    DiscoHealerOptionsPanel.panel.spellSelect.box4Label:SetPoint("CENTER", DiscoHealerOptionsPanel.panel.spellSelect, "LEFT", 65, -125)
    DiscoHealerOptionsPanel.panel.spellSelect.box4Label:SetText("MB5 (forward)")
    
    DiscoHealerOptionsPanel.panel.spellSelect.box4 = CreateFrame("EditBox", "DiscoSpellBox4", DiscoHealerOptionsPanel.panel.spellSelect, "InputBoxTemplate")
    DiscoHealerOptionsPanel.panel.spellSelect.box4:SetSize(320,20)
    DiscoHealerOptionsPanel.panel.spellSelect.box4:SetAutoFocus(false)
    DiscoHealerOptionsPanel.panel.spellSelect.box4:SetPoint("CENTER", DiscoHealerOptionsPanel.panel.spellSelect, "CENTER", 100, -125)

    if not DiscoHealerOptionsPanel.panel.spellSelect.box4Selector then DiscoHealerOptionsPanel.panel.spellSelect.box4Selector = CreateFrame("BUTTON", "DiscoActionDropdownMenu", DiscoHealerOptionsPanel.panel, "UIDropDownMenuTemplate"); end
    DiscoHealerOptionsPanel.panel.spellSelect.box4Selector.editBox = DiscoHealerOptionsPanel.panel.spellSelect.box4
    DiscoHealerOptionsPanel.panel.spellSelect.box4Selector:SetPoint("CENTER", DiscoHealerOptionsPanel.panel.spellSelect, "LEFT", 180, -125)
    DiscoHealerOptionsPanel.panel.spellSelect.box4Selector.textChangedFunc = function()
        if not DiscoHealerOptionsPanel.tempSettings.keybinds[keybindModState] then DiscoHealerOptionsPanel.tempSettings.keybinds[keybindModState] = {} end;
        DiscoHealerOptionsPanel.tempSettings.keybinds[keybindModState].mb5Macro = DiscoHealerOptionsPanel.panel.spellSelect.box4:GetText()
    end;
    DiscoHealerOptionsPanel.panel.spellSelect.box4:SetScript("OnTextChanged", DiscoHealerOptionsPanel.panel.spellSelect.box4Selector.textChangedFunc)
    UIDropDownMenu_SetWidth(DiscoHealerOptionsPanel.panel.spellSelect.box4Selector, 65)
    UIDropDownMenu_Initialize(DiscoHealerOptionsPanel.panel.spellSelect.box4Selector, SpellSelectDropDownMenu)

    -- Scroll Wheel Click
    DiscoHealerOptionsPanel.panel.spellSelect.box5Label = DiscoHealerOptionsPanel.panel.spellSelect:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    DiscoHealerOptionsPanel.panel.spellSelect.box5Label:SetPoint("CENTER", DiscoHealerOptionsPanel.panel.spellSelect, "LEFT", 65, -150)
    DiscoHealerOptionsPanel.panel.spellSelect.box5Label:SetText("Scroll Wheel Click")
    
    DiscoHealerOptionsPanel.panel.spellSelect.box5 = CreateFrame("EditBox", "DiscoSpellBox5", DiscoHealerOptionsPanel.panel.spellSelect, "InputBoxTemplate")
    DiscoHealerOptionsPanel.panel.spellSelect.box5:SetSize(320,20)
    DiscoHealerOptionsPanel.panel.spellSelect.box5:SetAutoFocus(false)
    DiscoHealerOptionsPanel.panel.spellSelect.box5:SetPoint("CENTER", DiscoHealerOptionsPanel.panel.spellSelect, "CENTER", 100, -150)

    if not DiscoHealerOptionsPanel.panel.spellSelect.box5Selector then DiscoHealerOptionsPanel.panel.spellSelect.box5Selector = CreateFrame("BUTTON", "DiscoActionDropdownMenu", DiscoHealerOptionsPanel.panel, "UIDropDownMenuTemplate"); end
    DiscoHealerOptionsPanel.panel.spellSelect.box5Selector.editBox = DiscoHealerOptionsPanel.panel.spellSelect.box5
    DiscoHealerOptionsPanel.panel.spellSelect.box5Selector:SetPoint("CENTER", DiscoHealerOptionsPanel.panel.spellSelect, "LEFT", 180, -150)
    DiscoHealerOptionsPanel.panel.spellSelect.box5Selector.textChangedFunc = function()
        if not DiscoHealerOptionsPanel.tempSettings.keybinds[keybindModState] then DiscoHealerOptionsPanel.tempSettings.keybinds[keybindModState] = {} end;
        DiscoHealerOptionsPanel.tempSettings.keybinds[keybindModState].scrollClickMacro = DiscoHealerOptionsPanel.panel.spellSelect.box5:GetText()
    end;
    DiscoHealerOptionsPanel.panel.spellSelect.box5:SetScript("OnTextChanged", DiscoHealerOptionsPanel.panel.spellSelect.box5Selector.textChangedFunc)
    UIDropDownMenu_SetWidth(DiscoHealerOptionsPanel.panel.spellSelect.box5Selector, 65)
    UIDropDownMenu_Initialize(DiscoHealerOptionsPanel.panel.spellSelect.box5Selector, SpellSelectDropDownMenu)

    -- Mouse Wheel Up
    DiscoHealerOptionsPanel.panel.spellSelect.box6Label = DiscoHealerOptionsPanel.panel.spellSelect:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    DiscoHealerOptionsPanel.panel.spellSelect.box6Label:SetPoint("CENTER", DiscoHealerOptionsPanel.panel.spellSelect, "LEFT", 65, -175)
    DiscoHealerOptionsPanel.panel.spellSelect.box6Label:SetText("Mouse Wheel Up")
    
    DiscoHealerOptionsPanel.panel.spellSelect.box6 = CreateFrame("EditBox", "DiscoSpellBox6", DiscoHealerOptionsPanel.panel.spellSelect, "InputBoxTemplate")
    DiscoHealerOptionsPanel.panel.spellSelect.box6:SetSize(320,20)
    DiscoHealerOptionsPanel.panel.spellSelect.box6:SetAutoFocus(false)
    DiscoHealerOptionsPanel.panel.spellSelect.box6:SetPoint("CENTER", DiscoHealerOptionsPanel.panel.spellSelect, "CENTER", 100, -175)

    if not DiscoHealerOptionsPanel.panel.spellSelect.box6Selector then DiscoHealerOptionsPanel.panel.spellSelect.box6Selector = CreateFrame("BUTTON", "DiscoActionDropdownMenu", DiscoHealerOptionsPanel.panel, "UIDropDownMenuTemplate"); end
    DiscoHealerOptionsPanel.panel.spellSelect.box6Selector.editBox = DiscoHealerOptionsPanel.panel.spellSelect.box6
    DiscoHealerOptionsPanel.panel.spellSelect.box6Selector:SetPoint("CENTER", DiscoHealerOptionsPanel.panel.spellSelect, "LEFT", 180, -175)
    DiscoHealerOptionsPanel.panel.spellSelect.box6Selector.textChangedFunc = function()
        if not DiscoHealerOptionsPanel.tempSettings.keybinds[keybindModState] then DiscoHealerOptionsPanel.tempSettings.keybinds[keybindModState] = {} end;
        DiscoHealerOptionsPanel.tempSettings.keybinds[keybindModState].mwUpMacro = DiscoHealerOptionsPanel.panel.spellSelect.box6:GetText()
    end;
    DiscoHealerOptionsPanel.panel.spellSelect.box6:SetScript("OnTextChanged", DiscoHealerOptionsPanel.panel.spellSelect.box6Selector.textChangedFunc)
    UIDropDownMenu_SetWidth(DiscoHealerOptionsPanel.panel.spellSelect.box6Selector, 65)
    UIDropDownMenu_Initialize(DiscoHealerOptionsPanel.panel.spellSelect.box6Selector, SpellSelectDropDownMenu)

    -- Mouse Wheel Down
    DiscoHealerOptionsPanel.panel.spellSelect.box7Label = DiscoHealerOptionsPanel.panel.spellSelect:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    DiscoHealerOptionsPanel.panel.spellSelect.box7Label:SetPoint("CENTER", DiscoHealerOptionsPanel.panel.spellSelect, "LEFT", 65, -200)
    DiscoHealerOptionsPanel.panel.spellSelect.box7Label:SetText("Mouse Wheel Down")
    
    DiscoHealerOptionsPanel.panel.spellSelect.box7 = CreateFrame("EditBox", "DiscoSpellBox7", DiscoHealerOptionsPanel.panel.spellSelect, "InputBoxTemplate")
    DiscoHealerOptionsPanel.panel.spellSelect.box7:SetSize(320,20)
    DiscoHealerOptionsPanel.panel.spellSelect.box7:SetAutoFocus(false)
    DiscoHealerOptionsPanel.panel.spellSelect.box7:SetPoint("CENTER", DiscoHealerOptionsPanel.panel.spellSelect, "CENTER", 100, -200)

    if not DiscoHealerOptionsPanel.panel.spellSelect.box7Selector then DiscoHealerOptionsPanel.panel.spellSelect.box7Selector = CreateFrame("BUTTON", "DiscoActionDropdownMenu", DiscoHealerOptionsPanel.panel, "UIDropDownMenuTemplate"); end
    DiscoHealerOptionsPanel.panel.spellSelect.box7Selector.editBox = DiscoHealerOptionsPanel.panel.spellSelect.box7
    DiscoHealerOptionsPanel.panel.spellSelect.box7Selector:SetPoint("CENTER", DiscoHealerOptionsPanel.panel.spellSelect, "LEFT", 180, -200)
    DiscoHealerOptionsPanel.panel.spellSelect.box7Selector.textChangedFunc = function()
        if not DiscoHealerOptionsPanel.tempSettings.keybinds[keybindModState] then DiscoHealerOptionsPanel.tempSettings.keybinds[keybindModState] = {} end;
        DiscoHealerOptionsPanel.tempSettings.keybinds[keybindModState].mwDownMacro = DiscoHealerOptionsPanel.panel.spellSelect.box7:GetText()
    end;
    DiscoHealerOptionsPanel.panel.spellSelect.box7:SetScript("OnTextChanged", DiscoHealerOptionsPanel.panel.spellSelect.box7Selector.textChangedFunc)
    UIDropDownMenu_SetWidth(DiscoHealerOptionsPanel.panel.spellSelect.box7Selector, 65)
    UIDropDownMenu_Initialize(DiscoHealerOptionsPanel.panel.spellSelect.box7Selector, SpellSelectDropDownMenu)

    refreshKeybindTextBoxes()
end

function refreshKeybindTextBoxes()
    if not DiscoHealerOptionsPanel.tempSettings.keybinds[keybindModState] then DiscoHealerOptionsPanel.tempSettings.keybinds[keybindModState] = {} end;
    DiscoHealerOptionsPanel.panel.spellSelect.box1:SetText(DiscoHealerOptionsPanel.tempSettings.keybinds[keybindModState].leftMacro or "")
    DiscoHealerOptionsPanel.panel.spellSelect.box1:SetCursorPosition(0)
    DiscoHealerOptionsPanel.panel.spellSelect.box2:SetText(DiscoHealerOptionsPanel.tempSettings.keybinds[keybindModState].rightMacro or "")
    DiscoHealerOptionsPanel.panel.spellSelect.box2:SetCursorPosition(0)
    DiscoHealerOptionsPanel.panel.spellSelect.box3:SetText(DiscoHealerOptionsPanel.tempSettings.keybinds[keybindModState].mb4Macro or "")
    DiscoHealerOptionsPanel.panel.spellSelect.box3:SetCursorPosition(0)
    DiscoHealerOptionsPanel.panel.spellSelect.box4:SetText(DiscoHealerOptionsPanel.tempSettings.keybinds[keybindModState].mb5Macro or "")
    DiscoHealerOptionsPanel.panel.spellSelect.box4:SetCursorPosition(0)
    DiscoHealerOptionsPanel.panel.spellSelect.box5:SetText(DiscoHealerOptionsPanel.tempSettings.keybinds[keybindModState].scrollClickMacro or "")
    DiscoHealerOptionsPanel.panel.spellSelect.box5:SetCursorPosition(0)
    DiscoHealerOptionsPanel.panel.spellSelect.box6:SetText(DiscoHealerOptionsPanel.tempSettings.keybinds[keybindModState].mwUpMacro or "")
    DiscoHealerOptionsPanel.panel.spellSelect.box6:SetCursorPosition(0)
    DiscoHealerOptionsPanel.panel.spellSelect.box7:SetText(DiscoHealerOptionsPanel.tempSettings.keybinds[keybindModState].mwDownMacro or "")
    DiscoHealerOptionsPanel.panel.spellSelect.box7:SetCursorPosition(0)

    if DiscoHealerOptionsPanel.panel.spellSelect.box1:GetText() == "target" then DiscoHealerOptionsPanel.panel.spellSelect.box1:Hide(); else DiscoHealerOptionsPanel.panel.spellSelect.box1:Show(); end;
    if DiscoHealerOptionsPanel.tempSettings.keybinds[keybindModState].leftMacro == "target" then
        UIDropDownMenu_SetText(DiscoHealerOptionsPanel.panel.spellSelect.box1Selector, "Target")
    else
        UIDropDownMenu_SetText(DiscoHealerOptionsPanel.panel.spellSelect.box1Selector, "Spell")
    end

    if DiscoHealerOptionsPanel.panel.spellSelect.box2:GetText() == "target" then DiscoHealerOptionsPanel.panel.spellSelect.box2:Hide(); else DiscoHealerOptionsPanel.panel.spellSelect.box2:Show(); end;
    if DiscoHealerOptionsPanel.tempSettings.keybinds[keybindModState].rightMacro == "target" then
        UIDropDownMenu_SetText(DiscoHealerOptionsPanel.panel.spellSelect.box2Selector, "Target")
    else
        UIDropDownMenu_SetText(DiscoHealerOptionsPanel.panel.spellSelect.box2Selector, "Spell")
    end

    if DiscoHealerOptionsPanel.panel.spellSelect.box3:GetText() == "target" then DiscoHealerOptionsPanel.panel.spellSelect.box3:Hide(); else DiscoHealerOptionsPanel.panel.spellSelect.box3:Show(); end;
    if DiscoHealerOptionsPanel.tempSettings.keybinds[keybindModState].mb4Macro == "target" then
        UIDropDownMenu_SetText(DiscoHealerOptionsPanel.panel.spellSelect.box3Selector, "Target")
    else
        UIDropDownMenu_SetText(DiscoHealerOptionsPanel.panel.spellSelect.box3Selector, "Spell")
    end
    
    if DiscoHealerOptionsPanel.panel.spellSelect.box4:GetText() == "target" then DiscoHealerOptionsPanel.panel.spellSelect.box4:Hide(); else DiscoHealerOptionsPanel.panel.spellSelect.box4:Show(); end;
    if DiscoHealerOptionsPanel.tempSettings.keybinds[keybindModState].mb5Macro == "target" then
        UIDropDownMenu_SetText(DiscoHealerOptionsPanel.panel.spellSelect.box4Selector, "Target")
    else
        UIDropDownMenu_SetText(DiscoHealerOptionsPanel.panel.spellSelect.box4Selector, "Spell")
    end

    if DiscoHealerOptionsPanel.panel.spellSelect.box5:GetText() == "target" then DiscoHealerOptionsPanel.panel.spellSelect.box5:Hide(); else DiscoHealerOptionsPanel.panel.spellSelect.box5:Show(); end;
    if DiscoHealerOptionsPanel.tempSettings.keybinds[keybindModState].scrollClickMacro == "target" then
        UIDropDownMenu_SetText(DiscoHealerOptionsPanel.panel.spellSelect.box5Selector, "Target")
    else
        UIDropDownMenu_SetText(DiscoHealerOptionsPanel.panel.spellSelect.box5Selector, "Spell")
    end

    if DiscoHealerOptionsPanel.panel.spellSelect.box6:GetText() == "target" then DiscoHealerOptionsPanel.panel.spellSelect.box6:Hide(); else DiscoHealerOptionsPanel.panel.spellSelect.box6:Show(); end;
    if DiscoHealerOptionsPanel.tempSettings.keybinds[keybindModState].mwUpMacro == "target" then
        UIDropDownMenu_SetText(DiscoHealerOptionsPanel.panel.spellSelect.box6Selector, "Target")
    else
        UIDropDownMenu_SetText(DiscoHealerOptionsPanel.panel.spellSelect.box6Selector, "Spell")
    end

    if DiscoHealerOptionsPanel.panel.spellSelect.box7:GetText() == "target" then DiscoHealerOptionsPanel.panel.spellSelect.box7:Hide(); else DiscoHealerOptionsPanel.panel.spellSelect.box7:Show(); end;
    if DiscoHealerOptionsPanel.tempSettings.keybinds[keybindModState].mwDownMacro == "target" then
        UIDropDownMenu_SetText(DiscoHealerOptionsPanel.panel.spellSelect.box7Selector, "Target")
    else
        UIDropDownMenu_SetText(DiscoHealerOptionsPanel.panel.spellSelect.box7Selector, "Spell")
    end
end
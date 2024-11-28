local addonName, discoVars = ...
local LibCLHealth = LibStub("LibCombatLogHealth-1.0")

-- Cache commonly used functions
local UnitGUID = UnitGUID;
local UnitName = UnitName;
local UnitInRange = UnitInRange;
local GetRaidRosterInfo = GetRaidRosterInfo;
-- Override UnitGUID function
local DISCO_UnitGUID = function(unitID)
    local guid = UnitGUID(unitID)
    if not guid then return; end
    local unitType, _, _, _, _, _, spawnUID = strsplit("-", guid)
    if unitType == "Pet" then
        return string.sub(spawnUID, 3)
    end
    return guid
end

-- Initialize the main DiscoHealer frame
function generateMainDiscoFrame(mainFrame)
    local fs = DiscoSettings.frameSize
    mainFrame:SetSize(500*fs, 130*fs)
    mainFrame:SetMovable(true)
    mainFrame:EnableMouse(true)
    mainFrame:RegisterForDrag("LeftButton")
    --mainFrame:SetPoint("CENTER", UIParent, "CENTER")
    mainFrame:SetScript("OnDragStart", function()
        if not DiscoSettings.locked then
            mainFrame:StartMoving()
        end
    end)
    mainFrame:SetScript("OnDragStop", mainFrame.StopMovingOrSizing)
    if not mainFrame.texture then mainFrame.texture = mainFrame:CreateTexture(nil, "BACKGROUND"); end
    mainFrame.texture:SetAllPoints(mainFrame)
    mainFrame.texture:SetColorTexture(0.3,0.3,0.3)
    mainFrame.texture:SetAlpha(0.3)

    -- Handle Bar
    if not mainFrame.handleBar then mainFrame.handleBar = CreateFrame("FRAME", "DiscoHandleBar", mainFrame); end
    mainFrame.handleBar:SetSize(15*fs, 55*fs)
    mainFrame.handleBar:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", 15*fs, 0*fs)

    mainFrame.handleBar:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" and not mainFrame.isMoving and not DiscoSettings.locked then
            mainFrame:StartMoving();
            mainFrame.isMoving = true;
        end
      end)
    mainFrame.handleBar:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" and mainFrame.isMoving then
            mainFrame:StopMovingOrSizing();
            mainFrame.isMoving = false;
        end
        end)

    if not mainFrame.handleBar.texture then mainFrame.handleBar.texture = mainFrame.handleBar:CreateTexture(nil, "BORDER"); end
    mainFrame.handleBar.texture:SetAllPoints(mainFrame.handleBar)
    mainFrame.handleBar.texture:SetColorTexture(0.2,0.2,0.2)
    mainFrame.handleBar.texture:SetAlpha(0.3)

    -- Disco Settings Button
    if not mainFrame.handleBar.textDFrame then mainFrame.handleBar.textDFrame = CreateFrame("FRAME", "DiscoHandleBarTextDFrame", mainFrame.handleBar); end
    mainFrame.handleBar.textDFrame:SetPoint("CENTER", mainFrame.handleBar, "TOP", 0, -38*fs)
    mainFrame.handleBar.textDFrame:SetSize(15*fs, 15*fs)
    if not mainFrame.handleBar.textDFrame.text then mainFrame.handleBar.textDFrame.text = mainFrame.handleBar.textDFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal"); end
    mainFrame.handleBar.textDFrame.text:SetPoint("CENTER", mainFrame.handleBar.textDFrame, "CENTER", 0, 0)
    mainFrame.handleBar.textDFrame.text:SetText("D")
    mainFrame.handleBar.textDFrame.text:SetTextColor(0.9, 0.9, 0.9)
    mainFrame.handleBar.textDFrame.text:SetAlpha(0.3)
    mainFrame.handleBar.textDFrame:SetScript("OnEnter", function(self, button)
        --self.text:SetTextColor(1, 1, 1)
        self.text:SetAlpha(1)
      end)
    mainFrame.handleBar.textDFrame:SetScript("OnLeave", function(self, button)
        --self.text:SetTextColor(0.4, 0.4, 0.4)
        self.text:SetAlpha(0.3)
    end)
    mainFrame.handleBar.textDFrame:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" then
            Settings.OpenToCategory("DiscoHealer") -- Replace with your registered category name
        end
    end)
    
    

    -- Disco Minimize Button
    local discoMinimizeAlpha = 0.3
    if not mainFrame.handleBar.textMinFrame then mainFrame.handleBar.textMinFrame = CreateFrame("FRAME", "DiscoHandleBarTextDFrame", mainFrame.handleBar); end
    mainFrame.handleBar.textMinFrame:SetPoint("CENTER", mainFrame.handleBar, "TOP", 0, -48*fs)
    mainFrame.handleBar.textMinFrame:SetSize(15*fs, 15*fs)
    if not mainFrame.handleBar.textMinFrame.text then mainFrame.handleBar.textMinFrame.text = mainFrame.handleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal"); end
    mainFrame.handleBar.textMinFrame.text:SetPoint("CENTER", mainFrame.handleBar.textMinFrame, "CENTER", 0, 0)
    mainFrame.handleBar.textMinFrame.text:SetTextColor(0.8, 0.8, 0.8)
    if DiscoSettings.minimized then
        mainFrame.handleBar.textMinFrame.text:SetText("+")
        discoMinimizeAlpha = 1
    else
        mainFrame.handleBar.textMinFrame.text:SetText("-")
        discoMinimizeAlpha = 0.3
    end
    mainFrame.handleBar.textMinFrame.text:SetAlpha(discoMinimizeAlpha)
    mainFrame.handleBar.textMinFrame:SetScript("OnEnter", function(self, button)
        self.text:SetAlpha(1)
      end)
    mainFrame.handleBar.textMinFrame:SetScript("OnLeave", function(self, button)
        self.text:SetAlpha(discoMinimizeAlpha)
    end)
    mainFrame.handleBar.textMinFrame:SetScript("OnMouseUp", function(self, button)
        if not InCombatLockdown() then
            DiscoSettings.minimized = not DiscoSettings.minimized
            if DiscoSettings.minimized then
                mainFrame.handleBar.textMinFrame.text:SetText("+")
                discoMinimizeAlpha = 1
                minimizeFrames(discoVars.discoMainFrame, discoVars.discoSubframes, discoVars.discoOverlaySubframes)
            else
                mainFrame.handleBar.textMinFrame.text:SetText("-")
                discoMinimizeAlpha = 0.3
                recreateAllSubFrames(discoVars.discoSubframes, discoVars.discoOverlaySubframes, discoVars.discoMainFrame, discoVars.allPartyMembers)
            end
        end
            end)

    -- Disco Move Button
    if not mainFrame.handleBar.moveTextureFrame then mainFrame.handleBar.moveTextureFrame = CreateFrame("FRAME", "DiscoHandleBarMoveFrame", mainFrame.handleBar); end
    mainFrame.handleBar.moveTextureFrame:SetPoint("CENTER", mainFrame.handleBar, "TOP", 0, -10*fs)
    mainFrame.handleBar.moveTextureFrame:SetSize(15*fs, 15*fs)
    mainFrame.handleBar.moveTextureFrame:SetAlpha(0.7)
    if not mainFrame.handleBar.moveTextureFrame.texture then mainFrame.handleBar.moveTextureFrame.texture = mainFrame.handleBar.moveTextureFrame:CreateTexture(nil, "BORDER"); end
    mainFrame.handleBar.moveTextureFrame.texture:SetTexture("Interface/AddOns/DiscoHealer/assets/move")
    mainFrame.handleBar.moveTextureFrame.texture:SetSize(12*fs, 12*fs)
    mainFrame.handleBar.moveTextureFrame.texture:SetPoint("CENTER", mainFrame.handleBar.moveTextureFrame, "CENTER", 0, 0)
    mainFrame.handleBar.moveTextureFrame:SetScript("OnEnter", function(self, button)
        self.texture:SetTexture("Interface/AddOns/DiscoHealer/assets/move_light")
      end)
    mainFrame.handleBar.moveTextureFrame:SetScript("OnLeave", function(self, button)
        self.texture:SetTexture("Interface/AddOns/DiscoHealer/assets/move")
        end)
    mainFrame.handleBar.moveTextureFrame:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" and not mainFrame.isMoving and not DiscoSettings.locked then
            mainFrame:StartMoving();
            mainFrame.isMoving = true;
        end
        end)
    mainFrame.handleBar.moveTextureFrame:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" and mainFrame.isMoving then
            mainFrame:StopMovingOrSizing();
            mainFrame.isMoving = false;
            mainFrame.handleBar.moveTextureFrame:SetPoint("CENTER", mainFrame.handleBar, "TOP", 0, -10*fs)
        end
        end)

    -- Disco Lock Button
    if not mainFrame.handleBar.lockTextureFrame then mainFrame.handleBar.lockTextureFrame = CreateFrame("FRAME", "DiscoHandleBarLockFrame", mainFrame.handleBar); end
    mainFrame.handleBar.lockTextureFrame:SetPoint("CENTER", mainFrame.handleBar, "TOP", 0, -25*fs)
    mainFrame.handleBar.lockTextureFrame:SetSize(15*fs, 15*fs)
    mainFrame.handleBar.lockTextureFrame:SetAlpha(0.2)
    if not mainFrame.handleBar.lockTextureFrame.texture then mainFrame.handleBar.lockTextureFrame.texture = mainFrame.handleBar.lockTextureFrame:CreateTexture(nil, "BORDER"); end
    if DiscoSettings.locked then
        mainFrame.handleBar.lockTextureFrame.texture:SetTexture("Interface/AddOns/DiscoHealer/assets/lock")
    else
        mainFrame.handleBar.lockTextureFrame.texture:SetTexture("Interface/AddOns/DiscoHealer/assets/unlock")
    end
    mainFrame.handleBar.lockTextureFrame.texture:SetSize(12*fs, 12*fs)
    mainFrame.handleBar.lockTextureFrame.texture:SetPoint("CENTER", mainFrame.handleBar.lockTextureFrame, "CENTER", 0, 0)
    mainFrame.handleBar.lockTextureFrame:SetScript("OnEnter", function(self, button)
        self:SetAlpha(0.7)
        end)
    mainFrame.handleBar.lockTextureFrame:SetScript("OnLeave", function(self, button)
        self:SetAlpha(0.2)
        end)
    mainFrame.handleBar.lockTextureFrame:SetScript("OnMouseUp", function(self, button)
        if not InCombatLockdown() then
            DiscoSettings.locked = not DiscoSettings.locked
            if DiscoSettings.locked then
                mainFrame.handleBar.lockTextureFrame.texture:SetTexture("Interface/AddOns/DiscoHealer/assets/lock")
            else
                mainFrame.handleBar.lockTextureFrame.texture:SetTexture("Interface/AddOns/DiscoHealer/assets/unlock")
            end
        end
            end)
    
end


-- Initialize subframes
function generateDiscoSubframes(subframes, overlayFrames, discoMainFrame)
    local fs = DiscoSettings.frameSize or 1
    local titlePadding = 0
    if DiscoSettings.arrangeByGroup == true then
        titlePadding = -15 * fs
    end

    local function createSubFrame(i, subframes, overlayFrames, frameType)
        local key = i
        if frameType == "large" then
            key = "large" .. i
        elseif frameType == "group" then
            key = "group" .. i
        end

        -- Generate subframes
        if not subframes[key] then subframes[key] = CreateFrame("FRAME", "DiscoRaidSubFrame" .. key, discoMainFrame); end

        if not subframes[key].leftClick then subframes[key].leftClick = CreateFrame("BUTTON", "DiscoRaidSubFrameLeftClick" .. key, subframes[key], "SecureUnitButtonTemplate,SecureHandlerEnterLeaveTemplate,SecureHandlerShowHideTemplate"); end
        subframes[key].leftClick:SetAllPoints(subframes[key])
        subframes[key].leftClick:RegisterForClicks("AnyDown")
        subframes[key].leftClick:EnableMouseWheel(1);
        --[[
        if not subframes[key].scrollWheel then subframes[key].scrollWheel = CreateFrame("BUTTON", "DiscoRaidSubFrameScrollWheel" .. key, subframes[key], "SecureUnitButtonTemplate,SecureHandlerEnterLeaveTemplate,SecureHandlerShowHideTemplate"); end
        subframes[key].scrollWheel:SetAllPoints(subframes[key])
        subframes[key].scrollWheel:EnableMouseWheel(1);
        ]]
        if not subframes[key].classTexture then subframes[key].classTexture = subframes[key]:CreateTexture(nil, "BACKGROUND"); end
        subframes[key].classTexture:SetAllPoints(subframes[key])
        subframes[key].classTexture:SetAlpha(0.7)

        if not subframes[key].texture then subframes[key].texture = subframes[key]:CreateTexture(nil, "BORDER"); end
        subframes[key].texture:SetPoint("CENTER", subframes[key], "CENTER", 0, 0)
        subframes[key].texture:SetColorTexture(1,1,1)
        subframes[key].texture:SetAlpha(1)

        if not subframes[key].healthBar then subframes[key].healthBar = CreateFrame("StatusBar", nil, subframes[key]); end
        subframes[key].healthBar:SetFrameStrata("MEDIUM")
        subframes[key].healthBar:SetFrameLevel(200)
        subframes[key].healthBar:SetPoint("CENTER", subframes[key], "CENTER", 0, 0)
        if not subframes[key].healthBar.texture then subframes[key].healthBar.texture = subframes[key].healthBar:CreateTexture(nil, "BACKGROUND"); end
        subframes[key].healthBar.texture:SetColorTexture(1,1,1)
        subframes[key].healthBar.texture:SetGradient("VERTICAL", CreateColor(0.45,0.45,0.45,1), CreateColor(0.65,0.65,0.65,1))
        subframes[key].healthBar:SetStatusBarTexture(subframes[key].healthBar.texture)

        if not subframes[key].healBar then subframes[key].healBar = CreateFrame("StatusBar", nil, subframes[key]); end
        subframes[key].healBar:SetFrameStrata("MEDIUM")
        subframes[key].healBar:SetFrameLevel(50)
        subframes[key].healBar:SetPoint("CENTER", subframes[key], "CENTER", 0, 0)
        if not subframes[key].healBar.texture then subframes[key].healBar.texture = subframes[key].healBar:CreateTexture(nil, "BACKGROUND"); end
        subframes[key].healBar.texture:SetColorTexture(0.2,0.6,1)
        subframes[key].healBar:SetStatusBarTexture(subframes[key].healBar.texture)

        if not subframes[key].playerHealBar then subframes[key].playerHealBar = CreateFrame("StatusBar", nil, subframes[key]); end
        subframes[key].playerHealBar:SetFrameStrata("MEDIUM")
        subframes[key].playerHealBar:SetFrameLevel(100)
        subframes[key].playerHealBar:SetPoint("CENTER", subframes[key], "CENTER", 0, 0)
        if not subframes[key].playerHealBar.texture then subframes[key].playerHealBar.texture = subframes[key].playerHealBar:CreateTexture(nil, "BACKGROUND"); end
        subframes[key].playerHealBar.texture:SetColorTexture(0,0.9,0.7)
        subframes[key].playerHealBar:SetStatusBarTexture(subframes[key].playerHealBar.texture)

        if not subframes[key].otherHealBar then subframes[key].otherHealBar = CreateFrame("StatusBar", nil, subframes[key]); end
        subframes[key].otherHealBar:SetFrameStrata("MEDIUM")
        subframes[key].otherHealBar:SetFrameLevel(150)
        subframes[key].otherHealBar:SetPoint("CENTER", subframes[key], "CENTER", 0, 0)
        if not subframes[key].otherHealBar.texture then subframes[key].otherHealBar.texture = subframes[key].otherHealBar:CreateTexture(nil, "BACKGROUND"); end
        subframes[key].otherHealBar.texture:SetColorTexture(0.2,0.6,1)
        subframes[key].otherHealBar:SetStatusBarTexture(subframes[key].otherHealBar.texture)

        if not subframes[key].overhealBar then subframes[key].overhealBar = CreateFrame("StatusBar", nil, subframes[key]); end
        subframes[key].overhealBar:SetFrameStrata("MEDIUM")
        subframes[key].overhealBar:SetFrameLevel(250)
        subframes[key].overhealBar:SetPoint("CENTER", subframes[key], "BOTTOM", 0, 3*fs)

        if not subframes[key].overhealBar.texture then subframes[key].overhealBar.texture = subframes[key].overhealBar:CreateTexture(nil, "BACKGROUND"); end
        subframes[key].overhealBar.texture:SetColorTexture(1,1,1)
        subframes[key].overhealBar.texture:SetGradient("VERTICAL", CreateColor(0.65,0.65,0.65,1), CreateColor(1,1,1,1))
        subframes[key].overhealBar:SetStatusBarTexture(subframes[key].overhealBar.texture)

        if not subframes[key].textFrame then subframes[key].textFrame = CreateFrame("FRAME", "DiscoRaidTextSubFrame"..key, subframes[key]); end
        subframes[key].textFrame:SetFrameStrata("MEDIUM")
        subframes[key].textFrame:SetFrameLevel(400)
        if not subframes[key].text then subframes[key].text = subframes[key].textFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal"); end
        if not subframes[key].subtext then subframes[key].subtext = subframes[key].textFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall"); end
        if not subframes[key].healthText then subframes[key].healthText = subframes[key].textFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall"); end
        subframes[key].text:SetPoint("BOTTOM", subframes[key], "TOP", 0, -17*fs)
        subframes[key].subtext:SetPoint("BOTTOM", subframes[key], "TOP", 0, -23*fs)
        subframes[key].subtext:SetTextColor(0.8, 0.8, 0.8)
        subframes[key].healthText:SetFont((subframes[key].healthText:GetFont()), 7*math.sqrt(fs))
        subframes[key].healthText:SetPoint("BOTTOM", subframes[key], "TOP", 0, -22.5*fs)
        subframes[key].healthText:SetTextColor(1, 0.4, 0.4)
        if DiscoSettings.showHealthText then
            subframes[key].healthText:Show()
        else
            subframes[key].healthText:Hide()
        end

        generateDebuffFrames(overlayFrames[key], 5, "debuff")
        generateDebuffFrames(subframes[key], 3, "buff")
        generateTooltipFrames(discoMainFrame, 10)

        if frameType == "large" then
            subframes[key]:SetSize(100*fs, 25*fs)
            subframes[key]:SetPoint("TOPLEFT", discoMainFrame, "TOPLEFT", (i-1)%5*100*fs, math.floor((i-0.1)/5)*-25*fs-2*fs)

            subframes[key].texture:SetSize(97*fs, 22*fs)
            subframes[key].healthBar:SetSize(97*fs, 22*fs)
            subframes[key].healBar:SetSize(97*fs, 22*fs)
            subframes[key].playerHealBar:SetSize(97*fs, 22*fs)
            subframes[key].otherHealBar:SetSize(97*fs, 22*fs)
            subframes[key].overhealBar:SetSize(97*fs, 5*fs)

            subframes[key].defaultAlpha = 0.1
        elseif frameType == "group" then
                subframes[key]:SetSize(100*fs, 25*fs)
                subframes[key]:SetPoint("TOPLEFT", discoMainFrame, "TOPLEFT", 0, i*-25*fs-2*fs + titlePadding)
    
                subframes[key].texture:SetSize(97*fs, 22*fs)
                subframes[key].healthBar:SetSize(97*fs, 22*fs)
                subframes[key].healBar:SetSize(97*fs, 22*fs)
                subframes[key].playerHealBar:SetSize(97*fs, 22*fs)
                subframes[key].otherHealBar:SetSize(97*fs, 22*fs)
                subframes[key].overhealBar:SetSize(97*fs, 5*fs)
    
                subframes[key].defaultAlpha = 0.1
        else
            subframes[key]:SetSize(50*fs, 25*fs)
            subframes[key]:SetPoint("TOPLEFT", discoMainFrame, "TOPLEFT", (i-1)%10*50*fs, math.floor((i-0.1)/10)*-25*fs-28*fs + titlePadding)

            subframes[key].texture:SetSize(47*fs, 22*fs)
            subframes[key].healthBar:SetSize(47*fs, 22*fs)
            subframes[key].healBar:SetSize(47*fs, 22*fs)
            subframes[key].playerHealBar:SetSize(47*fs, 22*fs)
            subframes[key].otherHealBar:SetSize(47*fs, 22*fs)
            subframes[key].overhealBar:SetSize(47*fs, 5*fs)
            
            if not DiscoSettings.showNames then
                subframes[key].text:Hide()
            end

            subframes[key].defaultAlpha = 0.025
        end

        -- Frame alpha settings
        subframes[key].alpha = subframes[key].defaultAlpha
        subframes[key].overlayFrame = overlayFrames[key]
        subframes[key].SetHidden = function(self)
            --self:SetAlpha(self.alpha)
            self:SetSubframeAlpha(self.alpha)
        end
        subframes[key].SetSubframeAlpha = function(self, alpha)
            self:SetAlpha(alpha)
            if alpha > 0.5 then
                self.overlayFrame.nameText:SetAlpha(1)
            elseif subframes[key].inRange then
                self.overlayFrame.nameText:SetAlpha(0.5)
            else
                self.overlayFrame.nameText:SetAlpha(0.15)
            end
        end
    end

    -- Generate overlay for frame
    local function createSubFrameOverlay(i, subframes, frameType, discoSettings)
        local fs = DiscoSettings.frameSize or 1
        local key
        if frameType == "large" then
            key = "large" .. i
        elseif frameType == "group" then
            key = "group" .. i
        else
            key = i
        end
        if not subframes[key] then subframes[key] = CreateFrame("FRAME", "DiscoRaidSubFrameOverlay"..key, discoMainFrame); end
        subframes[key]:SetFrameStrata("HIGH")

        if not subframes[key].mouseOver then subframes[key].mouseOver = CreateFrame("FRAME", "DiscoOverlayMouseOver"..key, subframes[key]); end
        subframes[key].mouseOver:SetAllPoints(subframes[key])

        if not subframes[key].threatFrame then subframes[key].threatFrame = CreateFrame("FRAME", "DiscoThreatOverlay"..key, subframes[key]); end
        subframes[key].threatFrame:SetPoint("CENTER", subframes[key], "TOPLEFT", 7*fs, -7*fs)
        subframes[key].threatFrame:SetSize(12*fs, 12*fs)
        subframes[key].threatFrame:SetAlpha(0)

        if not subframes[key].textureH then subframes[key].textureH = subframes[key].threatFrame:CreateTexture(nil, "BACKGROUND"); end
        subframes[key].textureH:SetAllPoints(subframes[key].threatFrame)
        subframes[key].textureH:SetColorTexture(1,0.2,0.2)
        subframes[key].textureH:SetGradient("HORIZONTAL", CreateColor(1,0.2,0.2,0.5), CreateColor(1,0.2,0.2,0))

        if not subframes[key].textureV then subframes[key].textureV = subframes[key].threatFrame:CreateTexture(nil, "BACKGROUND"); end
        subframes[key].textureV:SetAllPoints(subframes[key].threatFrame)
        subframes[key].textureV:SetColorTexture(1,0.2,0.2)
        subframes[key].textureV:SetGradient("VERTICAL", CreateColor(1,0.2,0.2,0), CreateColor(1,0.2,0.2,0.5))

        if not subframes[key].bossThreatFrame then subframes[key].bossThreatFrame = CreateFrame("FRAME", "DiscoBossThreatOverlay"..key, subframes[key]); end
        subframes[key].bossThreatFrame:SetAllPoints(subframes[key].threatFrame)
        subframes[key].bossThreatFrame:SetAlpha(0)

        if not subframes[key].bossThreatTexture then subframes[key].bossThreatTexture = subframes[key].bossThreatFrame:CreateTexture(nil, "BACKGROUND"); end
        subframes[key].bossThreatTexture:SetAllPoints(subframes[key].bossThreatFrame)
        subframes[key].bossThreatTexture:SetTexture("Interface/AddOns/DiscoHealer/assets/skull.tga")

        if not subframes[key].targeted then subframes[key].targeted = CreateFrame("FRAME", nil, subframes[key]); end
        subframes[key].targeted:SetFrameStrata("HIGH")
        subframes[key].targeted:SetAllPoints(subframes[key])

        if not subframes[key].targetedL then subframes[key].targetedL = subframes[key].targeted:CreateLine(); end
        subframes[key].targetedL:SetColorTexture(0.9,0.9,0.9,1)
        subframes[key].targetedL:SetStartPoint("TOPLEFT",0,0)
        subframes[key].targetedL:SetEndPoint("BOTTOMLEFT",0,0)
        subframes[key].targetedL:SetThickness(1*fs)

        if not subframes[key].targetedD then subframes[key].targetedD = subframes[key].targeted:CreateLine(); end
        subframes[key].targetedD:SetColorTexture(0.9,0.9,0.9,1)
        subframes[key].targetedD:SetStartPoint("BOTTOMLEFT",0,0)
        subframes[key].targetedD:SetEndPoint("BOTTOMRIGHT",0,0)
        subframes[key].targetedD:SetThickness(1*fs)

        if not subframes[key].targetedR then subframes[key].targetedR = subframes[key].targeted:CreateLine(); end
        subframes[key].targetedR:SetColorTexture(0.9,0.9,0.9,1)
        subframes[key].targetedR:SetStartPoint("TOPRIGHT",0,0)
        subframes[key].targetedR:SetEndPoint("BOTTOMRIGHT",0,0)
        subframes[key].targetedR:SetThickness(1*fs)

        if not subframes[key].targetedU then subframes[key].targetedU = subframes[key].targeted:CreateLine(); end
        subframes[key].targetedU:SetColorTexture(0.9,0.9,0.9,1)
        subframes[key].targetedU:SetStartPoint("TOPLEFT",0,0)
        subframes[key].targetedU:SetEndPoint("TOPRIGHT",0,0)
        subframes[key].targetedU:SetThickness(1*fs)
        subframes[key].targeted:SetAlpha(0)

        if not subframes[key].resurrect then subframes[key].resurrect = subframes[key]:CreateTexture(nil, "BORDER"); end
        subframes[key].resurrect:SetTexture("Interface/AddOns/DiscoHealer/assets/ankh.tga")
        subframes[key].resurrect:SetSize(18*fs, 18*fs)
        subframes[key].resurrect:SetPoint("CENTER", subframes[key], "CENTER", 0, -2*fs)
        subframes[key].resurrect:SetAlpha(0)

        if not subframes[key].arrow then subframes[key].arrow = subframes[key]:CreateTexture(nil, "BORDER"); end
        subframes[key].arrow:SetTexture("Interface/AddOns/DiscoHealer/assets/arrow.tga")
        subframes[key].arrow:SetSize(22*fs, 22*fs)
        subframes[key].arrow:SetPoint("CENTER", subframes[key], "CENTER", 0, 0)
        subframes[key].arrow:SetAlpha(0)

        if not subframes[key].nameText then subframes[key].nameText = subframes[key]:CreateFontString(nil, "OVERLAY", "GameFontNormal"); end
        subframes[key].nameText:SetPoint("CENTER", subframes[key], "CENTER", 0, 0)
        subframes[key].nameText:SetFont((subframes[key].nameText:GetFont()), 10*math.sqrt(fs))

        if not subframes[key].mindControl then subframes[key].mindControl = subframes[key]:CreateFontString(nil, "OVERLAY", "GameFontNormal"); end
        subframes[key].mindControl:SetText("(MC)")
        --subframes[key].mindControl:SetTextColor(0.4, 0.4, 0.4)
        subframes[key].mindControl:SetPoint("CENTER", subframes[key], "CENTER", 0, 0)


        -- CastBar Animation
        if not subframes[key].castBarFrame then subframes[key].castBarFrame = CreateFrame("FRAME", "DiscoRaidCastBarSubFrame"..key, subframes[key]); end
        subframes[key].castBarFrame:SetFrameStrata("HIGH")
        subframes[key].castBarFrame:SetAllPoints(subframes[key])

        if not subframes[key].castBarFrame.castAnimationGroup then subframes[key].castBarFrame.castAnimationGroup = subframes[key].castBarFrame:CreateAnimationGroup(); end
        subframes[key].castBarFrame.castAnimationGroup:SetLooping("NONE")
        subframes[key].castBarFrame.castAnimationGroup:SetScript("OnPlay", function(self)
            self.castbar:SetAlpha(0.3)
        end)
        subframes[key].castBarFrame.castAnimationGroup:SetScript("OnStop", function(self)
            self.castbar:SetAlpha(0)
        end)
        subframes[key].castBarFrame.castAnimationGroup:SetScript("OnFinished", function(self)
            self.castbar:SetAlpha(0)
        end)

        if not subframes[key].castBarFrame.castAnimationGroup.castbar then subframes[key].castBarFrame.castAnimationGroup.castbar = subframes[key].castBarFrame:CreateTexture(nil, "OVERLAY"); end
        subframes[key].castBarFrame.castAnimationGroup.castbar:SetPoint("CENTER", subframes[key].castBarFrame, "LEFT", 0, 0)
        subframes[key].castBarFrame.castAnimationGroup.castbar:SetSize(1*fs, 25*fs)
        subframes[key].castBarFrame.castAnimationGroup.castbar:SetColorTexture(0.9, 0.9, 0.9)
        subframes[key].castBarFrame.castAnimationGroup.castbar:SetAlpha(0)

        if not subframes[key].castBarFrame.castAnimation then subframes[key].castBarFrame.castAnimation = subframes[key].castBarFrame.castAnimationGroup:CreateAnimation("SCALE"); end
        subframes[key].castBarFrame.castAnimation:SetOrigin("LEFT",0,0)

        if frameType == "large" then
            subframes[key]:SetSize(100*fs, 25*fs)
            subframes[key]:SetPoint("TOPLEFT", discoMainFrame, "TOPLEFT", (i-1)%5*100*fs, math.floor((i-0.1)/5)*-25*fs-2*fs)
            subframes[key].targeted:SetSize(100*fs, 3.5*fs)
            subframes[key].threatAlphaMedium = 0.75
            subframes[key].threatAlphaHigh = 0.75
            subframes[key].castBarFrame.size = 100
        elseif frameType == "group" then
                subframes[key]:SetSize(100*fs, 25*fs)
                subframes[key]:SetPoint("TOPLEFT", discoMainFrame, "TOPLEFT", 0, i*-25*fs-2*fs + titlePadding)
                subframes[key].targeted:SetSize(100*fs, 3.5*fs)
                subframes[key].threatAlphaMedium = 0.75
                subframes[key].threatAlphaHigh = 0.75
                subframes[key].castBarFrame.size = 100
        else
            subframes[key]:SetSize(50*fs, 25*fs)
            subframes[key]:SetPoint("TOPLEFT", discoMainFrame, "TOPLEFT", (i-1)%10*50*fs, math.floor((i-0.1)/10)*-25*fs-25*fs-2*fs + titlePadding)
            subframes[key].targeted:SetSize(50*fs, 3.5*fs)
            subframes[key].castBarFrame.size = 50
        end

        subframes[key].target = function(self)
            self.targeted:SetAlpha(1)
        end
        subframes[key].untarget = function(self)
            self.targeted:SetAlpha(0)
        end

        subframes[key]:SetAlpha(1)
    end

    local function createLabels(discoMainFrame)
        if not discoMainFrame.groupLabels then discoMainFrame.groupLabels = CreateFrame("FRAME", "DiscoRaidSubFrameLabel", discoMainFrame); end
        discoMainFrame.groupLabels:SetAllPoints(discoMainFrame)
        discoMainFrame.groupLabels:SetFrameStrata("HIGH")

        for i=1, 10 do
            key = "label" .. i
            if not discoMainFrame.groupLabels[key] then discoMainFrame.groupLabels[key] = discoMainFrame.groupLabels:CreateFontString(nil, "OVERLAY", "GameFontNormal"); end
            discoMainFrame.groupLabels[key]:SetPoint("LEFT", discoMainFrame.groupLabels, "TOPLEFT", (i-1)*50*fs + 4*fs, -35*fs)
            discoMainFrame.groupLabels[key]:SetAlpha(1)
        end
    end

    -- Generate all large and regular subframes
    for i=1, 60 do
        createSubFrameOverlay(i, overlayFrames, nil)
        createSubFrame(i, subframes, overlayFrames, nil)
    end

    for i=1, 10 do
        createSubFrameOverlay(i, overlayFrames, "large")
        createSubFrame(i, subframes, overlayFrames, "large")
    end

    for i=1, 6 do
        createSubFrameOverlay(i, overlayFrames, "group")
        createSubFrame(i, subframes, overlayFrames, "group")
    end

    createLabels(discoMainFrame)
end

function generateDebuffFrames(subframe, n, type)
    local fs = DiscoSettings.frameSize
    for i=1, n do
        local key = "buff" .. i
        if type == "debuff" then key = "debuff" .. i; end

        if not subframe[key] then subframe[key] = CreateFrame("FRAME", nil, subframe); end
        if type == "debuff" then
            subframe[key]:SetPoint("CENTER", subframe, "BOTTOMRIGHT", (3 - i*9)*fs, 6*fs)
        else
            subframe[key]:SetPoint("CENTER", subframe, "TOPRIGHT", (3 - i*9)*fs, -6*fs)
        end

        subframe[key]:SetFrameStrata("MEDIUM")
        subframe[key]:SetFrameLevel(500)
        subframe[key]:SetSize(8*fs, 8*fs)
        --subframe[key]:SetAlpha(1)
        if not subframe[key].texture then subframe[key].texture = subframe[key]:CreateTexture(nil, "BORDER"); end
        subframe[key].texture:SetAllPoints(subframe[key])
        --subframe[key].texture:SetColorTexture(1,0,0)
        --subframe[key].texture:SetColorTexture(0,1,0);
        --subframe[key].texture:SetColorTexture(0,0,1);

    end
end

function generateTooltipFrames(mainframe, n)
    local fs = DiscoSettings.frameSize
    for i=1, n do
        local key = "toolTip" .. i
        if not mainframe[key] then mainframe[key] = CreateFrame("FRAME", nil, mainframe); end
        mainframe[key]:SetSize(300*fs, 20*fs)
        mainframe[key]:SetPoint("LEFT", mainframe, "TOPLEFT", 0, i*25 * fs)
        mainframe[key]:SetAlpha(0.5)
        mainframe[key]:Hide()

        if not mainframe[key].texture then mainframe[key].texture = mainframe[key]:CreateTexture(nil, "BORDER"); end
        mainframe[key].texture:SetAllPoints(mainframe[key])
        mainframe[key].texture:SetColorTexture(0.5,0.5,0.5)

        if not mainframe[key].icon then mainframe[key].icon = mainframe[key]:CreateTexture(nil, "BORDER"); end
        mainframe[key].icon:SetSize(16*fs, 16*fs)
        mainframe[key].icon:SetPoint("LEFT", mainframe[key], "LEFT", 2 * fs, 0)
        mainframe[key].icon:SetColorTexture(0,1,0)

        if not mainframe[key].text then mainframe[key].text = mainframe[key]:CreateFontString(nil, "OVERLAY", "GameFontNormal"); end
        mainframe[key].text:SetPoint("LEFT", mainframe[key], "LEFT", 22 * fs, 0)
    end
end

local function setSubframeValues(subframe, unitID, overlayFrame)
    local unitHealth = LibCLHealth.UnitHealth(unitID)
    local maxHealth = UnitHealthMax(unitID)
    local unitGUID = DISCO_UnitGUID(unitID)

    discoVars.playerMapping[unitGUID].unitHealth = unitHealth
    discoVars.playerMapping[unitGUID].maxHealth = maxHealth

    if discoVars.playerMapping[unitGUID].isMobTarget then
        overlayFrame.threatFrame:SetAlpha(0.75)
    else
        overlayFrame.threatFrame:SetAlpha(0)
    end
    if discoVars.playerMapping[unitGUID].isBossTarget then
        overlayFrame.bossThreatFrame:SetAlpha(0.75)
    else
        overlayFrame.bossThreatFrame:SetAlpha(0)
    end

    subframe.healthBar:SetMinMaxValues(0, maxHealth)
    subframe.healBar:SetMinMaxValues(0, maxHealth)
    subframe.playerHealBar:SetMinMaxValues(0, maxHealth)
    subframe.otherHealBar:SetMinMaxValues(0, maxHealth)
    subframe.overhealBar:SetMinMaxValues(0, maxHealth)
    subframe.overhealBar:SetValue(0)

    subframe.healthText:SetText(maxHealth - unitHealth)
end

function DISCO_displayToolTips(unitThreatList)
    local fs = DiscoSettings.frameSize
    local i = 1
    if discoVars.mouseOverTarget then
        local playerInfo = discoVars.playerMapping[UnitGUID(discoVars.mouseOverTarget)]
        if playerInfo then
            -- Aggro
            if playerInfo.targetedBy then
                for k in pairs(playerInfo.targetedBy) do
                    if i < 11 then
                        local key = "toolTip" .. i
                        i = i + 1
                        if unitThreatList[k] and unitThreatList[k].isBoss then
                            discoVars.discoMainFrame[key].icon:SetTexture("Interface/AddOns/DiscoHealer/assets/skull.tga")
                        else
                            discoVars.discoMainFrame[key].icon:SetColorTexture(1,0.2,0.2)
                        end
                        discoVars.discoMainFrame[key].text:SetText("Aggro: " .. playerInfo.targetedBy[k])
                        local strLen = discoVars.discoMainFrame[key].text:GetStringWidth()
                        discoVars.discoMainFrame[key]:SetWidth(strLen + 30 * fs)
                        discoVars.discoMainFrame[key]:Show()
                    end
                end
            end
            -- Debuff
            if playerInfo.debuffs then
                for k in pairs(playerInfo.debuffs) do
                    if playerInfo.debuffs[k] ~= "" and i < 11 then
                        local key = "toolTip" .. i
                        i = i + 1
                        discoVars.discoMainFrame[key].icon:SetTexture(k)
                        discoVars.discoMainFrame[key].text:SetText(playerInfo.debuffs[k])
                        local strLen = discoVars.discoMainFrame[key].text:GetStringWidth()
                        discoVars.discoMainFrame[key]:SetWidth(strLen + 30 * fs)
                        discoVars.discoMainFrame[key]:Show()
                    end
                end
            end
        end
    end
    for i=i, 10 do
        local key = "toolTip" .. i
        discoVars.discoMainFrame[key]:Hide()
    end
end

--[[
local function hideToolTips()
    for i=1, 10 do
        local key = "toolTip" .. i
        discoVars.discoMainFrame[key]:Hide()
    end
end
]]

-- Redraw all the subframes when the party changes
function recreateAllSubFrames(subframes, overlayFrames, mainframe, allPartyMembers, playerTarget)
    local fs = DiscoSettings.frameSize

    local partySize = GetNumGroupMembers()
    discoVars.playerMapping = {[UnitGUID("player")]={
        key="large1", 
        unitName=UnitName("player"), 
        isPlayer = true, 
        targetedBy = {},
        unitIDs={player=""}}
    }
    overlayFrames["large1"].nameText:SetText(UnitName("player"))
    -- Create player mapping
    local j,k= 2,1
    local pets = {}

    local playerIndex = UnitInRaid("player")
    local playerGroup
    if playerIndex then
        playerGroup = (select(3, GetRaidRosterInfo(playerIndex)))
    end
    local groupKeys = {}
    local nextPlayerGroupKey = 1
    local nextGroupKey = 1
    local allPartyMembersSorted = {}

    -- Sort all party members by group
    for i=1, 8 do
        for j=1, #allPartyMembers do
            local unitID = allPartyMembers[j]
            local unitIndex = UnitInRaid(unitID)
            local unitGroup
            if unitIndex then
                unitGroup = (select(3, GetRaidRosterInfo(unitIndex)))
            end
            if unitGroup == i then
                allPartyMembersSorted[#allPartyMembersSorted + 1] = unitID
            end
        end
    end
    for i=1, #allPartyMembers do
        local unitID = allPartyMembers[i]
        local unitIndex = UnitInRaid(unitID)
        if not unitIndex then
            allPartyMembersSorted[#allPartyMembersSorted + 1] = unitID
        end
    end

    -- Find all main tanks
    for _, key in pairs(allPartyMembers) do
        if not string.find(key, "pet") then
            local framekey
            --local index = string.match (key, "%d+")
            local unitIndex = UnitInRaid(key)
            local isRaidMember = string.find(key, "raid")==1
            local isTank = unitIndex and isRaidMember and ((select(10, GetRaidRosterInfo(unitIndex))) == "MAINTANK")

            if partySize < 6 or (isTank and j < 11) then
                if discoVars.playerMapping[DISCO_UnitGUID(key)] then
                    discoVars.playerMapping[DISCO_UnitGUID(key)].unitIDs[key] = ""
                elseif isTank or partySize < 6 then
                    frameKey = "large" .. j
                    j=j+1
                    --subframes[frameKey].text:SetText(UnitName(key))
                    overlayFrames[frameKey].nameText:SetText(UnitName(key))
                    discoVars.playerMapping[DISCO_UnitGUID(key)] = {
                        key=frameKey, 
                        unitName=UnitName(key), 
                        targetedBy={},
                        unitIDs={[key]=""}, 
                        isPriority=isTank,
                    }
                end
                --[[
                    frameKey = "group" .. nextPlayerGroupKey
                    nextPlayerGroupKey = nextPlayerGroupKey + 1
                    subframes[frameKey].text:SetText(UnitName(key))
                    discoVars.playerMapping[DISCO_UnitGUID(key)] = {
                        key=frameKey, 
                        unitName=UnitName(key), 
                        unitIDs={[key]=""}, 
                        isPriority=true,
                    }
                end
                ]]
            end
        end
    end

    -- Two rows of tanks
    if j > 6 then 
        k = 11
        subframes["group1"]:Hide()
        overlayFrames["group1"]:Hide()
        nextPlayerGroupKey = 2
        nextGroupKey = 11
        for i=1, 10 do
            key = "label" .. i
            mainframe.groupLabels[key]:SetPoint("LEFT", mainframe.groupLabels, "TOPLEFT", (i-1)*50*fs + 4*fs, -60*fs)
        end
    else
        for i=1, 10 do
            key = "label" .. i
            mainframe.groupLabels[key]:SetPoint("LEFT", mainframe.groupLabels, "TOPLEFT", (i-1)*50*fs + 4*fs, -35*fs)
        end
    end

    if playerGroup and partySize > 5 then
        mainframe.groupLabels.label1:SetText("Grp " .. playerGroup)
        mainframe.groupLabels.label1:Show()
        groupKeys[playerGroup] = nextGroupKey
        nextGroupKey = nextGroupKey + 1
    end

    -- Find priority group members
    if DiscoSettings.prioritizeGroup and DiscoSettings.arrangeByGroup then
        for _, key in pairs(allPartyMembers) do
            if not string.find(key, "pet") then
                local framekey
                --local index = string.match (key, "%d+")
                local unitIndex = UnitInRaid(key)
                local isRaidMember = string.find(key, "raid")==1
                local isTank = unitIndex and isRaidMember and ((select(10, GetRaidRosterInfo(unitIndex))) == "MAINTANK")
                local unitGroup
                if unitIndex then
                    unitGroup = (select(3, GetRaidRosterInfo(unitIndex)))
                end

                if partySize > 6 and not isTank and (DiscoSettings.prioritizeGroup and DiscoSettings.arrangeByGroup and unitGroup == playerGroup) then
                    if discoVars.playerMapping[DISCO_UnitGUID(key)] then
                        discoVars.playerMapping[DISCO_UnitGUID(key)].unitIDs[key] = ""
                    else
                        frameKey = "group" .. nextPlayerGroupKey
                        nextPlayerGroupKey = nextPlayerGroupKey + 1
                        --subframes[frameKey].text:SetText(UnitName(key))
                        overlayFrames[frameKey].nameText:SetText(UnitName(key))
                        discoVars.playerMapping[DISCO_UnitGUID(key)] = {
                            key=frameKey, 
                            unitName=UnitName(key), 
                            targetedBy={},
                            unitIDs={[key]=""}, 
                            isPriority=true,
                        }
                    end
                end
            end
        end
    end

    -- Skip a label
    if (j > 6 and nextPlayerGroupKey > 2) or (j <= 6 and nextPlayerGroupKey > 1) then
        local labelKey = "label" .. nextGroupKey%10
        if labelKey == "label0" then labelKey = "label10"; end
        discoVars.discoMainFrame.groupLabels[labelKey]:Hide()
        nextGroupKey = nextGroupKey + 1
    end

    -- Find all regular party members
    for _, key in pairs(allPartyMembersSorted) do
        if not string.find(key, "pet") then
            local unitIndex = UnitInRaid(key)
            local unitGroup
            if unitIndex then
                unitGroup = (select(3, GetRaidRosterInfo(unitIndex)))
            end
            if discoVars.playerMapping[DISCO_UnitGUID(key)] then
                discoVars.playerMapping[DISCO_UnitGUID(key)].unitIDs[key] = ""
            else
                local frameKey = k
                if DiscoSettings.arrangeByGroup and unitGroup then
                    if groupKeys[unitGroup] then
                        frameKey = groupKeys[unitGroup]
                        groupKeys[unitGroup] = groupKeys[unitGroup] + 10
                    else
                        frameKey = nextGroupKey
                        groupKeys[unitGroup] = nextGroupKey + 10
                        local labelKey = "label" .. nextGroupKey%10
                        nextGroupKey = nextGroupKey + 1
                        discoVars.discoMainFrame.groupLabels[labelKey]:SetText("Grp " .. unitGroup)
                        discoVars.discoMainFrame.groupLabels[labelKey]:Show()
                    end
                    --end
                else
                    k=k+1
                end

                maxStrLength = DiscoSettings.frameSize * 5
                nameSubStr = string.sub(UnitName(key), 0, maxStrLength)
                --subframes[frameKey].text:SetText(nameSubStr)
                overlayFrames[frameKey].nameText:SetText(nameSubStr)
                discoVars.playerMapping[DISCO_UnitGUID(key)] = {
                    key=frameKey, 
                    unitName=UnitName(key), 
                    targetedBy = {},
                    unitIDs={[key]=""}, 
                    isPriority=(unitGroup == playerGroup and DiscoSettings.prioritizeGroup)
                }
            end
        else
            pets[#pets+1] = key
        end 
    end

    -- Find all Pets
    if DiscoSettings.showPets and #pets > 0 then
        local nextPetGroupKey = nextGroupKey
        local labelKey = "label" .. nextGroupKey%10
        if labelKey == "label0" then labelKey = "label10"; end
        nextGroupKey = nextGroupKey + 1
        groupKeys[9] = nextPetGroupKey
        discoVars.discoMainFrame.groupLabels[labelKey]:SetText("Pets")
        discoVars.discoMainFrame.groupLabels[labelKey]:Show()

        for _, key in pairs(pets) do
            if discoVars.playerMapping[DISCO_UnitGUID(key)] then
                discoVars.playerMapping[DISCO_UnitGUID(key)].unitIDs[key] = ""
            else
                local petName = UnitName(key)
                if petName and k < 61 and nextPetGroupKey < 61 then
                    local frameKey = k
                    if DiscoSettings.arrangeByGroup then
                        frameKey = nextPetGroupKey
                        nextPetGroupKey = nextPetGroupKey + 10
                        groupKeys[9] = nextPetGroupKey
                    else
                        k=k+1
                    end
                    maxStrLength = DiscoSettings.frameSize * 5
                    nameSubStr = string.sub(petName, 0, maxStrLength)
                    overlayFrames[frameKey].nameText:SetText(nameSubStr)
                    discoVars.playerMapping[DISCO_UnitGUID(key)] = {
                        key=frameKey, 
                        unitName=UnitName(key), 
                        targetedBy = {},
                        unitIDs={[key]=""}
                    }
                end
            end
        end
    end

    -- Show/hide labels
    if DiscoSettings.arrangeByGroup and not DiscoSettings.minimized then
        mainframe.groupLabels:Show()
    else
        mainframe.groupLabels:Hide()
    end

    -- Untarget current playerTarget
    if subframes[playerTarget] then
        overlayFrames[playerTarget]:untarget()
    end

    -- Update frames for each unit in playerMapping
    for unitGuid, v in pairs(discoVars.playerMapping) do
        --[[
        if string.find(unitGuid, "Pet") then
            print("unitguid ", unitGuid)
        end
        ]]
        -- Subframes
        subframes[unitGuid] = subframes[v.key]
        subframes[v.unitName] = subframes[unitGuid]
        for unitID, _ in pairs(v.unitIDs) do
            subframes[unitID] = subframes[unitGuid]
            subframes[UnitGUID(unitID)] = subframes[v.key]
            local classFilename, classId = UnitClassBase(unitID)
            local classRGB = getClassColorRGB(classFilename)
            setSubframeValues(subframes[v.key], unitID, overlayFrames[v.key])
            subframes[v.key].classTexture:SetColorTexture(classRGB.r, classRGB.g, classRGB.b)
            local alpha = overlayFrames[v.key].nameText:GetAlpha()
            overlayFrames[v.key].nameText:SetTextColor(classRGB.r, classRGB.g, classRGB.b, alpha)
            -- Set Attributes
            -- Click
            subframes[v.key].leftClick:SetAttribute("unit", unitID)
            subframes[v.key].leftClick:SetAttribute("type", "macro")
            local macroText = generateMacroText(unitID)
            subframes[v.key].leftClick:SetAttribute("macrotext", macroText)

            -- Scroll Wheel
            --local mouseWheelStr = "self:ClearBindings();\nself:SetBindingClick(0, \"MOUSEWHEELUP\", self:GetName(), \"mw1\");\nself:SetBindingClick(0, \"MOUSEWHEELDOWN\", self:GetName(), \"mw2\");"
            mouseWheelStr, mwMacroStrings = createMWStr(unitID)
            subframes[v.key].leftClick:SetAttribute("_onenter", mouseWheelStr);
            subframes[v.key].leftClick:SetAttribute("_onleave", "self:ClearBindings();");
            subframes[v.key].leftClick:SetAttribute("_onshow", "self:ClearBindings();");
            subframes[v.key].leftClick:SetAttribute("_onhide", "self:ClearBindings();");
            subframes[v.key].leftClick:SetAttribute(
                "_onmousedown", 
                "if not self:IsUnderMouse(false) then self:ClearBindings(); end"
            );

            for i=1, #mwMacroStrings do
                local ts = "type-mw" .. i
                local mts = "macrotext-mw" .. i
                subframes[v.key].leftClick:SetAttribute(ts, "macro");
                subframes[v.key].leftClick:SetAttribute(mts, mwMacroStrings[i]);
            end
            --[[
            mwMacroUpText = generateMacroText(unitID, 1)
            mwMacroDownText = generateMacroText(unitID, 2)
            subframes[v.key].leftClick:SetAttribute("type-mw1", "macro");
            subframes[v.key].leftClick:SetAttribute("macrotext-mw1", mwMacroUpText);
            subframes[v.key].leftClick:SetAttribute("type-mw2", "macro");
            subframes[v.key].leftClick:SetAttribute("macrotext-mw2", mwMacroDownText);
            ]]

            -- Mouse Over for Tooltips and Arrow
            subframes[v.key].leftClick.unitID = unitID
            if not subframes[v.key].leftClick.hooked then
                subframes[v.key].leftClick:HookScript("OnEnter", function(self) 
                    discoVars.mouseOverTarget = self.unitID;
                end)
                subframes[v.key].leftClick:HookScript("OnLeave", function(self) 
                    discoVars.mouseOverTarget = nil; 
                    overlayFrames[v.key].arrow:SetAlpha(0);
                end)
                subframes[v.key].leftClick.hooked = true
            end
        end
        if not DiscoSettings.minimized then
            subframes[v.key]:Show()
        end
        -- OverlayFrames
        overlayFrames[unitGuid] = overlayFrames[v.key]
        overlayFrames[v.unitName] = overlayFrames[unitGuid]
        for unitID, _ in pairs(v.unitIDs) do
            overlayFrames[unitID] = overlayFrames[unitGuid]
            overlayFrames[UnitGUID(unitID)] = overlayFrames[v.key]
        end
        if not DiscoSettings.minimized then
            overlayFrames[v.key]:Show()
        end
    end

    -- Hide unused subframes
    if DiscoSettings.arrangeByGroup then
        local groupSlotsUsed = {}
        for i=1, 10 do
            if groupKeys[i] then
                local groupSlot = groupKeys[i]%10
                if groupSlot == 0 then
                    groupSlot = 10
                end
                groupSlotsUsed[groupSlot] = groupKeys[i]
            end
        end
        for i=1, 10 do
            local j = groupSlotsUsed[i] or i
            while j < 61 do
                subframes[j]:Hide()
                overlayFrames[j]:Hide()
                j = j+10
            end
            i = i+1
        end
    else
        -- Hide unused subframes
        for i=k, 60 do
            subframes[i]:Hide()
            overlayFrames[i]:Hide()
        end
    end
    -- Hide all unused group prio frames
    for i=nextPlayerGroupKey, 6 do
        local pGroupKey = "group" .. i
        subframes[pGroupKey]:Hide()
        overlayFrames[pGroupKey]:Hide()
    end
    -- Hide first row of subframes
    if j > 6 then
        for i=1, 10 do
            subframes[i]:Hide()
            overlayFrames[i]:Hide()
        end
    end
    
    -- Hide unused labels
    if nextGroupKey < 11 then
        local i = nextGroupKey%10
        if i == 0 then i = 10; end
        for i=i, 10 do
            local labelKey = "label" .. i
            discoVars.discoMainFrame.groupLabels[labelKey]:Hide()
        end
    end
    -- Hide unused large frames
    for i=j, 10 do
        subframes["large" .. i]:Hide()
        overlayFrames["large" .. i]:Hide()
    end

    -- retarget current target
    if subframes[playerTarget] then
        overlayFrames[playerTarget]:target()
    end

    resizeMainFrame(k, j, mainframe, groupKeys, nextPlayerGroupKey)
end

-- Generate mousewheel string
function createMWStr(targetID)
    local targetName = (UnitName(targetID)) or targetID
    local mwMacros = {}
    if string.find(targetID, "pet") then
        targetName = targetID
    end

    local mwString = "self:ClearBindings();\n"
    local mwIndex = 1

    for mods, allSpells in pairs(DiscoSettings.keybinds) do
        local mwModString
        for word in string.gmatch(mods, '([^,]+)') do
            if not mwModString then
                mwModString = ""
            else
                mwModString = mwModString .. word .. "-"
            end
        end

        for action, spell in pairs(allSpells) do
            if spell ~= "" then
                if action == "mwUpMacro" then
                    if spell == "target" then
                        mwMacros[mwIndex] = "/target [@" .. targetName .. "];\n"
                    else
                        mwMacros[mwIndex] = "/cast [@" .. targetName .. ",help,exists,nodead] " .. spell .. ";\n"
                    end
                    mwString = mwString .. "self:SetBindingClick(0, \"" .. mwModString .. "MOUSEWHEELUP\", self:GetName(), \"mw" .. mwIndex .. "\");\n"
                    mwIndex = mwIndex + 1
                elseif action == "mwDownMacro" then
                    if spell == "target" then
                        mwMacros[mwIndex] = "/target [@" .. targetName .. "];\n"
                    else
                        mwMacros[mwIndex] = "/cast [@" .. targetName .. ",help,exists,nodead] " .. spell .. ";\n"
                    end
                    mwString = mwString .. "self:SetBindingClick(0, \"" .. mwModString .. "MOUSEWHEELDOWN\", self:GetName(), \"mw" .. mwIndex .. "\");\n"
                    mwIndex = mwIndex + 1
                end
            end
        end
    end

    return mwString, mwMacros
end

-- New macrotext function
function generateMacroText(targetID, mw)
    local actionToBtnMap = {
        ["leftMacro"]="btn:1", ["rightMacro"]="btn:2", ["scrollClickMacro"]="btn:3", ["mb4Macro"]="btn:4", ["mb5Macro"]="btn:5"
    }

    local targetName = (UnitName(targetID)) or targetID
    if discoVars.useTargetUnitIDs then
        targetName = targetID
    end
    if string.find(targetID, "pet") then
        targetName = targetID
    end

    local macroText = "/script UIErrorsFrame:Hide();\n/console Sound_EnableErrorSpeech 0\n"
    local usedMods = {}

    for mods, _ in pairs(DiscoSettings.keybinds) do
        usedMods[#usedMods+1] = mods
    end

    table.sort(usedMods, function(a,b)
        if a == nil then
            return false
        elseif b == nil then
            return true
        end
        return #a > #b
    end)

    for i=1, #usedMods do
        local mods = usedMods[i]
        local allSpells = DiscoSettings.keybinds[mods]
        local modString = mods
        if mods ~= "nomodifier" then
            modString = strsub(mods, 12, #mods)
            modString = "modifier:" .. modString
        end
        modString = string.gsub(modString, ",", "")
        
        for action, spell in pairs(allSpells) do
            if spell ~= "" then
                if action ~= "mwUpMacro" and action ~= "mwDownMacro" then
                    local btn = actionToBtnMap[action]
                
                    if spell == "target" then
                        macroText = macroText .. "/target [@" .. targetName .. "," .. btn .. "," .. "," .. modString .. "];\n"
                    else
                        macroText = macroText .. "/cast [@" .. targetName .. ",help,exists,nodead," .. btn .. "," .. modString .. "] " .. spell .. ";\n"
                    end
                end
            end
        end
    end

    macroText = macroText .. "/console Sound_EnableErrorSpeech 1\n/script UIErrorsFrame:Clear();\n/script UIErrorsFrame:Show();"

    return macroText
end


-- Create Macro Text for frames
-- MW = 1 or 2 for mousewheel up/down macros
--[[
function generateMacroText(targetID, mw)
    local macroText = ""
    local targetName = (UnitName(targetID)) or targetID
    if string.find(targetID, "pet") then
        targetName = targetID
    end

    if mw and mw==1 then
        if DiscoSettings.mwUpMacro == "target" then
            macroText = macroText .. "/target [@" .. targetName .. "];"
        else
            macroText = macroText .. "/cast [@" .. targetName .. ",help,exists,nodead] " .. DiscoSettings.mwUpMacro .. ";"
        end
        return macroText
    elseif mw and mw==2 then
        if DiscoSettings.mwDownMacro == "target" then
            macroText = macroText .. "/target [@" .. targetName .. "];"
        else
            macroText = macroText .. "/cast [@" .. targetName .. ",help,exists,nodead] " .. DiscoSettings.mwDownMacro .. ";"
        end
        return macroText
    end

    if DiscoSettings.leftMacro == "target" then
        macroText = macroText .. "/target [@" .. targetName .. ",btn:1,nomodifier];\n"
    else
        macroText = macroText .. "/cast [@" .. targetName .. ",help,exists,nodead,btn:1,nomodifier] " .. DiscoSettings.leftMacro .. ";\n"
    end

    if DiscoSettings.rightMacro == "target" then
        macroText = macroText .. "/target [@" .. targetName .. ",btn:2,nomodifier];\n"
    else
        macroText = macroText .. "/cast [@" .. targetName .. ",help,exists,nodead,btn:2,nomodifier] " .. DiscoSettings.rightMacro .. ";\n"
    end

    if DiscoSettings.ctrlLMacro == "target" then
        macroText = macroText .. "/target [@" .. targetName .. ",btn:1,modifier:ctrl];\n"
    else
        macroText = macroText .. "/cast [@" .. targetName .. ",help,exists,nodead,btn:1,modifier:ctrl] " .. DiscoSettings.ctrlLMacro .. ";\n"
    end

    if DiscoSettings.ctrlRMacro == "target" then
        macroText = macroText .. "/target [@" .. targetName .. ",btn:2,modifier:ctrl];\n"
    else
        macroText = macroText .. "/cast [@" .. targetName .. ",help,exists,nodead,btn:2,modifier:ctrl] " .. DiscoSettings.ctrlRMacro .. ";\n"
    end

    if DiscoSettings.shiftLMacro == "target" then
        macroText = macroText .. "/target [@" .. targetName .. ",btn:1,modifier:shift];\n"
    else
        macroText = macroText .. "/cast [@" .. targetName .. ",help,exists,nodead,btn:1,modifier:shift] " .. DiscoSettings.shiftLMacro .. ";\n"
    end

    if DiscoSettings.shiftRMacro == "target" then
        macroText = macroText .. "/target [@" .. targetName .. ",btn:2,modifier:shift];\n"
    else
        macroText = macroText .. "/cast [@" .. targetName .. ",help,exists,nodead,btn:2,modifier:shift] " .. DiscoSettings.shiftRMacro .. ";\n"
    end

    if DiscoSettings.altLMacro == "target" then
        macroText = macroText .. "/target [@" .. targetName .. ",btn:1,modifier:alt];\n"
    else
        macroText = macroText .. "/cast [@" .. targetName .. ",help,exists,nodead,btn:1,modifier:alt] " .. DiscoSettings.altLMacro .. ";\n"
    end

    if DiscoSettings.altRMacro == "target" then
        macroText = macroText .. "/target [@" .. targetName .. ",btn:2,modifier:alt];\n"
    else
        macroText = macroText .. "/cast [@" .. targetName .. ",help,exists,nodead,btn:2,modifier:alt] " .. DiscoSettings.altRMacro .. ";\n"
    end
    
    if DiscoSettings.scrollClickMacro == "target" then
        macroText = macroText .. "/target [@" .. targetName .. ",btn:3,nomodifier];\n"
    else
        macroText = macroText .. "/cast [@" .. targetName .. ",help,exists,nodead,btn:3,nomodifier] " .. DiscoSettings.scrollClickMacro .. ";\n"
    end

    if DiscoSettings.mb4Macro == "target" then
        macroText = macroText .. "/target [@" .. targetName .. ",btn:4,nomodifier];\n"
    else
        macroText = macroText .. "/cast [@" .. targetName .. ",help,exists,nodead,btn:4,nomodifier] " .. DiscoSettings.mb4Macro .. ";\n"
    end

    if DiscoSettings.mb5Macro == "target" then
        macroText = macroText .. "/target [@" .. targetName .. ",btn:5,nomodifier];\n"
    else
        macroText = macroText .. "/cast [@" .. targetName .. ",help,exists,nodead,btn:5,nomodifier] " .. DiscoSettings.mb5Macro .. ";\n"
    end

    return macroText
end
]]

-- Called when minimize frames clicked
function minimizeFrames(mainframe, subframes, overlayFrames)
    local fs = DiscoSettings.frameSize

    for i=1, 60 do
        subframes[i]:Hide()
        overlayFrames[i]:Hide()
    end
    for i=2, 5 do
        subframes["large" .. i]:Hide()
        overlayFrames["large" .. i]:Hide()
    end
    for i=1, 6 do
        subframes["group" .. i]:Hide()
        overlayFrames["group" .. i]:Hide()
    end
    
    mainframe.groupLabels:Hide()
    mainframe:SetSize(100*fs, 28*fs)
end

-- Resize the main DiscoHealer frame
function resizeMainFrame(nextFrameSmall, nextFrameLarge, mainframe, groups, nextPlayerGroupKey)
    local fs = DiscoSettings.frameSize
    local subframeHeight = (math.ceil((nextFrameSmall-1)/10) * 26)
    local subframeWidth = math.min(500, 50*(nextFrameSmall-1))

    if DiscoSettings.arrangeByGroup == true then
        local maxHeight = 0
        local numGroups = 0
        for k,v in pairs(groups) do
            numGroups = numGroups + 1
            if v and v > maxHeight then
                maxHeight = v
            end
        end
        if maxHeight > 1 then
            maxHeight = maxHeight - 1
        end
        subframeHeight = ((math.floor(maxHeight/10)) * 26 + 15)
        subframeWidth = numGroups * 50

        -- Don't leave extra space if labels are hidden
        if math.floor(maxHeight/10) < 1 then
            subframeHeight = subframeHeight - 15
        end

        -- Add extra space if wide group prio frames are used
        if nextPlayerGroupKey > 1 then
            subframeWidth = subframeWidth + 50
        end
    end

    -- subframe k starts at second row
    if nextFrameLarge > 6 then
        subframeHeight = subframeHeight - 25
    end

    local frameWidth = math.max(math.min(100*(nextFrameLarge-1), 500), subframeWidth) * fs
    local frameHeight = (27 * math.ceil((nextFrameLarge-1)/5) + subframeHeight) * fs

    if DiscoSettings.minimized then
        mainframe:SetSize(100*fs, 28*fs)
    else
        mainframe:SetSize(frameWidth, frameHeight)
    end
end

function getClassColorRGB(className)
    if className == "DRUID" then
        return {r=1.00, g=0.49, b=0.04}
    elseif className == "HUNTER" then
        return {r=0.67, g=0.83, b=0.45}
    elseif className == "MAGE" then
        return {r=0.25, g=0.78, b=0.92}
    elseif className == "PALADIN" then
        return {r=0.96, g=0.55, b=0.73}
    elseif className == "PRIEST" then
        return {r=1.00, g=1.00, b=1.00}
    elseif className == "ROGUE" then
        return {r=1.00, g=0.96, b=0.41}
    elseif className == "SHAMAN" then
        return {r=0.00, g=0.44, b=0.87}
    elseif className == "WARLOCK" then
        return {r=0.53, g=0.53, b=0.93}
    elseif className == "WARRIOR" then
        return {r=0.78, g=0.61, b=0.43}
    else
        return {r=0.5, g=0.5, b=0.5}
    end
end

function getArrowCoords(direction)
    local l, r, u, d
    if direction == 1 then
        l, r, u, d = 0, 0.33, 0, 0.33
    elseif direction == 8 then
        l, r, u, d = 0.33, 0.66, 0.66, 1
    elseif direction == 7 then
        l, r, u, d = 0, 0.33, 0.66, 1
    elseif direction == 6 then
        l, r, u, d = 0.33, 0.66, 0.33, 0.66
    elseif direction == 5 then
        l, r, u, d = 0.33, 0.66, 0, 0.333
    elseif direction == 4 then
        l, r, u, d = 0, 0.33, 0.33, 0.66
    elseif direction == 3 then
        l, r, u, d = 0.66, 1, 0, 0.33
    elseif direction == 2 then
        l, r, u, d = 0.66, 1, 0.33, 0.66
    end
    return l, r, u, d
end
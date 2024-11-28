local addonName, discoVars = ...
HealIndicator = {}

if discoVars.enableHealIndicator then
    HealIndicator.eventFrame = CreateFrame("Frame")

    HealIndicator.eventFrame:SetSize(100, 25)
    HealIndicator.eventFrame:SetMovable(true)
    HealIndicator.eventFrame:EnableMouse(true)
    HealIndicator.eventFrame:RegisterForDrag("LeftButton")
    HealIndicator.eventFrame:SetPoint("CENTER", UIParent, "CENTER")
    HealIndicator.eventFrame:SetScript("OnDragStart", HealIndicator.eventFrame.StartMoving)
    HealIndicator.eventFrame:SetScript("OnDragStop", HealIndicator.eventFrame.StopMovingOrSizing)
    if not HealIndicator.eventFrame.texture then HealIndicator.eventFrame.texture = HealIndicator.eventFrame:CreateTexture(nil, "BACKGROUND"); end
    HealIndicator.eventFrame.texture:SetAllPoints(HealIndicator.eventFrame)
    HealIndicator.eventFrame.texture:SetColorTexture(0.3,0.3,0.3)
    HealIndicator.eventFrame.texture:SetAlpha(0.3)

    if not HealIndicator.eventFrame.heal then HealIndicator.eventFrame.heal = HealIndicator.eventFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal"); end
    HealIndicator.eventFrame.heal:SetPoint("LEFT", HealIndicator.eventFrame, "LEFT", 5, 0)
    HealIndicator.eventFrame.heal:SetTextColor(0, 1, 0)
    HealIndicator.eventFrame.heal:SetText("1000")

    if not HealIndicator.eventFrame.overheal then HealIndicator.eventFrame.overheal = HealIndicator.eventFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal"); end
    HealIndicator.eventFrame.overheal:SetPoint("LEFT", HealIndicator.eventFrame, "LEFT", 50, 0)
    HealIndicator.eventFrame.overheal:SetTextColor(1, 0, 0)
    HealIndicator.eventFrame.overheal:SetText("1000")

    HealIndicator.eventFrame:SetScript("OnEvent", function(self, event, ...)

        local timestamp, subevent, _, sourceGUID, sourceName, _, _, destGUID, destName, _, _, _, spellName, test, healAmount, overhealAmount, _, crit = CombatLogGetCurrentEventInfo()

        if subevent == "SPELL_HEAL" and UnitIsUnit(sourceName, "player") then
            --print('ha: ', healAmount, " absorbedAmount: ", healAmount - overhealAmount, " overheal: ", overhealAmount)
            --print("interval: ", GetTime() - tempTime)
            HealIndicator.eventFrame.heal:SetText(healAmount - overhealAmount)
            HealIndicator.eventFrame.overheal:SetText(overhealAmount)
        end

    end)
    HealIndicator.eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED");
end


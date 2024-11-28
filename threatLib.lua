local UnitGUID = function(unitID)
    local guid = UnitGUID(unitID)
    local unitType, _, _, _, _, _, spawnUID = strsplit("-", guid)
    if unitType == "Pet" then
        return string.sub(spawnUID, 3)
    end
    return UnitGUID(unitID)
end

-- Check if unitGUID in threat list and clear threat
function DISCO_removeThreat(unitGUID, overlayFrames, unitThreatList, playerMapping)
    if unitThreatList[unitGUID] then
        overlayFrames[unitThreatList[unitGUID].threatGUID].threatFrame:SetAlpha(0)
        overlayFrames[unitThreatList[unitGUID].threatGUID].bossThreatFrame:SetAlpha(0)
        playerMapping[unitThreatList[unitGUID].threatGUID].isMobTarget = false
        playerMapping[unitThreatList[unitGUID].threatGUID].isBossTarget = false
        playerMapping[unitThreatList[unitGUID].threatGUID].targetedBy[unitGUID] = nil
        unitThreatList[unitGUID] = nil
    end
end

-- Clears all threat
function DISCO_clearThreat(overlayFrames, unitThreatList)
    for guid, threatInfo in pairs(unitThreatList) do
        overlayFrames[threatInfo.threatGUID].threatFrame:SetAlpha(0)
        unitThreatList[guid] = nil
    end
end

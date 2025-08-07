-- KillCounter_Events.lua
-- Handles all combat and game events

function KillCounter:RegisterEvents()
    -- Create event frame
    self.eventFrame = CreateFrame("Frame")
    self.eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self.eventFrame:SetScript("OnEvent", function(frame, event, ...)
        KillCounter:OnCombatEvent(CombatLogGetCurrentEventInfo())
    end)
end

-- Handle combat events
function KillCounter:OnCombatEvent()
    local args = {CombatLogGetCurrentEventInfo()}
    local timestamp, event, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName, spellSchool, auraType, amount = unpack(args)
    
    -- We only care about kill events
    if event ~= "UNIT_DIED" and event ~= "PARTY_KILL" then
        return
    end
    
    local playerGUID = UnitGUID("player")
    
    -- Enemy dies - check if player or party got the kill
    if destGUID and destName and destName ~= "" then
        -- Count if player was the killer OR if it's a party kill and player is in a party
        if sourceGUID == playerGUID or (event == "PARTY_KILL" and (IsInGroup() or IsInRaid())) then
            local enemyID = self:GetNPCID(destGUID)
            if not enemyID then 
                return nil 
            end
            KillCounter:AddKill(enemyID, destName)

            -- Check if this enemy is being tracked for loot
            if self.db.profile.lootTracking[enemyID] then
                local tracking = self.db.profile.lootTracking[enemyID]
                local currentKills = self.db.profile.kills[enemyID]
                local dropChance = KillCounter:CalculateDropChance(tracking.baseChance, currentKills)
                
                print("|cFF00FFFFLoot Chance:|r " .. string.format("%.2f", dropChance) .. "%")
            end
            
            -- Update UI if it's visible
            if self.mainFrame and self.mainFrame:IsShown() then
                self:UpdateUI()
            end
        end
    end
end

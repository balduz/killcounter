-- KillCounter_Core.lua
-- Core addon functionality and initialization

local AceAddon = LibStub("AceAddon-3.0")
KillCounter = AceAddon:NewAddon("KillCounter", "AceEvent-3.0", "AceConsole-3.0")

-- A constant for the inactivity timer (in seconds). 15 minutes by default.
local KPH_INACTIVITY_THRESHOLD = 900

-- Helper function to extract NPC ID from GUID
function KillCounter:GetNPCID(guid)
    if not guid then return nil end

    local objectType, _, _, _, _, npcID = strsplit("-", guid)
    if objectType == "Creature" and npcID then
        return tonumber(npcID)
    end
    return nil
end

-- Initialize the addon
function KillCounter:OnInitialize()
    self:OnAce3Initialize()
    self.db.sessionKills = {}
    self.sessionKphData = {}
    
    self.eventFrame = CreateFrame("Frame")
    self.eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self.eventFrame:SetScript("OnEvent", function(frame, event, ...)
      self:OnCombatEvent()
    end)
    
    self:InitializeTooltip()
    self:CreateDashboard()

    if self.db.profile.showDashboard then
        self.dashboardFrame:Show()
        self:UpdateDashboard()
    end
end

function KillCounter:InitializeTooltip()
    GameTooltip:SetScript("OnTooltipSetUnit", function(tooltipSelf)
        local unit = "mouseover"
        local guid = UnitGUID(unit)
        if not guid then return end

        local npcID = KillCounter:GetNPCID(guid)
        if not npcID then return end

        local totalKills = KillCounter.db.profile.kills[npcID] or 0
        local sessionKills = KillCounter.db.sessionKills[npcID] or 0

        local showTotal = KillCounter.db.profile.showTotalKills and totalKills > 0
        local showSession = KillCounter.db.profile.showSessionKills and sessionKills > 0
        local showKph = KillCounter.db.profile.showKphInTooltip and sessionKills > 0

        if showTotal or showSession or showKph then
            tooltipSelf:AddLine(" ") -- Add a blank line for spacing
            tooltipSelf:AddLine("|cFF00FF00Kill Counter|r")

            if showTotal then
                tooltipSelf:AddDoubleLine("  Total:", totalKills, 1, 1, 1, 1, 1, 0)
            end

            if showSession then
                tooltipSelf:AddDoubleLine("  Session:", sessionKills, 1, 1, 1, 1, 1, 0)
            end

            if showKph then
                local kphValue = "N/A"
                if sessionKills > 1 then
                    local kphData = KillCounter.sessionKphData[npcID]
                    if kphData then
                        local elapsedTime = GetTime() - kphData.startTime
                        if elapsedTime > 0 then
                            kphValue = math.floor((sessionKills / elapsedTime) * 3600)
                        end
                    end
                end
                tooltipSelf:AddDoubleLine("  Kills/Hr:", kphValue, 1, 1, 1, 1, 1, 0)
            end
        end
    end)
end

function KillCounter:AddKill(npcID, enemyName)
    if not npcID then return end

    -- Total kills
    self.db.profile.kills[npcID] = (self.db.profile.kills[npcID] or 0) + 1
    self.db.profile.enemyNames[npcID] = enemyName

    -- Session kills
    self.db.sessionKills[npcID] = (self.db.sessionKills[npcID] or 0) + 1

    -- KPH Tracking Logic
    local currentTime = GetTime()
    local kphData = self.sessionKphData[npcID]

    if not kphData then
        self.sessionKphData[npcID] = { startTime = currentTime, lastKillTime = currentTime }
    else
        -- Check for inactivity. If it's been too long, reset the start time to "pause" the timer.
        if (currentTime - kphData.lastKillTime) > KPH_INACTIVITY_THRESHOLD then
            -- We effectively remove the inactive time by moving the start time forward.
            local inactiveTime = currentTime - kphData.lastKillTime
            kphData.startTime = kphData.startTime + inactiveTime
        end
        kphData.lastKillTime = currentTime
    end
end

function KillCounter:GetSessionKillCount(npcID)
    return self.db.sessionKills[npcID] or 0
end

function KillCounter:GetAllSessionKills()
    return self.db.sessionKills
end

function KillCounter:ResetSessionKills()
    self.db.sessionKills = {}
    self.sessionKphData = {}
    print("|cFF00FF00KillCounter:|r Session kill data reset.")
    self:UpdateDashboard()
end

function KillCounter:ResetAllKills()
  self.db.profile.kills = {}
  self.db.profile.enemyNames = {}
  self.db.sessionKills = {}
  self.sessionKphData = {}
  print("|cFF00FF00KillCounter:|r All data reset.")
  self:UpdateDashboard()
end

function KillCounter:GetKillTotals()
    local totalKills = 0
    for _, count in pairs(self.db.profile.kills) do
        totalKills = totalKills + count
    end

    local sessionKills = 0
    for _, count in pairs(self.db.sessionKills) do
        sessionKills = sessionKills + count
    end

    return totalKills, sessionKills
end

function KillCounter:GetTopKills(killsTable, count)
    local sortedKills = {}
    for npcID, kills in pairs(killsTable) do
        table.insert(sortedKills, {npcID, kills})
    end

    table.sort(sortedKills, function(a, b)
        return a[2] > b[2]
    end)

    local topKills = {}
    for i = 1, math.min(count, #sortedKills) do
        table.insert(topKills, sortedKills[i])
    end

    return topKills
end

function KillCounter:OnCombatEvent()
    local args = {CombatLogGetCurrentEventInfo()}
    local timestamp, event, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName, spellSchool, auraType, amount = unpack(args)
    
    if event ~= "UNIT_DIED" and event ~= "PARTY_KILL" then
        return
    end
    
    local playerGUID = UnitGUID("player")
    
    if destGUID and destName and destName ~= "" then
        -- Count if player was the killer OR if it's a party kill and player is in a party
        if sourceGUID == playerGUID or (event == "PARTY_KILL" and (IsInGroup() or IsInRaid())) then
            local enemyID = self:GetNPCID(destGUID)
            if not enemyID then 
                return nil 
            end
            KillCounter:AddKill(enemyID, destName)

            self:UpdateDashboard()
        end
    end
end

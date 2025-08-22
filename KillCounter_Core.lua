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
    self:OnAce3Initialize() -- Call the Ace3 initialization from KillCounter_AceConfig.lua
    self.db.sessionKills = {} -- Initialize session kills
    self.sessionKphData = {} -- Initialize KPH tracking data
    self:InitializeTooltip()
    self:RegisterEvents()
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

        if (KillCounter.db.profile.showTotalKills and totalKills > 0) or (KillCounter.db.profile.showSessionKills and sessionKills > 0) then
            tooltipSelf:AddLine(" ") -- Add a blank line for spacing
        end

        if KillCounter.db.profile.showTotalKills and totalKills > 0 then
            tooltipSelf:AddDoubleLine("Kills (Total):", totalKills, 1, 1, 1, 1, 1, 0)
        end

        if KillCounter.db.profile.showSessionKills and sessionKills > 0 then
            tooltipSelf:AddDoubleLine("Kills (Session):", sessionKills, 1, 1, 1, 1, 1, 0)
        end

        -- KPH Display Logic
        if KillCounter.db.profile.showKphInTooltip and sessionKills > 1 then
            local kphData = KillCounter.sessionKphData[npcID]
            if kphData then
                local elapsedTime = GetTime() - kphData.startTime
                if elapsedTime > 0 then
                    local kph = math.floor((sessionKills / elapsedTime) * 3600)
                    tooltipSelf:AddDoubleLine("Kills/Hr (Session):", kph, 1, 1, 1, 1, 1, 0)
                end
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
        -- First kill for this mob this session, start the timer.
        self.sessionKphData[npcID] = { startTime = currentTime, lastKillTime = currentTime }
    else
        -- Check for inactivity. If it's been too long, reset the start time.
        if (currentTime - kphData.lastKillTime) > KPH_INACTIVITY_THRESHOLD then
            -- The number of kills to subtract from the time calculation to "pause" the timer
            local killsDuringOldPeriod = self.db.sessionKills[npcID] - 1
            kphData.startTime = currentTime - ((killsDuringOldPeriod / (kphData.lastKillTime - kphData.startTime)) * 3600)
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
    self.sessionKphData = {} -- Also reset the KPH data
    print("|cFF00FF00KillCounter:|r Session kill data reset.")
    self:UpdateDashboard()
end

function KillCounter:ResetAllKills()
  self.db.profile.kills = {}
  self.db.profile.enemyNames = {}
  self.db.sessionKills = {}
  self.sessionKphData = {} -- Also reset the KPH data
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

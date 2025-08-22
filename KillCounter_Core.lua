-- KillCounter_Core.lua
-- Core addon functionality and initialization

local AceAddon = LibStub("AceAddon-3.0")
KillCounter = AceAddon:NewAddon("KillCounter", "AceEvent-3.0", "AceConsole-3.0")

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
    end)
end

function KillCounter:AddKill(npcID, enemyName)
    if not npcID then return end

    -- Total kills
    self.db.profile.kills[npcID] = (self.db.profile.kills[npcID] or 0) + 1
    self.db.profile.enemyNames[npcID] = enemyName

    -- Session kills
    self.db.sessionKills[npcID] = (self.db.sessionKills[npcID] or 0) + 1
end

function KillCounter:GetSessionKillCount(npcID)
    return self.db.sessionKills[npcID] or 0
end

function KillCounter:GetAllSessionKills()
    return self.db.sessionKills
end

function KillCounter:ResetSessionKills()
    self.db.sessionKills = {}
    print("|cFF00FF00KillCounter:|r Session kill data reset.")
    self:UpdateDashboard()
end

function KillCounter:ResetAllKills()
  self.db.profile.kills = {}
  self.db.profile.enemyNames = {}
  self.db.sessionKills = {}
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

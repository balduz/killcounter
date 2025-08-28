-- KillCounter_Core.lua
local AceAddon = LibStub("AceAddon-3.0")
KillCounter = AceAddon:NewAddon("KillCounter", "AceEvent-3.0", "AceConsole-3.0")

local DEFAULT_KPH_THRESHOLD_MINUTES = 15

-- Helper function to extract NPC ID from GUID
function KillCounter:GetNPCID(guid)
    if not guid then
        return nil
    end

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

    self.db:RegisterCallback("OnProfileChanged", function()
        self:RefreshDashboardFromProfile()
    end)
    self.db:RegisterCallback("OnProfileCopied", function()
        self:RefreshDashboardFromProfile()
    end)
    self.db:RegisterCallback("OnProfileReset", function()
        self:RefreshDashboardFromProfile()
    end)

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

    if not self.db.profile.firstRun then
        self:PrintWelcomeMessage()
        self.db.profile.firstRun = true
    end
end

function KillCounter:RefreshDashboardFromProfile()
    if not self.dashboardFrame then
        return
    end

    -- Update all dashboard settings from the current profile
    self:SetDashboardLocked(self.db.profile.dashboardLocked)
    self:SetDashboardResizeLocked(self.db.profile.dashboardResizeLocked)
    self:SetDashboardOpacity(self.db.profile.dashboardOpacity)
    self:SetDashboardFontSize(self.db.profile.dashboardFontSize)
    self:UpdateDashboardLayout()
    self:ToggleDashboard(self.db.profile.showDashboard)

    -- Re-apply position and size
    local pos = self.db.profile.dashboardPosition
    self.dashboardFrame:ClearAllPoints()
    if pos and pos.point then
        self.dashboardFrame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)
    else
        self.dashboardFrame:SetPoint("LEFT", 20, 0)
    end
    self.dashboardFrame:SetSize(self.db.profile.dashboardWidth, self.db.profile.dashboardHeight)

    self:UpdateDashboard()
end

function KillCounter:InitializeTooltip()
    GameTooltip:SetScript("OnTooltipSetUnit", function(tooltipSelf)
        local unit = "mouseover"
        local guid = UnitGUID(unit)
        if not guid then
            return
        end

        local npcID = KillCounter:GetNPCID(guid)
        if not npcID then
            return
        end

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
                            kphValue = math.floor(((sessionKills - 1) / elapsedTime) * 3600)
                        end
                    end
                end
                tooltipSelf:AddDoubleLine("  Kills/Hr:", kphValue, 1, 1, 1, 1, 1, 0)
            end
        end
    end)
end

function KillCounter:AddKill(npcID, enemyName)
    if not npcID then
        return
    end

    -- Total kills
    self.db.profile.kills[npcID] = (self.db.profile.kills[npcID] or 0) + 1
    self.db.profile.enemyNames[npcID] = enemyName

    -- Session kills
    self.db.sessionKills[npcID] = (self.db.sessionKills[npcID] or 0) + 1

    -- KPH Tracking Logic
    local currentTime = GetTime()
    local kphData = self.sessionKphData[npcID]

    local inactivityThreshold = (self.db.profile.kphThreshold or DEFAULT_KPH_THRESHOLD_MINUTES) * 60

    if not kphData then
        self.sessionKphData[npcID] = {
            startTime = currentTime,
            lastKillTime = currentTime
        }
    else
        -- Check for inactivity. If it's been too long, reset the start time to "pause" the timer.
        if (currentTime - kphData.lastKillTime) > inactivityThreshold then
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
    local timestamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName,
        destFlags, destRaidFlags = CombatLogGetCurrentEventInfo()

    if eventType ~= "UNIT_DIED" and eventType ~= "PARTY_KILL" then
        return
    end

    local isPlayerKill = bit.band(sourceFlags, COMBATLOG_OBJECT_CONTROL_PLAYER) > 0 and
                             bit.band(sourceFlags, COMBATLOG_OBJECT_REACTION_FRIENDLY) > 0
    if (isPlayerKill or (eventType == "PARTY_KILL" and (IsInGroup() or IsInRaid()))) and destGUID and destName and
        destName ~= "" then
        local enemyID = self:GetNPCID(destGUID)
        if enemyID then
            KillCounter:AddKill(enemyID, destName)
            if self.dashboardFrame and self.dashboardFrame:IsShown() then
                self:UpdateDashboard()
            end
        end
    end
end

function KillCounter:PrintWelcomeMessage()
    self:Print("Thank you for installing Kill Counter!")
    self:Print("You can configure the addon in the Interface Options panel or by typing |cFFFFFF00/kc|r.")
end

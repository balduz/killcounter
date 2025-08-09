-- KillCounter_Dashboard.lua
-- Creates and manages the kill counter dashboard

local KillCounter = LibStub("AceAddon-3.0"):GetAddon("KillCounter")

function KillCounter:CreateDashboard()
    -- Main frame
    self.dashboardFrame = CreateFrame("Frame", "KillCounterDashboard", UIParent, "BackdropTemplate")
    self.dashboardFrame:SetSize(220, 180) -- Adjusted height
    self.dashboardFrame:SetPoint("LEFT", 20, 0)
    self.dashboardFrame:SetMovable(true)
    self.dashboardFrame:EnableMouse(true)
    self.dashboardFrame:SetClampedToScreen(true)
    self.dashboardFrame:RegisterForDrag("LeftButton")
    self.dashboardFrame:SetScript("OnDragStart", self.dashboardFrame.StartMoving)
    self.dashboardFrame:SetScript("OnDragStop", self.dashboardFrame.StopMovingOrSizing)
    self.dashboardFrame:SetBackdrop({
        bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
        edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    self.dashboardFrame:SetBackdropColor(0, 0, 0, 0.7)
    self.dashboardFrame:Hide()

    -- Title
    local title = self.dashboardFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    title:SetPoint("TOPLEFT", 15, -10)
    title:SetText("Kill Counter")
    title:SetTextColor(1, 1, 0)

    -- Kills frame
    local killsFrame = CreateFrame("Frame", nil, self.dashboardFrame)
    killsFrame:SetSize(200, 140)
    killsFrame:SetPoint("TOPLEFT", 0, -35)

    -- Total Kills Section
    self.totalKillsTitle = killsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    self.totalKillsTitle:SetPoint("TOPLEFT", 15, 0)
    self.totalKillsTitle:SetText("Total")
    self.totalKillsTitle:SetTextColor(1, 1, 0.6)

    self.totalKillsCount = killsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    self.totalKillsCount:SetPoint("TOPRIGHT", killsFrame, "RIGHT", 0, 0)
    self.totalKillsCount:SetPoint("TOP", self.totalKillsTitle, "TOP")
    self.totalKillsCount:SetJustifyH("RIGHT")

    self.totalKillsLines = {}
    local lastAnchor = self.totalKillsTitle
    for i = 1, 3 do
        local name = killsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        name:SetPoint("TOPLEFT", lastAnchor, "BOTTOMLEFT", 0, -5)
        name:SetTextColor(1, 1, 1)

        local count = killsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        count:SetPoint("TOPRIGHT", killsFrame, "RIGHT", 0, 0)
        count:SetPoint("TOP", name, "TOP")
        count:SetJustifyH("RIGHT")

        self.totalKillsLines[i] = { name = name, count = count }
        lastAnchor = name
    end

    -- Session Kills Section
    self.sessionKillsTitle = killsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    self.sessionKillsTitle:SetPoint("TOPLEFT", lastAnchor, "BOTTOMLEFT", 0, -15)
    self.sessionKillsTitle:SetText("Session")
    self.sessionKillsTitle:SetTextColor(1, 1, 0.6)

    self.sessionKillsCount = killsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    self.sessionKillsCount:SetPoint("TOPRIGHT", killsFrame, "RIGHT", 0, 0)
    self.sessionKillsCount:SetPoint("TOP", self.sessionKillsTitle, "TOP")
    self.sessionKillsCount:SetJustifyH("RIGHT")

    self.sessionKillsLines = {}
    lastAnchor = self.sessionKillsTitle
    for i = 1, 3 do
        local name = killsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        name:SetPoint("TOPLEFT", lastAnchor, "BOTTOMLEFT", 0, -5)
        name:SetTextColor(1, 1, 1)

        local count = killsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        count:SetPoint("TOPRIGHT", killsFrame, "RIGHT", 0, 0)
        count:SetPoint("TOP", name, "TOP")
        count:SetJustifyH("RIGHT")

        self.sessionKillsLines[i] = { name = name, count = count }
        lastAnchor = name
    end
end

function KillCounter:UpdateDashboard()
    if not self.dashboardFrame or not self.dashboardFrame:IsShown() then
        return
    end

    local totalKills, sessionKills = self:GetKillTotals()
    self.totalKillsCount:SetText(string.format("|cFF87CEEB%d|r", totalKills))
    self.sessionKillsCount:SetText(string.format("|cFF87CEEB%d|r", sessionKills))

    local topTotalKills = self:GetTopKills(self.db.profile.kills, 3)
    for i = 1, 3 do
        local line = self.totalKillsLines[i]
        if topTotalKills[i] then
            local npcID, count = topTotalKills[i][1], topTotalKills[i][2]
            local enemyName = self.db.profile.enemyNames[npcID] or "Unknown"
            line.name:SetText(string.format("%d. %s:", i, enemyName))
            line.count:SetText(string.format("|cFFFFD100%d|r", count))
        else
            line.name:SetText("")
            line.count:SetText("")
        end
    end

    local topSessionKills = self:GetTopKills(self.db.sessionKills, 3)
    for i = 1, 3 do
        local line = self.sessionKillsLines[i]
        if topSessionKills[i] then
            local npcID, count = topSessionKills[i][1], topSessionKills[i][2]
            local enemyName = self.db.profile.enemyNames[npcID] or "Unknown"
            line.name:SetText(string.format("%d. %s:", i, enemyName))
            line.count:SetText(string.format("|cFFFFD100%d|r", count))
        else
            line.name:SetText("")
            line.count:SetText("")
        end
    end
end

function KillCounter:ToggleDashboard(show)
    if show == nil then
        show = not self.dashboardFrame:IsShown()
    end

    if show then
        self.dashboardFrame:Show()
        self:UpdateDashboard()
    else
        self.dashboardFrame:Hide()
    end
end

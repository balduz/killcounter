-- KillCounter_Dashboard.lua
-- Creates and manages the kill counter dashboard

local KillCounter = LibStub("AceAddon-3.0"):GetAddon("KillCounter")

function KillCounter:CreateDashboard()
    -- Main frame
    self.dashboardFrame = CreateFrame("Frame", "KillCounterDashboard", UIParent, "BackdropTemplate")
    self.dashboardFrame:SetSize(220, 320) -- Narrower and adjusted height
    self.dashboardFrame:SetPoint("CENTER")
    self.dashboardFrame:SetMovable(true)
    self.dashboardFrame:EnableMouse(true)
    self.dashboardFrame:SetClampedToScreen(true)
    self.dashboardFrame:RegisterForDrag("LeftButton")
    self.dashboardFrame:SetScript("OnDragStart", self.dashboardFrame.StartMoving)
    self.dashboardFrame:SetScript("OnDragStop", self.dashboardFrame.StopMovingOrSizing)
    self.dashboardFrame:SetBackdrop({
        bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
        edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
        tile = true,
        tileSize = 32,
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    self.dashboardFrame:SetBackdropColor(0, 0, 0, 0.7) -- Black, 70% transparent
    self.dashboardFrame:Hide()

    -- Title
    local title = self.dashboardFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOP", 0, -15)
    title:SetText("Kill Counter")
    title:SetTextColor(1, 1, 0) -- Yellow

    -- Close button
    local closeButton = CreateFrame("Button", nil, self.dashboardFrame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", -5, -5)
    closeButton:SetScript("OnClick", function() KillCounter.dashboardFrame:Hide() end)

    -- Totals section
    local totalsFrame = CreateFrame("Frame", nil, self.dashboardFrame)
    totalsFrame:SetSize(200, 40)
    totalsFrame:SetPoint("TOP", 0, -50)

    self.totalKillsText = totalsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    self.totalKillsText:SetPoint("TOPLEFT", 10, -10)
    self.totalKillsText:SetTextColor(0.8, 0.8, 0.8) -- Light Gray

    self.sessionKillsText = totalsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    self.sessionKillsText:SetPoint("TOPRIGHT", -10, -10)
    self.sessionKillsText:SetTextColor(0.8, 0.8, 0.8) -- Light Gray

    -- Single column for kills
    local killsFrame = CreateFrame("Frame", nil, self.dashboardFrame)
    killsFrame:SetSize(200, 220)
    killsFrame:SetPoint("TOP", 0, -90)

    -- Top 3 Total Kills
    local totalKillsTitle = killsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    totalKillsTitle:SetPoint("TOP", 0, -5)
    totalKillsTitle:SetText("Top 3 Total Kills")
    totalKillsTitle:SetTextColor(1, 1, 0.6) -- Lighter Yellow

    self.totalKillsLines = {}
    for i = 1, 3 do
        local line = killsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        line:SetPoint("TOPLEFT", 10, -30 - ((i - 1) * 20))
        line:SetTextColor(1, 1, 1) -- White
        self.totalKillsLines[i] = line
    end

    -- Top 3 Session Kills
    local sessionKillsTitle = killsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    sessionKillsTitle:SetPoint("TOP", 0, -105)
    sessionKillsTitle:SetText("Top 3 Session Kills")
    sessionKillsTitle:SetTextColor(1, 1, 0.6) -- Lighter Yellow

    self.sessionKillsLines = {}
    for i = 1, 3 do
        local line = killsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        line:SetPoint("TOPLEFT", 10, -130 - ((i - 1) * 20))
        line:SetTextColor(1, 1, 1) -- White
        self.sessionKillsLines[i] = line
    end
end

function KillCounter:UpdateDashboard()
    if not self.dashboardFrame or not self.dashboardFrame:IsShown() then
        return
    end

    -- Update totals
    local totalKills, sessionKills = self:GetKillTotals()
    self.totalKillsText:SetText("Total: " .. totalKills)
    self.sessionKillsText:SetText("Session: " .. sessionKills)

    -- Update top 3 total kills
    local topTotalKills = self:GetTopKills(self.db.profile.kills, 3)
    for i = 1, 3 do
        local line = self.totalKillsLines[i]
        if topTotalKills[i] then
            local npcID, count = topTotalKills[i][1], topTotalKills[i][2]
            local enemyName = self.db.profile.enemyNames[npcID] or "Unknown"
            line:SetText(string.format("%s: |cFFFFD100%d|r", enemyName, count))
        else
            line:SetText("")
        end
    end

    -- Update top 3 session kills
    local topSessionKills = self:GetTopKills(self.db.sessionKills, 3)
    for i = 1, 3 do
        local line = self.sessionKillsLines[i]
        if topSessionKills[i] then
            local npcID, count = topSessionKills[i][1], topSessionKills[i][2]
            local enemyName = self.db.profile.enemyNames[npcID] or "Unknown"
            line:SetText(string.format("%s: |cFFFFD100%d|r", enemyName, count))
        else
            line:SetText("")
        end
    end
end

function KillCounter:ToggleDashboard()
    if self.dashboardFrame:IsShown() then
        self.dashboardFrame:Hide()
    else
        self.dashboardFrame:Show()
        self:UpdateDashboard()
    end
end

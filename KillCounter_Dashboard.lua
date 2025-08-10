-- KillCounter_Dashboard.lua
-- Creates and manages the kill counter dashboard

local KillCounter = LibStub("AceAddon-3.0"):GetAddon("KillCounter")

-- Helper function to create a section in the dashboard
local function CreateKillSection(parent, anchor, titleText, yOffset, killCountLabel, linesTable)
    local title = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    if anchor then
        title:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, yOffset)
    else
        title:SetPoint("TOPLEFT", 15, yOffset)
    end
    title:SetText(titleText)
    title:SetTextColor(1, 1, 0.6)

    local countLabel = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    countLabel:SetPoint("TOPRIGHT", parent, "RIGHT", 0, 0)
    countLabel:SetPoint("TOP", title, "TOP")
    countLabel:SetJustifyH("RIGHT")
    
    local lastAnchor = title
    for i = 1, 3 do
        local name = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        name:SetPoint("TOPLEFT", lastAnchor, "BOTTOMLEFT", 0, -5)
        name:SetTextColor(1, 1, 1)

        local count = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        count:SetPoint("TOPRIGHT", parent, "RIGHT", 0, 0)
        count:SetPoint("TOP", name, "TOP")
        count:SetJustifyH("RIGHT")

        linesTable[i] = { name = name, count = count }
        lastAnchor = name
    end

    return countLabel, lastAnchor
end

function KillCounter:CreateDashboard()
    -- Main frame
    self.dashboardFrame = CreateFrame("Frame", "KillCounterDashboard", UIParent, "BackdropTemplate")
    self.dashboardFrame:SetSize(220, 180) -- Adjusted height
    
    -- Load position or set default
    local pos = self.db.profile.dashboardPosition
    if pos and pos.point then
        self.dashboardFrame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)
    else
        self.dashboardFrame:SetPoint("LEFT", 20, 0)
    end

    self.dashboardFrame:SetMovable(true)
    self.dashboardFrame:EnableMouse(true)
    self.dashboardFrame:SetClampedToScreen(true)
    self.dashboardFrame:RegisterForDrag("LeftButton")
    self.dashboardFrame:SetScript("OnDragStart", self.dashboardFrame.StartMoving)
    self.dashboardFrame:SetScript("OnDragStop", function(frame)
        frame:StopMovingOrSizing()
        self:SaveDashboardPosition()
    end)
    self.dashboardFrame:SetBackdrop({
        bgFile = "Interface/DialogFrame/UI-DialogBox-Background",
        edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
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

    -- Create Total and Session Kills sections
    self.totalKillsLines = {}
    local lastAnchor
    self.totalKillsCount, lastAnchor = CreateKillSection(killsFrame, nil, "Total", 0, self.totalKillsCount, self.totalKillsLines)

    self.sessionKillsLines = {}
    self.sessionKillsCount, _ = CreateKillSection(killsFrame, lastAnchor, "Session", -15, self.sessionKillsCount, self.sessionKillsLines)

    self:SetDashboardLocked(self.db.profile.dashboardLocked)
    self:SetDashboardOpacity(self.db.profile.dashboardOpacity)
end

function KillCounter:SaveDashboardPosition()
    local point, _, relativePoint, xOfs, yOfs = self.dashboardFrame:GetPoint()
    self.db.profile.dashboardPosition = {
        point = point,
        relativePoint = relativePoint,
        xOfs = xOfs,
        yOfs = yOfs,
    }
end

function KillCounter:SetDashboardLocked(locked)
    if locked then
        self.dashboardFrame:SetMovable(false)
        self.dashboardFrame:EnableMouse(false)
    else
        self.dashboardFrame:SetMovable(true)
        self.dashboardFrame:EnableMouse(true)
    end
end

function KillCounter:SetDashboardOpacity(opacity)
    self.dashboardFrame:SetBackdropColor(0, 0, 0, opacity)
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

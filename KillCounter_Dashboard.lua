-- KillCounter_Dashboard.lua
-- Creates and manages the kill counter dashboard
local KillCounter = LibStub("AceAddon-3.0"):GetAddon("KillCounter")

local MAX_DASHBOARD_LINES = 10 -- Define a maximum number of lines

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
    countLabel:SetPoint("TOPRIGHT", parent, "RIGHT", -15, 0)
    countLabel:SetPoint("TOP", title, "TOP")
    countLabel:SetJustifyH("RIGHT")

    local lastAnchor = title
    for i = 1, MAX_DASHBOARD_LINES do
        local name = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        name:SetPoint("TOPLEFT", lastAnchor, "BOTTOMLEFT", 0, -5)
        name:SetTextColor(1, 1, 1)

        local count = parent:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        count:SetPoint("TOPRIGHT", parent, "RIGHT", -15, 0)
        count:SetPoint("TOP", name, "TOP")
        count:SetJustifyH("RIGHT")

        linesTable[i] = {
            name = name,
            count = count
        }
        lastAnchor = name
    end

    return countLabel, lastAnchor, title
end

function KillCounter:CreateDashboard()
    -- Main frame
    self.dashboardFrame = CreateFrame("Frame", "KillCounterDashboard", UIParent, "BackdropTemplate")
    self.dashboardFrame:SetSize(self.db.profile.dashboardWidth, self.db.profile.dashboardHeight)

    -- Load position or set default
    local pos = self.db.profile.dashboardPosition
    if pos and pos.point then
        self.dashboardFrame:SetPoint(pos.point, UIParent, pos.relativePoint, pos.xOfs, pos.yOfs)
    else
        self.dashboardFrame:SetPoint("LEFT", 20, 0)
    end

    self.dashboardFrame:SetMovable(true)
    self.dashboardFrame:SetResizable(true)
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
        tile = true,
        tileSize = 32,
        edgeSize = 16,
        insets = {
            left = 4,
            right = 4,
            top = 4,
            bottom = 4
        }
    })
    self.dashboardFrame:Hide()

    -- Title
    self.dashboardTitle = self.dashboardFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    self.dashboardTitle:SetPoint("TOPLEFT", 15, -10)
    self.dashboardTitle:SetText("Kill Counter")
    self.dashboardTitle:SetTextColor(1, 1, 0)

    -- Kills frame
    local killsFrame = CreateFrame("Frame", nil, self.dashboardFrame)
    killsFrame:SetPoint("TOPLEFT", 0, -35)
    killsFrame:SetPoint("BOTTOMRIGHT", self.dashboardFrame, "BOTTOMRIGHT", 0, 0)

    -- Create Total and Session Kills sections
    self.totalKillsLines = {}
    local lastAnchor
    self.totalKillsCount, lastAnchor, self.totalKillsTitle =
        CreateKillSection(killsFrame, nil, "Total", 0, self.totalKillsCount, self.totalKillsLines)

    self.sessionKillsLines = {}
    self.sessionKillsCount, _, self.sessionKillsTitle = CreateKillSection(killsFrame, lastAnchor, "Session", -15,
        self.sessionKillsCount, self.sessionKillsLines)

    -- Resize Handle
    self.resizeHandle = CreateFrame("Frame", nil, self.dashboardFrame)
    self.resizeHandle:SetSize(16, 16)
    self.resizeHandle:SetPoint("BOTTOMRIGHT", self.dashboardFrame, "BOTTOMRIGHT", 0, 0)
    self.resizeHandle:EnableMouse(true)

    local resizeTexture = self.resizeHandle:CreateTexture(nil, "ARTWORK")
    resizeTexture:SetTexture("Interface\\CHATFRAME\\UI-ChatIM-SizeGrabber-Up")
    resizeTexture:SetAllPoints(self.resizeHandle)

    self.resizeHandle:SetScript("OnMouseDown", function(frame, button)
        if button == "LeftButton" then
            self.dashboardFrame:StartSizing("BOTTOMRIGHT")
        end
    end)
    self.resizeHandle:SetScript("OnMouseUp", function(frame, button)
        if button == "LeftButton" then
            self.dashboardFrame:StopMovingOrSizing()
            self:SaveDashboardSize()
        end
    end)

    self:SetDashboardLocked(self.db.profile.dashboardLocked)
    self:SetDashboardResizeLocked(self.db.profile.dashboardResizeLocked)
    self:SetDashboardOpacity(self.db.profile.dashboardOpacity)
    self:SetDashboardFontSize(self.db.profile.dashboardFontSize)

    self:UpdateDashboardLayout()
end

function KillCounter:SaveDashboardPosition()
    local point, _, relativePoint, xOfs, yOfs = self.dashboardFrame:GetPoint()
    self.db.profile.dashboardPosition = {
        point = point,
        relativePoint = relativePoint,
        xOfs = xOfs,
        yOfs = yOfs
    }
end

function KillCounter:SaveDashboardSize()
    local width, height = self.dashboardFrame:GetSize()
    self.db.profile.dashboardWidth = width
    self.db.profile.dashboardHeight = height
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

function KillCounter:SetDashboardResizeLocked(locked)
    if locked then
        self.resizeHandle:Hide()
    else
        self.resizeHandle:Show()
    end
end

function KillCounter:SetDashboardOpacity(opacity)
    self.dashboardFrame:SetBackdropColor(0, 0, 0, opacity)
end

function KillCounter:SetDashboardFontSize(size)
    local fontName, _, fontFlags = self.dashboardTitle:GetFont()
    self.dashboardTitle:SetFont(fontName, size + 2, fontFlags)

    self.totalKillsTitle:SetFont(fontName, size, fontFlags)
    self.totalKillsCount:SetFont(fontName, size, fontFlags)

    self.sessionKillsTitle:SetFont(fontName, size, fontFlags)
    self.sessionKillsCount:SetFont(fontName, size, fontFlags)

    for i = 1, MAX_DASHBOARD_LINES do
        self.totalKillsLines[i].name:SetFont(fontName, size - 2, fontFlags)
        self.totalKillsLines[i].count:SetFont(fontName, size - 2, fontFlags)
        self.sessionKillsLines[i].name:SetFont(fontName, size - 2, fontFlags)
        self.sessionKillsLines[i].count:SetFont(fontName, size - 2, fontFlags)
    end
end

local function UpdateKillSection(linesTable, topKills, enemyNames, placeholder)
    local showCount = KillCounter.db.profile.dashboardTopKills or 3

    if #topKills == 0 then
        -- Handle the placeholder case
        for i = 1, MAX_DASHBOARD_LINES do
            local line = linesTable[i]
            if i <= showCount then
                line.name:Show()
                line.count:Show()
                if i == 1 then
                    line.name:SetText(placeholder)
                    line.count:SetText("")
                else
                    line.name:SetText(" ") -- Use a space to maintain height
                    line.count:SetText("")
                end
            else
                line.name:Hide()
                line.count:Hide()
            end
        end
        return
    end

    -- Handle the case with data
    for i = 1, MAX_DASHBOARD_LINES do
        local line = linesTable[i]
        if i <= showCount then
            line.name:Show()
            line.count:Show()
            if topKills[i] then
                local npcID, count = topKills[i][1], topKills[i][2]
                local enemyName = enemyNames[npcID] or "Unknown"
                line.name:SetText(string.format("%d. %s:", i, enemyName))
                line.count:SetText(string.format("|cFFFFD100%d|r", count))
            else
                line.name:SetText(" ") -- Use a space to maintain height
                line.count:SetText("")
            end
        else
            line.name:Hide()
            line.count:Hide()
        end
    end
end

function KillCounter:UpdateDashboard()
    if not self.dashboardFrame or not self.dashboardFrame:IsShown() then
        return
    end

    local topKillsCount = self.db.profile.dashboardTopKills or 3
    local totalKills, sessionKills = self:GetKillTotals()
    local topTotalKills = self:GetTopKills(self.db.profile.kills, topKillsCount)
    local topSessionKills = self:GetTopKills(self.db.sessionKills, topKillsCount)

    self.totalKillsCount:SetText(string.format("|cFF87CEEB%d|r", totalKills))
    UpdateKillSection(self.totalKillsLines, topTotalKills, self.db.profile.enemyNames, "|cFFa0a0a0No kills yet!|r")

    self.sessionKillsCount:SetText(string.format("|cFF87CEEB%d|r", sessionKills))
    UpdateKillSection(self.sessionKillsLines, topSessionKills, self.db.profile.enemyNames,
        "|cFFa0a0a0No kills this session.|r")
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

function KillCounter:UpdateDashboardLayout()
    if not self.dashboardFrame then
        return
    end

    local showTotal = self.db.profile.showTotalOnDashboard
    local showSession = self.db.profile.showSessionOnDashboard
    local topKillsCount = self.db.profile.dashboardTopKills or 3

    -- Show/hide entire section titles
    self.totalKillsTitle:SetShown(showTotal)
    self.totalKillsCount:SetShown(showTotal)
    self.sessionKillsTitle:SetShown(showSession)
    self.sessionKillsCount:SetShown(showSession)

    -- Show/hide the lines within each section based on their master visibility toggle
    for i = 1, MAX_DASHBOARD_LINES do
        self.totalKillsLines[i].name:SetShown(showTotal)
        self.totalKillsLines[i].count:SetShown(showTotal)
        self.sessionKillsLines[i].name:SetShown(showSession)
        self.sessionKillsLines[i].count:SetShown(showSession)
    end

    -- Correctly anchor the session section
    self.sessionKillsTitle:ClearAllPoints()
    if showTotal then
        -- Anchor to the last line that is SUPPOSED to be visible, creating a static layout.
        self.sessionKillsTitle:SetPoint("TOPLEFT", self.totalKillsLines[topKillsCount].name, "BOTTOMLEFT", 0, -15)
    else
        -- If the total section is hidden, anchor to the top of the container.
        self.sessionKillsTitle:SetPoint("TOPLEFT", self.totalKillsTitle:GetParent(), "TOPLEFT", 15, 0)
    end

    self:UpdateDashboard()
end

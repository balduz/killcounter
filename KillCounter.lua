-- Kill Counter for WoW Classic
-- Tracks the number of enemies killed by the player

-- Global variables
KillCounter = {}
KillCounterDB = KillCounterDB or {
    sessionKills = {},
    lootTracking = {},
    enemyNames = {} -- Map enemy IDs to names for display
}

-- Helper function to extract NPC ID from GUID
function KillCounter:GetNPCID(guid)
    if not guid then return nil end
    -- GUID format: "Creature-0-5252-1-3172-5331-000007DE68"
    -- NPC ID is the 6th element in the dash-separated list
    local parts = {}
    for part in string.gmatch(guid, "[^-]+") do
        table.insert(parts, part)
    end
    if #parts >= 6 then
        return tonumber(parts[6])
    end
    return nil
end

-- Initialize the addon
function KillCounter:Initialize()
    print("|cFF00FF00Kill Counter|r loaded. Type /kc for commands.")
    
    -- Create event frame
    self.eventFrame = CreateFrame("Frame")
    self.eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self.eventFrame:SetScript("OnEvent", function(frame, event, ...)
        self:OnCombatEvent(CombatLogGetCurrentEventInfo())
    end)
    
    -- Create UI window
    self:CreateUI()
end

-- Handle combat events
function KillCounter:OnCombatEvent()
    local args = {CombatLogGetCurrentEventInfo()}
    local timestamp, event, _, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, spellId, spellName, spellSchool, auraType, amount = unpack(args)
    
    local playerGUID = UnitGUID("player")
    
    -- Enemy dies - check if player or party got the kill
    if event == "UNIT_DIED" or event == "PARTY_KILL" then
        if destGUID and destName and destName ~= "" then
            -- Count if player was the killer OR if it's a party kill and player is in a party
            if sourceGUID == playerGUID or (event == "PARTY_KILL" and (IsInGroup() or IsInRaid())) then
                local enemyID = self:GetNPCID(destGUID)
                if not enemyID then return nil end
                -- Store enemy name for display purposes
                KillCounterDB.enemyNames[enemyID] = destName
                
                -- Initialize counter for this enemy if it doesn't exist
                KillCounterDB.sessionKills[enemyID] = KillCounterDB.sessionKills[enemyID] or 0
                
                -- Increment kill counter for this enemy
                KillCounterDB.sessionKills[enemyID] = KillCounterDB.sessionKills[enemyID] + 1

                -- Check if this enemy is being tracked for loot
                if KillCounterDB.lootTracking[enemyID] then
                    local tracking = KillCounterDB.lootTracking[enemyID]
                    local currentKills = KillCounterDB.sessionKills[enemyID]
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
end

-- Create the UI window
function KillCounter:CreateUI()
    -- Main frame
    self.mainFrame = CreateFrame("Frame", "KillCounterFrame", UIParent, "BasicFrameTemplateWithInset")
    self.mainFrame:SetSize(400, 500)
    self.mainFrame:SetPoint("CENTER")
    self.mainFrame:SetMovable(true)
    self.mainFrame:EnableMouse(true)
    self.mainFrame:RegisterForDrag("LeftButton")
    self.mainFrame:SetScript("OnDragStart", self.mainFrame.StartMoving)
    self.mainFrame:SetScript("OnDragStop", self.mainFrame.StopMovingOrSizing)
    self.mainFrame:Hide()
    
    -- Title
    self.mainFrame.title = self.mainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    self.mainFrame.title:SetPoint("TOP", self.mainFrame, "TOP", 0, -5)
    self.mainFrame.title:SetText("Kill Counter")
    
    -- Close button
    -- self.mainFrame.closeButton = CreateFrame("Button", nil, self.mainFrame, "GameMenuButtonTemplate")
    -- self.mainFrame.closeButton:SetSize(20, 20)
    -- self.mainFrame.closeButton:SetPoint("TOPRIGHT", self.mainFrame, "TOPRIGHT", -5, -5)
    -- self.mainFrame.closeButton:SetText("X")
    -- self.mainFrame.closeButton:SetScript("OnClick", function() self.mainFrame:Hide() end)
    
    -- Scroll frame for content
    self.mainFrame.scrollFrame = CreateFrame("ScrollFrame", nil, self.mainFrame, "UIPanelScrollFrameTemplate")
    self.mainFrame.scrollFrame:SetPoint("TOPLEFT", self.mainFrame, "TOPLEFT", 10, -30)
    self.mainFrame.scrollFrame:SetPoint("BOTTOMRIGHT", self.mainFrame, "BOTTOMRIGHT", -30, 10)
    
    -- Content frame
    self.mainFrame.content = CreateFrame("Frame", nil, self.mainFrame.scrollFrame)
    self.mainFrame.content:SetSize(350, 1)
    self.mainFrame.scrollFrame:SetScrollChild(self.mainFrame.content)
    
    -- Update button
    self.mainFrame.updateButton = CreateFrame("Button", nil, self.mainFrame, "GameMenuButtonTemplate")
    self.mainFrame.updateButton:SetSize(80, 25)
    self.mainFrame.updateButton:SetPoint("BOTTOMLEFT", self.mainFrame, "BOTTOMLEFT", 10, 10)
    self.mainFrame.updateButton:SetText("Update")
    self.mainFrame.updateButton:SetScript("OnClick", function() KillCounter:UpdateUI() end)

    -- Reset session button
    self.mainFrame.resetButton = CreateFrame("Button", nil, self.mainFrame, "GameMenuButtonTemplate")
    self.mainFrame.resetButton:SetSize(100, 25)
    self.mainFrame.resetButton:SetPoint("LEFT", self.mainFrame.updateButton, "RIGHT", 10, 0)
    self.mainFrame.resetButton:SetText("Reset Session")
    self.mainFrame.resetButton:SetScript("OnClick", function()
        KillCounterDB.sessionKills = {}
        KillCounter:UpdateUI()
        print("|cFF00FF00Kill Counter:|r Session kills reset")
    end)

    -- Toggle loot tracking button
    self.mainFrame.toggleLootButton = CreateFrame("Button", nil, self.mainFrame, "GameMenuButtonTemplate")
    self.mainFrame.toggleLootButton:SetSize(80, 25)
    self.mainFrame.toggleLootButton:SetPoint("LEFT", self.mainFrame.resetButton, "RIGHT", 10, 0)
    self.mainFrame.toggleLootButton:SetText("Show Loot")
    self.mainFrame.toggleLootButton:SetScript("OnClick", function()
        KillCounter.showLoot = not KillCounter.showLoot
        KillCounter.mainFrame.toggleLootButton:SetText(KillCounter.showLoot and "Hide Loot" or "Show Loot")
        KillCounter:UpdateUI()
    end)

    -- Add loot tracking button
    self.mainFrame.addLootButton = CreateFrame("Button", nil, self.mainFrame, "GameMenuButtonTemplate")
    self.mainFrame.addLootButton:SetSize(80, 25)
    self.mainFrame.addLootButton:SetPoint("LEFT", self.mainFrame.toggleLootButton, "RIGHT", 10, 0)
    self.mainFrame.addLootButton:SetText("Add Loot")
    self.mainFrame.addLootButton:SetScript("OnClick", function()
        KillCounter:ShowLootDialog()
    end)
    
    -- Initialize show loot state
    self.showLoot = false
    
    -- Create loot dialog
    self:CreateLootDialog()
end

-- Create the loot dialog
function KillCounter:CreateLootDialog()
    -- Main dialog frame
    self.lootDialog = CreateFrame("Frame", "KillCounterLootDialog", UIParent, "BasicFrameTemplateWithInset")
    self.lootDialog:SetSize(300, 200)
    self.lootDialog:SetPoint("CENTER")
    self.lootDialog:SetMovable(true)
    self.lootDialog:EnableMouse(true)
    self.lootDialog:RegisterForDrag("LeftButton")
    self.lootDialog:SetScript("OnDragStart", self.lootDialog.StartMoving)
    self.lootDialog:SetScript("OnDragStop", self.lootDialog.StopMovingOrSizing)
    self.lootDialog:Hide()
    
    -- Title
    self.lootDialog.title = self.lootDialog:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    self.lootDialog.title:SetPoint("TOP", self.lootDialog, "TOP", 0, -5)
    self.lootDialog.title:SetText("Add Loot Tracking")
    
    -- Close button
    self.lootDialog.closeButton = CreateFrame("Button", nil, self.lootDialog, "GameMenuButtonTemplate")
    self.lootDialog.closeButton:SetSize(20, 20)
    self.lootDialog.closeButton:SetPoint("TOPRIGHT", self.lootDialog, "TOPRIGHT", -5, -5)
    self.lootDialog.closeButton:SetText("X")
    self.lootDialog.closeButton:SetScript("OnClick", function() self.lootDialog:Hide() end)
    
    -- Enemy ID label
    self.lootDialog.enemyIDLabel = self.lootDialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.lootDialog.enemyIDLabel:SetPoint("TOPLEFT", self.lootDialog, "TOPLEFT", 20, -40)
    self.lootDialog.enemyIDLabel:SetText("Enemy ID:")
    
    -- Enemy ID input
    self.lootDialog.enemyIDInput = CreateFrame("EditBox", nil, self.lootDialog, "InputBoxTemplate")
    self.lootDialog.enemyIDInput:SetSize(100, 20)
    self.lootDialog.enemyIDInput:SetPoint("TOPLEFT", self.lootDialog, "TOPLEFT", 20, -60)
    self.lootDialog.enemyIDInput:SetAutoFocus(false)
    self.lootDialog.enemyIDInput:SetNumeric(true)
    
    -- Base chance label
    self.lootDialog.chanceLabel = self.lootDialog:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.lootDialog.chanceLabel:SetPoint("TOPLEFT", self.lootDialog, "TOPLEFT", 20, -90)
    self.lootDialog.chanceLabel:SetText("Base Chance (%):")
    
    -- Base chance input
    self.lootDialog.chanceInput = CreateFrame("EditBox", nil, self.lootDialog, "InputBoxTemplate")
    self.lootDialog.chanceInput:SetSize(100, 20)
    self.lootDialog.chanceInput:SetPoint("TOPLEFT", self.lootDialog, "TOPLEFT", 20, -110)
    self.lootDialog.chanceInput:SetAutoFocus(false)
    self.lootDialog.chanceInput:SetNumeric(false)
    
    -- Accept button
    self.lootDialog.acceptButton = CreateFrame("Button", nil, self.lootDialog, "GameMenuButtonTemplate")
    self.lootDialog.acceptButton:SetSize(80, 25)
    self.lootDialog.acceptButton:SetPoint("BOTTOMLEFT", self.lootDialog, "BOTTOMLEFT", 20, 20)
    self.lootDialog.acceptButton:SetText("Accept")
    self.lootDialog.acceptButton:SetScript("OnClick", function() 
        KillCounter:AcceptLootTracking()
    end)
    
    -- Cancel button
    self.lootDialog.cancelButton = CreateFrame("Button", nil, self.lootDialog, "GameMenuButtonTemplate")
    self.lootDialog.cancelButton:SetSize(80, 25)
    self.lootDialog.cancelButton:SetPoint("BOTTOMRIGHT", self.lootDialog, "BOTTOMRIGHT", -20, 20)
    self.lootDialog.cancelButton:SetText("Cancel")
    self.lootDialog.cancelButton:SetScript("OnClick", function() 
        KillCounter.lootDialog:Hide()
    end)
end

-- Show the loot dialog
function KillCounter:ShowLootDialog()
    if self.lootDialog then
        -- Clear previous input
        self.lootDialog.enemyIDInput:SetText("")
        self.lootDialog.chanceInput:SetText("")
        self.lootDialog:Show()
    end
end

-- Accept loot tracking from dialog
function KillCounter:AcceptLootTracking()
    local enemyID = tonumber(self.lootDialog.enemyIDInput:GetText())
    local baseChance = tonumber(self.lootDialog.chanceInput:GetText())
    
    -- Validate inputs
    if not enemyID or enemyID <= 0 then
        print("|cFFFF0000Kill Counter:|r Invalid enemy ID. Please enter a positive number.")
        return
    end
    
    if not baseChance or baseChance <= 0 or baseChance > 100 then
        print("|cFFFF0000Kill Counter:|r Invalid chance value. Use a number between 0.1 and 100 (e.g., 5.5 for 5.5%).")
        return
    end
    
    -- Add to loot tracking
    local enemyName = KillCounterDB.enemyNames[enemyID] or "Unknown (ID: " .. enemyID .. ")"
    KillCounterDB.lootTracking[enemyID] = {
        baseChance = baseChance
    }
    
    print("|cFF00FF00Kill Counter:|r Now tracking loot from " .. enemyName .. " (ID: " .. enemyID .. ", Base chance: " .. baseChance .. "%)")
    
    -- Hide dialog and update UI
    self.lootDialog:Hide()
    if KillCounter.mainFrame and KillCounter.mainFrame:IsShown() then
        KillCounter:UpdateUI()
    end
end

-- Update the UI with current data
function KillCounter:UpdateUI()
    if not KillCounter.mainFrame or not KillCounter.mainFrame.scrollFrame then return end
    
    -- Destroy old content frame and create a new one
    if KillCounter.mainFrame.content then
        KillCounter.mainFrame.content:Hide()
        KillCounter.mainFrame.content:SetParent(nil)
        KillCounter.mainFrame.content = nil
    end
    
    -- Create new content frame
    KillCounter.mainFrame.content = CreateFrame("Frame", nil, KillCounter.mainFrame.scrollFrame)
    KillCounter.mainFrame.content:SetSize(350, 1)
    KillCounter.mainFrame.scrollFrame:SetScrollChild(KillCounter.mainFrame.content)
    
    local yOffset = 0
    local lineHeight = 20
    
    -- Header
    local header = KillCounter.mainFrame.content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    header:SetPoint("TOPLEFT", KillCounter.mainFrame.content, "TOPLEFT", 0, yOffset)
    header:SetText("Session Kills")
    yOffset = yOffset - lineHeight - 5
    
    -- Sort enemies by session kills
    local sortedEnemies = {}
    for enemyID, sessionKills in pairs(KillCounterDB.sessionKills) do
        if sessionKills > 0 then
            table.insert(sortedEnemies, {id = enemyID, session = sessionKills})
        end
    end
    table.sort(sortedEnemies, function(a, b) return a.session > b.session end)
    
    -- Display enemies
    for i, enemy in ipairs(sortedEnemies) do
        local enemyName = KillCounterDB.enemyNames[enemy.id] or "Unknown (ID: " .. enemy.id .. ")"
        
        -- Enemy name and kills
        local enemyText = KillCounter.mainFrame.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        enemyText:SetPoint("TOPLEFT", KillCounter.mainFrame.content, "TOPLEFT", 0, yOffset)
        enemyText:SetText(enemyName)
        
        local killsText = KillCounter.mainFrame.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        killsText:SetPoint("TOPRIGHT", KillCounter.mainFrame.content, "TOPRIGHT", 0, yOffset)
        killsText:SetText("Kills: " .. enemy.session)
        
        yOffset = yOffset - lineHeight
        
        -- Show loot tracking info if enabled and available
        if KillCounter.showLoot and KillCounterDB.lootTracking[enemy.id] then
            local tracking = KillCounterDB.lootTracking[enemy.id]
            local dropChance = KillCounter:CalculateDropChance(tracking.baseChance, enemy.session)
            
            local lootText = KillCounter.mainFrame.content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            lootText:SetPoint("TOPLEFT", KillCounter.mainFrame.content, "TOPLEFT", 20, yOffset)
            lootText:SetText("|cFF00FFFFLoot:|r " .. string.format("%.2f", dropChance) .. "% chance (Base: " .. tracking.baseChance .. "%)")
            lootText:SetTextColor(0, 1, 1)
            
            yOffset = yOffset - lineHeight
        end
        
        -- Add some spacing between enemies
        yOffset = yOffset - 2
    end
    
    -- Show all tracked loot if enabled
    if KillCounter.showLoot then
        -- Add separator
        yOffset = yOffset - 10
        
        local separator = KillCounter.mainFrame.content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        separator:SetPoint("TOPLEFT", KillCounter.mainFrame.content, "TOPLEFT", 0, yOffset)
        separator:SetText("Tracked Loot")
        yOffset = yOffset - lineHeight - 5
        
        -- Get all tracked loot
        local trackedLoot = {}
        for enemyID, tracking in pairs(KillCounterDB.lootTracking) do
            local enemyName = KillCounterDB.enemyNames[enemyID] or "Unknown (ID: " .. enemyID .. ")"
            local sessionKills = KillCounterDB.sessionKills[enemyID] or 0
            local dropChance = KillCounter:CalculateDropChance(tracking.baseChance, sessionKills)
            table.insert(trackedLoot, {
                enemyID = enemyID,
                enemyName = enemyName,
                baseChance = tracking.baseChance,
                sessionKills = sessionKills,
                dropChance = dropChance
            })
        end
        
        -- Sort by enemy name
        table.sort(trackedLoot, function(a, b) return a.enemyName < b.enemyName end)
        
        -- Display all tracked loot
        for i, loot in ipairs(trackedLoot) do
            local lootText = KillCounter.mainFrame.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            lootText:SetPoint("TOPLEFT", KillCounter.mainFrame.content, "TOPLEFT", 0, yOffset)
            lootText:SetText(loot.enemyName)
            
            local chanceText = KillCounter.mainFrame.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            chanceText:SetPoint("TOPRIGHT", KillCounter.mainFrame.content, "TOPRIGHT", 0, yOffset)
            chanceText:SetText(string.format("%.2f", loot.dropChance) .. "% (" .. loot.baseChance .. "%)")
            chanceText:SetTextColor(0, 1, 1)
            
            yOffset = yOffset - lineHeight
        end
        
        if #trackedLoot == 0 then
            local noLootText = KillCounter.mainFrame.content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            noLootText:SetPoint("TOPLEFT", KillCounter.mainFrame.content, "TOPLEFT", 0, yOffset)
            noLootText:SetText("No loot being tracked")
            noLootText:SetTextColor(0.7, 0.7, 0.7)
            yOffset = yOffset - lineHeight
        end
    end
    
    -- Update content height
    KillCounter.mainFrame.content:SetHeight(math.abs(yOffset) + 10)
end

-- Toggle UI visibility
function KillCounter:ToggleUI()
    if KillCounter.mainFrame:IsShown() then
        KillCounter.mainFrame:Hide()
    else
        KillCounter:UpdateUI()
        KillCounter.mainFrame:Show()
    end
end

-- Calculate drop chance based on kills and base chance
function KillCounter:CalculateDropChance(baseChance, totalKills)
    local chance = 1 - (1 - baseChance / 100) ^ totalKills
    return chance * 100
end

-- Parse track command
function KillCounter:ParseTrackCommand(msg)
    -- Remove "track " prefix
    local args = string.sub(msg, 7)
    
    local enemyID, baseChance
    
    -- First argument is enemy ID (number)
    local spacePos = string.find(args, " ")
    if spacePos then
        enemyID = tonumber(string.sub(args, 1, spacePos - 1))
        args = string.sub(args, spacePos + 1)
    else
        return nil, nil
    end
    
    -- The remaining part should be the chance
    baseChance = string.match(args, "^%s*(.+)$")
    
    return enemyID, baseChance
end

-- Parse untrack command
function KillCounter:ParseUntrackCommand(msg)
    -- Remove "untrack " prefix
    local args = string.sub(msg, 9)
    
    -- Argument is enemy ID (number)
    local enemyID = tonumber(string.match(args, "^%s*(.+)$"))
    
    return enemyID
end

-- Slash commands
SLASH_KILLCOUNTER1 = "/kc"
SLASH_KILLCOUNTER2 = "/killcounter"
SlashCmdList["KILLCOUNTER"] = function(msg)
    msg = string.lower(msg)
    
    if msg == "help" then
        print("|cFF00FF00Kill Counter Commands:|r")
        print("/kc - Show all kill counts")
        print("/kc help - Show this help")
        print("/kc reset - Reset session kills")
        print("/kc ui - Toggle UI window")
        print("/kc [enemyID] - Show kills for specific enemy")
        print("/kc track [enemyID] [chance] - Track loot drop chance")
        print("/kc untrack [enemyID] - Stop tracking loot for enemy")
        print("/kc loot - Show all tracked loot")
    elseif msg == "reset" then
        KillCounterDB.sessionKills = {}
        if KillCounter.mainFrame and KillCounter.mainFrame:IsShown() then
            KillCounter:UpdateUI()
        end
        print("|cFF00FF00Kill Counter:|r Session kills reset")
    elseif msg == "ui" then
        KillCounter:ToggleUI()
    elseif msg ~= "" then
        -- Show kills for specific enemy (by ID)
        local enemyID = tonumber(msg)
        if enemyID then
            local enemyName = KillCounterDB.enemyNames[enemyID] or "Unknown (ID: " .. enemyID .. ")"
            local sessionKills = KillCounterDB.sessionKills[enemyID] or 0
            print("|cFF00FF00Kill Counter:|r " .. enemyName .. " (ID: " .. enemyID .. ") - Kills: " .. sessionKills)
            
            -- Also show loot tracking info if available
            if KillCounterDB.lootTracking[enemyID] then
                local tracking = KillCounterDB.lootTracking[enemyID]
                local dropChance = KillCounter:CalculateDropChance(tracking.baseChance, sessionKills)
                print("  |cFF00FFFFLoot:|r " .. string.format("%.2f", dropChance) .. "% chance")
            end
        else
            print("|cFFFF0000Kill Counter:|r Invalid enemy ID. Use a number.")
        end
    elseif string.find(msg, "^track ") then
        -- Track loot for an enemy
        local enemyID, baseChance = KillCounter:ParseTrackCommand(msg)
        if enemyID and baseChance then
            baseChance = tonumber(baseChance)
            if baseChance and baseChance > 0 and baseChance <= 100 then
                local enemyName = KillCounterDB.enemyNames[enemyID] or "Unknown (ID: " .. enemyID .. ")"
                KillCounterDB.lootTracking[enemyID] = {
                    baseChance = baseChance
                }
                print("|cFF00FF00Kill Counter:|r Now tracking loot from " .. enemyName .. " (ID: " .. enemyID .. ", Base chance: " .. baseChance .. "%)")
            else
                print("|cFFFF0000Kill Counter:|r Invalid chance value. Use a number between 0.1 and 100")
            end
        else
            print("|cFFFF0000Kill Counter:|r Usage: /kc track [enemyID] [chance]")
            print("Example: /kc track 257 5.5")
            print("Example: /kc track 116 2.1")
        end
    elseif string.find(msg, "^untrack ") then
        -- Stop tracking loot for an enemy
        local enemyID = KillCounter:ParseUntrackCommand(msg)
        if enemyID and KillCounterDB.lootTracking[enemyID] then
            local enemyName = KillCounterDB.enemyNames[enemyID] or "Unknown (ID: " .. enemyID .. ")"
            KillCounterDB.lootTracking[enemyID] = nil
            print("|cFF00FF00Kill Counter:|r Stopped tracking loot from " .. enemyName)
        else
            print("|cFFFF0000Kill Counter:|r Not tracking any loot for enemy ID " .. (enemyID or "invalid"))
        end
    elseif msg == "loot" then
        -- Show all tracked loot
        print("|cFF00FF00Kill Counter - Tracked Loot:|r")
        local hasTracking = false
        for enemyID, tracking in pairs(KillCounterDB.lootTracking) do
            local enemyName = KillCounterDB.enemyNames[enemyID] or "Unknown (ID: " .. enemyID .. ")"
            local currentKills = KillCounterDB.sessionKills[enemyID] or 0
            local dropChance = KillCounter:CalculateDropChance(tracking.baseChance, currentKills)
            print("  " .. enemyName .. " (Base: " .. tracking.baseChance .. "%, Current: " .. string.format("%.2f", dropChance) .. "%)")
            hasTracking = true
        end
        if not hasTracking then
            print("  No loot being tracked")
        end
    else
        -- Show all kill counts
        print("|cFF00FF00Kill Counter - Session Kills:|r")
        local hasKills = false
        for enemyID, sessionKills in pairs(KillCounterDB.sessionKills) do
            if sessionKills > 0 then
                local enemyName = KillCounterDB.enemyNames[enemyID] or "Unknown (ID: " .. enemyID .. ")"
                print("  " .. enemyName .. " - Kills: " .. sessionKills)
                hasKills = true
            end
        end
        if not hasKills then
            print("  No kills recorded yet")
        end
    end
end

-- Create loader frame
local loaderFrame = CreateFrame("Frame")
loaderFrame:RegisterEvent("ADDON_LOADED")
loaderFrame:RegisterEvent("PLAYER_LOGIN")
loaderFrame:SetScript("OnEvent", function(self, event, addonName)
    if event == "ADDON_LOADED" and addonName == "KillCounter" then
        KillCounter:Initialize()
    elseif event == "PLAYER_LOGIN" then
        -- Fallback initialization
        if not KillCounter.eventFrame then
            KillCounter:Initialize()
        end
    end
end) 
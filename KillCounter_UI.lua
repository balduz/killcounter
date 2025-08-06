-- KillCounter_UI.lua
-- Handles all UI elements, including frames, buttons, and slash commands

function KillCounter:CreateUI()
    -- Main frame
    self.mainFrame = CreateFrame("Frame", "KillCounterFrame", UIParent, "BasicFrameTemplateWithInset")
    self.mainFrame:SetSize(400, 600) -- Increased height to accommodate both sections
    self.mainFrame:SetPoint("CENTER")
    self.mainFrame:SetMovable(true)
    self.mainFrame:EnableMouse(true)
    self.mainFrame:SetFrameStrata("HIGH")
    self.mainFrame:SetFrameLevel(100)
    self.mainFrame:RegisterForDrag("LeftButton")
    self.mainFrame:SetScript("OnDragStart", self.mainFrame.StartMoving)
    self.mainFrame:SetScript("OnDragStop", self.mainFrame.StopMovingOrSizing)
    self.mainFrame:Hide()    
    -- Title
    self.mainFrame.title = self.mainFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    self.mainFrame.title:SetPoint("TOP", self.mainFrame, "TOP", 0, -5)
    self.mainFrame.title:SetText("Kill Counter")
    
    -- Scroll frame for content
    self.mainFrame.scrollFrame = CreateFrame("ScrollFrame", nil, self.mainFrame, "UIPanelScrollFrameTemplate")
    self.mainFrame.scrollFrame:SetPoint("TOPLEFT", self.mainFrame, "TOPLEFT", 10, -30)
    self.mainFrame.scrollFrame:SetPoint("BOTTOMRIGHT", self.mainFrame, "BOTTOMRIGHT", -30, 40) -- Adjusted for buttons
    
    -- Content frame
    self.mainFrame.content = CreateFrame("Frame", nil, self.mainFrame.scrollFrame)
    self.mainFrame.content:SetSize(350, 1)
    self.mainFrame.scrollFrame:SetScrollChild(self.mainFrame.content)
    
    -- Buttons
    local buttonYOffset = 10
    local buttonXOffset = 10
    local buttonWidth = 100
    local buttonHeight = 25
    local buttonSpacing = 10

    -- Update button
    self.mainFrame.updateButton = CreateFrame("Button", nil, self.mainFrame, "GameMenuButtonTemplate")
    self.mainFrame.updateButton:SetSize(buttonWidth, buttonHeight)
    self.mainFrame.updateButton:SetPoint("BOTTOMLEFT", self.mainFrame, "BOTTOMLEFT", buttonXOffset, buttonYOffset)
    self.mainFrame.updateButton:SetText("Update")
    self.mainFrame.updateButton:SetScript("OnClick", function() KillCounter:UpdateUI() end)

    -- Reset Session button
    self.mainFrame.resetSessionButton = CreateFrame("Button", nil, self.mainFrame, "GameMenuButtonTemplate")
    self.mainFrame.resetSessionButton:SetSize(buttonWidth, buttonHeight)
    self.mainFrame.resetSessionButton:SetPoint("LEFT", self.mainFrame.updateButton, "RIGHT", buttonSpacing, 0)
    self.mainFrame.resetSessionButton:SetText("Reset Session")
    self.mainFrame.resetSessionButton:SetScript("OnClick", function() 
        KillCounter:ResetSessionKills()
    end)

    -- Reset All button
    self.mainFrame.resetAllButton = CreateFrame("Button", nil, self.mainFrame, "GameMenuButtonTemplate")
    self.mainFrame.resetAllButton:SetSize(buttonWidth, buttonHeight)
    self.mainFrame.resetAllButton:SetPoint("LEFT", self.mainFrame.resetSessionButton, "RIGHT", buttonSpacing, 0)
    self.mainFrame.resetAllButton:SetText("Reset All")
    self.mainFrame.resetAllButton:SetScript("OnClick", function() 
        KillCounter:ResetAllKills()
    end)

    -- Toggle Loot Tracking button (new row)
    self.mainFrame.toggleLootButton = CreateFrame("Button", nil, self.mainFrame, "GameMenuButtonTemplate")
    self.mainFrame.toggleLootButton:SetSize(buttonWidth, buttonHeight)
    self.mainFrame.toggleLootButton:SetPoint("BOTTOMLEFT", self.mainFrame, "BOTTOMLEFT", buttonXOffset, buttonYOffset + buttonHeight + buttonSpacing)
    self.mainFrame.toggleLootButton:SetText("Show Loot")
    self.mainFrame.toggleLootButton:SetScript("OnClick", function() 
        KillCounter.showLoot = not KillCounter.showLoot
        KillCounter.mainFrame.toggleLootButton:SetText(KillCounter.showLoot and "Hide Loot" or "Show Loot")
        KillCounter:UpdateUI()
    end)

    -- Add Loot Tracking button
    self.mainFrame.addLootButton = CreateFrame("Button", nil, self.mainFrame, "GameMenuButtonTemplate")
    self.mainFrame.addLootButton:SetSize(buttonWidth, buttonHeight)
    self.mainFrame.addLootButton:SetPoint("LEFT", self.mainFrame.toggleLootButton, "RIGHT", buttonSpacing, 0)
    self.mainFrame.addLootButton:SetText("Add Loot")
    self.mainFrame.addLootButton:SetScript("OnClick", function() 
        KillCounter:ShowLootDialog()
    end)
    
    -- Initialize show loot state
    self.showLoot = false
    
    -- Create loot dialog
    self:CreateLootDialog()
end

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

function KillCounter:ShowLootDialog()
    if self.lootDialog then
        -- Clear previous input
        self.lootDialog.enemyIDInput:SetText("")
        self.lootDialog.chanceInput:SetText("")
        self.lootDialog:Show()
    end
end

function KillCounter:AcceptLootTracking()
    local enemyID = tonumber(self.lootDialog.enemyIDInput:GetText())
    local baseChance = tonumber(self.lootDialog.chanceInput:GetText())
    
    -- Validate inputs
    if not enemyID or enemyID <= 0 then
        print("|cFFFF0000Kill Counter:|r Invalid enemy ID. Please enter a positive number.")
        return
    end
    
    if not baseChance or baseChance <= 0 or baseChance > 100 then
        print("|cFFFF0000Kill Counter:|r Invalid chance value. Use a number between 0.1 and 100 (e.g., 5.5 for 5.5%)")
        return
    end
    
    -- Add to loot tracking
    local enemyName = KillCounterEnhancedDB.enemyNames[enemyID] or "Unknown (ID: " .. enemyID .. ")"
    KillCounterEnhancedDB.lootTracking[enemyID] = {
        baseChance = baseChance
    }
    
    print("|cFF00FF00Kill Counter:|r Now tracking loot from " .. enemyName .. " (ID: " .. enemyID .. ", Base chance: " .. baseChance .. "%)")
    
    -- Hide dialog and update UI
    self.lootDialog:Hide()
    if KillCounter.mainFrame and KillCounter.mainFrame:IsShown() then
        KillCounter:UpdateUI()
    end
end

function KillCounter:UpdateUI()
    if not self.mainFrame then
        return
    end
    
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
    
    -- Persistent Kills Header
    local persistentHeader = KillCounter.mainFrame.content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    persistentHeader:SetPoint("TOPLEFT", KillCounter.mainFrame.content, "TOPLEFT", 0, yOffset)
    persistentHeader:SetText("Persistent Kills")
    yOffset = yOffset - lineHeight - 5
    
    -- Sort enemies by persistent kills
    local sortedPersistentEnemies = {}
    for enemyID, kills in pairs(KillCounterEnhancedDB.kills) do
        if kills > 0 then
            table.insert(sortedPersistentEnemies, {id = enemyID, kills = kills})
        end
    end
    table.sort(sortedPersistentEnemies, function(a, b) return a.kills > b.kills end)
    
    -- Display persistent enemies
    for i, enemy in ipairs(sortedPersistentEnemies) do
        local enemyName = KillCounterEnhancedDB.enemyNames[enemy.id] or "Unknown (ID: " .. enemy.id .. ")"
        
        local enemyText = KillCounter.mainFrame.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        enemyText:SetPoint("TOPLEFT", KillCounter.mainFrame.content, "TOPLEFT", 0, yOffset)
        enemyText:SetText(enemyName)
        
        local killsText = KillCounter.mainFrame.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        killsText:SetPoint("TOPRIGHT", KillCounter.mainFrame.content, "TOPRIGHT", 0, yOffset)
        killsText:SetText("Kills: " .. enemy.kills)
        
        yOffset = yOffset - lineHeight
        
        -- Show loot tracking info if enabled and available
        if KillCounter.showLoot and KillCounterEnhancedDB.lootTracking[enemy.id] then
            local tracking = KillCounterEnhancedDB.lootTracking[enemy.id]
            local dropChance = KillCounter:CalculateDropChance(tracking.baseChance, enemy.kills)
            
            local lootText = KillCounter.mainFrame.content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            lootText:SetPoint("TOPLEFT", KillCounter.mainFrame.content, "TOPLEFT", 20, yOffset)
            lootText:SetText("|cFF00FFFFLoot:|r " .. string.format("%.2f", dropChance) .. "% chance (Base: " .. tracking.baseChance .. ")")
            lootText:SetTextColor(0, 1, 1)
            
            yOffset = yOffset - lineHeight
        end
        
        yOffset = yOffset - 2
    end
    
    -- Session Kills Header
    yOffset = yOffset - 10 -- Add some space
    local sessionHeader = KillCounter.mainFrame.content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    sessionHeader:SetPoint("TOPLEFT", KillCounter.mainFrame.content, "TOPLEFT", 0, yOffset)
    sessionHeader:SetText("Session Kills")
    yOffset = yOffset - lineHeight - 5
    
    -- Sort enemies by session kills
    local sortedSessionEnemies = {}
    for enemyID, kills in pairs(KillCounterEnhancedDB.sessionKills) do
        if kills > 0 then
            table.insert(sortedSessionEnemies, {id = enemyID, kills = kills})
        end
    end
    table.sort(sortedSessionEnemies, function(a, b) return a.kills > b.kills end)
    
    -- Display session enemies
    for i, enemy in ipairs(sortedSessionEnemies) do
        local enemyName = KillCounterEnhancedDB.enemyNames[enemy.id] or "Unknown (ID: " .. enemy.id .. ")"
        
        local enemyText = KillCounter.mainFrame.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        enemyText:SetPoint("TOPLEFT", KillCounter.mainFrame.content, "TOPLEFT", 0, yOffset)
        enemyText:SetText(enemyName)
        
        local killsText = KillCounter.mainFrame.content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        killsText:SetPoint("TOPRIGHT", KillCounter.mainFrame.content, "TOPRIGHT", 0, yOffset)
        killsText:SetText("Kills: " .. enemy.kills)
        
        yOffset = yOffset - lineHeight
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
        for enemyID, tracking in pairs(KillCounterEnhancedDB.lootTracking) do
            local enemyName = KillCounterEnhancedDB.enemyNames[enemyID] or "Unknown (ID: " .. enemyID .. ")"
            local kills = KillCounterEnhancedDB.kills[enemyID] or 0
            local dropChance = KillCounter:CalculateDropChance(tracking.baseChance, kills)
            table.insert(trackedLoot, {
                enemyID = enemyID,
                enemyName = enemyName,
                baseChance = tracking.baseChance,
                kills = kills,
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

function KillCounter:ToggleUI()
    if KillCounter.mainFrame:IsShown() then
        KillCounter.mainFrame:Hide()
    else
        KillCounter:UpdateUI()
        KillCounter.mainFrame:Show()
    end
end

function KillCounter:CalculateDropChance(baseChance, totalKills)
    local chance = 1 - (1 - baseChance / 100) ^ totalKills
    return chance * 100
end

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
        print("/kc reset all - Reset all kill data")
        print("/kc reset session - Reset session kill data")
        print("/kc ui - Toggle UI window")
        print("/kc [enemyID] - Show kills for specific enemy")
        print("/kc track [enemyID] [chance] - Track loot drop chance")
        print("/kc untrack [enemyID] - Stop tracking loot for enemy")
        print("/kc loot - Show all tracked loot")
    elseif msg == "reset all" then
        KillCounter:ResetAllKills()
    elseif msg == "reset session" then
        KillCounter:ResetSessionKills()
    elseif msg == "ui" then
        KillCounter:ToggleUI()
    elseif string.find(msg, "^track ") then
        -- Track loot for an enemy
        local enemyID, baseChance = KillCounter:ParseTrackCommand(msg)
        if enemyID and baseChance then
            baseChance = tonumber(baseChance)
            if baseChance and baseChance > 0 and baseChance <= 100 then
                local enemyName = KillCounterEnhancedDB.enemyNames[enemyID] or "Unknown (ID: " .. enemyID .. ")"
                KillCounterEnhancedDB.lootTracking[enemyID] = {
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
        if enemyID and KillCounterEnhancedDB.lootTracking[enemyID] then
            local enemyName = KillCounterEnhancedDB.enemyNames[enemyID] or "Unknown (ID: " .. enemyID .. ")"
            KillCounterEnhancedDB.lootTracking[enemyID] = nil
            print("|cFF00FF00Kill Counter:|r Stopped tracking loot from " .. enemyName)
        else
            print("|cFFFF0000Kill Counter:|r Not tracking any loot for enemy ID " .. (enemyID or "invalid"))
        end
    elseif msg == "loot" then
        -- Show all tracked loot
        print("|cFF00FF00Kill Counter - Tracked Loot:|r")
        local hasTracking = false
        for enemyID, tracking in pairs(KillCounterEnhancedDB.lootTracking) do
            local enemyName = KillCounterEnhancedDB.enemyNames[enemyID] or "Unknown (ID: " .. enemyID .. ")"
            local currentKills = KillCounterEnhancedDB.kills[enemyID] or 0
            local dropChance = KillCounter:CalculateDropChance(tracking.baseChance, currentKills)
            print("  " .. enemyName .. " (Base: " .. tracking.baseChance .. "%, Current: " .. string.format("%.2f", dropChance) .. "%)")
            hasTracking = true
        end
        if not hasTracking then
            print("  No loot being tracked")
        end
    elseif msg ~= "" then
        -- Show kills for specific enemy (by ID)
        local enemyID = tonumber(msg)
        if enemyID then
            local enemyName = KillCounterEnhancedDB.enemyNames[enemyID] or "Unknown (ID: " .. enemyID .. ")"
            local persistentKills = KillCounterEnhancedDB.kills[enemyID] or 0
            local sessionKills = KillCounterEnhancedDB.sessionKills[enemyID] or 0
            print("|cFF00FF00Kill Counter:|r " .. enemyName .. " (ID: " .. enemyID .. ") - Persistent Kills: " .. persistentKills .. ", Session Kills: " .. sessionKills)
            
            -- Also show loot tracking info if available
            if KillCounterEnhancedDB.lootTracking[enemyID] then
                local tracking = KillCounterEnhancedDB.lootTracking[enemyID]
                local dropChance = KillCounter:CalculateDropChance(tracking.baseChance, persistentKills)
                print("  |cFF00FFFFLoot:|r " .. string.format("%.2f", dropChance) .. "% chance")
            end
        else
            print("|cFFFF0000Kill Counter:|r Invalid enemy ID. Use a number.")
        end
    else
        -- Show all kill counts
        print("|cFF00FF00Kill Counter - Persistent Kills:|r")
        local hasPersistentKills = false
        for enemyID, kills in pairs(KillCounterEnhancedDB.kills) do
            if kills > 0 then
                local enemyName = KillCounterEnhancedDB.enemyNames[enemyID] or "Unknown (ID: " .. enemyID .. ")"
                print("  " .. enemyName .. " - Kills: " .. kills)
                hasPersistentKills = true
            end
        end
        if not hasPersistentKills then
            print("  No persistent kills recorded yet")
        end

        print("\n|cFF00FF00Kill Counter - Session Kills:|r")
        local hasSessionKills = false
        for enemyID, kills in pairs(KillCounterEnhancedDB.sessionKills) do
            if kills > 0 then
                local enemyName = KillCounterEnhancedDB.enemyNames[enemyID] or "Unknown (ID: " .. enemyID .. ")"
                print("  " .. enemyName .. " - Kills: " .. kills)
                hasSessionKills = true
            end
        end
        if not hasSessionKills then
            print("  No session kills recorded yet")
        end
    end
end


function KillCounter:ShowKillNotification(enemyName)
    UIErrorsFrame:AddMessage("|cFF00FF00Kill Counter:|r Killed " .. enemyName .. "!", 1.0, 1.0, 0)
end

-- Tooltip integration
GameTooltip:SetScript("OnTooltipSetUnit", function(self)
    local unit = "mouseover"
    local guid = UnitGUID(unit)
    if not guid then return end

    local npcID = KillCounter:GetNPCID(guid)
    if not npcID then return end

    local persistentKills = KillCounterEnhancedDB.kills[npcID] or 0
    local sessionKills = KillCounterEnhancedDB.sessionKills[npcID] or 0

    if persistentKills > 0 or sessionKills > 0 then
        self:AddLine(" ") -- Add a blank line for spacing
        self:AddDoubleLine("Kills (Overall):", persistentKills, 1, 1, 1, 1, 1, 0)
        self:AddDoubleLine("Kills (Session):", sessionKills, 1, 1, 1, 1, 1, 0)
    end
end)

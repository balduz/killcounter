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
        print("/kc [enemyID] - Show kills for specific enemy")
    elseif msg == "reset all" then
        KillCounter:ResetAllKills()
    elseif msg == "reset session" then
        KillCounter:ResetSessionKills()
    elseif msg ~= "" then
        -- Show kills for specific enemy (by ID)
        local enemyID = tonumber(msg)
        if enemyID then
            local enemyName = KillCounter.db.profile.enemyNames[enemyID] or "Unknown (ID: " .. enemyID .. ")"
            local totalKills = KillCounter.db.profile.kills[enemyID] or 0
            local sessionKills = KillCounter.db.sessionKills[enemyID] or 0
            print("|cFF00FF00Kill Counter:|r " .. enemyName .. " (ID: " .. enemyID .. ") - Total Kills: " .. totalKills .. ", Session Kills: " .. sessionKills)
        else
            print("|cFFFF0000Kill Counter:|r Invalid enemy ID. Use a number.")
        end
    else
        -- Show all kill counts
        print("|cFF00FF00Kill Counter - Total Kills:|r")
        local hasTotalKills = false
        for enemyID, kills in pairs(KillCounter.db.profile.kills) do
            if kills > 0 then
                local enemyName = KillCounter.db.profile.enemyNames[enemyID] or "Unknown (ID: " .. enemyID .. ")"
                print("  " .. enemyName .. " - Kills: " .. kills)
                hasTotalKills = true
            end
        end
        if not hasTotalKills then
            print("  No total kills recorded yet")
        end

        print("\n|cFF00FF00Kill Counter - Session Kills:|r")
        local hasSessionKills = false
        for enemyID, kills in pairs(KillCounter.db.sessionKills) do
            if kills > 0 then
                local enemyName = KillCounter.db.profile.enemyNames[enemyID] or "Unknown (ID: " .. enemyID .. ")"
                print("  " .. enemyName .. ": " .. kills)
                hasSessionKills = true
            end
        end
        if not hasSessionKills then
            print("  No session kills recorded yet")
        end
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

-- Add a function to reset all total kills
function KillCounter:ResetAllKills()
    self.db.profile.kills = {}
    self.db.profile.enemyNames = {}
    self:ResetSessionKills() -- Also reset session kills
    print("|cFF00FF00KillCounter:|r All total kill data reset.")
end
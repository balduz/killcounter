-- Slash commands
SLASH_KILLCOUNTER1 = "/kc"
SLASH_KILLCOUNTER2 = "/killcounter"
SlashCmdList["KILLCOUNTER"] = function(msg)
    msg = string.lower(msg)

    if msg == "help" then
        print("|cFF00FF00Kill Counter Commands:|r")
        print("/kc - Opens the configuration panel")
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
        -- Open the config panel
        LibStub("AceConfigDialog-3.0"):Open("KillCounter")
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
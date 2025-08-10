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

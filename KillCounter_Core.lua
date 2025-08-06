-- KillCounter_Core.lua
-- Core addon functionality and initialization

KillCounter = {}

-- Helper function to extract NPC ID from GUID
function KillCounter:GetNPCID(guid)
    if not guid then return nil end
    local _, _, _, _, _, _, id = string.find(guid, "Creature%-(%d+)%-(%d+)%-(%d+)%-(%d+)%-(%d+)%-(%d+)")
    return tonumber(id)
end

-- Initialize the addon
function KillCounter:Initialize()
    self:InitializeDB()
    self:RegisterEvents()
    self:CreateUI()
    print("|cFF00FF00Kill Counter|r loaded. Type /kc for commands.")
end

-- Create loader frame
local loaderFrame = CreateFrame("Frame")
loaderFrame:RegisterEvent("PLAYER_LOGIN")
loaderFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        KillCounter:Initialize()
        -- Reset session kills on login
        KillCounterEnhancedDB.sessionKills = {}
        -- Unregister the event after initialization to prevent it from running again
        self:UnregisterEvent("PLAYER_LOGIN")
    end
end)

function KillCounter:AddKill(npcID, enemyName)
    if not npcID then return end

    -- Persistent kills
    KillCounterEnhancedDB.kills[npcID] = (KillCounterEnhancedDB.kills[npcID] or 0) + 1
    KillCounterEnhancedDB.enemyNames[npcID] = enemyName

    -- Session kills
    KillCounterEnhancedDB.sessionKills[npcID] = (KillCounterEnhancedDB.sessionKills[npcID] or 0) + 1

    self:UpdateUI()
    self:ShowKillNotification(enemyName)
end

function KillCounter:GetSessionKillCount(npcID)
    return KillCounterEnhancedDB.sessionKills[npcID] or 0
end

function KillCounter:GetAllSessionKills()
    return KillCounterEnhancedDB.sessionKills
end

function KillCounter:ResetSessionKills()
    KillCounterEnhancedDB.sessionKills = {}
    self:UpdateUI()
    print("|cFF00FF00KillCounter:|r Session kill data reset.")
end


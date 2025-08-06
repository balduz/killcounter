-- KillCounter_DB.lua
-- Handles database initialization and access

function KillCounter:InitializeDB()
    KillCounterEnhancedDB = KillCounterEnhancedDB or {}
    KillCounterEnhancedDB.kills = KillCounterEnhancedDB.kills or {}
    KillCounterEnhancedDB.lootTracking = KillCounterEnhancedDB.lootTracking or {}
    KillCounterEnhancedDB.enemyNames = KillCounterEnhancedDB.enemyNames or {}
    print("|cFF00FF00KillCounter:|r Database initialized.")
end

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
        -- Unregister the event after initialization to prevent it from running again
        self:UnregisterEvent("PLAYER_LOGIN")
    end
end)

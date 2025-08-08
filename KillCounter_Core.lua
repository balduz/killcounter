-- KillCounter_Core.lua
-- Core addon functionality and initialization

local AceAddon = LibStub("AceAddon-3.0")
KillCounter = AceAddon:NewAddon("KillCounter", "AceEvent-3.0") -- Assuming you use AceEvent

-- Helper function to extract NPC ID from GUID
function KillCounter:GetNPCID(guid)
    if not guid then return nil end
    local _, _, _, _, _, _, id = string.find(guid, "Creature%-(%d+)%-(%d+)%-(%d+)%-(%d+)%-(%d+)%-(%d+)")
    return tonumber(id)
end

-- Initialize the addon
function KillCounter:OnInitialize()
    self:OnAce3Initialize() -- Call the Ace3 initialization from KillCounter_AceConfig.lua
    self.db.sessionKills = {} -- Initialize session kills
    self:InitializeTooltip()
    self:RegisterEvents()
end

function KillCounter:AddKill(npcID, enemyName)
    if not npcID then return end

    -- Total kills
    self.db.profile.kills[npcID] = (self.db.profile.kills[npcID] or 0) + 1
    self.db.profile.enemyNames[npcID] = enemyName

    -- Session kills
    self.db.sessionKills[npcID] = (self.db.sessionKills[npcID] or 0) + 1
end

function KillCounter:GetSessionKillCount(npcID)
    return self.db.sessionKills[npcID] or 0
end

function KillCounter:GetAllSessionKills()
    return self.db.sessionKills
end

function KillCounter:ResetSessionKills()
    self.db.sessionKills = {}
    self:UpdateUI()
    print("|cFF00FF00KillCounter:|r Session kill data reset.")
end

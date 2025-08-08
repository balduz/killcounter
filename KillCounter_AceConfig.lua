
local AceAddon = LibStub("AceAddon-3.0")
local AceDB = LibStub("AceDB-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

-- Get a reference to your main addon object (assuming it's named KillCounter)
local KillCounter = AceAddon:GetAddon("KillCounter")

-- Define default settings
local defaults = {
    profile = {
        enableKillCounter = true,
        showOverallKills = true,
        showSessionKills = true,
        kills = {},
        enemyNames = {},
    }
}

-- Define the options table for AceConfig
local options = {
    type = "group",
    name = "Kill Counter",
    args = {
        general = {
            type = "group",
            name = "General Settings",
            args = {
                enable = {
                    type = "toggle",
                    name = "Enable Kill Counter",
                    desc = "Toggles the Kill Counter on or off.",
                    get = function(info) return KillCounter.db.profile.enableKillCounter end,
                    set = function(info, value) KillCounter.db.profile.enableKillCounter = value end,
                    order = 1,
                },
                showOverallKills = {
                    type = "toggle",
                    name = "Show Total Kills",
                    desc = "Displays the total number of kills for a mob in the tooltip",
                    get = function(info) return KillCounter.db.profile.showOverallKills end,
                    set = function(info, value) KillCounter.db.profile.showOverallKills = value end,
                    order = 2,
                },
                showSessionKills = {
                    type = "toggle",
                    name = "Show Session Kills",
                    desc = "Displays the number of kills for a mob in the current session in the tooltip",
                    get = function(info) return KillCounter.db.profile.showSessionKills end,
                    set = function(info, value) KillCounter.db.profile.showSessionKills = value end,
                    order = 2,
                },
            },
        },
    },
}

-- Register the options table and add to Blizzard Interface Options
function KillCounter:OnAce3Initialize()
    self.db = AceDB:New("KillCounterEnhancedDB", defaults, true)
    AceConfig:RegisterOptionsTable("KillCounter", options)
    AceConfigDialog:AddToBlizOptions("KillCounter", "Kill Counter")
end

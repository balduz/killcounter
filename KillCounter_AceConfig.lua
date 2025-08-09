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
        showTotalKills = true,
        showSessionKills = true,
        showDashboard = true,
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
                showTotalKills = {
                    type = "toggle",
                    name = "Show Total Kills",
                    desc = "Displays the total number of kills for a mob in the tooltip",
                    get = function(info) return KillCounter.db.profile.showTotalKills end,
                    set = function(info, value) KillCounter.db.profile.showTotalKills = value end,
                    order = 2,
                },
                showSessionKills = {
                    type = "toggle",
                    name = "Show Session Kills",
                    desc = "Displays the number of kills for a mob in the current session in the tooltip",
                    get = function(info) return KillCounter.db.profile.showSessionKills end,
                    set = function(info, value) KillCounter.db.profile.showSessionKills = value end,
                    order = 3,
                },
                showDashboard = {
                    type = "toggle",
                    name = "Show Dashboard on Startup",
                    desc = "If enabled, the dashboard will be shown when you log in.",
                    get = function(info) return KillCounter.db.profile.showDashboard end,
                    set = function(info, value) KillCounter.db.profile.showDashboard = value end,
                    order = 4,
                },
                resetSession = {
                    type = "execute",
                    name = "Reset Session",
                    desc = "Clears all the kill counters for the current session",
                    func = function(info, value) KillCounter:ResetSessionKills() end,
                    order = 5,
                },
                resetTotal = {
                    type = "execute",
                    name = "Reset All",
                    desc = "Clears all the kill counters",
                    func = function(info, value) StaticPopup_Show("KILL_COUNTER_RESET_ALL") end,
                    order = 6,
                }
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

StaticPopupDialogs["KILL_COUNTER_RESET_ALL"] = {
  text = "This will delete all the data you have about enemies. Are you sure you want to continue?",
  button1 = "Yes",
  button2 = "No",
  OnAccept = function()
      KillCounter:ResetAllKills()
  end,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  preferredIndex = 3,  -- avoid some UI taint, see http://www.wowace.com/announcements/how-to-avoid-some-ui-taint/
}
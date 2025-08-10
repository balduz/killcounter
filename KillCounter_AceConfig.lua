
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
        dashboardLocked = false,
        dashboardOpacity = 0.7,
        dashboardPosition = {},
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
                    name = "Show Dashboard",
                    desc = "Toggles the dashboard visibility.",
                    get = function(info) return KillCounter.db.profile.showDashboard end,
                    set = function(info, value)
                        KillCounter.db.profile.showDashboard = value
                        if value then
                            KillCounter:ToggleDashboard(true)
                        else
                            KillCounter:ToggleDashboard(false)
                        end
                    end,
                    order = 4,
                },
                dashboardLocked = {
                    type = "toggle",
                    name = "Lock Dashboard",
                    desc = "Toggles whether the dashboard can be moved.",
                    get = function(info) return KillCounter.db.profile.dashboardLocked end,
                    set = function(info, value)
                        KillCounter.db.profile.dashboardLocked = value
                        KillCounter:SetDashboardLocked(value)
                    end,
                    order = 5,
                },
                dashboardOpacity = {
                    type = "range",
                    name = "Dashboard Opacity",
                    desc = "Adjusts the background opacity of the dashboard.",
                    min = 0,
                    max = 1,
                    step = 0.1,
                    get = function(info) return KillCounter.db.profile.dashboardOpacity end,
                    set = function(info, value)
                        KillCounter.db.profile.dashboardOpacity = value
                        KillCounter:SetDashboardOpacity(value)
                    end,
                    order = 6,
                },
                resetSession = {
                    type = "execute",
                    name = "Reset Session",
                    desc = "Clears all the kill counters for the current session",
                    func = function(info, value) KillCounter:ResetSessionKills() end,
                    order = 7,
                },
                resetTotal = {
                    type = "execute",
                    name = "Reset All",
                    desc = "Clears all the kill counters",
                    func = function(info, value) StaticPopup_Show("KILL_COUNTER_RESET_ALL") end,
                    order = 8,
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

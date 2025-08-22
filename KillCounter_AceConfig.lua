-- KillCounter_AceConfig.lua
-- Defines the addon's options panel and slash commands using AceConfig-3.0

local AceAddon = LibStub("AceAddon-3.0")
local KillCounter = AceAddon:GetAddon("KillCounter")

-- Localize Ace3 Libs
local AceDB = LibStub("AceDB-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

-- Localize WoW API functions
local StaticPopup_Show = StaticPopup_Show
local StaticPopupDialogs = StaticPopupDialogs
local tonumber = tonumber
local print = print
local string = string

function KillCounter:OnAce3Initialize()
    -- Default settings for the addon.
    local defaults = {
        profile = {
            enableKillCounter = true,
            showTotalKills = true,
            showSessionKills = true,
            showDashboard = true,
            dashboardLocked = false,
            dashboardResizeLocked = false,
            dashboardOpacity = 0.7,
            dashboardFontSize = 12,
            dashboardWidth = 220,
            dashboardHeight = 180,
            dashboardPosition = {},
            kills = {},
            enemyNames = {},
        }
    }

    -- Initialize the database with the defaults.
    self.db = AceDB:New("KillCounterEnhancedDB", defaults, true)

    -- Define a single, unified options table for both the GUI and slash commands.
    self.options = {
        type = "group",
        name = "Kill Counter",
        args = {
            -- GUI Options (visible in the panel because they have an 'order')
            general = {
                type = "group",
                name = "General Settings",
                order = 1,
                args = {
                    enable = {
                        type = "toggle",
                        name = "Enable Kill Counter",
                        desc = "Toggles the Kill Counter on or off.",
                        get = function(info) return self.db.profile.enableKillCounter end,
                        set = function(info, value) self.db.profile.enableKillCounter = value end,
                        order = 1,
                    },
                    showTotalKills = {
                        type = "toggle",
                        name = "Show Total Kills in Tooltip",
                        desc = "Displays the total number of kills for a mob in the tooltip.",
                        get = function(info) return self.db.profile.showTotalKills end,
                        set = function(info, value) self.db.profile.showTotalKills = value end,
                        order = 2,
                    },
                    showSessionKills = {
                        type = "toggle",
                        name = "Show Session Kills in Tooltip",
                        desc = "Displays the number of kills for a mob in the current session in the tooltip.",
                        get = function(info) return self.db.profile.showSessionKills end,
                        set = function(info, value) self.db.profile.showSessionKills = value end,
                        order = 3,
                    },
                },
            },
            dashboard = {
                type = "group",
                name = "Dashboard",
                order = 2,
                args = {
                    showDashboard = {
                        type = "toggle",
                        name = "Show Dashboard",
                        desc = "Toggles the dashboard visibility.",
                        get = function(info) return self.db.profile.showDashboard end,
                        set = function(info, value)
                            self.db.profile.showDashboard = value
                            self:ToggleDashboard(value)
                        end,
                        order = 1,
                    },
                    dashboardLocked = {
                        type = "toggle",
                        name = "Lock Dashboard Position",
                        desc = "Toggles whether the dashboard can be moved.",
                        get = function(info) return self.db.profile.dashboardLocked end,
                        set = function(info, value)
                            self.db.profile.dashboardLocked = value
                            self:SetDashboardLocked(value)
                        end,
                        order = 2,
                    },
                    dashboardResizeLocked = {
                        type = "toggle",
                        name = "Lock Dashboard Size",
                        desc = "Toggles whether the dashboard can be resized.",
                        get = function(info) return self.db.profile.dashboardResizeLocked end,
                        set = function(info, value)
                            self.db.profile.dashboardResizeLocked = value
                            self:SetDashboardResizeLocked(value)
                        end,
                        order = 3,
                    },
                    dashboardOpacity = {
                        type = "range",
                        name = "Dashboard Opacity",
                        desc = "Adjusts the background opacity of the dashboard.",
                        min = 0, max = 1, step = 0.05,
                        get = function(info) return self.db.profile.dashboardOpacity end,
                        set = function(info, value)
                            self.db.profile.dashboardOpacity = value
                            self:SetDashboardOpacity(value)
                        end,
                        order = 4,
                    },
                    dashboardFontSize = {
                        type = "range",
                        name = "Dashboard Font Size",
                        desc = "Adjusts the font size of the dashboard.",
                        min = 8, max = 20, step = 1,
                        get = function(info) return self.db.profile.dashboardFontSize end,
                        set = function(info, value)
                            self.db.profile.dashboardFontSize = value
                            self:SetDashboardFontSize(value)
                        end,
                        order = 5,
                    },
                },
            },
            reset = {
                type = "group",
                name = "Data Management",
                order = 3,
                args = {
                    resetSession = {
                        type = "execute",
                        name = "Reset Session Kills",
                        desc = "Clears all the kill counters for the current session.",
                        func = function() self:ResetSessionKills() end,
                        order = 1,
                    },
                    resetTotal = {
                        type = "execute",
                        name = "Reset All Kills",
                        desc = "Clears all persistent and session kill counters.",
                        func = function() StaticPopup_Show("KILL_COUNTER_RESET_ALL") end,
                        order = 2,
                    },
                },
            },

            -- Slash Command Handlers (hidden from the GUI because they lack an 'order')
            slash_reset = {
                type = "group",
                name = "reset",
                desc = "Reset kill data",
                hidden = true, -- This keeps it out of the GUI panel
                args = {
                    session = {
                        type = "execute",
                        name = "session",
                        desc = "Reset session kill data",
                        func = function() self:ResetSessionKills() end,
                    },
                    all = {
                        type = "execute",
                        name = "all",
                        desc = "Reset all kill data",
                        func = function() StaticPopup_Show("KILL_COUNTER_RESET_ALL") end,
                    },
                }
            },
            slash_show = {
                type = "input",
                name = "show",
                desc = "Show kills for a specific enemy ID",
                hidden = true, -- This keeps it out of the GUI panel
                set = function(info, input)
                    local enemyID = tonumber(input)
                    if enemyID then
                        local enemyName = self.db.profile.enemyNames[enemyID] or "Unknown"
                        local totalKills = self.db.profile.kills[enemyID] or 0
                        local sessionKills = self.db.sessionKills[enemyID] or 0
                        print(string.format("|cFF00FF00KillCounter:|r %s (ID: %d) - Total: %d, Session: %d", enemyName, enemyID, totalKills, sessionKills))
                    else
                        print("|cFFFF0000KillCounter:|r Invalid enemy ID. Please provide a number.")
                    end
                end,
            },
        },
    }

    -- Register the single, unified options table.
    AceConfig:RegisterOptionsTable("KillCounter", self.options)
    -- Add the GUI part to the Blizzard Interface Options panel.
    AceConfigDialog:AddToBlizOptions("KillCounter", "Kill Counter")

    -- Register the chat commands with AceConsole.
    self:RegisterChatCommand("kc", "ChatCommand")
    self:RegisterChatCommand("killcounter", "ChatCommand")
end

-- This is the simplified handler function that AceConsole will call.
function KillCounter:ChatCommand(input)
    -- If the user just types /kc, open the options panel.
    if not input or input:trim() == "" then
        LibStub("AceConfigDialog-3.0"):Open("KillCounter")
        return
    end
    -- Otherwise, let AceConfig process the input (e.g., "reset session").
    LibStub("AceConfig-3.0"):HandleOptions(self.options, input)
end


-- Create a confirmation dialog for resetting all data.
StaticPopupDialogs["KILL_COUNTER_RESET_ALL"] = {
  text = "This will permanently delete all recorded kill data. Are you sure?",
  button1 = "Yes",
  button2 = "No",
  OnAccept = function()
      KillCounter:ResetAllKills()
  end,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
  preferredIndex = 3,
}

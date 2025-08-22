-- KillCounter_AceConfig.lua
-- Defines the addon's options panel and slash commands using AceConfig-3.0

local AceAddon = LibStub("AceAddon-3.0")
local KillCounter = AceAddon:GetAddon("KillCounter")

-- Localize WoW API functions
local StaticPopup_Show = StaticPopup_Show
local StaticPopupDialogs = StaticPopupDialogs
local tonumber = tonumber
local print = print
local string = string

function KillCounter:OnAce3Initialize()
    -- Store library references on the addon object itself to avoid scope issues.
    self.AceDB = LibStub("AceDB-3.0")
    self.AceConfig = LibStub("AceConfig-3.0")
    self.AceConfigDialog = LibStub("AceConfigDialog-3.0")

    -- Default settings for the addon.
    local defaults = {
        profile = {
            enableKillCounter = true,
            showTotalKills = true,
            showSessionKills = true,
            showKphInTooltip = true, -- ADDED: New default for KPH
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
    self.db = self.AceDB:New("KillCounterEnhancedDB", defaults, true)

    -- Define the options table for the GUI settings panel.
    local options = {
        type = "group",
        name = "Kill Counter",
        args = {
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
                    -- ADDED: New toggle for KPH in the options panel
                    showKphInTooltip = {
                        type = "toggle",
                        name = "Show Kills/Hr in Tooltip",
                        desc = "Displays the kills per hour for a mob in the current session.",
                        get = function(info) return self.db.profile.showKphInTooltip end,
                        set = function(info, value) self.db.profile.showKphInTooltip = value end,
                        order = 4,
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
            data_management = {
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
        }
    }

    -- Register the options table.
    self.AceConfig:RegisterOptionsTable("KillCounter", options)
    -- Add the GUI part to the Blizzard Interface Options panel.
    self.AceConfigDialog:AddToBlizOptions("KillCounter", "Kill Counter")

    -- Register the chat commands with AceConsole.
    self:RegisterChatCommand("kc", "ChatCommand")
    self:RegisterChatCommand("killcounter", "ChatCommand")
end

-- This is the handler function that AceConsole will call.
-- It now manually parses the input string.
function KillCounter:ChatCommand(input)
    input = input and input:trim():lower() or ""

    if input == "" then
        self.AceConfigDialog:Open("KillCounter")
    elseif input == "help" then
        print("|cFF00FF00Kill Counter Commands:|r")
        print("/kc - Opens the configuration panel")
        print("/kc help - Show this help")
        print("/kc reset all - Reset all kill data")
        print("/kc reset session - Reset session kill data")
        print("/kc show [enemyID] - Show kills for specific enemy")
    elseif input == "reset session" then
        self:ResetSessionKills()
    elseif input == "reset all" then
        StaticPopup_Show("KILL_COUNTER_RESET_ALL")
    else
        -- Handle commands with arguments, like "show 12345"
        local command, arg = input:match("^(%S+)%s+(.*)$")
        if command == "show" and arg then
            local enemyID = tonumber(arg)
            if enemyID then
                local enemyName = self.db.profile.enemyNames[enemyID] or "Unknown"
                local totalKills = self.db.profile.kills[enemyID] or 0
                local sessionKills = self.db.sessionKills[enemyID] or 0
                print(string.format("|cFF00FF00KillCounter:|r %s (ID: %d) - Total: %d, Session: %d", enemyName, enemyID, totalKills, sessionKills))
            else
                print("|cFFFF0000KillCounter:|r Invalid enemy ID. Please provide a number.")
            end
        else
            print("|cFFFF0000KillCounter:|r Unknown command. Type '/kc help' for a list of commands.")
        end
    end
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


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
        displayMode = "chat", -- "chat" or "frame"
        showPlayerKills = true,
        showNPCKills = true,
        resetOnZoneChange = false,
        showOverallKills = true,
        showSessionKills = true,
        announceKills = true,
        announceChannel = "SAY", -- "SAY", "EMOTE", "PARTY", "RAID", "GUILD", "WHISPER"
        framePositionX = 0,
        framePositionY = 0,
        kills = {},
        lootTracking = {},
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
                displayMode = {
                    type = "select",
                    name = "Display Mode",
                    desc = "Choose how kill counts are displayed.",
                    values = {
                        chat = "Chat Frame",
                        frame = "Movable Frame",
                    },
                    get = function(info) return KillCounter.db.profile.displayMode end,
                    set = function(info, value) KillCounter.db.profile.displayMode = value end,
                    order = 2,
                },
                showPlayerKills = {
                    type = "toggle",
                    name = "Show Player Kills",
                    desc = "Display kills against other players.",
                    get = function(info) return KillCounter.db.profile.showPlayerKills end,
                    set = function(info, value) KillCounter.db.profile.showPlayerKills = value end,
                    order = 3,
                },
                showNPCKills = {
                    type = "toggle",
                    name = "Show NPC Kills",
                    desc = "Display kills against NPCs.",
                    get = function(info) return KillCounter.db.profile.showNPCKills end,
                    set = function(info, value) KillCounter.db.profile.showNPCKills = value end,
                    order = 4,
                },
                resetOnZoneChange = {
                    type = "toggle",
                    name = "Reset on Zone Change",
                    desc = "Resets kill counts when you enter a new zone.",
                    get = function(info) return KillCounter.db.profile.resetOnZoneChange end,
                    set = function(info, value) KillCounter.db.profile.resetOnZoneChange = value end,
                    order = 5,
                },
            },
        },
        announcements = {
            type = "group",
            name = "Announcement Settings",
            args = {
                announceKills = {
                    type = "toggle",
                    name = "Announce Kills",
                    desc = "Announce your kills in chat.",
                    get = function(info) return KillCounter.db.profile.announceKills end,
                    set = function(info, value) KillCounter.db.profile.announceKills = value end,
                    order = 1,
                },
                announceChannel = {
                    type = "select",
                    name = "Announcement Channel",
                    desc = "Choose the chat channel for announcements.",
                    values = {
                        SAY = "Say",
                        EMOTE = "Emote",
                        PARTY = "Party",
                        RAID = "Raid",
                        GUILD = "Guild",
                        WHISPER = "Whisper (Target)",
                    },
                    get = function(info) return KillCounter.db.profile.announceChannel end,
                    set = function(info, value) KillCounter.db.profile.announceChannel = value end,
                    disabled = function(info) return not KillCounter.db.profile.announceKills end,
                    order = 2,
                },
            },
        },
        frame = {
            type = "group",
            name = "Frame Settings",
            args = {
                framePositionX = {
                    type = "range",
                    name = "Frame X Position",
                    desc = "Adjust the X position of the movable frame.",
                    min = -1000, max = 1000, step = 1,
                    get = function(info) return KillCounter.db.profile.framePositionX end,
                    set = function(info, value) KillCounter.db.profile.framePositionX = value end,
                    disabled = function(info) return KillCounter.db.profile.displayMode ~= "frame" end,
                    order = 1,
                },
                framePositionY = {
                    type = "range",
                    name = "Frame Y Position",
                    desc = "Adjust the Y position of the movable frame.",
                    min = -1000, max = 1000, step = 1,
                    get = function(info) return KillCounter.db.profile.framePositionY end,
                    set = function(info, value) KillCounter.db.profile.framePositionY = value end,
                    disabled = function(info) return KillCounter.db.profile.displayMode ~= "frame" end,
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

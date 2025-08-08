# Enhanced Kill Counter - WoW Classic Addon

A lightweight addon for World of Warcraft Classic that tracks enemy kills, providing both total and session-based statistics. It integrates seamlessly with the game's interface, displaying kill counts directly in unit tooltips and offering detailed reports via slash commands.

## Features

- **Automatic Kill Tracking**: Automatically records kills of enemies by the player or their party/raid.
- **Total Kill Counts**: Maintains a persistent record of all kills for each unique enemy across game sessions.
- **Session Kill Counts**: Tracks kills specifically within the current game session, which can be reset.
- **Tooltip Integration**: Displays total and session kill counts directly in the tooltip when mousing over an enemy unit. This feature can be toggled on or off via the in-game options.
- **Slash Commands**: Provides a set of intuitive slash commands for managing and viewing kill data:
    - `/kc` or `/killcounter`: Shows a summary of all total and session kill counts.
    - `/kc help`: Displays a list of available commands.
    - `/kc reset all`: Resets all recorded total and session kill data.
    - `/kc reset session`: Resets only the kill data for the current session.
    - `/kc [enemyID]`: Shows detailed total and session kill counts for a specific enemy by its NPC ID.
- **Configuration Options**: Accessible via Blizzard's Interface Options panel, allowing users to:
    - Enable or disable the Kill Counter addon.
    - Toggle the display of total kills in unit tooltips.
    - Toggle the display of session kills in unit tooltips.

## Installation

1. Download or extract the addon files to your WoW Classic AddOns folder:
   ```
   World of Warcraft\_classic_\Interface\AddOns\KillCounter\
   ```

2. Make sure the folder structure looks like this:
   ```
   KillCounter\
   ├── KillCounter.toc
   ├── KillCounter_Core.lua
   ├── KillCounter_DB.lua
   ├── KillCounter_Events.lua
   ├── KillCounter_UI.lua
   ├── KillCounter_AceConfig.lua
   └── README.md
   ```

3. Restart WoW Classic or reload your UI (`/reload`)

## Usage

### Commands

- `/kc` or `/killcounter` - Show a summary of all total and session kill counts.
- `/kc help` - Show help information.
- `/kc reset all` - Reset all total and session kill data.
- `/kc reset session` - Reset only session kill data.
- `/kc [enemyID]` - Show kills for a specific enemy by its NPC ID.

### How It Works

The addon monitors `COMBAT_LOG_EVENT_UNFILTERED` events and automatically detects when you or your party/raid kill an enemy. Each kill is added to your statistics, and the unit tooltip is updated in real-time when mousing over an enemy.

## Files

- `KillCounter.toc` - Addon metadata and file references
- `KillCounter_Core.lua` - Core addon functionality and initialization
- `KillCounter_DB.lua` - Defines the SavedVariables structure (managed by AceDB-3.0)
- `KillCounter_Events.lua` - Handles combat and game events for kill tracking
- `KillCounter_UI.lua` - Manages slash commands and tooltip integration
- `KillCounter_AceConfig.lua` - Defines default settings and configuration options for the in-game interface
- `README.md` - This documentation file

## Compatibility

- **WoW Classic**: Interface version 11404
- **WoW Classic Era**: Should work with current Classic Era servers
- **WoW Classic Wrath**: May need interface version update

## Troubleshooting

1. **Addon not loading**: Check that the files are in the correct folder and the TOC file is properly formatted.
2. **Kills not counting**: Ensure you or your party/raid are responsible for the killing blow.
3. **Tooltip not showing kills**: Check the in-game Interface Options for "Kill Counter" to ensure "Show Total Kills" and "Show Session Kills" are enabled.
4. **Data not saving**: The addon uses SavedVariables, which should persist between sessions. Ensure no other addons are interfering with SavedVariables.

## Customization

You can modify the addon by editing the Lua files directly to change behavior or add new features. Familiarity with Lua and the WoW API is recommended.

## License

This addon is provided as-is for personal use. Feel free to modify and distribute as needed.

## Support

If you encounter any issues or have suggestions for improvements, please check the troubleshooting section above or create an issue in the project repository.
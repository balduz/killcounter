# Enhanced Kill Counter - WoW Classic Addon

A feature-rich addon for World of Warcraft Classic that tracks how many enemies of each type you have killed and displays a dashboard on your screen with advanced features.

## Features

- **Automatic Kill Tracking**: Automatically counts kills when you defeat enemies
- **Dashboard Display**: Shows a movable dashboard with your kill statistics
- **Kill Notifications**: Displays a brief notification when you kill an enemy
- **Persistent Data**: Your kill data is saved between sessions
- **Sortable List**: Shows your most killed enemies (configurable limit)
- **Filtering System**: Search for specific enemies in your kill list
- **Settings Panel**: Customize notifications, display options, and more
- **Export Functionality**: Export your kill data for external use
- **Advanced Controls**: Enhanced slash commands and interface options

## Installation

1. Download or extract the addon files to your WoW Classic AddOns folder:
   ```
   World of Warcraft\_classic_\Interface\AddOns\KillCounter\
   ```

2. Make sure the folder structure looks like this:
   ```
   KillCounter\
   ├── KillCounter.toc
   ├── KillCounter.lua
   └── README.md
   ```

3. Restart WoW Classic or reload your UI (`/reload`)

4. The addon should load automatically and you'll see a message: "Enhanced Kill Counter addon loaded. Type /kce for commands."

## Usage

### Commands

- `/kce` or `/killcounterenhanced` - Show/hide the kill counter dashboard
- `/kce show` - Show the dashboard
- `/kce hide` - Hide the dashboard
- `/kce reset` - Reset all kill data
- `/kce settings` - Open settings panel
- `/kce export` - Export kill data
- `/kce help` - Show help information

### Interface

- **Dashboard**: A movable window showing your kill statistics
- **Toggle Button**: A button below the dashboard to show/hide it
- **Close Button**: X button in the top-right corner of the dashboard
- **Filter Input**: Search box to filter enemies by name
- **Sort Button**: Toggle between sorting by kill count or enemy name
- **Settings Panel**: Configure notifications, display limits, and auto-show options
- **Export Window**: View and copy your kill data
- **Drag**: Click and drag the dashboard to move it around the screen

### How It Works

The addon monitors combat log events and automatically detects when you kill an enemy. Each kill is added to your statistics and the dashboard is updated in real-time.

## Files

- `KillCounter.toc` - Addon metadata and file references
- `KillCounter.lua` - Main addon code (enhanced version)
- `README.md` - This documentation file

## Compatibility

- **WoW Classic**: Interface version 11404
- **WoW Classic Era**: Should work with current Classic Era servers
- **WoW Classic Wrath**: May need interface version update

## Troubleshooting

1. **Addon not loading**: Check that the files are in the correct folder and the TOC file is properly formatted
2. **Kills not counting**: Make sure you're the one dealing the killing blow to enemies
3. **Dashboard not showing**: Try `/kc show` or check if the addon is enabled in the addon list
4. **Data not saving**: The addon uses SavedVariables, which should persist between sessions

## Customization

You can modify the addon by editing `KillCounter.lua`:

- Change the dashboard position by modifying the `SetPoint` calls
- Adjust the dashboard size by changing the `SetSize` values
- Modify colors by changing the `SetColorTexture` values
- Add more features by extending the existing functions

## License

This addon is provided as-is for personal use. Feel free to modify and distribute as needed.

## Support

If you encounter any issues or have suggestions for improvements, please check the troubleshooting section above or create an issue in the project repository. 
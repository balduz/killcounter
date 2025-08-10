# Kill Counter

A lightweight addon for World of Warcraft that tracks enemy kills, providing both total and session-based statistics.

## Features

- **Automatic Kill Tracking**: Automatically records every time you kill an enemy.
- **Persistent Totals**: Keeps a running total of all kills for each unique enemy.
- **Session Kills**: Tracks kills within your current game session.
- **Informative Dashboard**: A movable and customizable dashboard that displays your top total and session kills in real-time.
- **Tooltip Integration**: See total and session kill counts directly in the tooltip when you mouse over an enemy.
- **Configuration Options**: Use the in-game Interface Options panel to:
    - Toggle the addon on or off.
    - Show or hide the dashboard.
    - Lock the dashboard's position.
    - Adjust the dashboard's opacity.
    - Toggle the kill display in tooltips.

## Installation

1.  Download the addon.
2.  Extract the `KillCounter` folder into your `World of Warcraft\_classic_era_\Interface\AddOns\` directory.
3.  Restart World of Warcraft or reload your UI by typing `/reload` in the chat.

## Usage

The addon works automatically upon installation. You can configure its features in the Interface Options menu under "Kill Counter".

You can also use the following slash commands:

-   `/kc` or `/killcounter`: Opens the configuration panel.
-   `/kc help`: Displays a list of available commands.
-   `/kc reset all`: Resets all recorded kill data.
-   `/kc reset session`: Resets only the kill data for the current session.
-   `/kc [enemyID]`: Shows total and session kill counts for a specific enemy by its ID.

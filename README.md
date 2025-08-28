# Kill Counter
A lightweight addon to track enemy kills, providing both total and session-based numbers.

![Dashboard Preview](https://raw.githubusercontent.com/balduz/killcounter/main/screenshots/dashboard_example.jpg)

## Features
- **Kill Tracking**: records every time you kill an enemy.
- **Persistent Totals**: keeps a running total of all kills for each unique enemy.
- **Session Kills**: tracks kills within your current game session.
- **Kills Per Hour (KPH)**: see your farming efficiency with a KPH tracker.
- **Informative Dashboard**: a customizable dashboard that displays your top total and session kills.
- **Tooltip Integration**: see total kills, session kills, and KPH directly in the tooltip when you mouse over an enemy.

![Tooltip Preview](https://raw.githubusercontent.com/balduz/killcounter/main/screenshots/tooltip_example.jpg)

## Usage
The addon works automatically upon installation. You can configure its features in the Interface Options menu under "Kill Counter".

You can also use the following slash commands:

- `/kc or /killcounter`: Opens the configuration panel.
- `/kc help`: Displays a list of available commands.
- `/kc reset all`: Resets all recorded kill data for the current profile.
- `/kc reset session`: Resets only the kill data for the current session.
- `/kc show [enemyID]`: Shows total and session kill counts for a specific enemy by its ID.

## Customization
You can customize the dashboard to your liking:

- Dashboard opacity.
- Total number of kills displayed.
- Whether to see total kills only, session kills only, or both.
- Font size.
- Resize or move the dashboard, and lock it from the settings when happy.
- Change the KPH inactivity timer.

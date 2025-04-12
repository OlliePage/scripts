# Opal Startup Monitor

A bash script that ensures the Opal application is running on system startup or restarts it if it's not active.

## Features

- Automatically launches Opal if it's not running
- Prevents multiple instances by using a lock file
- Logs all activity for troubleshooting
- Can be used as a cron job for periodic checking
- Waits 24 hours before checking again (unless system restarts)

## Installation

1. Save the script to your preferred location:
   ```
   mkdir -p ~/scripts
   cp opal_startup_monitor.sh ~/scripts/
   chmod +x ~/scripts/opal_startup_monitor.sh
   ```

2. Add it to your crontab:
   ```
   crontab -e
   ```

3. Add these lines to run at startup and check every 10 minutes:
   ```
   @reboot ~/scripts/opal_startup_monitor.sh
   */10 * * * * ~/scripts/opal_startup_monitor.sh
   ```

## Usage

To run the script manually:
```
~/scripts/opal_startup_monitor.sh
```

To view logs:
```
cat ~/Library/Logs/opal_startup_monitor.log
```

## How It Works

- Uses `pgrep` to detect if Opal is already running
- Launches Opal with the `open` command if needed
- Creates a lock file to prevent multiple executions
- The lock expires after 24 hours or system restart
- All actions are logged to `~/Library/Logs/opal_startup_monitor.log`

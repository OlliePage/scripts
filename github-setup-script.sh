#!/bin/bash

# This script sets up a GitHub repository for your scripts directory

# Navigate to your scripts directory
cd ~/Developer/scripts

# Check if git is already initialized
if [ ! -d .git ]; then
  echo "Initializing git repository..."
  git init
else
  echo "Git repository already initialized."
fi

# Create main README.md file
cat > README.md << 'EOF'
# My Scripts Collection

This repository contains various utility scripts I've created or collected for automating tasks.

## Contents

- [Opal Startup Monitor](./opal_startup_monitor/README.md) - Ensures the Opal application is running on system startup
EOF

# Create directory for opal script
mkdir -p opal_startup_monitor

# Move the opal script to its directory if it exists in the main folder
if [ -f opal_startup_monitor.sh ]; then
  mv opal_startup_monitor.sh opal_startup_monitor/
elif [ -f ~/scripts/opal_startup_monitor.sh ]; then
  cp ~/scripts/opal_startup_monitor.sh opal_startup_monitor/
else
  # Create the opal script in its directory
  cat > opal_startup_monitor/opal_startup_monitor.sh << 'EOF'
#!/bin/bash

# Script to ensure Opal.app is running
# To be used as a cron job

# Path to application
OPAL_APP="/Applications/Opal.app"
# Log file for debugging
LOG_FILE="$HOME/Library/Logs/opal_startup_monitor.log"
# Lock file to prevent multiple instances from running
LOCK_FILE="/tmp/opal_startup_monitor.lock"

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Check if lock file exists and is recent (less than 24 hours old)
if [ -f "$LOCK_FILE" ]; then
    file_age=$(($(date +%s) - $(stat -f %m "$LOCK_FILE")))
    if [ $file_age -lt 86400 ]; then  # 86400 seconds = 24 hours
        log "Script already ran within last 24 hours. Exiting."
        exit 0
    else
        log "Lock file is older than 24 hours. Proceeding with check."
    fi
fi

# Create lock file
touch "$LOCK_FILE"

# Log script start
log "Starting Opal startup check"

# Check if Opal is already running
if pgrep -q -x "Opal" || pgrep -q -f "Opal.app"; then
    log "Opal is already running. No action needed."
    exit 0
fi

# If we reach here, Opal is not running. Let's start it.
log "Opal is not running. Attempting to start it."

# Check if the application exists
if [ ! -d "$OPAL_APP" ]; then
    log "Error: $OPAL_APP does not exist!"
    rm "$LOCK_FILE"
    exit 1
fi

# Launch Opal
open "$OPAL_APP"
log "Launched Opal application"

# Wait a few seconds to verify it started correctly
sleep 5

# Verify Opal is now running
if pgrep -q -x "Opal" || pgrep -q -f "Opal.app"; then
    log "Verified Opal is now running."
else
    log "Warning: Attempted to start Opal but couldn't verify it's running."
    # You could add more advanced retry logic here if needed
fi

log "Opal startup check completed"
exit 0
EOF
fi

# Make the script executable
chmod +x opal_startup_monitor/opal_startup_monitor.sh

# Create README for opal script
cat > opal_startup_monitor/README.md << 'EOF'
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
EOF

# Create .gitignore
cat > .gitignore << 'EOF'
# macOS system files
.DS_Store
.AppleDouble
.LSOverride
Icon
._*

# Logs
*.log

# Temporary files
*.tmp
*.swp
*.swo

# IDE files
.idea/
.vscode/
*.sublime-project
*.sublime-workspace
EOF

# Add all files to git
git add .

# Make initial commit
git commit -m "Initial commit with Opal startup script"

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
  echo "GitHub CLI (gh) is not installed. Please install it first:"
  echo "  brew install gh"
  echo "Then run 'gh auth login' to authenticate."
  exit 1
fi

# Check if authenticated with GitHub
if ! gh auth status &> /dev/null; then
  echo "Please authenticate with GitHub:"
  gh auth login
fi

# Create GitHub repository
echo "Creating GitHub repository 'scripts'..."
gh repo create scripts --public --source=. --remote=origin --push

echo "Repository created and pushed successfully!"
echo "View your repository at: https://github.com/$(gh api user | jq -r '.login')/scripts"

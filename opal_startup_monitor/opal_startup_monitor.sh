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

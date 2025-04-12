#!/bin/bash

# Script to check if notebook instance is running and start it if not
# Designed to be run as a cron job

# Configuration
PROJECT="jet-ml-dev"
LOCATION="europe-west1-b"
ENVIRONMENT="pricing-and-promotions-ukca"

# Log file setup
LOG_FILE="$HOME/notebook_checker.log"
echo "$(date): Notebook checker script started" >> "$LOG_FILE"

# Set the full path to gcloud
GCLOUD="/usr/local/bin/gcloud"

# Function to check if instance is running
check_instance_status() {
  # Check status of the environment
  status=$($GCLOUD workbench instances describe \
    --project=$PROJECT \
    --location=$LOCATION \
    $ENVIRONMENT 2>/dev/null)
  
  # If the command failed, assume the instance is not running
  if [ $? -ne 0 ]; then
    echo "NOT_RUNNING"
  else
    # Extract the state from the output
    state=$(echo "$status" | grep "state:" | awk '{print $2}')
    echo $state
  fi
}

# Function to check if current time is before end time
is_before_end_time() {
  local end_time="19:00"
  current_time=$(date +"%H:%M")
  if [[ "$current_time" < "$end_time" ]]; then
    return 0  # True in bash
  else
    return 1  # False in bash
  fi
}

# Check if we should run based on time
if ! is_before_end_time; then
  echo "$(date): Current time is after 19:00. Exiting." >> "$LOG_FILE"
  exit 0
fi

# Main execution
echo "$(date): Checking if environment $ENVIRONMENT is running..." >> "$LOG_FILE"
status=$(check_instance_status)

if [[ "$status" != "ACTIVE" && "$status" != "RUNNING" ]]; then
  echo "$(date): Instance is not running (status: $status). Starting instance..." >> "$LOG_FILE"
  
  # Using the exact command format that works, as provided by the user
  echo "$(date): Executing: $GCLOUD workbench instances start --project=$PROJECT --location=$LOCATION $ENVIRONMENT" >> "$LOG_FILE"
  
  $GCLOUD workbench instances start \
    --project=$PROJECT \
    --location=$LOCATION \
    $ENVIRONMENT >> "$LOG_FILE" 2>&1
  
  start_result=$?
  if [ $start_result -eq 0 ]; then
    echo "$(date): Start command succeeded." >> "$LOG_FILE"
  else
    echo "$(date): Start command failed with exit code $start_result." >> "$LOG_FILE"
  fi
  
  # Wait for a bit and check new status
  sleep 30
  
  new_status=$(check_instance_status)
  echo "$(date): New instance status: $new_status" >> "$LOG_FILE"
else
  echo "$(date): Instance is already running (status: $status). No action needed." >> "$LOG_FILE"
fi
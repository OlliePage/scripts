#!/bin/bash

# Script to check if instance is running and execute awake.py
# Runs every 45 minutes but not after a randomized time around 19:00 (±17 minutes)

# Configuration
PROJECT="jet-ml-dev"
LOCATION="europe-west1-b"
ENVIRONMENT="pricing-and-promotions-ukca"
PYTHON_SCRIPT_PATH="/home/jupyter/ollie/awake.py"

# Log file setup - Using absolute path
LOG_FILE="/Users/oliver.page/Developer/scripts/script_executor.log"
echo "$(date): Awake script executor started" >> "$LOG_FILE"

# Set the full path to gcloud and python
GCLOUD="/usr/local/bin/gcloud"
PYTHON="python3"

# Function to check if current time is before randomized end time
is_before_end_time() {
  # Base end time is 19:00 (19 hours, 0 minutes)
  local base_hour=19
  local base_minute=0
  
  # Generate a random offset between -17 and +17 minutes
  # We'll use the day of month as a seed to keep it consistent for the day
  day_of_month=$(date +"%d")
  # Use the day of month to generate a deterministic "random" number between 0 and 34
  random_offset=$(( (day_of_month * 7) % 35 - 17 ))
  
  # Calculate the end minutes with the random offset
  end_minute=$(( base_minute + random_offset ))
  end_hour=$base_hour
  
  # Adjust hour if minutes roll over
  if [ $end_minute -ge 60 ]; then
    end_hour=$(( end_hour + 1 ))
    end_minute=$(( end_minute - 60 ))
  elif [ $end_minute -lt 0 ]; then
    end_hour=$(( end_hour - 1 ))
    end_minute=$(( end_minute + 60 ))
  fi
  
  # Format the end time for comparison
  end_time=$(printf "%02d:%02d" $end_hour $end_minute)
  current_time=$(date +"%H:%M")
  
  echo "$(date): Today's randomized end time is $end_time (base 19:00 ± random offset)" >> "$LOG_FILE"
  
  if [[ "$current_time" < "$end_time" ]]; then
    return 0  # True in bash
  else
    return 1  # False in bash
  fi
}

# Check if we should run based on time
if ! is_before_end_time; then
  echo "$(date): Current time is after today's randomized end time. Exiting." >> "$LOG_FILE"
  exit 0
fi

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

# Function to execute the Python script on the instance
execute_python_script() {
  echo "$(date): Executing Python script $PYTHON_SCRIPT_PATH..." >> "$LOG_FILE"
  
  # Use SSH to connect to the instance and run the Python script with python3
  $GCLOUD compute ssh \
    --project=$PROJECT \
    --zone=$LOCATION \
    $ENVIRONMENT \
    --command="$PYTHON $PYTHON_SCRIPT_PATH" >> "$LOG_FILE" 2>&1
  
  exec_result=$?
  if [ $exec_result -eq 0 ]; then
    echo "$(date): Python script execution succeeded." >> "$LOG_FILE"
    
    # Check the Python script output log
    echo "$(date): Checking Python script log..." >> "$LOG_FILE"
    $GCLOUD compute ssh \
      --project=$PROJECT \
      --zone=$LOCATION \
      $ENVIRONMENT \
      --command="tail -10 /tmp/awake_activity.log" >> "$LOG_FILE" 2>&1
  else
    echo "$(date): Python script execution failed with exit code $exec_result." >> "$LOG_FILE"
  fi
}

# Main execution
echo "$(date): Checking if environment $ENVIRONMENT is running..." >> "$LOG_FILE"
status=$(check_instance_status)

if [[ "$status" != "ACTIVE" && "$status" != "RUNNING" ]]; then
  echo "$(date): Instance is not running (status: $status). Starting instance..." >> "$LOG_FILE"
  
  $GCLOUD workbench instances start \
    --project=$PROJECT \
    --location=$LOCATION \
    $ENVIRONMENT >> "$LOG_FILE" 2>&1
  
  start_result=$?
  if [ $start_result -eq 0 ]; then
    echo "$(date): Start command succeeded." >> "$LOG_FILE"
  else
    echo "$(date): Start command failed with exit code $start_result." >> "$LOG_FILE"
    echo "$(date): Exiting due to failure to start instance." >> "$LOG_FILE"
    exit 1
  fi
  
  # Wait for instance to fully start before executing the script
  echo "$(date): Waiting for instance to become ready..." >> "$LOG_FILE"
  sleep 120
  
  new_status=$(check_instance_status)
  echo "$(date): New instance status: $new_status" >> "$LOG_FILE"
  
  if [[ "$new_status" == "ACTIVE" || "$new_status" == "RUNNING" ]]; then
    # Execute the Python script
    execute_python_script
  else
    echo "$(date): Instance did not reach running state. Cannot execute Python script." >> "$LOG_FILE"
  fi
else
  echo "$(date): Instance is already running (status: $status)." >> "$LOG_FILE"
  # Execute the Python script
  execute_python_script
fi

echo "$(date): Script completed." >> "$LOG_FILE"
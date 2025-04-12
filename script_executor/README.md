# Script Executor

A bash script that checks if a Vertex AI instance is running, starts it if needed, and executes a Python script on the instance.

## Features

- Checks and starts Vertex AI notebook instances if not running
- Executes a specified Python script on the remote instance
- Implements a randomized daily cutoff time (around 19:00 ±17 minutes)
- Logs all activities for monitoring and troubleshooting
- Waits for instance startup before executing the script

## Installation

1. Save the script to your preferred location:
   ```
   chmod +x script_executor.sh
   ```

2. Add it to your crontab to run periodically:
   ```
   crontab -e
   ```

3. Add this line to run every 45 minutes:
   ```
   */45 9-19 * * 1-5 ~/scripts/script_executor/script_executor.sh
   ```

## Configuration

Edit the script to set these variables:
- `PROJECT`: Your Google Cloud project ID
- `LOCATION`: The zone where your notebook is located
- `ENVIRONMENT`: The name of your notebook instance
- `PYTHON_SCRIPT_PATH`: Path to the Python script on the remote instance
- `LOG_FILE`: Path to the log file

## How It Works

- Determines a randomized cutoff time based on the day of month
- Checks if the instance is running and starts it if necessary
- Waits for the instance to reach the running state
- Executes the Python script on the remote instance via SSH
- Logs the output of the Python script execution
- All actions are logged to the specified log file
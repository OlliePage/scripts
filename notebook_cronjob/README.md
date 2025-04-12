# Notebook Cronjob

A bash script designed to check if a Vertex AI notebook instance is running and start it if necessary. Perfect for scheduling as a cron job.

## Features

- Automatically starts Vertex AI workbench instances when they're not running
- Logs all activity for monitoring and troubleshooting
- Includes time-based execution control (stops running after 19:00)
- Configurable for different projects and instances

## Installation

1. Save the script to your preferred location:
   ```
   chmod +x notebook-cronjob.sh
   ```

2. Add it to your crontab to run periodically:
   ```
   crontab -e
   ```

3. Add this line to run every hour on weekdays:
   ```
   0 9-19 * * 1-5 ~/scripts/notebook_cronjob/notebook-cronjob.sh
   ```

## Configuration

Edit the script to set these variables:
- `PROJECT`: Your Google Cloud project ID
- `LOCATION`: The zone where your notebook is located
- `ENVIRONMENT`: The name of your notebook instance
- `LOG_FILE`: Path to the log file

## How It Works

- Checks if the current time is before the cutoff time (19:00)
- Queries the status of the specified notebook instance
- If the instance is not running, initiates the startup process
- All actions are logged to the specified log file for monitoring
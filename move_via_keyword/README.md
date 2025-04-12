# Move via Keyword

A bash script that moves markdown files containing specific hashtags from an INBOX directory to a designated destination folder.

## Features

- Searches for markdown files in INBOX containing a specific hashtag
- Automatically moves matching files to a specified destination folder
- Outputs the names of moved files for verification

## Usage

```bash
./move-via-keyword.sh "#hashtag" "destination_folder"
```

### Parameters

- `hashtag`: The hashtag to search for (e.g., "#project" or "#work")
- `destination_folder`: The folder where matching files should be moved

### Example

```bash
./move-via-keyword.sh "#work" "~/Documents/Work"
```

## How It Works

- Iterates through all markdown files in the INBOX directory
- Uses grep to check if the specified hashtag exists in each file
- Moves files containing the hashtag to the destination folder
- Outputs the names of moved files for verification
# Find and Replace

A bash script that searches for files containing a specific string in an INBOX directory and replaces instances of that string.

## Features

- Searches all files in the INBOX directory for a specific string
- Performs find and replace operations across multiple files
- Preserves original files by creating backups before modification
- Skips directories during processing

## Usage

```bash
./find-and-replace.sh "search_string" "replacement_string"
```

### Parameters

- `search_string`: The text you want to find
- `replacement_string`: The text you want to replace it with

### Example

```bash
./find-and-replace.sh "TODO" "DONE"
```

## How It Works

- Iterates through all files in the INBOX directory
- Uses grep to check if the search string exists in each file
- Uses sed to perform the replacement if the string is found
- Creates a backup of each file before modifying it
- Removes backup files after successful replacement
- Outputs the names of modified files for verification
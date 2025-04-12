#!/bin/bash

# Set the hashtag and destination path from the arguments
hashtag=$1
destination=$2

# Find all markdown files containing the specified hashtag in the INBOX 

for file in INBOX/*.md; do
  if grep -q "$hashtag" "$file"; then
    # Echo the name of the file being moved
    echo "Moving file: $file"
    # Move the file to the specified destination
    mv "$file" "$destination"
  fi
done

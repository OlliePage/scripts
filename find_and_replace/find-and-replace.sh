#!/bin/bash

# Set the search string and replacement string from the arguments
search=$1
replace=$2

# Find all files in the INBOX directory that contain the search string
for file in INBOX/*; do
  # Skip directories
  if [ ! -d "$file" ]; then
    if grep -q "$search" "$file"; then
      # Echo the name of the file being modified
      echo "Modifying file: $file"
      # Modify the file using sed
      sed -i.bak "s/$search/$replace/g" "$file"
      # Delete the .bak file
      rm "$file.bak"
    fi
  fi
done

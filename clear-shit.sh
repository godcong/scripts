#!/bin/bash

# Check if directory parameters are provided, and if not, use the current directory
if [ -z "$1" ]; then
    TARGET_DIR="."
else
    TARGET_DIR="$1"
fi

# Use the find command to find and delete .DS_Store files
find "$TARGET_DIR" -type f -name ".DS_Store" -print0 | xargs -0 -P 4 -I {} rm -f {}

echo "All shits have been deleted."
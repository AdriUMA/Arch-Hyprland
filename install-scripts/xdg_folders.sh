#!/bin/bash
# XDG-User-Dirs creator #

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##

# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_xdg_folders.log"

# Folder list
folders=(
    "~/Downloads"
    "~/Templates"
    "~/Public"
    "~/Documents"
    "~/Music"
    "~/Pictures"
    "~/Videos"
)

# For each folder
for folder in "${folders[@]}"; do
    # Check if not exists
    if [ ! -d "$folder" ]; then
        # Create folder
        mkdir -p "$folder"
        echo "Folder '$folder' created." >> "$LOG" 2>&1
    else
        echo "Folder '$folder' already exists." >> "$LOG" 2>&1
    fi
done
    
printf "\n%.0s" {1..2}

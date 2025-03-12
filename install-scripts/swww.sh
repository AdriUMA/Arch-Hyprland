#!/bin/bash
# SWWW wallpaper #

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_sddm.log"

# Copy the wallpaper to the default location
echo "Copying default wallpaper." >> "$LOG" 2>&1
mkdir -p "$HOME/Pictures/wallpapers" >> "$LOG" 2>&1
cp -r assets/wallpapers "$HOME/Pictures/wallpapers" >> "$LOG" 2>&1

# Set the wallpaper
echo "Setting the wallpaper." >> "$LOG" 2>&1
swww "$HOME/Pictures/wallpapers/default.png" >> "$LOG" 2>&1

echo "Wallpaper set." >> "$LOG" 2>&1

printf "\n%.0s" {1..2}
#!/bin/bash
# pacman adding up extra-spices #

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##
source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_pacman.log"

echo -e "${NOTE} Adding ${MAGENTA}Extra Spice${RESET} in pacman.conf ... ${RESET}" 2>&1 | tee -a "$LOG"
pacman_conf="/etc/pacman.conf"

# Remove comments '#' from specific lines
lines_to_edit=(
    "Color"
    "CheckSpace"
    "VerbosePkgLists"
    "ParallelDownloads"
)

# Uncomment specified lines if they are commented out
for line in "${lines_to_edit[@]}"; do
    if grep -q "^#$line" "$pacman_conf"; then
        sudo sed -i "s/^#$line/$line/" "$pacman_conf"
        echo -e "${CAT} Uncommented: $line ${RESET}" 2>&1 | tee -a "$LOG"
    else
        echo -e "${CAT} $line is already uncommented. ${RESET}" 2>&1 | tee -a "$LOG"
    fi
done

# Add "ILoveCandy" below ParallelDownloads if it doesn't exist
if grep -q "^ParallelDownloads" "$pacman_conf" && ! grep -q "^ILoveCandy" "$pacman_conf"; then
    sudo sed -i "/^ParallelDownloads/a ILoveCandy" "$pacman_conf"
    echo -e "${CAT} Added ${MAGENTA}ILoveCandy${RESET} after ${MAGENTA}ParallelDownloads${RESET}. ${RESET}" 2>&1 | tee -a "$LOG"
else
    echo -e "${CAT} It seems ${YELLOW}ILoveCandy${RESET} already exists ${RESET} moving on.." 2>&1 | tee -a "$LOG"
fi

echo -e "${CAT} ${MAGENTA}Pacman.conf${RESET} spicing up completed ${RESET}" 2>&1 | tee -a "$LOG"


# updating pacman.conf
printf "\n%s - ${SKY_BLUE}Synchronizing Pacman Repo${RESET}\n" "${INFO}"
sudo pacman -Sy

printf "\n%.0s" {1..2}

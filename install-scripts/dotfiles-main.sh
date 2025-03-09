#!/bin/bash
# Hyprland-Dots to download from main #

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##

source "$(dirname "$(readlink -f "$0")")/Global_functions.sh"

# Check if Hyprland-Dots exists
printf "${NOTE} Cloning and Installing ${SKY_BLUE}Adri's dotfiles${RESET}....\n"

# Prepare copy script to be executed
copy_script_into_dotfiles(){
  cp assets/dotfiles/copy.sh AdriUMA-dotfiles/copy.sh
  chmod +x AdriUMA-dotfiles/copy.sh
}

if [ -d AdriUMA-dotfiles ]; then
  copy_script_into_dotfiles
  cd AdriUMA-dotfiles
  git stash
  git pull
  git stash apply
  ./copy.sh 
else
  if git clone --depth 1 https://github.com/AdriUMA/dotfiles AdriUMA-dotfiles; then
    copy_script_into_dotfiles
    cd AdriUMA-dotfiles || exit 1
    ./copy.sh 
  else
    echo -e "$ERROR Can't download ${YELLOW}Adri's dotfiles${RESET}. Check your internet connection"
  fi
fi

printf "\n%.0s" {1..2}
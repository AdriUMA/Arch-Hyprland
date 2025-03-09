#!/bin/bash

clear
wallpaper=$HOME/.config/hypr/wallpaper_effects/.wallpaper_current
waybar_style="$HOME/.config/waybar/style/[Extra] Modern-Combined - Transparent.css"
waybar_config="$HOME/.config/waybar/configs/[TOP] Default"
waybar_config_laptop="$HOME/.config/waybar/configs/[TOP] Default Laptop" 

# Set some colors for output messages
OK="$(tput setaf 2)[OK]$(tput sgr0)"
ERROR="$(tput setaf 1)[ERROR]$(tput sgr0)"
NOTE="$(tput setaf 3)[NOTE]$(tput sgr0)"
INFO="$(tput setaf 4)[INFO]$(tput sgr0)"
WARN="$(tput setaf 1)[WARN]$(tput sgr0)"
CAT="$(tput setaf 6)[ACTION]$(tput sgr0)"
MAGENTA="$(tput setaf 5)"
ORANGE="$(tput setaf 214)"
WARNING="$(tput setaf 1)"
YELLOW="$(tput setaf 3)"
GREEN="$(tput setaf 2)"
BLUE="$(tput setaf 4)"
SKY_BLUE="$(tput setaf 6)"
RESET="$(tput sgr0)"


# Check if running as root. If root, script will exit
if [[ $EUID -eq 0 ]]; then
    echo "${ERROR}  This script should ${WARNING}NOT${RESET} be executed as root!! Exiting......."
    printf "\n%.0s" {1..2} 
    exit 1
fi

# Check if the config directory exists
if [ ! -d ".config" ]; then
  echo "${ERROR} - The '.config' directory does not exist."
  exit 1
fi

# Function to print colorful text
print_color() {
    printf "%b%s%b\n" "$1" "$2" "$CLEAR"
}

# Check /etc/os-release to see if this is an Ubuntu or Debian based distro
if ! grep -iq '^\(ID_LIKE\|ID\)=.*\(arch\)' /etc/os-release >/dev/null 2>&1; then
	printf "\n%.0s" {1..1}
    print_color $WARNING "
    █▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀█
                 Adri DOTS version INCOMPATIBLE
    █▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄█

    No-Arch distro detected.

    exiting ....
    "
  printf "\n%.0s" {1..3}
  exit 1
fi


printf "\n%.0s" {1..1}  
echo -e "\e[35m
    ╔═╗┬─┐┌─┐┬ ┬╔╦╗╔╦╗  ╔╦╗┌─┐┌┬┐┌─┐
    ╠═╣├┬┘│  ├─┤ ║ ║║║   ║║│ │ │ └─┐
    ╩ ╩┴└─└─┘┴ ┴ ╩ ╩ ╩  ═╩╝└─┘ ┴ └─┘
\e[0m"
printf "\n%.0s" {1..1}  

# Create Directory for Copy Logs
if [ ! -d Copy-Logs ]; then
    mkdir Copy-Logs
fi

# Set the name of the log file to include the current date and time
LOG="Copy-Logs/install-$(date +%d-%H%M%S)_dotfiles.log"

# update home folders
xdg-user-dirs-update 2>&1 | tee -a "$LOG" || true

# setting up for nvidia
if lspci -k | grep -A 2 -E "(VGA|3D)" | grep -iq nvidia; then
  echo "${INFO} Nvidia GPU detected. Setting up proper env's and configs" 2>&1 | tee -a "$LOG" || true
  sed -i '/env = LIBVA_DRIVER_NAME,nvidia/s/^#//' config/hypr/UserConfigs/ENVariables.conf
  sed -i '/env = __GLX_VENDOR_LIBRARY_NAME,nvidia/s/^#//' config/hypr/UserConfigs/ENVariables.conf
  sed -i '/env = NVD_BACKEND,direct/s/^#//' config/hypr/UserConfigs/ENVariables.conf
  sed -i 's/^\([[:space:]]*no_hardware_cursors[[:space:]]*=[[:space:]]*\)false/\1true/' config/hypr/UserConfigs/UserSettings.conf  
fi

# uncommenting WLR_RENDERER_ALLOW_SOFTWARE,1 if running in a VM is detected
if hostnamectl | grep -q 'Chassis: vm'; then
  echo "${INFO} System is running in a virtual machine. Setting up proper env's and configs" 2>&1 | tee -a "$LOG" || true
  # enabling proper ENV's for Virtual Environment which should help
  sed -i 's/^\([[:space:]]*no_hardware_cursors[[:space:]]*=[[:space:]]*\)false/\1true/' config/hypr/UserConfigs/UserSettings.conf
  sed -i '/env = WLR_RENDERER_ALLOW_SOFTWARE,1/s/^#//' config/hypr/UserConfigs/ENVariables.conf
  #sed -i '/env = LIBGL_ALWAYS_SOFTWARE,1/s/^#//' config/hypr/UserConfigs/ENVariables.conf
  sed -i '/monitor = Virtual-1, 1920x1080@60,auto,1/s/^#//' config/hypr/monitors.conf
fi

printf "\n%.0s" {1..1} 

# set autostart: 
#   $1: detect command
#   $2: autostart app
startup_setter() {
    if command -v "$1" >/dev/null 2>&1; then
        if grep -q "$2" config/hypr/UserConfigs/Startup_Apps.conf; then
            echo "${WARN} $2 detected on Startup_Apps.conf. Configure manually this settings."
        else
            echo "" >> config/hypr/UserConfigs/Startup_Apps.conf
            echo "exec-once = $2 & # Autocreated by Adri's dotfiles script" >> config/hypr/UserConfigs/Startup_Apps.conf
            echo "${INFO} $1 detected and auto configured $2 on start up."
        fi
    fi
}

# Check if asusctl is installed and add rog-control-center on Startup
startup_setter asusctl rog-control-center
# Check if blueman-applet is installed and add blueman-applet on Startup
startup_setter blueman-applet blueman-applet

printf "\n%.0s" {1..1}

printf "\n"

set -e

# Function to create a unique backup directory name with month, day, hours, and minutes
get_backup_dirname() {
  local timestamp
  timestamp=$(date +"%m%d_%H%M")
  echo "back-up_${timestamp}"
}

# Check if the ~/.config/ directory exists
if [ ! -d "$HOME/.config" ]; then
  echo "${ERROR} - $HOME/.config directory does not exist. Creating it now."
  mkdir -p "$HOME/.config" && echo "Directory created successfully." || echo "Failed to create directory."
fi

printf "${INFO} - copying ${SKY_BLUE}dotfiles${RESET}\n"

# for waybar special part since it contains symlink
DIRW="waybar"
DIRPATHw="$HOME/.config/$DIRW"
if [ -d "$DIRPATHw" ]; then
    printf "\n${INFO} Found ${YELLOW}$DIRW${RESET} config found in ~/.config/\n"
    
    BACKUP_DIR=$(get_backup_dirname)
    cp -r "$DIRPATHw" "$DIRPATHw-backup-$BACKUP_DIR" 2>&1 | tee -a "$LOG"
    echo -e "${NOTE} - Backed up $DIRW to $DIRPATHw-backup-$BACKUP_DIR." 2>&1 | tee -a "$LOG"
    
    # Remove the old $DIRPATHw and copy the new one
    rm -rf "$DIRPATHw" && cp -r "config/$DIRW" "$DIRPATHw" 2>&1 | tee -a "$LOG"
    
    # Step 1: Handle waybar symlinks 
    for file in "config" "style.css"; do
        symlink="$DIRPATHw-backup-$BACKUP_DIR/$file"
        target_file="$DIRPATHw/$file"
        
        if [ -L "$symlink" ]; then
            symlink_target=$(readlink "$symlink")
            if [ -f "$symlink_target" ]; then
                rm -f "$target_file" && cp -f "$symlink_target" "$target_file"
                echo -e "${NOTE} - Copied $file as a regular file."
            else
                echo -e "${WARN} - Symlink target for $file does not exist."
            fi
        fi
    done
    
    # Step 2: Copy non-existing directories and files under waybar/configs
    for dir in "$DIRPATHw-backup-$BACKUP_DIR/configs"/*; do
        [ -e "$dir" ] || continue  # Skip if no files are found
        if [ -d "$dir" ]; then
            target_dir="$HOME/.config/waybar/configs/$(basename "$dir")"
            if [ ! -d "$target_dir" ]; then
                echo "Copying directory $dir to $HOME/.config/waybar/configs/" >> "$LOG"
                cp -r "$dir" "$HOME/.config/waybar/configs/"
            else
                echo "Directory $target_dir already exists. Skipping." >> "$LOG"
            fi
        fi
    done

    for file in "$DIRPATHw-backup-$BACKUP_DIR/configs"/*; do
        [ -e "$file" ] || continue  
        target_file="$HOME/.config/waybar/configs/$(basename "$file")"
        if [ ! -e "$target_file" ]; then
            echo "Copying $file to $HOME/.config/waybar/configs/" >> "$LOG"
            cp "$file" "$HOME/.config/waybar/configs/"
        else
            echo "File $target_file already exists. Skipping." >> "$LOG"
        fi
    done || true
    
    # Step 3: Copy unique files in waybar/style
    for file in "$DIRPATHw-backup-$BACKUP_DIR/style"/*; do
        [ -e "$file" ] || continue  
        
        if [ -d "$file" ]; then
            target_dir="$HOME/.config/waybar/style/$(basename "$file")"
            if [ ! -d "$target_dir" ]; then
                echo "Copying directory $file to $HOME/.config/waybar/style/" >> "$LOG"
                cp -r "$file" "$HOME/.config/waybar/style/"
            else
                echo "Directory $target_dir already exists. Skipping." >> "$LOG"
            fi
        else
            target_file="$HOME/.config/waybar/style/$(basename "$file")"
            if [ ! -e "$target_file" ]; then
                echo "Copying file $file to $HOME/.config/waybar/style/" >> "$LOG"
                cp "$file" "$HOME/.config/waybar/style/"
            else
                echo "File $target_file already exists. Skipping." >> "$LOG"
            fi
        fi
    done || true

    # Step 4: restore Modules_Extras
    BACKUP_FILEw="$DIRPATHw-backup-$BACKUP_DIR/UserModules"
    if [ -f "$BACKUP_FILEw" ]; then
        cp -f "$BACKUP_FILEw" "$DIRPATHw/UserModules"
    fi
else
    cp -r "config/$DIRW" "$DIRPATHw" 2>&1 | tee -a "$LOG"
    echo -e "${OK} - Copy completed for ${YELLOW}$DIRW${RESET}" 2>&1 | tee -a "$LOG"
fi

printf "\n%.0s" {1..1}

# Else config
DIR="ags fastfetch kitty rofi swaync btop cava hypr Kvantum qt5ct qt6ct swappy wallust wlogout"
for DIR_NAME in $DIR; do
  DIRPATH="$HOME/.config/$DIR_NAME"
  
  # Backup the existing directory if it exists
  if [ -d "$DIRPATH" ]; then
    echo -e "\n${NOTE} - Config for ${YELLOW}$DIR_NAME${RESET} found, attempting to back up."
    BACKUP_DIR=$(get_backup_dirname)
    
    # Backup the existing directory
    mv "$DIRPATH" "$DIRPATH-backup-$BACKUP_DIR" 2>&1 | tee -a "$LOG"
    if [ $? -eq 0 ]; then
      echo -e "${NOTE} - Backed up $DIR_NAME to $DIRPATH-backup-$BACKUP_DIR."
    else
      echo "${ERROR} - Failed to back up $DIR_NAME."
      exit 1
    fi
  fi
  
  # Copy the new config
  if [ -d "config/$DIR_NAME" ]; then
    cp -r "config/$DIR_NAME/" "$HOME/.config/$DIR_NAME" 2>&1 | tee -a "$LOG"
    if [ $? -eq 0 ]; then
      echo "${OK} - Copy of config for ${YELLOW}$DIR_NAME${RESET} completed!"
    else
      echo "${ERROR} - Failed to copy $DIR_NAME."
      exit 1
    fi
  else
    echo "${ERROR} - Directory config/$DIR_NAME does not exist to copy."
  fi
done

printf "\n%.0s" {1..1}

# Define the target directory for rofi themes
rofi_DIR="$HOME/.local/share/rofi/themes"

if [ ! -d "$rofi_DIR" ]; then
  mkdir -p "$rofi_DIR"
fi
if [ -d "$HOME/.config/rofi/themes" ]; then
  if [ -z "$(ls -A $HOME/.config/rofi/themes)" ]; then
    echo '/* Dummy Rofi theme */' > "$HOME/.config/rofi/themes/dummy.rasi"
  fi
  ln -snf "$HOME/.config/rofi/themes/"* "$HOME/.local/share/rofi/themes/"
  # Delete the dummy file if it was created
  if [ -f "$HOME/.config/rofi/themes/dummy.rasi" ]; then
    rm "$HOME/.config/rofi/themes/dummy.rasi"
  fi
fi

printf "\n%.0s" {1..1}
 
# Set some files as executable
chmod +x "$HOME/.config/hypr/scripts/"* 2>&1 | tee -a "$LOG"
chmod +x "$HOME/.config/hypr/UserScripts/"* 2>&1 | tee -a "$LOG"
# Set executable for initial-boot.sh
chmod +x "$HOME/.config/hypr/initial-boot.sh" 2>&1 | tee -a "$LOG"

# for SDDM (sequoia_2)
sddm_sequioa="/usr/share/sddm/themes/sequoia_2"
if [ -d "$sddm_sequioa" ]; then
  while true; do
    read -rp "${CAT} SDDM sequoia_2 theme detected! Apply current wallpaper as SDDM background? (y/n): " SDDM_WALL
    
    # Remove any leading/trailing whitespace or newlines from input
    SDDM_WALL=$(echo "$SDDM_WALL" | tr -d '\n' | tr -d ' ')

    case $SDDM_WALL in
      [Yy])
        # Copy the wallpaper, ignore errors if the file exists or fails
        sudo cp -r "config/hypr/wallpaper_effects/.wallpaper_current" "/usr/share/sddm/themes/sequoia_2/backgrounds/default" || true
        echo "${NOTE} Current wallpaper applied as default SDDM background" 2>&1 | tee -a "$LOG"
        break
        ;;
      [Nn])
        echo "${NOTE} You chose not to apply the current wallpaper to SDDM." 2>&1 | tee -a "$LOG"
        break
        ;;
      *)
        echo "Please enter 'y' or 'n' to proceed."
        ;;
    esac
  done
fi

printf "\n%.0s" {1..1}

# CLeaning up of ~/.config/ backups
cleanup_backups() {
  CONFIG_DIR="$HOME/.config"
  BACKUP_PREFIX="-backup"

  # Loop through directories in $HOME/.config
  for DIR in "$CONFIG_DIR"/*; do
    if [ -d "$DIR" ]; then
      BACKUP_DIRS=()

      # Check for backup directories
      for BACKUP in "$DIR"$BACKUP_PREFIX*; do
        if [ -d "$BACKUP" ]; then
          BACKUP_DIRS+=("$BACKUP")
        fi
      done
	  
      # If more than one backup found
      if [ ${#BACKUP_DIRS[@]} -gt 1 ]; then
      	printf "\n%.0s" {1..2}
        echo -e "${INFO} Found ${MAGENTA}multiple backups${RESET} for: ${YELLOW}${DIR##*/}${RESET}"
        echo "${YELLOW}Backups: ${RESET}"

        # List the backups
        for BACKUP in "${BACKUP_DIRS[@]}"; do
          echo "  - ${BACKUP##*/}"
        done

        read -p "${CAT} Do you want to delete the older backups of ${YELLOW}${DIR##*/}${RESET} and keep the latest backup only? (y/N): " back_choice
        if [[ "$back_choice" == [Yy]* ]]; then
          # Sort backups by modification time
          latest_backup="${BACKUP_DIRS[0]}"
          for BACKUP in "${BACKUP_DIRS[@]}"; do
            if [ "$BACKUP" -nt "$latest_backup" ]; then
              latest_backup="$BACKUP"
            fi
          done

          for BACKUP in "${BACKUP_DIRS[@]}"; do
            if [ "$BACKUP" != "$latest_backup" ]; then
              echo "Deleting: ${BACKUP##*/}"
              rm -rf "$BACKUP"
            fi
          done
          echo "Old backups of ${YELLOW}${DIR##*/}${RESET} deleted, keeping: ${MAGENTA}${latest_backup##*/}${RESET}"
        fi
      fi
    fi
  done
}
# Execute the cleanup function
cleanup_backups

# Check if ~/.config/waybar/style.css does not exist or is a symlink
if [ ! -e "$HOME/.config/waybar/style.css" ] || [ -L "$HOME/.config/waybar/style.css" ]; then
    ln -sf "$waybar_style" "$HOME/.config/waybar/style.css" 2>&1 | tee -a "$LOG"
fi

printf "\n%.0s" {1..1}

# initial-boot
scriptsDir=$HOME/.config/hypr/scripts
color_scheme="prefer-dark"
gtk_theme="Flat-Remix-GTK-Blue-Dark"
icon_theme="Flat-Remix-Blue-Dark"
cursor_theme="Bibata-Modern-Ice"

swww="swww img"
effect="--transition-bezier .43,1.19,1,.4 --transition-fps 30 --transition-type grow --transition-pos 0.925,0.977 --transition-duration 2"

sleep 1

# initiate GTK dark mode and apply icon and cursor theme
gsettings set org.gnome.desktop.interface color-scheme $color_scheme > /dev/null 2>&1 &
gsettings set org.gnome.desktop.interface gtk-theme $gtk_theme > /dev/null 2>&1 &
gsettings set org.gnome.desktop.interface icon-theme $icon_theme > /dev/null 2>&1 &
gsettings set org.gnome.desktop.interface cursor-theme $cursor_theme > /dev/null 2>&1 &
gsettings set org.gnome.desktop.interface cursor-size 24 > /dev/null 2>&1 &

    # NIXOS initiate GTK dark mode and apply icon and cursor theme
if [ -n "$(grep -i nixos < /etc/os-release)" ]; then
    gsettings set org.gnome.desktop.interface color-scheme "'$color_scheme'" > /dev/null 2>&1 &
    dconf write /org/gnome/desktop/interface/gtk-theme "'$gtk_theme'" > /dev/null 2>&1 &
    dconf write /org/gnome/desktop/interface/icon-theme "'$icon_theme'" > /dev/null 2>&1 &
    dconf write /org/gnome/desktop/interface/cursor-theme "'$cursor_theme'" > /dev/null 2>&1 &
    dconf write /org/gnome/desktop/interface/cursor-size "24" > /dev/null 2>&1 &
fi

# initiate the kb_layout (for some reason) waybar cant launch it
"$scriptsDir/SwitchKeyboardLayout.sh" > /dev/null 2>&1 &

# initialize wallust to avoid config error on hyprland
wallust run -s $wallpaper 2>&1 | tee -a "$LOG"

printf "\n%.0s" {1..2}
printf "${OK} GREAT! Adri's dotfiles is now Loaded & Ready !!! "
printf "\n%.0s" {1..1}
printf "${INFO} However, it is ${MAGENTA}HIGHLY SUGGESTED${RESET} to logout and re-login or better reboot to avoid any issues"
printf "\n%.0s" {1..3}
#!/bin/bash

clear

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

# Check if --preset argument is provided
if [[ "$1" == "--preset" ]]; then

    if [ -z "$2" -o ! -f "$2" ]; then
        echo "$ERROR Preset $2 not found, aborting."
        exit 1
    fi
    
    use_preset = "$2"
    source "$2"
fi

# Check if PulseAudio package is installed
if pacman -Qq | grep -qw '^pulseaudio$'; then
    echo "$ERROR PulseAudio is detected as installed. Uninstall it first."
    printf "\n%.0s" {1..2} 
    exit 1
fi

clear

printf "\n%.0s" {1..2}  
echo -e "\e[35m\n
        ╔═╗┬─┐┌─┐┬ ┬╔╦╗╔╦╗
        ╠═╣├┬┘│  ├─┤ ║ ║║║
        ╩ ╩┴└─└─┘┴ ┴ ╩ ╩ ╩
\e[0m"
printf "\n%.0s" {1..1} 

# Welcome message
echo "${SKY_BLUE}Welcome to Adri's Arch-Hyprland Install Script!${RESET}"
echo
echo "${WARNING}ATTENTION: Run a full system update and Reboot first!! (Highly Recommended) ${RESET}"
echo
echo "${YELLOW}NOTE: You will be required to answer some questions during the installation! ${RESET}"
echo
echo "${YELLOW}NOTE: If you are installing on a VM, ensure to enable 3D acceleration else Hyprland wont start! ${RESET}"
echo

read -p "${SKY_BLUE}Would you like to proceed? (y/n): ${RESET}" proceed

if [ "$proceed" != "y" ]; then
    printf "\n%.0s" {1..2}
    echo "${INFO} Installation aborted. ${SKY_BLUE}No changes in your system.${RESET} ${YELLOW}Goodbye!${RESET}"
    printf "\n%.0s" {1..2}
    exit 1
fi

printf "\n%.0s" {1..1}

# Check if base-devel is installed
if pacman -Q base-devel &> /dev/null; then
    echo "base-devel is already installed."
else
    echo "$NOTE Install base-devel.........."

    if sudo pacman -S --noconfirm base-devel; then
        echo "$OK base-devel has been installed successfully."
    else
        echo "$ERROR base-devel not found nor cannot be installed."
        echo "$ACTION Please install base-devel manually before running this script... Exiting"
        exit 1
    fi
    printf "\n%.0s" {1..1}
fi

# install pciutils if detected not installed. Necessary for detecting GPU
if ! pacman -Qs pciutils > /dev/null; then
    echo "pciutils is not installed. Installing..."
    sudo pacman -S --noconfirm pciutils
    printf "\n%.0s" {1..1}
fi

# Function to colorize prompts
colorize_prompt() {
    local color="$1"
    local message="$2"
    echo -n "${color}${message}$(tput sgr0)"
}

# Set the name of the log file to include the current date and time
LOG="install-$(date +%d-%H%M%S).log"


# Create Directory for Install Logs
if [ ! -d Install-Logs ]; then
    mkdir Install-Logs
fi

# Define the directory where your scripts are located
script_directory=install-scripts

# Function to ask a yes/no question and set the response in a variable
ask_yes_no() {
  if [[ ! -z "${!2}" ]]; then
    echo "$(colorize_prompt "$CAT"  "$1 (Preset): ${!2}")" 
    if [[ "${!2}" = [Yy] ]]; then
      return 0
    else
      return 1
    fi
  else
    eval "$2=''" 
  fi
    while true; do
        read -p "$(colorize_prompt "$CAT"  "$1 (y/n): ")" choice
        case "$choice" in
            [Yy]* ) eval "$2='Y'"; return 0;;
            [Nn]* ) eval "$2='N'"; return 1;;
            * ) echo "Please answer with y or n.";;
        esac
    done
}

# Function to ask a custom question with specific options and set the response in a variable
ask_custom_option() {
    local prompt="$1"
    local valid_options="$2"
    local response_var="$3"

    if [[ ! -z "${!3}" ]]; then
      return 0
    else
     eval "$3=''" 
    fi

    while true; do
        read -p "$(colorize_prompt "$CAT"  "$prompt ($valid_options): ")" choice
        if [[ " $valid_options " == *" $choice "* ]]; then
            eval "$response_var='$choice'"
            return 0
        else
            echo "Please choose one of the provided options: $valid_options"
        fi
    done
}

# Function to execute a script if it exists and make it executable
execute_script() {
    local script="$1"
    local script_path="$script_directory/$script"
    if [ -f "$script_path" ]; then
        chmod +x "$script_path"
        if [ -x "$script_path" ]; then
            env USE_PRESET=$use_preset  "$script_path"
        else
            echo "Failed to make script '$script' executable."
        fi
    else
        echo "Script '$script' not found in '$script_directory'."
    fi
}

# Collect user responses to all questions
# Check if nvidia is present
if lspci | grep -i "nvidia" &> /dev/null; then
    printf "\n"
    printf "${INFO} ${YELLOW}NVIDIA GPU${RESET} detected in your system \n"
    printf "${NOTE} Script will install ${YELLOW}nvidia-dkms nvidia-utils and nvidia-settings${RESET} \n"
    ask_yes_no "-Do you want script to configure ${YELLOW}NVIDIA${RESET} for you?" nvidia
fi

if [[ "$nvidia" == "Y" ]]; then
    ask_yes_no "-Would you like to ${YELLOW}blacklist nouveau?${RESET}" blacklistNouveau
fi

# AUR helper
if ! command -v yay &>/dev/null && ! command -v paru &>/dev/null; then
    printf "\n"
    ask_custom_option "-Which ${YELLOW}AUR helper${RESET} would you like to use? (paru or yay): " "paru yay" aur_helper
fi

printf "\n"
ask_yes_no "-Do you want to configure ${YELLOW}Bluetooth${RESET}?" bluetooth

printf "\n"
ask_yes_no "-Install & configure ${YELLOW}SDDM${RESET} as login manager?" sddm
# check if any known login managers are active when users choose to install sddm
if [ "$sddm" == "y" ] || [ "$sddm" == "Y" ]; then
    # List of services to check
    services=("gdm.service" "gdm3.service" "lightdm.service" "lxdm.service")

    # Loop through each service
    for svc in "${services[@]}"; do
        if systemctl is-active --quiet "$svc"; then
            echo "${ERROR} ${MAGENTA}$svc${RESET} is active.  stop or disable it first or ${YELLOW}DO NOT choose SDDM${RESET} to install."
            echo "${NOTE} If you have GDM, no need to install SDDM. GDM will work fine as Login Manager for Hyprland."
            printf "\n%.0s" {1..2}            
            exit 1  
        fi
    done
fi
if [[ "$sddm" == "Y" ]]; then
    ask_yes_no "-Download and Install ${YELLOW}SDDM Theme?${RESET} " sddm_theme
fi

printf "\n"
ask_yes_no "-Installing on ${YELLOW}Asus ROG laptops?${RESET}" rog

printf "\n"
ask_yes_no "-Do you want to add pre-configured ${YELLOW}KooL's Hyprland dotfiles?${RESET}" dots

printf "\n"


# Ensuring all in the scripts folder are made executable
chmod +x install-scripts/*

sleep 1
# Ensuring base-devel is installed
execute_script "00-base.sh"
sleep 1
execute_script "pacman.sh"
sleep 1
# Execute AUR helper script based on user choice
if [ "$aur_helper" == "paru" ]; then
    execute_script "paru.sh"
elif [ "$aur_helper" == "yay" ]; then
    execute_script "yay.sh"
fi

# Install hyprland packages
execute_script "01-hypr-pkgs.sh"

# Install pipewire and pipewire-audio
execute_script "pipewire.sh"

# Install necessary fonts
execute_script "fonts.sh"

# Install hyprland
execute_script "hyprland.sh"

if [ "$nvidia" == "Y" ]; then
    execute_script "nvidia.sh"
fi
if [ "$blacklistNouveau" == "Y" ]; then
    execute_script "nvidia_blacklist_nouveau.sh"
fi

if [ "$bluetooth" == "Y" ]; then
    execute_script "bluetooth.sh"
fi

execute_script "thunar.sh"

execute_script "ags.sh"

if [ "$sddm" == "Y" ]; then
    execute_script "sddm.sh"
fi
if [ "$sddm_theme" == "Y" ]; then
    execute_script "sddm_theme.sh"
fi

execute_script "xdg_folders.sh"

execute_script "xdph.sh"

execute_script "zsh.sh"

execute_script "InputGroup.sh"

if [ "$rog" == "Y" ]; then
    execute_script "rog.sh"
fi

if [ "$dots" == "Y" ]; then
    execute_script "dotfiles-main.sh"
fi

clear

# final check essential packages if it is installed
execute_script "02-Final-Check.sh"

printf "\n%.0s" {1..1}

# Check if hyprland is installed
if pacman -Q hyprland &> /dev/null; then
    printf "\n${OK} Hyprland is installed. However, some essential packages may not be installed. Please see above!"
    printf "\n${CAT} Ignore this message if it states ${YELLOW}All essential packages${RESET} are installed as per above\n"
    sleep 2
    printf "\n%.0s" {1..2}

    printf "${SKY_BLUE}Thank you${RESET} for using ${MAGENTA}KooL's Hyprland Dots${RESET}. ${YELLOW}Enjoy and Have a good day!${RESET}"
    printf "\n%.0s" {1..2}

    printf "\n${NOTE} You can start Hyprland by typing ${SKY_BLUE}Hyprland${RESET} (IF SDDM is not installed) (note the capital H!).\n"
    printf "\n${NOTE} However, it is ${YELLOW}highly recommended to reboot${RESET} your system.\n\n"

    read -rp "${CAT} Would you like to reboot now? (y/n): " HYP

    HYP=$(echo "$HYP" | tr '[:upper:]' '[:lower:]')

    if [[ "$HYP" == "y" || "$HYP" == "yes" ]]; then
        echo "${INFO} Rebooting now..."
        systemctl reboot 
    elif [[ "$HYP" == "n" || "$HYP" == "no" ]]; then
        echo "${OK} You choose NOT to reboot"
        printf "\n%.0s" {1..1}
        # Check if NVIDIA GPU is present
        if lspci | grep -i "nvidia" &> /dev/null; then
            echo "${INFO} HOWEVER ${YELLOW}NVIDIA GPU${RESET} detected. Reminder that you must REBOOT your SYSTEM..."
            printf "\n%.0s" {1..1}
        fi
    else
        echo "${WARN} Invalid response. Please answer with 'y' or 'n'. Exiting."
        exit 1
    fi
else
    # Print error message if neither package is installed
    printf "\n${WARN} Hyprland is NOT installed. Please check 00_CHECK-time_installed.log and other files in the Install-Logs/ directory..."
    printf "\n%.0s" {1..3}
    exit 1
fi

printf "\n%.0s" {1..2}

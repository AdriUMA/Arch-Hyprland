# ** Hyprland Install Script **

- This Repo does not contain Hyprland Dots or configs! Dotfiles can be checked [`here`](https://github.com/AdriUMA/dotfiles) . During installation, if you opt to copy pre-configured dots, it will be downloaded from that centralized repo.

> [!NOTE]
> This is my modified, summarized, and hardware-adapted version of [`Jakoo's repository`](https://github.com/JaKooLit/Arch-Hyprland). The README has been modified, as well as the installation scripts—I recommend reading it. I am not responsible for any malfunctions it may have.

> [!IMPORTANT]
> Create a backup of your system before installing hyprland using this script. This script does NOT include uninstallation of packages.

#### 🆕 Prerequisites

- This install script is intended for at least Server type / [Minimal Arch Linux](https://github.com/AdriUMA/Arch-Hyprland/blob/main/README.arch.md) installed.

> [!NOTE]
> 🔘 Pipewire and Pipewire audio

- This script will install pipewire and will also disable or will uninstall pulseaudio.

#### 👀 NVidia GPU Owners.

- By default, nvidia-dkms will be installed. and only supports GTX 900 and newer. If required to install older driver, edit the nvidia.sh in install-scripts directory

> [!IMPORTANT]
> If you want to use nouveau driver, choose N when asked if you have nvidia gpu. This is because the nvidia installer part, it will blacklist nouveau. Hyprland will still be installed but it will skip blacklisting nouveau.

## ✨ To use this script

> [!CAUTION]
> DO NOT cd into install-scripts directory as script will most likely to fail
> Download this script on a directory where you have write permissions. ie. HOME. Or any directory within your home directory. Else script will fail

- clone this repo (latest commit only) to reduce file size download by using git. Change directory, make executable and run the script

```bash
git clone --depth=1 https://github.com/AdriUMA/Arch-Hyprland.git ~/Arch-Hyprland
cd ~/Arch-Hyprland
chmod +x install.sh
./install.sh
```

### 🤟 Presets

- Edit/Create any preset.sh (examples under `presets` folder) to modify what packages you want. Make sure to change only with Y, N or any expected option.
- To use preset instead of usual `./install.sh` you can ran like this

```bash
./install.sh --preset presets/your_preset.sh
```

### ✨ ZSH Themes

- To easy-change the theme, `SUPER SHIFT O` , choose desired theme, and close and open terminal.

### ✨ Keybinds

- SUPER H for HINT!
- Searchable keybind function via rofi whit SUPER SHIFT K!

#### ⏩ Thanks and Credits!

- [`Hyprland`](https://hyprland.org/) | [`JaKooLit Hyprland`](https://github.com/JaKooLit/Arch-Hyprland)

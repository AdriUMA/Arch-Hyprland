# Arch Linux

## 🤖 Operating System Installation

> [!IMPORTANT]
> I recommend using the [official installation guide](https://wiki.archlinux.org/title/Installation_guide). This is a simplified summary adapted to my needs. It may not take into account hardware different from the one I have on my devices.

> [!WARNING]
> If for any reason SecureBoot needs to be enabled after installing Arch, I recommend deleting all BIOS keys before starting.

> [!CAUTION]
> Install Windows before Arch for dual boot.
> Dual boot installation will fail if you have Windows 11 with BitLocker enabled.

### Preparation

[Download ISO](https://archlinux.org/download/) of Arch Linux and [flash](https://www.balena.io/etcher) an external drive.
Connect the device via Ethernet and boot the live system from the bootable drive.

(Optional) Configure the keyboard layout.

```sh
loadkeys es
```

We check if we have an internet connection.

```sh
ping archlinux.org
```

Set timezone, enable synchronization, and check the date.

```sh
timedatectl set-timezone Europe/Madrid
timedatectl set-ntp true
timedatectl show
```

### 🦿 Partitions and Formats

We will check if the hardware's boot mode is EFI or BIOS for the installation of the operating system.

```sh
ls /sys/firmware/efi/efivars
```

If there is no error running this command, it means it's an EFI boot. Otherwise, it is likely an older machine with BIOS boot.

Check the available drives and the installation target.

```sh
lsblk
```

Run the program to create partitions

> If the option to select a label appears: `gpt` for EFI and `dos` for BIOS.

```sh
cfdisk sdX
```

Create partitions for the operating system or root `/`, for users `/home`, and for swap memory `swap`.

**EFI (with or without Windows)**

> [!IMPORTANT] If you have another Linux installed, you have multiple options if you want to keep it. However, for the sake of simplicity, this guide does not consider that case.

| Path     | Type             | Suggested Size |
| -------- | ---------------- | -------------- |
| `/`      | Linux filesystem | 50GB           |
| `/boot`  | EFI System       | 1GB            |
| `/home`  | Linux filesystem | 50GB           |
| `[SWAP]` | Linux swap       | 8GB            |

Vemos los nuevos `/dev/sdXY` que se nos han creado

> [!NOTE]
> root `/` and `/home` can be on the same partition, but it is useful to separate them for future reinstalls to keep the system separate from data.
> The `swap` partition is not mandatory, but it is recommended.

**BIOS/MBR same disk with Windows**

> [!WARNING] On BIOS/MBR systems, only 4 primary volumes can be created. Since Windows occupies 3, we cannot have swap or separate home from root.

| Path | Bootable | Type  | Suggested Size |
| ---- | -------- | ----- | -------------- |
| `/`  | Yes      | Linux | 100GB          |

**BIOS/MBR without any other OS**

| Path     | Bootable | Type          | Suggested Size |
| -------- | -------- | ------------- | -------------- |
| `/`      | Yes      | Linux         | 50GB           |
| `/home`  | No       | Linux         | 50GB           |
| `[SWAP]` | No       | swap/ Solaris | 8GB            |

```sh
lsblk
```

Let's format them
For the formats of _Linux filesystem_ or _Linux_

For HDD

```sh
mkfs.ext4 /dev/sdXY
```

For SSD (btrfs is recommended for SSDs for various reasons, such as optimization and sector management)

```sh
mkfs.btrfs /dev/sdXY
```

If you have created swap, you need to format it and "activate" it

```sh
mkswap /dev/sdXY
swapon /dev/sdXY
```

> [!CAUTION]
> Remember that this guide assumes the EFI partition is new for this installation.

Create the "EFI System" partition

```sh
mkfs.fat -F 32 /dev/sdXY
```

### 🦾 Mounting and Installation

We will mount the partitions to the appropriate paths so that the pacstrap script installs correctly

```sh
mount /dev/sdXY(Particion del ROOT) /mnt
```

If you have separated `/home` into another partition, add:

```sh
mkdir /mnt/home
mount /dev/sdXY(Particion del HOME) /mnt/home
```

Also, for UEFI systems, the EFI partition needs to be mounted:

```sh
mkdir /mnt/boot
mount /dev/sdXY /mnt/boot
```

Install the Operating System

**Intel**

```
pacstrap /mnt base linux linux-firmware git sudo intel-ucode
```

**AMD**

```
pacstrap /mnt base linux linux-firmware git sudo amd-ucode
```

When it's done, generate the system tables and check that everything is correct.

**BIOS/MBR**

```
genfstab /mnt >> /mnt/etc/fstab
```

**EFI**

```
genfstab -U /mnt >> /mnt/etc/fstab
```

### ⚙️ Configuration

Access the newly installed operating system and begin configuring.

```sh
arch-chroot /mnt
```

Install `nano` and `git` (useful for later).

```sh
pacman -S nano git
```

Set the time.

```sh
ln -sf /usr/share/zoneinfo/Europe/Madrid /etc/localtime
hwclock --systohc
```

System language: uncomment `en_US.UTF-8 UTF-8` and `es_ES.UTF-8 UTF-8`.

```sh
nano /etc/locale.gen
```

Generate the file and create `locale.conf`.

```sh
locale-gen
echo "LANG=es_ES.UTF-8" > /etc/locale.conf
```

For the keyboard layout.

```sh
echo "KEYMAP=es" > /etc/vconsole.conf
```

Networks

```sh
echo "ANYCUSTOMPCNAME" > /etc/hostname
echo "127.0.0.1     localhost" >> /etc/hosts
echo "::1           localhost" >> /etc/hosts
echo "127.0.1.1     ANYCUSTOMPCNAME.localhost        ANYCUSTOMPCNAME" >> /etc/hosts
pacman -S networkmanager
systemctl enable NetworkManager
```

### 💻 GRUB

**EFI**

> [!IMPORTANT]  
> At the end of the README, I explain how to set up dual-boot if you have Windows installed on another partition.

```sh
pacman -S grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg
```

**BIOS Dual boot with Windows**

```sh
pacman -S grub grub-bios os-prober ntfs-3g
grub-install /dev/sdX
```

Uncomment the last line (`GRUB_DISABLE_OS_PROBER=false`) in the file `/etc/default/grub` to detect Windows when creating the GRUB configuration.

```sh
nano /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
mkinitcpio -P
```

**BIOS single boot**

```sh
pacman -S grub
grub-install /dev/sdX
grub-mkconfig -o /boot/grub/grub.cfg
```

### 👤 Users

Create users, set passwords, and configure

```sh
passwd root
useradd -m CUSTOMUSERNAME
passwd CUSTOMUSERNAME
usermod -aG wheel,video,audio,storage CUSTOMUSERNAME
```

Install `sudo`

```sh
pacman -S sudo
nano /etc/sudoers
```

Configure `sudo` by uncommenting the line `# %wheel ALL=(ALL:ALL) ALL` and changing it to `%wheel ALL=(ALL:ALL) ALL`

```sh
nano /etc/sudoers
```

### 💯 Finish installation

Exit the operating system and return to the live environment

```sh
exit
```

Unmount all the bootable drives, power off, and remove the bootable drive

```sh
umount -R /mnt
shutdown now
```

## ✨ Extra: EFI Windows dual boot ✨

Once you turn off the system, remove the bootable USB, configure the boot order, and enter Arch.

First, synchronize packages and install `os-prober` to detect Windows.

```sh
sudo pacman -Syy
sudo pacman -S os-prober
```

> [!NOTE]  
> The line "GRUB_DISABLE_OS_PROBER=false" is at the end of the document.

Now configure `grub` by uncommenting the line `#GRUB_DISABLE_OS_PROBER=false` and changing it to `GRUB_DISABLE_OS_PROBER=false`

```sh
sudo nano /etc/default/grub
```

Generate the `grub` configuration

```sh
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

❗If the output does not show something like `Found Windows Boot Manager on /dev/...`, this step has failed.

## ⚠️ If everything went well but GRUB does not appear in the BIOS boot menu ⚠️

### 1️⃣ First: **Clean `/boot` and mount**

🅰️ **IF YOU HAVE `/boot` ON A SEPARATE PARTITION**  

For example, if you have:

- `/` on /dev/sda1  
- `/home` on /dev/sda2  
- swap on /dev/sda3  
- `/boot` on /dev/sda4  

Mount the partitions except for `boot`:

```sh
mount /dev/sda1 /mnt
mount /dev/sda2 /mnt/home
swapon /dev/sda3
```

Format `/boot`, mount it, and regenerate fstab:

```sh
mkfs.fat -F 32 /dev/sda4
mount /dev/sda4 /mnt/boot
genfstab -U > /mnt/etc/fstab
```

🅱️ **IF YOU DON'T HAVE `/boot` ON A SEPARATE PARTITION**  

For example, if you have:

- `/` on /dev/sda1  
- swap on /dev/sda3  

```sh
mount /dev/sda1 /mnt
swapon /dev/sda3
```

Then, remove the contents of `/boot`:

```sh
rm -rf /mnt/boot/*
```

### 2️⃣ Second: Regenerate files in `/boot` and install GRUB  

Enter the system and reinstall `linux` to regenerate files in `/boot`:

```sh
arch-root /mnt
pacman -Syy
pacman -S linux
mkinitcpio -P
```

Install GRUB with an additional flag:

> If you want to detect other operating systems: install `os-prober` and uncomment the line in `/etc/default/grub` at the end of the document so that it looks like this:  
> `GRUB_DISABLE_OS_PROBER=false`

```sh
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB --removable
grub-mkconfig -o /boot/grub/grub.cfg
```

### 3️⃣ Third: Restart  

```sh
umount -R /mnt
shutdown now
```

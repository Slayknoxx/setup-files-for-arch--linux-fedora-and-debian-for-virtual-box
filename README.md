# VM Post-Install Setup Scripts

Automated post-installation configuration scripts for fresh VirtualBox Linux images from [linuxvirtualimages.com](https://linuxvirtualimages.com). These scripts streamline the setup process by installing essential tools, dependencies, and system configurations across Debian, Arch Linux, and Fedora distributions.

## 📋 Overview

| Script | Distro | Package Manager |
|--------|--------|-----------------|
| `setup-debian.sh` | Debian 12/13 | apt |
| `setup-arch.sh` | Arch Linux | pacman |
| `setup-fedora.sh` | Fedora | dnf |

First clone the repo:

```bash
gitclone https://github.com/Slayknoxx/setup-files-for-arch--linux-fedora-and-debian-for-virtual-box.git
```
## 🚀 Quick Start

### Step 1: Copy Script Into Your VM

Choose one of the following methods:

**Option A: Using VirtualBox Shared Folders**
- Transfer the script to your VM using Shared Folders

**Option B: Download Directly**
```bash
# Example for Debian
curl -O https://your-location/setup-debian.sh
```

**Option C: Manual Copy-Paste**
- Open a text editor in your VM, paste the script contents, and save

### Step 2: Make Executable

```bash
chmod +x setup-debian.sh
# or: chmod +x setup-arch.sh / setup-fedora.sh
```

### Step 3: Run the Script

```bash
bash setup-debian.sh
```

⚠️ **Important:** Do NOT run as root. Run as your normal user — the script uses `sudo` internally.

## ✨ What Each Script Does

All scripts perform the following core tasks:

- ✅ Checks internet connectivity
- ✅ Fixes/updates package sources (Debian) or mirrors (Arch/Fedora)
- ✅ Runs a full system update
- ✅ Installs essential tools (curl, git, vim, htop, etc.)
- ✅ Installs VirtualBox Guest Additions
- ✅ Sets timezone to `Africa/Nairobi`
- ✅ Sets locale to `en_US.UTF-8`
- ✅ Prompts to change default password
- ✅ Reminds you of recommended VirtualBox settings

### Arch Linux Extras

- Installs `yay` AUR helper
- Enables multilib repository
- Uses `reflector` to find fastest mirrors

### Fedora Extras

- Optimizes DNF (parallel downloads, fastest mirror selection)
- Enables RPM Fusion (free + non-free repositories)
- Installs multimedia codecs
- Sets up Flatpak + Flathub

## 📝 Post-Installation Steps

After the script completes:

1. Follow any on-screen prompts
2. Reboot the system:
   ```bash
   sudo reboot
   ```
3. Take a VirtualBox snapshot:
   - Machine → Take Snapshot → "configured-baseline"

## 🖥️ Installing a Desktop Environment (Optional)

### Debian

```bash
sudo apt install xfce4 lightdm
sudo systemctl enable lightdm
sudo reboot
```

### Arch Linux

```bash
sudo pacman -S xfce4 lightdm
sudo systemctl enable lightdm
sudo reboot
```

### Fedora

```bash
sudo dnf groupinstall "Xfce Desktop"
sudo reboot
```

## 📦 Requirements

- VirtualBox with a fresh Linux VM from [linuxvirtualimages.com](https://linuxvirtualimages.com)
- Sudo access (no root login required)
- Internet connectivity

## 🔧 Customization

To modify any script:

1. Open the desired `.sh` file in a text editor
2. Update configurations (timezone, locale, package selections, etc.)
3. Save and run with `bash script-name.sh`

## 📖 License

[Specify your license here - e.g., MIT, GPL-3.0, etc.]

## 🤝 Contributing

Contributions are welcome! Please feel free to:
- Report issues
- Suggest improvements
- Submit pull requests

## 📧 Support

For questions or issues, please open a [GitHub Issue](https://github.com/Slayknoxx/setup-files-for-arch--linux-fedora-and-debian-for-virtual-box/issues).

---

**Last Updated:** 2026-05-16

#!/bin/bash
# ============================================================
#  VM POST-INSTALL SETUP — ARCH LINUX
#  Run as your normal user (sudo access required)
#  Usage: bash setup-arch.sh
# ============================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

log()  { echo -e "${GREEN}[✔]${NC} $1"; }
info() { echo -e "${CYAN}[i]${NC} $1"; }
warn() { echo -e "${YELLOW}[!]${NC} $1"; }
fail() { echo -e "${RED}[✘]${NC} $1"; }

echo -e "\n${BOLD}╔══════════════════════════════════════════╗${NC}"
echo -e "${BOLD}║   ARCH LINUX VM POST-INSTALL SETUP      ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════╝${NC}\n"

# ── 1. CHECK INTERNET ──────────────────────────────────────
info "Checking internet connection..."
if ping -c 2 archlinux.org &>/dev/null; then
    log "Internet is working."
else
    fail "No internet. Check your VirtualBox network adapter."
    exit 1
fi

# ── 2. UPDATE MIRRORLIST (use reflector for fastest mirrors) ─
info "Installing reflector to find fastest mirrors..."
sudo pacman -Sy --noconfirm reflector

info "Fetching fastest mirrors for your region (Africa/Kenya)..."
sudo reflector \
    --country "Kenya,South Africa,Ethiopia,Tanzania" \
    --age 12 \
    --protocol https \
    --sort rate \
    --save /etc/pacman.d/mirrorlist 2>/dev/null || \
sudo reflector \
    --latest 20 \
    --protocol https \
    --sort rate \
    --save /etc/pacman.d/mirrorlist
log "Mirrorlist updated with fastest mirrors."

# ── 3. ENABLE MULTILIB (32-bit support) ───────────────────
info "Enabling multilib repository..."
sudo sed -i '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf
log "Multilib enabled."

# ── 4. FULL SYSTEM UPDATE ──────────────────────────────────
info "Running full system update (this may take a while)..."
sudo pacman -Syu --noconfirm
log "System fully updated."

# ── 5. INSTALL ESSENTIAL TOOLS ─────────────────────────────
info "Installing essential tools..."
sudo pacman -S --noconfirm \
    curl wget git vim nano htop \
    net-tools unzip base-devel \
    bash-completion man-db man-pages \
    networkmanager openssh
log "Essential tools installed."

# ── 6. INSTALL AUR HELPER (yay) ────────────────────────────
if ! command -v yay &>/dev/null; then
    info "Installing yay (AUR helper)..."
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ~
    log "yay installed successfully."
else
    log "yay is already installed."
fi

# ── 7. INSTALL VIRTUALBOX GUEST UTILS ─────────────────────
info "Installing VirtualBox Guest Additions..."
sudo pacman -S --noconfirm virtualbox-guest-utils
sudo systemctl enable --now vboxservice
log "VirtualBox Guest Additions installed and enabled."

# ── 8. SET TIMEZONE ────────────────────────────────────────
info "Setting timezone to Africa/Nairobi..."
sudo timedatectl set-timezone Africa/Nairobi
sudo timedatectl set-ntp true
log "Timezone set: $(timedatectl | grep 'Time zone')"

# ── 9. SET LOCALE ──────────────────────────────────────────
info "Configuring locale..."
if ! grep -q "^en_US.UTF-8" /etc/locale.gen; then
    sudo sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
fi
sudo locale-gen
echo "LANG=en_US.UTF-8" | sudo tee /etc/locale.conf > /dev/null
log "Locale set to en_US.UTF-8."

# ── 10. ENABLE USEFUL SERVICES ────────────────────────────
info "Enabling NetworkManager..."
sudo systemctl enable --now NetworkManager
log "NetworkManager enabled."

# ── 11. CHANGE DEFAULT PASSWORD ───────────────────────────
warn "The default VM password is publicly known. Change it now."
echo -e "${YELLOW}Enter a new password for user: $(whoami)${NC}"
passwd

# ── 12. VBOX SETTINGS REMINDER ────────────────────────────
echo ""
warn "Recommended VirtualBox settings (shut down VM first):"
echo "  • RAM:           2048 MB minimum (4096 for GNOME/KDE)"
echo "  • CPUs:          2 or more"
echo "  • Video Memory:  128 MB"
echo "  • 3D Accel:      Enabled"
echo "  • Clipboard:     Bidirectional"
echo "  • Drag & Drop:   Bidirectional"
echo ""

# ── 13. DONE ──────────────────────────────────────────────
echo -e "${BOLD}${GREEN}"
echo "╔══════════════════════════════════════════╗"
echo "║       SETUP COMPLETE — ARCH LINUX        ║"
echo "╚══════════════════════════════════════════╝"
echo -e "${NC}"
echo "Next steps:"
echo "  1. Reboot: sudo reboot"
echo "  2. Take a VirtualBox snapshot named 'configured-baseline'"
echo "  3. Install a desktop: sudo pacman -S xfce4 lightdm"
echo ""

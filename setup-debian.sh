#!/bin/bash
# ============================================================
#  VM POST-INSTALL SETUP — DEBIAN (Trixie/Bookworm)
#  Run as your normal user (sudo access required)
#  Usage: bash setup-debian.sh
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
echo -e "${BOLD}║   DEBIAN VM POST-INSTALL SETUP SCRIPT   ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════╝${NC}\n"

# ── 1. CHECK INTERNET ──────────────────────────────────────
info "Checking internet connection..."
if ping -c 2 deb.debian.org &>/dev/null; then
    log "Internet is working."
else
    fail "No internet. Check your VirtualBox network adapter (NAT or Bridged)."
    exit 1
fi

# ── 2. FIX SOURCES LIST ────────────────────────────────────
info "Detecting Debian version..."
CODENAME=$(grep VERSION_CODENAME /etc/os-release | cut -d= -f2)
info "Detected: $CODENAME"

info "Writing sources.list..."
sudo tee /etc/apt/sources.list > /dev/null <<EOF
deb http://deb.debian.org/debian $CODENAME main contrib non-free non-free-firmware
deb http://deb.debian.org/debian $CODENAME-updates main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security $CODENAME-security main contrib non-free non-free-firmware
EOF
log "Sources list updated (using GeoDNS — auto-routes to nearest mirror)."

# ── 3. FULL SYSTEM UPDATE ──────────────────────────────────
info "Updating package lists..."
sudo apt update -y

info "Upgrading all packages (this may take a while)..."
sudo apt full-upgrade -y
log "System fully updated."

# ── 4. INSTALL ESSENTIAL TOOLS ─────────────────────────────
info "Installing essential tools..."
sudo apt install -y \
    curl wget git vim nano htop net-tools unzip \
    build-essential dkms linux-headers-$(uname -r) \
    bash-completion ca-certificates gnupg lsb-release
log "Essential tools installed."

# ── 5. SET TIMEZONE ────────────────────────────────────────
info "Setting timezone to Africa/Nairobi..."
sudo timedatectl set-timezone Africa/Nairobi
log "Timezone set: $(timedatectl | grep 'Time zone')"

# ── 6. SET LOCALE ──────────────────────────────────────────
info "Configuring locale..."
sudo sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
sudo locale-gen
sudo update-locale LANG=en_US.UTF-8
log "Locale set to en_US.UTF-8."

# ── 7. CHANGE DEFAULT PASSWORD ─────────────────────────────
warn "The default VM password is publicly known. Change it now."
echo -e "${YELLOW}Enter a new password for user: $(whoami)${NC}"
passwd

# ── 8. VIRTUALBOX GUEST ADDITIONS REMINDER ─────────────────
echo ""
warn "VirtualBox Guest Additions — MANUAL STEP REQUIRED:"
echo "  1. In VirtualBox menu: Devices → Insert Guest Additions CD Image"
echo "  2. Then run:"
echo "     sudo mount /dev/cdrom /mnt"
echo "     sudo /mnt/VBoxLinuxAdditions.run"
echo "     sudo reboot"
echo ""

# ── 9. VBOX SETTINGS REMINDER ──────────────────────────────
warn "Recommended VirtualBox settings (shut down VM first):"
echo "  • RAM:           2048 MB minimum (4096 for GNOME/KDE)"
echo "  • CPUs:          2 or more"
echo "  • Video Memory:  128 MB"
echo "  • 3D Accel:      Enabled"
echo "  • Clipboard:     Bidirectional"
echo "  • Drag & Drop:   Bidirectional"
echo ""

# ── 10. DONE ───────────────────────────────────────────────
echo -e "${BOLD}${GREEN}"
echo "╔══════════════════════════════════════════╗"
echo "║         SETUP COMPLETE — DEBIAN          ║"
echo "╚══════════════════════════════════════════╝"
echo -e "${NC}"
echo "Next steps:"
echo "  1. Install Guest Additions (see above)"
echo "  2. Reboot: sudo reboot"
echo "  3. Take a VirtualBox snapshot named 'configured-baseline'"
echo ""

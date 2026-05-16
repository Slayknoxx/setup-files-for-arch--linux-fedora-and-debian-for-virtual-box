#!/bin/bash
# ============================================================
#  VM POST-INSTALL SETUP — FEDORA
#  Run as your normal user (sudo access required)
#  Usage: bash setup-fedora.sh
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
echo -e "${BOLD}║     FEDORA VM POST-INSTALL SETUP         ║${NC}"
echo -e "${BOLD}╚══════════════════════════════════════════╝${NC}\n"

# ── 1. CHECK INTERNET ──────────────────────────────────────
info "Checking internet connection..."
if ping -c 2 fedoraproject.org &>/dev/null; then
    log "Internet is working."
else
    fail "No internet. Check your VirtualBox network adapter."
    exit 1
fi

# ── 2. SPEED UP DNF ───────────────────────────────────────
info "Optimizing DNF package manager..."
sudo tee -a /etc/dnf/dnf.conf > /dev/null <<EOF
fastestmirror=True
max_parallel_downloads=10
defaultyes=True
keepcache=True
EOF
log "DNF optimized (fastest mirror + parallel downloads enabled)."

# ── 3. FULL SYSTEM UPDATE ──────────────────────────────────
info "Running full system update (this may take a while)..."
sudo dnf upgrade --refresh -y
log "System fully updated."

# ── 4. INSTALL ESSENTIAL TOOLS ─────────────────────────────
info "Installing essential tools..."
sudo dnf install -y \
    curl wget git vim nano htop \
    net-tools unzip bash-completion \
    kernel-devel kernel-headers \
    gcc make perl dkms \
    ca-certificates gnupg2 \
    openssh-server
log "Essential tools installed."

# ── 5. ENABLE RPM FUSION (extra packages) ─────────────────
info "Enabling RPM Fusion repositories (free + non-free)..."
sudo dnf install -y \
    https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
    https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
log "RPM Fusion enabled — more software now available."

# ── 6. INSTALL MULTIMEDIA CODECS ──────────────────────────
info "Installing multimedia codecs..."
sudo dnf groupupdate -y multimedia --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin
sudo dnf groupupdate -y sound-and-video
log "Multimedia codecs installed."

# ── 7. INSTALL VIRTUALBOX GUEST ADDITIONS ─────────────────
info "Installing VirtualBox Guest Additions..."
sudo dnf install -y virtualbox-guest-additions
sudo systemctl enable --now vboxservice 2>/dev/null || true
log "VirtualBox Guest Additions installed."

# ── 8. SET TIMEZONE ────────────────────────────────────────
info "Setting timezone to Africa/Nairobi..."
sudo timedatectl set-timezone Africa/Nairobi
sudo timedatectl set-ntp true
log "Timezone set: $(timedatectl | grep 'Time zone')"

# ── 9. SET LOCALE ──────────────────────────────────────────
info "Configuring locale..."
sudo localectl set-locale LANG=en_US.UTF-8
log "Locale set to en_US.UTF-8."

# ── 10. ENABLE USEFUL SERVICES ────────────────────────────
info "Enabling NetworkManager and SSH..."
sudo systemctl enable --now NetworkManager
sudo systemctl enable sshd
log "Services enabled."

# ── 11. CONFIGURE FIREWALL ────────────────────────────────
info "Configuring firewall (allow SSH)..."
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --reload
log "Firewall configured."

# ── 12. FLATPAK SETUP ─────────────────────────────────────
info "Setting up Flatpak with Flathub..."
sudo dnf install -y flatpak
sudo flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
log "Flatpak + Flathub ready — install any app with: flatpak install flathub <appname>"

# ── 13. CHANGE DEFAULT PASSWORD ───────────────────────────
warn "The default VM password is publicly known. Change it now."
echo -e "${YELLOW}Enter a new password for user: $(whoami)${NC}"
passwd

# ── 14. VBOX SETTINGS REMINDER ────────────────────────────
echo ""
warn "Recommended VirtualBox settings (shut down VM first):"
echo "  • RAM:           2048 MB minimum (4096 for GNOME/KDE)"
echo "  • CPUs:          2 or more"
echo "  • Video Memory:  128 MB"
echo "  • 3D Accel:      Enabled"
echo "  • Clipboard:     Bidirectional"
echo "  • Drag & Drop:   Bidirectional"
echo ""

# ── 15. DONE ──────────────────────────────────────────────
echo -e "${BOLD}${GREEN}"
echo "╔══════════════════════════════════════════╗"
echo "║         SETUP COMPLETE — FEDORA          ║"
echo "╚══════════════════════════════════════════╝"
echo -e "${NC}"
echo "Next steps:"
echo "  1. Reboot: sudo reboot"
echo "  2. Take a VirtualBox snapshot named 'configured-baseline'"
echo "  3. Install a desktop: sudo dnf groupinstall 'Xfce Desktop'"
echo ""

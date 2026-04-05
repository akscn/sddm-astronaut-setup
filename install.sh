#!/bin/bash

# ============================================================
#  SDDM Astronaut Theme Installer
#  For Arch Linux + Hyprland + Nvidia
#  By: akscn | github.com/akscn
#
#  Credits: Original theme by Keyitdev
#  https://github.com/Keyitdev/sddm-astronaut-theme
#
#  Features:
#  - Full backup of existing configs before any changes
#  - Automatic rollback if anything goes wrong
#  - Dependency checks before starting
#  - Safe overwrite with confirmation prompts
#  - Color-coded status output
# ============================================================

# ─── Colors ─────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ─── Paths ───────────────────────────────────────────────────
THEME_DIR="/usr/share/sddm/themes/sddm-astronaut-theme"
THEME_REPO="https://github.com/keyitdev/sddm-astronaut-theme.git"
SDDM_CONF="/etc/sddm.conf"
SDDM_CONF_D="/etc/sddm.conf.d"
VKBD_CONF="$SDDM_CONF_D/virtualkbd.conf"
BACKUP_DIR="$HOME/.sddm-astronaut-backup-$(date +%Y%m%d_%H%M%S)"

# ─── Track what was done for rollback ────────────────────────
BACKUP_DONE=false
THEME_CLONED=false
SDDM_CONF_WRITTEN=false
VKBD_CONF_WRITTEN=false
SDDM_ENABLED=false

# ─── Helpers ─────────────────────────────────────────────────
log_info()    { echo -e "${CYAN}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error()   { echo -e "${RED}[✗]${NC} $1"; }
log_step()    { echo -e "\n${BOLD}${CYAN}━━━ $1 ━━━${NC}"; }

# ─── Rollback ────────────────────────────────────────────────
rollback() {
    echo ""
    log_error "Something went wrong! Rolling back all changes..."
    echo ""

    if [ -f "$BACKUP_DIR/sddm.conf" ]; then
        sudo cp "$BACKUP_DIR/sddm.conf" "$SDDM_CONF"
        log_info "Restored /etc/sddm.conf"
    elif [ "$SDDM_CONF_WRITTEN" = true ]; then
        sudo rm -f "$SDDM_CONF"
        log_info "Removed /etc/sddm.conf (was not present before)"
    fi

    if [ -f "$BACKUP_DIR/virtualkbd.conf" ]; then
        sudo cp "$BACKUP_DIR/virtualkbd.conf" "$VKBD_CONF"
        log_info "Restored $VKBD_CONF"
    elif [ "$VKBD_CONF_WRITTEN" = true ]; then
        sudo rm -f "$VKBD_CONF"
        log_info "Removed $VKBD_CONF (was not present before)"
    fi

    if [ "$THEME_CLONED" = true ] && [ -d "$THEME_DIR" ]; then
        sudo rm -rf "$THEME_DIR"
        log_info "Removed cloned theme"
    fi

    if [ -f "$BACKUP_DIR/display-manager-was" ]; then
        PREV_DM=$(cat "$BACKUP_DIR/display-manager-was")
        if [ -n "$PREV_DM" ]; then
            sudo systemctl enable "$PREV_DM" 2>/dev/null
            log_info "Re-enabled: $PREV_DM"
        fi
        if [ "$SDDM_ENABLED" = true ]; then
            sudo systemctl disable sddm 2>/dev/null
        fi
    fi

    echo ""
    log_warn "Rollback complete. System restored to previous state."
    log_warn "Backup saved at: $BACKUP_DIR"
    echo ""
    exit 1
}

trap rollback ERR

# ─── Banner ──────────────────────────────────────────────────
clear
echo -e "${CYAN}${BOLD}"
echo "  ____  ____  ____  __  __"
echo " / ___||  _ \|  _ \|  \/  |"
echo " \___ \| | | | | | | |\/| |"
echo "  ___) | |_| | |_| | |  | |"
echo " |____/|____/|____/|_|  |_|"
echo -e " Astronaut Theme Installer${NC}"
echo ""
echo -e " ${YELLOW}By akscn — github.com/akscn${NC}"
echo -e " ${YELLOW}Original theme by Keyitdev — github.com/Keyitdev/sddm-astronaut-theme${NC}"
echo ""

# ─── System Checks ───────────────────────────────────────────
log_step "Checking System"

if ! command -v pacman &>/dev/null; then
    log_error "This script only supports Arch Linux (pacman not found)."
    exit 1
fi
log_success "Arch Linux detected"

if [ "$EUID" -eq 0 ]; then
    log_error "Do not run this script as root. Run as your normal user."
    exit 1
fi
log_success "Running as normal user: $USER"

if ! sudo -v; then
    log_error "Could not get sudo access."
    exit 1
fi
log_success "sudo access confirmed"

if ! command -v git &>/dev/null; then
    log_warn "git not found — installing..."
    sudo pacman -S --needed --noconfirm git
fi
log_success "git available"

if ! ping -c 1 github.com &>/dev/null; then
    log_error "No internet connection. Please connect and try again."
    exit 1
fi
log_success "Internet connection OK"

if command -v sddm &>/dev/null; then
    SDDM_VER=$(sddm --version 2>/dev/null | grep -oP '\d+\.\d+\.\d+' | head -1)
    log_success "SDDM version: $SDDM_VER"
else
    log_warn "SDDM not found — will be installed."
fi

# ─── Confirm ─────────────────────────────────────────────────
echo ""
echo -e "${YELLOW}This script will:${NC}"
echo "  • Install dependencies"
echo "  • Clone sddm-astronaut-theme"
echo "  • Copy fonts"
echo "  • Configure /etc/sddm.conf"
echo "  • Enable SDDM as display manager"
echo ""
echo -e "${YELLOW}Backup will be saved to:${NC} $BACKUP_DIR"
echo ""
read -rp "$(echo -e ${BOLD}Continue? [y/N]: ${NC})" CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
fi

# ─── Step 0: Backup ──────────────────────────────────────────
log_step "Backing Up Existing Configs"

mkdir -p "$BACKUP_DIR"

[ -f "$SDDM_CONF" ] && cp "$SDDM_CONF" "$BACKUP_DIR/sddm.conf" && log_success "Backed up sddm.conf" || log_info "No existing sddm.conf"
[ -f "$VKBD_CONF" ] && cp "$VKBD_CONF" "$BACKUP_DIR/virtualkbd.conf" && log_success "Backed up virtualkbd.conf" || log_info "No existing virtualkbd.conf"

if [ -d "$THEME_DIR" ]; then
    log_warn "Theme already exists at $THEME_DIR"
    read -rp "$(echo -e ${YELLOW}Overwrite? [y/N]: ${NC})" OVERWRITE
    if [[ "$OVERWRITE" =~ ^[Yy]$ ]]; then
        sudo cp -r "$THEME_DIR" "$BACKUP_DIR/sddm-astronaut-theme"
        sudo rm -rf "$THEME_DIR"
        log_success "Old theme backed up and removed"
    else
        log_info "Keeping existing theme, pulling latest only."
    fi
fi

CURRENT_DM=$(systemctl list-units --type=service --state=enabled | grep -E 'gdm|sddm|lightdm' | awk '{print $1}' | head -1 | sed 's/.service//')
echo "$CURRENT_DM" > "$BACKUP_DIR/display-manager-was"
log_success "Noted current display manager: ${CURRENT_DM:-none}"
BACKUP_DONE=true

# ─── Step 1: Dependencies ─────────────────────────────────────
log_step "Installing Dependencies"
sudo pacman -S --needed --noconfirm sddm qt6-svg qt6-virtualkeyboard qt6-multimedia-ffmpeg
log_success "All dependencies installed"

# ─── Step 2: Clone Theme ──────────────────────────────────────
log_step "Cloning sddm-astronaut-theme"
if [ -d "$THEME_DIR" ]; then
    log_info "Pulling latest changes..."
    sudo git -C "$THEME_DIR" pull
else
    sudo git clone -b master --depth 1 "$THEME_REPO" "$THEME_DIR"
    THEME_CLONED=true
fi
log_success "Theme ready at $THEME_DIR"

# ─── Step 3: Fonts ───────────────────────────────────────────
log_step "Installing Fonts"
sudo cp -r "$THEME_DIR/Fonts/"* /usr/share/fonts/
log_success "Fonts installed"

# ─── Step 4: sddm.conf ───────────────────────────────────────
log_step "Configuring /etc/sddm.conf"
if [ -f "$SDDM_CONF" ]; then
    if grep -q '^\[Theme\]' "$SDDM_CONF"; then
        sudo sed -i '/^\[Theme\]/,/^\[/{s/^Current=.*/Current=sddm-astronaut-theme/}' "$SDDM_CONF"
        log_info "Updated existing [Theme] section"
    else
        echo -e "\n[Theme]\nCurrent=sddm-astronaut-theme" | sudo tee -a "$SDDM_CONF" > /dev/null
        log_info "Appended [Theme] section"
    fi
else
    echo "[Theme]
Current=sddm-astronaut-theme" | sudo tee "$SDDM_CONF" > /dev/null
    log_info "Created new sddm.conf"
fi
SDDM_CONF_WRITTEN=true
log_success "sddm.conf configured"

# ─── Step 5: Virtual Keyboard ────────────────────────────────
log_step "Configuring Virtual Keyboard"
sudo mkdir -p "$SDDM_CONF_D"
echo "[General]
InputMethod=qtvirtualkeyboard" | sudo tee "$VKBD_CONF" > /dev/null
VKBD_CONF_WRITTEN=true
log_success "Virtual keyboard configured"

# ─── Step 6: Metadata ────────────────────────────────────────
log_step "Writing Theme Metadata"
sudo tee "$THEME_DIR/metadata.desktop" > /dev/null <<'EOF'
[SddmGreeterTheme]
Name=sddm-astronaut-theme
Description=sddm-astronaut-theme
Author=keyitdev
Website=https://github.com/Keyitdev/sddm-astronaut-theme
License=GPL-3.0-or-later
Type=sddm-theme
Version=1.3

# Pick ONE by removing its # :
ConfigFile=Themes/astronaut.conf
#ConfigFile=Themes/black_hole.conf
#ConfigFile=Themes/japanese_aesthetic.conf
#ConfigFile=Themes/cyberpunk.conf
#ConfigFile=Themes/purple_leaves.conf
#ConfigFile=Themes/post-apocalyptic_hacker.conf
#ConfigFile=Themes/pixel_sakura_static.conf
#ConfigFile=Themes/pixel_sakura.conf
#ConfigFile=Themes/hyprland_kath.conf
#ConfigFile=Themes/jake_the_dog.conf

Screenshot=Previews/astronaut.png
MainScript=Main.qml
TranslationsDirectory=translations
Theme-Id=sddm-astronaut-theme
Theme-API=2.0
QtVersion=6
EOF
log_success "Metadata written — default theme: astronaut"

# ─── Step 7: Enable SDDM ─────────────────────────────────────
log_step "Enabling SDDM"
systemctl is-enabled gdm &>/dev/null && sudo systemctl disable gdm && log_info "GDM disabled"
systemctl is-enabled lightdm &>/dev/null && sudo systemctl disable lightdm && log_info "LightDM disabled"
sudo systemctl enable sddm
SDDM_ENABLED=true
log_success "SDDM enabled"

# ─── Step 8: Test Mode ───────────────────────────────────────
log_step "Test the Theme"
echo ""
echo -e "${YELLOW}Want to preview the theme before rebooting?${NC}"
read -rp "$(echo -e ${BOLD}Run test mode? [y/N]: ${NC})" RUN_TEST
if [[ "$RUN_TEST" =~ ^[Yy]$ ]]; then
    log_info "Launching preview... close with Super+Q or Alt+F4"
    sddm-greeter-qt6 --test-mode --theme "$THEME_DIR/" || true
fi

# ─── Write restore script ────────────────────────────────────
cat > "$BACKUP_DIR/restore.sh" <<RESTORE
#!/bin/bash
echo "Restoring previous SDDM configuration..."
[ -f "$BACKUP_DIR/sddm.conf" ] && sudo cp "$BACKUP_DIR/sddm.conf" "$SDDM_CONF" && echo "✓ Restored sddm.conf"
[ -f "$BACKUP_DIR/virtualkbd.conf" ] && sudo cp "$BACKUP_DIR/virtualkbd.conf" "$VKBD_CONF" && echo "✓ Restored virtualkbd.conf"
[ -d "$BACKUP_DIR/sddm-astronaut-theme" ] && sudo cp -r "$BACKUP_DIR/sddm-astronaut-theme" "$THEME_DIR" && echo "✓ Restored theme"
PREV_DM=\$(cat "$BACKUP_DIR/display-manager-was")
[ -n "\$PREV_DM" ] && sudo systemctl enable "\$PREV_DM" && sudo systemctl disable sddm && echo "✓ Restored display manager: \$PREV_DM"
echo "Done! Please reboot."
RESTORE
chmod +x "$BACKUP_DIR/restore.sh"

# ─── Done ────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}============================================${NC}"
echo -e "${GREEN}${BOLD}   Installation Complete! 🚀${NC}"
echo -e "${GREEN}${BOLD}============================================${NC}"
echo ""
echo -e " ${CYAN}Backup saved at:${NC}       $BACKUP_DIR"
echo -e " ${CYAN}Restore anytime:${NC}       bash $BACKUP_DIR/restore.sh"
echo ""
echo -e " ${YELLOW}Change theme preset:${NC}"
echo -e "   sudo nano $THEME_DIR/metadata.desktop"
echo ""
echo -e " ${YELLOW}Test without rebooting:${NC}"
echo -e "   sddm-greeter-qt6 --test-mode --theme $THEME_DIR/"
echo ""
echo -e " ${YELLOW}Apply changes:${NC}"
echo -e "   reboot"
echo ""

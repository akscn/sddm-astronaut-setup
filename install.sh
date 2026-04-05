#!/bin/bash

# ============================================================
# SDDM Astronaut Theme Installer
# For Arch Linux + Hyprland + Nvidia
# By: akscn | github.com/akscn
# ============================================================

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

THEME_DIR="/usr/share/sddm/themes/sddm-astronaut-theme"
THEME_REPO="https://github.com/keyitdev/sddm-astronaut-theme.git"

echo -e "${CYAN}"
echo "  ____  ____  ____  __  __"
echo " / ___||  _ \|  _ \|  \/  |"
echo " \___ \| | | | | | | |\/| |"
echo "  ___) | |_| | |_| | |  | |"
echo " |____/|____/|____/|_|  |_|"
echo -e " Astronaut Theme Installer${NC}"
echo ""

# ─── Step 1: Install dependencies ───────────────────────────
echo -e "${YELLOW}[1/6] Installing dependencies...${NC}"
sudo pacman -S --needed --noconfirm sddm qt6-svg qt6-virtualkeyboard qt6-multimedia-ffmpeg
echo -e "${GREEN}✓ Dependencies installed${NC}"

# ─── Step 2: Clone the theme ────────────────────────────────
echo -e "${YELLOW}[2/6] Cloning sddm-astronaut-theme...${NC}"
if [ -d "$THEME_DIR" ]; then
    echo -e "${YELLOW}Theme already exists, pulling latest...${NC}"
    sudo git -C "$THEME_DIR" pull
else
    sudo git clone -b master --depth 1 "$THEME_REPO" "$THEME_DIR"
fi
echo -e "${GREEN}✓ Theme cloned${NC}"

# ─── Step 3: Copy fonts ─────────────────────────────────────
echo -e "${YELLOW}[3/6] Installing fonts...${NC}"
sudo cp -r "$THEME_DIR/Fonts/"* /usr/share/fonts/
echo -e "${GREEN}✓ Fonts installed${NC}"

# ─── Step 4: Set theme in sddm.conf ─────────────────────────
echo -e "${YELLOW}[4/6] Configuring /etc/sddm.conf...${NC}"
echo "[Theme]
Current=sddm-astronaut-theme" | sudo tee /etc/sddm.conf > /dev/null
echo -e "${GREEN}✓ sddm.conf updated${NC}"

# ─── Step 5: Enable virtual keyboard ────────────────────────
echo -e "${YELLOW}[5/6] Setting up virtual keyboard...${NC}"
sudo mkdir -p /etc/sddm.conf.d
echo "[General]
InputMethod=qtvirtualkeyboard" | sudo tee /etc/sddm.conf.d/virtualkbd.conf > /dev/null
echo -e "${GREEN}✓ Virtual keyboard configured${NC}"

# ─── Step 6: Write metadata with all presets commented ───────
echo -e "${YELLOW}[6/6] Writing theme metadata...${NC}"
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
echo -e "${GREEN}✓ Metadata written${NC}"

# ─── Enable SDDM ────────────────────────────────────────────
echo ""
echo -e "${YELLOW}Enabling SDDM...${NC}"

# Disable GDM if running
if systemctl is-enabled gdm &>/dev/null; then
    echo -e "${YELLOW}Disabling GDM...${NC}"
    sudo systemctl disable gdm
fi

sudo systemctl enable sddm
echo -e "${GREEN}✓ SDDM enabled${NC}"

# ─── Done ───────────────────────────────────────────────────
echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  Installation complete!${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo -e "  To change theme preset, edit:"
echo -e "  ${CYAN}sudo nano $THEME_DIR/metadata.desktop${NC}"
echo ""
echo -e "  To test without rebooting:"
echo -e "  ${CYAN}sddm-greeter-qt6 --test-mode --theme $THEME_DIR/${NC}"
echo ""
echo -e "  Reboot to apply: ${CYAN}reboot${NC}"
echo ""

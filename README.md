# 🚀 SDDM Astronaut Theme Setup — Arch Linux + Hyprland

A setup guide and automated installer for the [sddm-astronaut-theme](https://github.com/Keyitdev/sddm-astronaut-theme) on Arch Linux with Hyprland. Includes animated wallpaper support and Nvidia compatibility.

> **Note:** This repo does not contain the theme itself. It provides an install script and guide to set it up correctly. All credit for the theme goes to [Keyitdev](https://github.com/Keyitdev).

---

## 📋 Prerequisites

- Arch Linux
- Hyprland (or any Wayland compositor)
- Internet connection
- A terminal

---

## ⚡ Quick Install (Recommended)

Clone this repo and run the install script — it handles everything automatically:

```bash
git clone https://github.com/akscn/sddm-astronaut-setup.git
cd sddm-astronaut-setup
chmod +x install.sh
./install.sh
```

The script will:
- ✅ Check your system before doing anything
- ✅ Ask for confirmation before making changes
- ✅ Back up all your existing configs
- ✅ Install dependencies, clone theme, copy fonts, configure SDDM
- ✅ Auto rollback everything if something goes wrong
- ✅ Generate a `restore.sh` for manual recovery anytime

After it finishes, jump to [Step 4](#-step-4--pick-your-theme-preset) to choose your theme.

---

## 🛠️ Manual Installation

If you prefer doing it yourself step by step:

### 📦 Step 1 — Install Dependencies

```bash
sudo pacman -S --needed sddm qt6-svg qt6-virtualkeyboard qt6-multimedia-ffmpeg
```

> `qt6-multimedia-ffmpeg` is required for animated/video wallpapers.

---

### 📥 Step 2 — Clone the Theme

```bash
sudo git clone -b master --depth 1 \
  https://github.com/keyitdev/sddm-astronaut-theme.git \
  /usr/share/sddm/themes/sddm-astronaut-theme
```

---

### 🔤 Step 3 — Copy Fonts

```bash
sudo cp -r /usr/share/sddm/themes/sddm-astronaut-theme/Fonts/* /usr/share/fonts/
```

---

### ⚙️ Configure SDDM

Set the theme:

```bash
echo "[Theme]
Current=sddm-astronaut-theme" | sudo tee /etc/sddm.conf
```

Enable virtual keyboard:

```bash
sudo mkdir -p /etc/sddm.conf.d
echo "[General]
InputMethod=qtvirtualkeyboard" | sudo tee /etc/sddm.conf.d/virtualkbd.conf
```

---

## 🎨 Step 4 — Pick Your Theme Preset

Open the metadata file:

```bash
sudo nano /usr/share/sddm/themes/sddm-astronaut-theme/metadata.desktop
```

Remove `#` from the theme you want, keep `#` on the rest:

```ini
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
```

Save with `Ctrl+O` → `Enter` → `Ctrl+X`

> You can also just copy the `metadata.desktop` from this repo directly — it already has all presets listed with `astronaut.conf` active by default.

### 🖼️ Available Presets

| Theme | Style |
|---|---|
| `astronaut.conf` | 🪐 Default space astronaut (static) |
| `black_hole.conf` | 🌑 Dark black hole (static) |
| `japanese_aesthetic.conf` | 🎌 Japanese lofi vibes (static) |
| `cyberpunk.conf` | 🌆 Neon cyberpunk (static) |
| `purple_leaves.conf` | 🍃 Purple nature (static) |
| `post-apocalyptic_hacker.conf` | 💀 Hacker dark (static) |
| `pixel_sakura_static.conf` | 🌸 Sakura static |
| `pixel_sakura.conf` | 🌸 Animated pixel sakura |
| `hyprland_kath.conf` | 🎌 Animated anime girl |
| `jake_the_dog.conf` | 🐶 Animated Jake the Dog |

---

## 🧪 Step 5 — Test Without Rebooting

```bash
sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/sddm-astronaut-theme/
```

> Login won't work in test mode — that's completely normal. It's just a visual preview. Close with `Super+Q` or `Alt+F4`.

---

## 🔁 Step 6 — Enable SDDM & Reboot

If you were on GDM (GNOME) before:

```bash
sudo systemctl disable gdm
sudo systemctl enable sddm
```

Then reboot:

```bash
reboot
```

🎉 SDDM with your chosen theme will now greet you on login!

---

## ✅ Verify SDDM is Running

```bash
systemctl status display-manager
```

You should see `sddm.service` as `active (running)`.

---

## ⚠️ Nvidia Troubleshooting

If you see a black screen or no animation in test mode, try:

```bash
QT_XCB_NO_MITSHM=1 sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/sddm-astronaut-theme/
```

If that fixes it, add the env variable permanently:

```bash
sudo nano /etc/sddm.conf.d/virtualkbd.conf
```

```ini
[General]
InputMethod=qtvirtualkeyboard
GreeterEnvironment=QT_XCB_NO_MITSHM=1
```

---

## 😱 Something Went Wrong?

**If the script crashed mid-way** — it auto-rolls back. Your system is restored automatically.

**If you want to restore manually after reboot:**

```bash
bash ~/.sddm-astronaut-backup-*/restore.sh
reboot
```

This restores all your original configs and re-enables your previous display manager.

---

## 📁 Repo Structure

```
sddm-astronaut-setup/
├── README.md           # This guide
├── install.sh          # Automated install script with backup + rollback
└── metadata.desktop    # Pre-configured preset file (astronaut active by default)
```

---

## 🔗 Credits

- 🎨 **Original theme:** [sddm-astronaut-theme](https://github.com/Keyitdev/sddm-astronaut-theme) by [Keyitdev](https://github.com/Keyitdev) — all theme assets, QML code, wallpapers and presets belong to him. Please ⭐ his repo!
- 📝 **This install guide & script:** [akscn](https://github.com/akscn) — written for Arch Linux + Hyprland + Nvidia

---

## 📄 License

This install guide and script are free to use and share.
The theme itself is licensed under [GPLv3+](https://www.gnu.org/licenses/gpl-3.0.html) by Keyitdev.

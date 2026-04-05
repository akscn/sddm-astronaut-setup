# 🚀 SDDM Astronaut Theme Setup — Arch Linux + Hyprland

A setup guide and automated installer for the [sddm-astronaut-theme](https://github.com/Keyitdev/sddm-astronaut-theme) on Arch Linux with Hyprland. Includes animated wallpaper support and Nvidia compatibility.

> **Note:** This repo does not contain the theme itself. It only provides an install script, a pre-configured `metadata.desktop`, and this guide. All credit for the actual theme goes to [Keyitdev](https://github.com/Keyitdev). Please ⭐ [his repo](https://github.com/Keyitdev/sddm-astronaut-theme)!

---

## 📁 What's in This Repo

| File | Purpose |
|---|---|
| `README.md` | This guide |
| `install.sh` | Automated installer with backup + rollback |
| `metadata.desktop` | Pre-configured theme preset file with all 10 presets listed — `astronaut.conf` is active by default. Copy this to `/usr/share/sddm/themes/sddm-astronaut-theme/` to use it. |

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
- ✅ Check your system (Arch, internet, sudo, git) before doing anything
- ✅ Ask for your confirmation before making any changes
- ✅ Back up all your existing configs to `~/.sddm-astronaut-backup-<timestamp>/`
- ✅ Install all dependencies
- ✅ Clone the theme, copy fonts, configure SDDM
- ✅ Write `metadata.desktop` with all presets ready to switch
- ✅ Auto rollback everything if something goes wrong mid-install
- ✅ Generate a `restore.sh` in your backup folder for manual recovery anytime
- ✅ Optionally preview the theme in test mode before rebooting

After it finishes, jump to [Picking Your Theme](#-picking-your-theme) to choose your preset, then reboot.

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

### ⚙️ Step 4 — Configure SDDM

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

### 🔁 Step 5 — Enable SDDM

If you were on **GDM** (GNOME):
```bash
sudo systemctl disable gdm
sudo systemctl enable sddm
```

If you were on **LightDM**:
```bash
sudo systemctl disable lightdm
sudo systemctl enable sddm
```

If **SDDM was already your display manager**, just skip this step.

---

## 🎨 Picking Your Theme

### Option A — Use the `metadata.desktop` from this repo

Just copy it directly to the theme folder:

```bash
sudo cp metadata.desktop /usr/share/sddm/themes/sddm-astronaut-theme/metadata.desktop
```

It already has all 10 presets listed with `astronaut.conf` active by default. Open it and uncomment whichever you want.

---

### Option B — Edit it manually

```bash
sudo nano /usr/share/sddm/themes/sddm-astronaut-theme/metadata.desktop
```

Find the `ConfigFile=` lines and remove `#` from the one you want, keep `#` on the rest:

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

---

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

## 🧪 Test Without Rebooting

After picking your preset, always test it first before rebooting:

```bash
sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/sddm-astronaut-theme/
```

> Login won't work in test mode — that's completely normal. It's just a visual preview. Close with `Super+Q` or `Alt+F4`.

---

## 🔃 Changing Theme Later

Already installed and want to switch to a different preset? Just edit the metadata file:

```bash
sudo nano /usr/share/sddm/themes/sddm-astronaut-theme/metadata.desktop
```

Uncomment the preset you want, comment the rest, save, test, then reboot. No reinstallation needed.

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

**If the script crashed mid-way** — it auto-rolls back automatically. Your system is restored to how it was before.

**If you want to restore manually after rebooting:**

```bash
bash ~/.sddm-astronaut-backup-*/restore.sh
reboot
```

This restores all your original configs and re-enables your previous display manager.

---

## 🔗 Credits

- 🎨 **Original theme:** [sddm-astronaut-theme](https://github.com/Keyitdev/sddm-astronaut-theme) by [Keyitdev](https://github.com/Keyitdev) — all theme assets, QML code, wallpapers and presets belong to him. Please ⭐ his repo!
- 📝 **This install guide & script:** [akscn](https://github.com/akscn) — written for Arch Linux + Hyprland + Nvidia

---

## 📄 License

This install guide and script are free to use and share.
The theme itself is licensed under [GPLv3+](https://www.gnu.org/licenses/gpl-3.0.html) by Keyitdev.

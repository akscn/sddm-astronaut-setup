# 🚀 SDDM Astronaut Theme Setup — Arch Linux + Hyprland

A step-by-step guide to installing and configuring the [sddm-astronaut-theme](https://github.com/Keyitdev/sddm-astronaut-theme) on Arch Linux with Hyprland. Includes animated wallpaper support for Nvidia GPUs.

---

## 📋 Prerequisites

- Arch Linux
- Hyprland (or any Wayland compositor)
- SDDM already installed
- Nvidia GPU (GTX 1650 or similar)

---

## 📦 Step 1 — Install Dependencies

```bash
sudo pacman -S --needed sddm qt6-svg qt6-virtualkeyboard qt6-multimedia-ffmpeg
```

> `qt6-multimedia-ffmpeg` is required for animated/video wallpapers.

---

## 📥 Step 2 — Clone the Theme

```bash
sudo git clone -b master --depth 1 \
  https://github.com/keyitdev/sddm-astronaut-theme.git \
  /usr/share/sddm/themes/sddm-astronaut-theme
```

---

## 🔤 Step 3 — Copy Fonts

```bash
sudo cp -r /usr/share/sddm/themes/sddm-astronaut-theme/Fonts/* /usr/share/fonts/
```

---

## ⚙️ Step 4 — Configure SDDM

Set the theme in `/etc/sddm.conf`:

```bash
echo "[Theme]
Current=sddm-astronaut-theme" | sudo tee /etc/sddm.conf
```

Enable the virtual keyboard:

```bash
sudo mkdir -p /etc/sddm.conf.d
echo "[General]
InputMethod=qtvirtualkeyboard" | sudo tee /etc/sddm.conf.d/virtualkbd.conf
```

---

## 🎨 Step 5 — Choose a Theme Preset

Edit the metadata file:

```bash
sudo nano /usr/share/sddm/themes/sddm-astronaut-theme/metadata.desktop
```

Replace the `ConfigFile=` section with the following block. Remove `#` from the theme you want and keep `#` on the rest:

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

### 🖼️ Available Presets

| Theme | Style |
|---|---|
| `astronaut.conf` | Default space astronaut (static) |
| `black_hole.conf` | Dark black hole (static) |
| `japanese_aesthetic.conf` | Japanese lofi vibes (static) |
| `cyberpunk.conf` | Neon cyberpunk (static) |
| `purple_leaves.conf` | Purple nature (static) |
| `post-apocalyptic_hacker.conf` | Hacker dark (static) |
| `pixel_sakura_static.conf` | Sakura — static version |
| `pixel_sakura.conf` | 🌸 Animated pixel sakura |
| `hyprland_kath.conf` | 🎌 Animated anime girl |
| `jake_the_dog.conf` | 🐶 Animated Jake the Dog |

---

## 🧪 Step 6 — Test Without Rebooting

```bash
sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/sddm-astronaut-theme/
```

> Login won't work in test mode — that's expected. It's just a visual preview.

---

## 🔁 Step 7 — Enable SDDM & Reboot

If you were previously using GDM (GNOME's display manager):

```bash
sudo systemctl disable gdm
sudo systemctl enable sddm
```

Then reboot:

```bash
reboot
```

---

## ⚠️ Nvidia Troubleshooting

If you see a black screen or no animation in test mode, try:

```bash
QT_XCB_NO_MITSHM=1 sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/sddm-astronaut-theme/
```

If that fixes it, add the env variable permanently to `/etc/sddm.conf.d/virtualkbd.conf`:

```ini
[General]
InputMethod=qtvirtualkeyboard
GreeterEnvironment=QT_XCB_NO_MITSHM=1
```

---

## ✅ Verify SDDM is Running

```bash
systemctl status display-manager
```

You should see `sddm.service` as `active (running)`.

---

## 🔗 Credits

- Theme by [Keyitdev](https://github.com/Keyitdev/sddm-astronaut-theme)
- Guide written for Arch Linux + Hyprland + Nvidia

---

## 📄 License

This guide is free to use and share. The theme itself is licensed under [GPLv3+](https://www.gnu.org/licenses/gpl-3.0.html).

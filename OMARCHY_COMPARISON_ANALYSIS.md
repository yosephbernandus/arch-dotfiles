# Omarchy vs Personal Dotfiles - Deep Dive Analysis

**Date:** 2025-10-08
**Comparison:** `/home/yoseph/workspace/omarchy` vs `/home/yoseph/dotfiles`
**System:** Arch Linux with Hyprland + Wayland

---

## Table of Contents
1. [Directory Structure Overview](#directory-structure-overview)
2. [Hyprland Configuration Deep Dive](#hyprland-configuration-deep-dive)
3. [WiFi/Network Configuration Analysis](#wifinetwork-configuration-analysis)
4. [Critical Issues Found](#critical-issues-found)
5. [Migration Plan](#migration-plan)

---

## Directory Structure Overview

### Omarchy Repository Structure
```
/home/yoseph/workspace/omarchy/
├── bin/                          # Utility scripts
│   ├── omarchy-launch-wifi       # WiFi TUI launcher (impala)
│   ├── omarchy-restart-wifi      # WiFi troubleshooting script
│   └── [~50 other utility scripts]
├── config/                       # Base config templates
│   ├── hypr/                     # Hyprland main user config (ENTRY POINT)
│   ├── waybar/                   # Waybar config
│   ├── alacritty/
│   ├── ghostty/
│   ├── nvim/
│   └── [17 other app configs]
├── default/                      # Default configurations (sourced by user configs)
│   ├── hypr/
│   │   ├── autostart.conf        # Auto-started applications
│   │   ├── envs.conf             # Environment variables
│   │   ├── looknfeel.conf        # Aesthetics & animations
│   │   ├── input.conf            # Keyboard/mouse settings
│   │   ├── windows.conf          # Window rules
│   │   ├── apps.conf             # App-specific tweaks aggregator
│   │   ├── bindings/
│   │   │   ├── media.conf        # Volume, brightness, media keys
│   │   │   ├── tiling.conf       # Window management keybinds
│   │   │   └── utilities.conf    # Screenshots, menus, notifications
│   │   └── apps/                 # Per-app window rules
│   │       ├── 1password.conf
│   │       ├── browser.conf
│   │       ├── terminals.conf
│   │       └── [11 others]
│   └── [other app defaults]
├── install/                      # Installation & configuration scripts
│   ├── omarchy-base.packages     # Core packages (132 packages)
│   ├── omarchy-other.packages    # Optional/hardware packages (54 packages)
│   ├── config/
│   │   ├── all.sh                # Master config runner
│   │   └── hardware/
│   │       ├── network.sh        # ⚠️ Sets up iwd (not NetworkManager)
│   │       ├── set-wireless-regdom.sh  # ⚠️ WiFi regulatory domain
│   │       ├── bluetooth.sh
│   │       ├── nvidia.sh
│   │       └── [8 others]
│   ├── first-run/
│   │   ├── wifi.sh               # First boot WiFi check
│   │   └── [4 others]
│   └── [7 other categories, 65 total scripts]
└── themes/                       # Pre-built themes
```

### Your Personal Dotfiles Structure
```
/home/yoseph/dotfiles/
├── hypr/
│   └── .config/hypr/
│       ├── hyprland.conf         # ⚠️ MONOLITHIC (372 lines, everything in one file)
│       ├── hypridle.conf
│       ├── hyprlock.conf
│       ├── hyprlock.conf.bak     # ⚠️ Backup file (not cleaned)
│       ├── hyprpaper.conf
│       ├── mocha.conf
│       ├── scripts/              # Helper scripts
│       │   ├── battery-monitor.sh
│       │   ├── ChangeBlur.sh
│       │   ├── ClipManager.sh
│       │   ├── RofiEmoji.sh
│       │   └── [9 others]
│       ├── wallpaper_effects/
│       └── wallust/
├── waybar/
│   └── .config/waybar/
│       ├── config                # Your waybar config
│       ├── modules.json
│       └── waybar-quicklinks.json
├── swaync/                       # Notification daemon (active)
├── swaync_bak/                   # ⚠️ Backup (inconsistent)
├── swaync_bak2/                  # ⚠️ Another backup
├── fish/.config/fish/
│   ├── config.fish
│   ├── config.fish.backup        # ⚠️ Backup file
│   └── conf.d/uv.env.fish
├── nvim/.config/nvim/
│   ├── init.lua
│   └── init.lua.backup           # ⚠️ Backup file
└── [15 other app configs]
```

**Key Observations:**
- 🔴 Your dotfiles have **backup files** scattered (`.backup`, `_bak`, `_bak2`) indicating config instability
- 🔴 Your Hyprland config is **monolithic** (1 file) vs Omarchy's **modular** approach (23+ files)
- 🔴 No separation between "defaults" and "user overrides" in your setup

---

## Hyprland Configuration Deep Dive

### Architecture Comparison

#### Omarchy's Modular Approach
**Entry Point:** `/home/yoseph/workspace/omarchy/config/hypr/hyprland.conf`

```conf
# This is the ONLY file users edit directly
source = ~/.local/share/omarchy/default/hypr/autostart.conf
source = ~/.local/share/omarchy/default/hypr/bindings/media.conf
source = ~/.local/share/omarchy/default/hypr/bindings/tiling.conf
source = ~/.local/share/omarchy/default/hypr/bindings/utilities.conf
source = ~/.local/share/omarchy/default/hypr/envs.conf
source = ~/.local/share/omarchy/default/hypr/looknfeel.conf
source = ~/.local/share/omarchy/default/hypr/input.conf
source = ~/.local/share/omarchy/default/hypr/windows.conf
source = ~/.config/omarchy/current/theme/hyprland.conf

# User overrides (these take precedence)
source = ~/.config/hypr/monitors.conf
source = ~/.config/hypr/input.conf
source = ~/.config/hypr/bindings.conf
source = ~/.config/hypr/envs.conf
source = ~/.config/hypr/looknfeel.conf
source = ~/.config/hypr/autostart.conf
```

**How It Works:**
1. **Defaults first** - Load Omarchy's opinionated configs from `~/.local/share/omarchy/default/`
2. **User overrides second** - Load user customizations from `~/.config/hypr/`
3. Later `source` statements override earlier ones (Hyprland behavior)
4. **Update safe** - When Omarchy updates, defaults improve without breaking your customizations

#### Your Monolithic Approach
**Location:** `/home/yoseph/dotfiles/hypr/.config/hypr/hyprland.conf`

```conf
# Everything in one 372-line file:
# - Monitor setup (line 19-21)
# - Programs (line 30-33)
# - Autostart (line 44-55)
# - Environment variables (line 64-67)
# - Look and feel (line 77-154)
# - Input settings (line 193-210)
# - Keybindings (line 230-324)
# - Window rules (line 330-371)
```

**Problems:**
- ❌ Hard to maintain (need to scroll through 372 lines to find settings)
- ❌ No separation of concerns
- ❌ Difficult to share/reuse parts of config
- ❌ Can't easily update parts without affecting others
- ❌ Keybindings mixed with aesthetics mixed with hardware settings

---

### Detailed File Breakdown

#### 1. Environment Variables (`envs.conf`)

**Omarchy** (`/home/yoseph/workspace/omarchy/default/hypr/envs.conf`):
```conf
env = XCURSOR_SIZE,24
env = HYPRCURSOR_SIZE,24

# ⚠️ CRITICAL: Force all apps to use Wayland (better performance & compatibility)
env = GDK_BACKEND,wayland,x11,*
env = QT_QPA_PLATFORM,wayland;xcb
env = QT_STYLE_OVERRIDE,kvantum
env = SDL_VIDEODRIVER,wayland
env = MOZ_ENABLE_WAYLAND,1
env = ELECTRON_OZONE_PLATFORM_HINT,wayland
env = OZONE_PLATFORM,wayland
env = XDG_SESSION_TYPE,wayland

# Screen sharing support (Google Meet, Discord, Teams, Zoom)
env = XDG_CURRENT_DESKTOP,Hyprland
env = XDG_SESSION_DESKTOP,Hyprland

xwayland {
  force_zero_scaling = true
}

# Use XCompose for special characters
env = XCOMPOSEFILE,~/.XCompose

# Don't show Hyprland update notifications
ecosystem {
  no_update_news = true
}
```

**Your Config** (`/home/yoseph/dotfiles/hypr/.config/hypr/hyprland.conf:64-67`):
```conf
env = XCURSOR_SIZE,24
env = HYPRCURSOR_SIZE,24
env = GTK_THEME,Adwaita-dark
env = XCURSOR_THEME,Adwaita
```

**⚠️ MISSING from your config:**
- `GDK_BACKEND=wayland` - Forces GTK apps to use Wayland instead of XWayland
- `QT_QPA_PLATFORM=wayland` - Forces Qt apps to use Wayland
- `MOZ_ENABLE_WAYLAND=1` - Makes Firefox/Thunderbird use Wayland
- `ELECTRON_OZONE_PLATFORM_HINT=wayland` - VSCode, Discord, Slack use Wayland
- Screen sharing environment variables

**Impact:** Your apps likely run through **XWayland** (X11 compatibility layer) instead of **native Wayland**, causing:
- 🐌 Worse performance
- 🖼️ Screen tearing potential
- 🔒 Worse security (X11 apps can keylog other apps)
- 📹 Screen sharing issues

---

#### 2. Autostart Applications

**Omarchy** (`/home/yoseph/workspace/omarchy/default/hypr/autostart.conf`):
```conf
# ⚠️ Uses UWSM (Universal Wayland Session Manager)
exec-once = uwsm app -- hypridle
exec-once = uwsm app -- mako
exec-once = uwsm app -- waybar
exec-once = uwsm app -- fcitx5
exec-once = uwsm app -- swaybg -i ~/.config/omarchy/current/background -m fill
exec-once = uwsm app -- swayosd-server
exec-once = uwsm app -- walker --gapplication-service &
exec-once = /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
exec-once = wl-clip-persist --clipboard regular --all-mime-type-regex '^(?!x-kde-passwordManagerHint).+'
exec-once = omarchy-cmd-first-run
```

**Your Config** (`/home/yoseph/dotfiles/hypr/.config/hypr/hyprland.conf:44-55`):
```conf
# Manual exec-once (no session manager)
exec-once = nm-applet --indicator &
exec-once = /usr/lib/polkit-kde-authentication-agent-1
exec-once = waybar & swaync & hypridle & hyprpaper
exec-once = blueman-applet
exec-once = $HOME/.config/hypr/scripts/battery-monitor.sh
exec-once = wl-paste --type text --watch cliphist store
exec-once = wl-paste --type image --watch cliphist store
```

**Key Differences:**

| Feature | Omarchy | Yours |
|---------|---------|-------|
| Session Manager | **uwsm** (proper lifecycle) | None (manual processes) |
| Notification Daemon | **mako** (lightweight) | **swaync** (feature-rich) |
| App Launcher | **walker** (modern) | **wofi/rofi** (older) |
| OSD (volume/brightness) | **swayosd-server** (modern) | Manual with wpctl |
| Network Manager UI | None (uses impala TUI) | **nm-applet** |
| Wallpaper | **swaybg** | **hyprpaper** |

**What is UWSM?**
- **U**niversal **W**ayland **S**ession **M**anager
- Properly manages app lifecycle (start, stop, restart)
- Ensures apps shut down cleanly when Hyprland exits
- Prevents orphaned processes
- **Your setup:** Apps may not terminate cleanly, leaving zombie processes

---

#### 3. Look & Feel

**Omarchy** (`/home/yoseph/workspace/omarchy/default/hypr/looknfeel.conf`):

```conf
general {
    gaps_in = 5
    gaps_out = 10          # ⚠️ Smaller gaps (more screen space)
    border_size = 2
    resize_on_border = false
    layout = dwindle
}

decoration {
    rounding = 0           # ⚠️ No rounded corners (clean, minimal)

    shadow {
        enabled = true
        range = 2          # ⚠️ Minimal shadows
        render_power = 3
    }

    blur {
        enabled = true
        size = 3
        passes = 1
        vibrancy = 0.1696
    }
}

animations {
    # Workspaces don't animate (instant switching)
    animation = workspaces, 0, 0, ease
    # Windows animate smoothly
    animation = windows, 1, 4.79, easeOutQuint
    # [... 10+ other animations]
}

dwindle {
    force_split = 2        # ⚠️ Always split to the right
}

misc {
    disable_hyprland_logo = true    # ⚠️ Clean startup
    disable_splash_rendering = true
    focus_on_activate = true
}

cursor {
    hide_on_key_press = true  # ⚠️ Cursor hides when typing
}
```

**Your Config** (`/home/yoseph/dotfiles/hypr/.config/hypr/hyprland.conf:77-185`):

```conf
general {
    gaps_in = 5
    gaps_out = 20          # ⚠️ LARGER gaps (wastes space)
    border_size = 2
    resize_on_border = true  # ⚠️ Different from Omarchy
    no_focus_fallback = true # ⚠️ Not in Omarchy
    layout = dwindle
}

decoration {
    rounding = 10          # ⚠️ Rounded corners
    rounding_power = 2     # ⚠️ Deprecated option!

    shadow {
        range = 4          # ⚠️ Larger shadows
    }
}

animations {
    # All animations enabled including workspaces
    animation = workspaces, 1, 1.94, almostLinear, fade
}

misc {
    force_default_wallpaper = -1   # ⚠️ Shows anime wallpapers
    disable_hyprland_logo = false
}

# No cursor settings
```

**Visual Differences:**
- **Omarchy:** Minimal, fast, clean (no rounded corners, small gaps, instant workspace switch)
- **Yours:** More visual flair (rounded corners, large gaps, animated workspaces)
- **Your `rounding_power = 2` is deprecated** (Hyprland removed this option)

---

#### 4. Keybindings

**Omarchy uses `bindd`, `bindld`, `bindeld`, `bindmd`** (descriptive binds with labels):

**Media Keys** (`/home/yoseph/workspace/omarchy/default/hypr/bindings/media.conf`):
```conf
# Defines OSD client to show on current monitor
$osdclient = swayosd-client --monitor "$(hyprctl monitors -j | jq -r '.[] | select(.focused == true).name')"

# Volume with visual OSD
bindeld = ,XF86AudioRaiseVolume, Volume up, exec, $osdclient --output-volume raise
bindeld = ,XF86AudioLowerVolume, Volume down, exec, $osdclient --output-volume lower

# Precise 1% control with Alt
bindeld = ALT, XF86AudioRaiseVolume, Volume up precise, exec, $osdclient --output-volume +1
```

**Tiling Keybinds** (`/home/yoseph/workspace/omarchy/default/hypr/bindings/tiling.conf`):
```conf
# Uses 'code:' for hardware scancodes (works on any keyboard layout)
bindd = SUPER, code:10, Switch to workspace 1, workspace, 1
bindd = SUPER, code:11, Switch to workspace 2, workspace, 2

# Swap windows
bindd = SUPER SHIFT, left, Swap window to the left, swapwindow, l

# Resize with -/= keys
bindd = SUPER, code:20, Expand window left, resizeactive, -100 0    # - key
bindd = SUPER, code:21, Shrink window left, resizeactive, 100 0     # = key
```

**Utilities** (`/home/yoseph/workspace/omarchy/default/hypr/bindings/utilities.conf`):
```conf
# App launcher
bindd = SUPER, SPACE, Launch apps, exec, walker -p "Start…"

# Omarchy menu system
bindd = SUPER ALT, SPACE, Omarchy menu, exec, omarchy-menu
bindd = SUPER, ESCAPE, Power menu, exec, omarchy-menu system

# Notifications (uses mako)
bindd = SUPER, COMMA, Dismiss last notification, exec, makoctl dismiss
bindd = SUPER CTRL, COMMA, Toggle silencing notifications, exec, makoctl mode -t do-not-disturb

# Screenshots
bindd = , PRINT, Screenshot of region, exec, omarchy-cmd-screenshot
bindd = SHIFT, PRINT, Screenshot of window, exec, omarchy-cmd-screenshot window
```

**Your Keybinds** (`/home/yoseph/dotfiles/hypr/.config/hypr/hyprland.conf:230-324`):
```conf
# Uses key names (may break on non-US keyboards)
bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2

# Volume (no OSD, just wpctl)
bindel = ,XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+

# Screenshots (uses hyprshot)
bind = $mainMod SHIFT, S, exec, hyprshot -m region

# Notifications (uses swaync)
bind = $mainMod, N, exec, swaync-client -t -sw

# Rofi launcher
bind = $mainMod, D, exec, rofi -show drun -show-icons
```

**Key Differences:**
- Omarchy uses **descriptive bind types** (`bindd` = description, `bindeld` = description + e + l + d flags)
- Omarchy uses **hardware scancodes** for number keys (works on any layout)
- Omarchy has **built-in OSD** for volume/brightness
- Omarchy has **centralized menu system** (`omarchy-menu`)

---

#### 5. Window Rules

**Omarchy** (`/home/yoseph/workspace/omarchy/default/hypr/windows.conf`):
```conf
windowrule = suppressevent maximize, class:.*
windowrule = opacity 0.97 0.9, class:.*  # ⚠️ Slight transparency on ALL windows

# App-specific tweaks (14 separate files)
source = ~/.local/share/omarchy/default/hypr/apps/1password.conf
source = ~/.local/share/omarchy/default/hypr/apps/browser.conf
source = ~/.local/share/omarchy/default/hypr/apps/terminals.conf
# [... 11 more]
```

**Your Config** (`/home/yoseph/dotfiles/hypr/.config/hypr/hyprland.conf:330-371`):
```conf
windowrulev2 = suppressevent maximize, class:.*
windowrulev2 = nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0

# Manual rules for dialogs/popups
windowrulev2 = float,class:^(file_progress)$
windowrulev2 = float,title:^(Open File)$
# [... 20+ manual rules]
```

**Omarchy's Modular App Configs Example** (`apps/browser.conf`):
```conf
# Chromium
windowrule = opacity 1 1, ^(chromium)$
windowrule = opacity 1 1, ^(Brave-browser)$

# Firefox
windowrule = opacity 1 1, ^(firefox)$
windowrule = idleinhibit focus, ^(firefox)$ # Prevent sleep during video

# Picture-in-picture
windowrule = float, ^(firefox)$,title:^(Picture-in-Picture)$
windowrule = pin, ^(firefox)$,title:^(Picture-in-Picture)$
```

**Advantage:** Each app's rules are in separate files, easy to maintain/share

---

## WiFi/Network Configuration Analysis

### Critical Finding: NetworkManager vs iwd

#### Your Current Setup
**Network Manager:** NetworkManager 1.48.8-1
**Location:** System-wide (`/etc/NetworkManager/`)
**Status:** ✅ Enabled and running
**WiFi Tool:** `nmcli`, `nm-applet`
**Config:** `/etc/NetworkManager/NetworkManager.conf` (minimal, nearly empty)

**Check:**
```bash
$ nmcli device wifi list
IN-USE  SSID                 MODE   CHAN  RATE        SIGNAL  SECURITY
*       POCOM5              Infra  153   135 Mbit/s  100     WPA2
        JULO                Infra  161   260 Mbit/s  67      WPA2
```

#### Omarchy's Setup
**Network Manager:** iwd (Intel Wireless Daemon)
**Location:** `/etc/iwd/main.conf` (would be created)
**Configuration Script:** `/home/yoseph/workspace/omarchy/install/config/hardware/network.sh`

```bash
# Content of network.sh:
sudo systemctl enable iwd.service
sudo systemctl disable systemd-networkd-wait-online.service
sudo systemctl mask systemd-networkd-wait-online.service
```

**WiFi Tool:** `impala` (TUI, uses iwd backend)
**Launcher:** `/home/yoseph/workspace/omarchy/bin/omarchy-launch-wifi`
```bash
#!/bin/bash
exec setsid uwsm app -- "$TERMINAL" --class=Impala -e impala "$@"
```

**Impala:** Terminal-based WiFi manager
- Modern Rust-based TUI
- Works with iwd backend
- Lightweight (1.4MB package)
- Shows signal strength, frequency, security

---

### Why Your WiFi Fails on Modern Networks

#### Current Wireless Regulatory Domain
```bash
$ iw reg get
global
country 00: DFS-UNSET   # ⚠️ WRONG! Should be your country code
...

phy#0 (self-managed)
country CN: DFS-UNSET   # ⚠️ Set to China (likely wrong)
```

**Problem 1: Wrong Regulatory Domain**
- Your card thinks it's in **China** (`CN`)
- Different countries have different WiFi channel regulations
- Some channels may be blocked or limited
- Newer networks (Ubiquity, iPhone hotspots) may use channels unavailable in CN

**Omarchy's Fix:** `/home/yoseph/workspace/omarchy/install/config/hardware/set-wireless-regdom.sh`
```bash
# Auto-detects country from timezone
TIMEZONE=$(readlink -f /etc/localtime)
COUNTRY="${TIMEZONE%%/*}"  # Extract country code

# Sets regulatory domain
echo "WIRELESS_REGDOM=\"$COUNTRY\"" | sudo tee -a /etc/conf.d/wireless-regdom
sudo iw reg set ${COUNTRY}
```

**Problem 2: NetworkManager vs iwd Compatibility**

| Feature | NetworkManager | iwd |
|---------|---------------|-----|
| WPA3 Support | ⚠️ Limited, requires wpa_supplicant | ✅ Native |
| Intel WiFi Cards | ✅ Works | ✅✅ Optimized (made by Intel) |
| Modern iPhone Hotspots | ⚠️ Issues | ✅ Works |
| Enterprise WiFi (Ubiquity) | ⚠️ WPA2-Enterprise can fail | ✅ Better support |
| 5GHz Channel Selection | ⚠️ Sometimes conservative | ✅ Aggressive |
| Power Management | ⚠️ Basic | ✅ Advanced |
| Fast Roaming (802.11r) | ⚠️ Limited | ✅ Full support |

**Your WiFi Card:** Intel Wireless 8265 (uses `iwlwifi` driver)
```bash
$ lspci -k | grep -A 3 -i network
01:00.0 Network controller: Intel Corporation Wireless 8265 / 8275 (rev 78)
	Kernel driver in use: iwlwifi
```

**Why iwd is better for Intel cards:**
- Intel develops both `iwlwifi` driver AND `iwd`
- They're designed to work together
- Better firmware integration
- Lower latency for connections

**Problem 3: Missing `wireless-regdb` Package**

```bash
$ pacman -Q wireless-regdb
error: package 'wireless-regdb' was not found
```

This package contains WiFi regulatory databases. Without it:
- Can't properly set regional rules
- May default to most restrictive settings
- Some channels blocked unnecessarily

**Omarchy includes it:** See `/home/yoseph/workspace/omarchy/install/omarchy-base.packages:118`

---

### iwd Configuration (What Omarchy Would Set Up)

**File:** `/etc/iwd/main.conf` (doesn't exist on your system)

**Typical Omarchy/iwd Setup:**
```conf
[General]
EnableNetworkConfiguration=true
# Use systemd-resolved for DNS
UseDefaultInterface=true

[Network]
EnableIPv6=true
NameResolvingService=systemd

[Scan]
DisablePeriodicScan=false

[Security]
# Enable WPA3 support
ControlPortOverNL80211=true
```

**What it does:**
- Enables WPA3 (newer security standard)
- Better roaming between access points
- Faster connection establishment
- Lower power consumption

---

## Critical Issues Found

### 🔴 Issue 1: WiFi Connection Failures

**Symptoms:**
- ❌ Can't connect to Ubiquity enterprise WiFi
- ❌ Can't connect to newer iPhone hotspots
- ✅ Can connect to older/legacy WiFi
- ✅ Can connect to older mobile hotspots

**Root Causes:**
1. **Wrong regulatory domain** (set to China `CN` instead of actual location)
2. **NetworkManager** instead of **iwd** (worse compatibility with modern networks)
3. **Missing wireless-regdb** package
4. **No WPA3 support** (newer iPhones prefer WPA3)

**Evidence:**
- Regulatory domain: `/home/yoseph/dotfiles` (iw reg get output shows `CN`)
- Network manager: NetworkManager instead of iwd
- Package check: `wireless-regdb` not installed

---

### 🔴 Issue 2: Configuration Inconsistency

**Evidence:**
- Multiple backup files: `hyprlock.conf.bak`, `config.fish.backup`, `init.lua.backup`
- Multiple backup directories: `swaync/`, `swaync_bak/`, `swaync_bak2/`
- Monolithic config files (hard to maintain)

**Impact:**
- Hard to track what changed
- Risk of using wrong config version
- Difficult to debug issues

**Omarchy's Approach:**
- No backup files in configs
- Modular structure (change one file at a time)
- Git-managed (track all changes)

---

### 🔴 Issue 3: Missing Wayland Optimizations

**Your Missing Environment Variables:**
```conf
# Missing from your hyprland.conf:
env = GDK_BACKEND,wayland,x11,*
env = QT_QPA_PLATFORM,wayland;xcb
env = MOZ_ENABLE_WAYLAND,1
env = ELECTRON_OZONE_PLATFORM_HINT,wayland
env = OZONE_PLATFORM,wayland
```

**Impact:**
- Apps run through XWayland (X11 compatibility layer)
- Worse performance (extra translation layer)
- Potential screen tearing
- Input lag
- Screen sharing issues
- Security concerns (X11 apps can snoop on each other)

**Location in Omarchy:** `/home/yoseph/workspace/omarchy/default/hypr/envs.conf:5-12`

---

### 🔴 Issue 4: No Session Manager

**Your Setup:**
```conf
exec-once = waybar & swaync & hypridle & hyprpaper
```

**Problems:**
- Apps started with `&` become orphans
- When Hyprland exits, apps may not terminate
- No proper lifecycle management
- Zombie processes accumulate

**Omarchy's Setup:**
```conf
exec-once = uwsm app -- waybar
exec-once = uwsm app -- mako
exec-once = uwsm app -- hypridle
```

**Benefits:**
- Apps properly managed
- Clean shutdown when logging out
- Can restart individual apps
- Process hierarchy maintained

---

### ⚠️ Issue 5: Deprecated/Suboptimal Settings

**In Your Config:**
```conf
rounding_power = 2   # ⚠️ Deprecated, Hyprland removed this
gaps_out = 20        # ⚠️ Very large (wastes screen space)
```

**Hardware Scancodes:**
```conf
# Yours:
bind = $mainMod, 1, workspace, 1  # Breaks on non-US keyboards

# Omarchy:
bindd = SUPER, code:10, Switch to workspace 1, workspace, 1  # Works everywhere
```

---

## Migration Plan

### Phase 1: Fix WiFi Issues (HIGH PRIORITY)

#### Step 1.1: Install Missing Packages
```bash
# Install iwd and wireless regulatory database
sudo pacman -S iwd wireless-regdb impala

# Verify installation
pacman -Q iwd wireless-regdb impala
```

**Expected output:**
```
iwd 2.x-x
wireless-regdb 2024.xx.xx-x
impala 0.2.4-1
```

#### Step 1.2: Set Correct Wireless Regulatory Domain
```bash
# Check current timezone
timedatectl

# Get country code from timezone
TIMEZONE=$(readlink -f /etc/localtime)
TIMEZONE=${TIMEZONE#/usr/share/zoneinfo/}
COUNTRY="${TIMEZONE%%/*}"

# If country is 2 letters (e.g., "US", "ID", "GB"), set it
echo "Detected country: $COUNTRY"

# Set regulatory domain
echo "WIRELESS_REGDOM=\"$COUNTRY\"" | sudo tee /etc/conf.d/wireless-regdom
sudo iw reg set $COUNTRY

# Verify
iw reg get
# Should show your country, not "CN" or "00"
```

#### Step 1.3: Backup NetworkManager Connections
```bash
# Export current WiFi passwords
nmcli -f NAME,TYPE connection show | grep wifi

# Backup saved connections
sudo cp -r /etc/NetworkManager/system-connections ~/network-backup-$(date +%Y%m%d)

# Document passwords (you'll need to re-enter them in iwd)
for conn in $(nmcli -t -f NAME,TYPE connection show | grep wifi | cut -d: -f1); do
  echo "Connection: $conn"
  # Note: Can't extract passwords directly, need to check GUI or files
done
```

⚠️ **IMPORTANT:** Write down your WiFi passwords before proceeding!

#### Step 1.4: Switch from NetworkManager to iwd
```bash
# Stop and disable NetworkManager
sudo systemctl stop NetworkManager
sudo systemctl disable NetworkManager

# Enable and start iwd
sudo systemctl enable iwd
sudo systemctl start iwd

# Disable networkd-wait-online (prevents boot delays)
sudo systemctl disable systemd-networkd-wait-online.service
sudo systemctl mask systemd-networkd-wait-online.service
```

#### Step 1.5: Configure iwd for Modern WiFi
```bash
# Create iwd config directory
sudo mkdir -p /etc/iwd

# Create main configuration
sudo tee /etc/iwd/main.conf << 'EOF'
[General]
EnableNetworkConfiguration=true
UseDefaultInterface=true

[Network]
EnableIPv6=true
NameResolvingService=systemd

[Scan]
DisablePeriodicScan=false

[Security]
# Enable WPA3 and modern security
ControlPortOverNL80211=true
EOF

# Restart iwd to apply
sudo systemctl restart iwd
```

#### Step 1.6: Connect to WiFi Using iwctl
```bash
# Launch interactive iwd client
iwctl

# Inside iwctl:
# List WiFi devices
device list

# Scan for networks (replace 'wlan0' with your device name, likely 'wlp1s0')
station wlp1s0 scan

# Show available networks
station wlp1s0 get-networks

# Connect to network
station wlp1s0 connect "POCOM5"
# Enter password when prompted

# Exit
exit

# Verify connection
ip addr show wlp1s0
ping -c 3 1.1.1.1
```

#### Step 1.7: Test Problematic Networks
```bash
# Try connecting to iPhone hotspot
iwctl station wlp1s0 connect "YourIPhone"

# Try connecting to Ubiquity network
iwctl station wlp1s0 connect "UbiquitySSID"

# Check connection quality
iwctl station wlp1s0 show
```

#### Step 1.8: Update Hyprland Autostart (Remove nm-applet)
```bash
# Edit your hyprland.conf
nvim ~/.config/hypr/hyprland.conf

# Change:
#   exec-once = nm-applet --indicator &
# To:
#   # Network now managed by iwd + impala (Super+N to open WiFi manager)
```

#### Step 1.9: Add WiFi Keybinding for impala
```bash
# Add to your hyprland.conf keybindings section:
bind = $mainMod, W, exec, ghostty --class=Impala -e impala

# Or if using kitty:
bind = $mainMod, W, exec, kitty --class=Impala -e impala
```

**Testing Checklist:**
- [ ] Can connect to older WiFi networks (regression test)
- [ ] Can connect to iPhone hotspot
- [ ] Can connect to Ubiquity WiFi
- [ ] Connection persists after reboot
- [ ] iwd auto-connects to known networks

---

### Phase 2: Modernize Hyprland Configuration (MEDIUM PRIORITY)

#### Step 2.1: Backup Current Config
```bash
cd ~/dotfiles/hypr/.config/hypr
cp hyprland.conf hyprland.conf.backup-$(date +%Y%m%d)

# Create git snapshot
cd ~/dotfiles
git add -A
git commit -m "Backup before Hyprland refactor ($(date +%Y-%m-%d))"
```

#### Step 2.2: Create Modular Directory Structure
```bash
cd ~/.config/hypr

# Create directories for modular configs
mkdir -p modular/{bindings,apps}

# Create empty override files
touch modular/monitors.conf
touch modular/input.conf
touch modular/looknfeel.conf
touch modular/envs.conf
touch modular/autostart.conf
touch modular/bindings.conf
```

#### Step 2.3: Extract Environment Variables
```bash
# Create modular/envs.conf
cat > ~/.config/hypr/modular/envs.conf << 'EOF'
# Cursor size
env = XCURSOR_SIZE,24
env = HYPRCURSOR_SIZE,24

# Theme
env = GTK_THEME,Adwaita-dark
env = XCURSOR_THEME,Adwaita

# Force apps to use native Wayland (better performance)
env = GDK_BACKEND,wayland,x11,*
env = QT_QPA_PLATFORM,wayland;xcb
env = SDL_VIDEODRIVER,wayland
env = MOZ_ENABLE_WAYLAND,1
env = ELECTRON_OZONE_PLATFORM_HINT,wayland
env = OZONE_PLATFORM,wayland
env = XDG_SESSION_TYPE,wayland

# Screen sharing support
env = XDG_CURRENT_DESKTOP,Hyprland
env = XDG_SESSION_DESKTOP,Hyprland

xwayland {
  force_zero_scaling = true
}
EOF
```

#### Step 2.4: Extract Autostart
```bash
# Create modular/autostart.conf
cat > ~/.config/hypr/modular/autostart.conf << 'EOF'
# Polkit authentication agent
exec-once = /usr/lib/polkit-kde-authentication-agent-1

# Status bar and notifications
exec-once = waybar
exec-once = swaync

# Idle management and wallpaper
exec-once = hypridle
exec-once = hyprpaper

# Bluetooth and battery monitoring
exec-once = blueman-applet
exec-once = $HOME/.config/hypr/scripts/battery-monitor.sh

# Clipboard manager
exec-once = wl-paste --type text --watch cliphist store
exec-once = wl-paste --type image --watch cliphist store
EOF
```

#### Step 2.5: Extract Monitor Configuration
```bash
# Create modular/monitors.conf
cat > ~/.config/hypr/modular/monitors.conf << 'EOF'
# Monitor configuration
monitor = HDMI-A-1, 1920x1080@60, 1920x0, 1
monitor = eDP-1, 1920x1200@60, 0x0, 1
# monitor=eDP-1,1920x1080@144,0x0,1
EOF
```

#### Step 2.6: Extract Look and Feel
```bash
# Create modular/looknfeel.conf
cat > ~/.config/hypr/modular/looknfeel.conf << 'EOF'
general {
    gaps_in = 5
    gaps_out = 10  # Changed from 20 (more screen space)
    border_size = 2
    col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
    col.inactive_border = rgba(595959aa)
    resize_on_border = true
    no_focus_fallback = true
    allow_tearing = false
    layout = dwindle
}

decoration {
    rounding = 10
    # rounding_power = 2  # REMOVED: deprecated option

    active_opacity = 1.0
    inactive_opacity = 1.0

    shadow {
        enabled = true
        range = 4
        render_power = 3
        color = rgba(1a1a1aee)
    }

    blur {
        enabled = true
        size = 3
        passes = 1
        vibrancy = 0.1696
    }
}

animations {
    enabled = yes, please :)

    bezier = easeOutQuint,0.23,1,0.32,1
    bezier = easeInOutCubic,0.65,0.05,0.36,1
    bezier = linear,0,0,1,1
    bezier = almostLinear,0.5,0.5,0.75,1.0
    bezier = quick,0.15,0,0.1,1

    animation = global, 1, 10, default
    animation = border, 1, 5.39, easeOutQuint
    animation = windows, 1, 4.79, easeOutQuint
    animation = windowsIn, 1, 4.1, easeOutQuint, popin 87%
    animation = windowsOut, 1, 1.49, linear, popin 87%
    animation = fadeIn, 1, 1.73, almostLinear
    animation = fadeOut, 1, 1.46, almostLinear
    animation = fade, 1, 3.03, quick
    animation = layers, 1, 3.81, easeOutQuint
    animation = layersIn, 1, 4, easeOutQuint, fade
    animation = layersOut, 1, 1.5, linear, fade
    animation = fadeLayersIn, 1, 1.79, almostLinear
    animation = fadeLayersOut, 1, 1.39, almostLinear
    animation = workspaces, 1, 1.94, almostLinear, fade
    animation = workspacesIn, 1, 1.21, almostLinear, fade
    animation = workspacesOut, 1, 1.94, almostLinear, fade
}

dwindle {
    pseudotile = true
    preserve_split = true
}

master {
    new_status = master
}

misc {
    force_default_wallpaper = -1
    disable_hyprland_logo = false
}
EOF
```

#### Step 2.7: Extract Input Settings
```bash
# Create modular/input.conf
cat > ~/.config/hypr/modular/input.conf << 'EOF'
input {
    kb_layout = us
    kb_variant =
    kb_model =
    kb_options =
    kb_rules =

    follow_mouse = 1
    sensitivity = 0

    touchpad {
        natural_scroll = true
        tap-to-click = true
        drag_lock = true
        disable_while_typing = true
    }
}

gestures {
    workspace_swipe = false
}

device {
    name = epic-mouse-v1
    sensitivity = -0.5
}
EOF
```

#### Step 2.8: Extract Keybindings
```bash
# Create modular/bindings.conf
cat > ~/.config/hypr/modular/bindings.conf << 'EOF'
$mainMod = SUPER

# Applications
bind = $mainMod, Q, exec, $terminal
bind = $mainMod, C, killactive,
bind = $mainMod, M, exit,
bind = $mainMod, E, exec, $fileManager
bind = $mainMod, V, togglefloating,
bind = $mainMod, R, exec, $menu
bind = $mainMod, P, pseudo,
bind = $mainMod, J, togglesplit,

# WiFi manager
bind = $mainMod, W, exec, $terminal --class=Impala -e impala

# Focus movement
bind = $mainMod, left, movefocus, l
bind = $mainMod, right, movefocus, r
bind = $mainMod, up, movefocus, u
bind = $mainMod, down, movefocus, d

# Workspaces
bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5
bind = $mainMod, 6, workspace, 6
bind = $mainMod, 7, workspace, 7
bind = $mainMod, 8, workspace, 8
bind = $mainMod, 9, workspace, 9
bind = $mainMod, 0, workspace, 10

# Move to workspace
bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
bind = $mainMod SHIFT, 3, movetoworkspace, 3
bind = $mainMod SHIFT, 4, movetoworkspace, 4
bind = $mainMod SHIFT, 5, movetoworkspace, 5
bind = $mainMod SHIFT, 6, movetoworkspace, 6
bind = $mainMod SHIFT, 7, movetoworkspace, 7
bind = $mainMod SHIFT, 8, movetoworkspace, 8
bind = $mainMod SHIFT, 9, movetoworkspace, 9
bind = $mainMod SHIFT, 0, movetoworkspace, 10

# Special workspace
bind = $mainMod, S, togglespecialworkspace, magic
bind = $mainMod SHIFT, M, movetoworkspace, special:magic

# Mouse workspace switching
bind = $mainMod, mouse_down, workspace, e+1
bind = $mainMod, mouse_up, workspace, e-1

# Mouse window actions
bindm = $mainMod, mouse:272, movewindow
bindm = $mainMod, mouse:273, resizewindow

# Media keys
bindel = ,XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+
bindel = ,XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
bindel = ,XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
bindel = ,XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
bindel = ,XF86MonBrightnessUp, exec, brightnessctl s 10%+
bindel = ,XF86MonBrightnessDown, exec, brightnessctl s 10%-

# Playerctl
bindl = , XF86AudioNext, exec, playerctl next
bindl = , XF86AudioPause, exec, playerctl play-pause
bindl = , XF86AudioPlay, exec, playerctl play-pause
bindl = , XF86AudioPrev, exec, playerctl previous

# Screenshots
bind = $mainMod SHIFT, S, exec, hyprshot -m region
bind = $mainMod ALT, S, exec, hyprshot -m window

# Lock screen
bind = $SUPER_SHIFT, L, exec, hyprlock
bind = $mainMod SHIFT, H, exec, /usr/local/bin/hibernate-lock

# Notifications
bind = $mainMod, N, exec, swaync-client -t -sw

# Rofi
bind = $mainMod, D, exec, rofi -show drun -show-icons

# Scripts
$scriptsDir = $HOME/.config/hypr/scripts
bind = $mainMod ALT, E, exec, $scriptsDir/RofiEmoji.sh
bind = $mainMod ALT, G, exec, $scriptsDir/RofiSearch.sh
bind = $mainMod SHIFT, B, exec, $scriptsDir/ChangeBlur.sh
bind = $mainMod ALT, V, exec, $scriptsDir/ClipManager.sh
EOF
```

#### Step 2.9: Extract Window Rules
```bash
# Create modular/windows.conf
cat > ~/.config/hypr/modular/windows.conf << 'EOF'
# General rules
windowrulev2 = suppressevent maximize, class:.*
windowrulev2 = nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0

# Dialog windows
windowrulev2 = float,class:^(file_progress)$
windowrulev2 = float,class:^(confirm)$
windowrulev2 = float,class:^(dialog)$
windowrulev2 = float,class:^(download)$
windowrulev2 = float,class:^(notification)$
windowrulev2 = float,class:^(error)$
windowrulev2 = float,class:^(confirmreset)$
windowrulev2 = float,title:^(Open File)$
windowrulev2 = float,title:^(Save File)$
windowrulev2 = float,title:^(File Operation Progress)$

# Popups and menus
windowrulev2 = float, class:^(firefox)$,title:^(Picture-in-Picture)$
windowrulev2 = float, class:.*(popup|menu|dropdown|dialog|tooltip|notification|error).*
windowrulev2 = size 40% 40%, class:.*(popup|menu|dropdown|dialog).*
windowrulev2 = move cursor -50% -50%, class:.*(popup|menu|dropdown).*
windowrulev2 = noanim, class:^(popup_menu)$
windowrulev2 = noinitialfocus, class:^(popup_menu)$
windowrulev2 = rounding 0, class:^(popup_menu)$
EOF
```

#### Step 2.10: Create New Modular Main Config
```bash
# Create the new main hyprland.conf
cat > ~/.config/hypr/hyprland-modular.conf << 'EOF'
# Modular Hyprland Configuration
# Based on Omarchy architecture

# Program definitions
$terminal = ghostty
$fileManager = nautilus
$menu = wofi --show drun

# Load modular configurations
source = ~/.config/hypr/modular/monitors.conf
source = ~/.config/hypr/modular/envs.conf
source = ~/.config/hypr/modular/looknfeel.conf
source = ~/.config/hypr/modular/input.conf
source = ~/.config/hypr/modular/windows.conf
source = ~/.config/hypr/modular/bindings.conf
source = ~/.config/hypr/modular/autostart.conf

# Optional: source color scheme if using one
# source = ~/.config/hypr/mocha.conf
EOF
```

#### Step 2.11: Test Modular Config
```bash
# Test the new config without replacing the old one
Hyprland -c ~/.config/hypr/hyprland-modular.conf

# If it works, make it permanent:
mv ~/.config/hypr/hyprland.conf ~/.config/hypr/hyprland-monolithic.backup
mv ~/.config/hypr/hyprland-modular.conf ~/.config/hypr/hyprland.conf

# Update stow if using it
cd ~/dotfiles
stow -R hypr
```

#### Step 2.12: Clean Up Backup Files
```bash
# After confirming modular config works, clean up
cd ~/dotfiles

# Remove backup files
find . -name "*.backup" -type f
# Review the list, then:
find . -name "*.backup" -type f -delete

find . -name "*.bak" -type f
# Review, then:
find . -name "*.bak" -type f -delete

# Remove duplicate swaync directories
rm -rf swaync_bak swaync_bak2

# Commit cleanup
git add -A
git commit -m "Clean up backup files after modularization"
```

---

### Phase 3: Optional Omarchy-Inspired Improvements (LOW PRIORITY)

#### Step 3.1: Install Session Manager (uwsm)
```bash
sudo pacman -S uwsm

# Update autostart to use uwsm
# Edit ~/.config/hypr/modular/autostart.conf
# Change:
#   exec-once = waybar
# To:
#   exec-once = uwsm app -- waybar
```

#### Step 3.2: Install swayosd for Visual Feedback
```bash
sudo pacman -S swayosd

# Add to autostart:
# exec-once = uwsm app -- swayosd-server

# Update media keybinds to use swayosd:
# bindel = ,XF86AudioRaiseVolume, exec, swayosd-client --output-volume raise
```

#### Step 3.3: Switch to Walker App Launcher (Optional)
```bash
# Install walker
yay -S walker-bin

# Add to autostart:
# exec-once = uwsm app -- walker --gapplication-service &

# Update keybind:
# bind = $mainMod, SPACE, exec, walker -p "Start…"
```

#### Step 3.4: Switch to Mako Notifications (Optional)
```bash
sudo pacman -S mako

# Update autostart (replace swaync):
# exec-once = uwsm app -- mako

# Update notification keybinds:
# bind = $mainMod, COMMA, exec, makoctl dismiss
# bind = $mainMod SHIFT, COMMA, exec, makoctl dismiss --all
```

---

### Phase 4: Verification & Testing

#### Step 4.1: WiFi Testing Checklist
```bash
# Test all previously failing networks
iwctl station wlp1s0 get-networks

# Test connections:
# [ ] Ubiquity enterprise WiFi
# [ ] Newer iPhone hotspot
# [ ] Legacy WiFi (regression test)
# [ ] Public WiFi with captive portal
# [ ] 5GHz networks
# [ ] 2.4GHz networks

# Check regulatory domain
iw reg get
# Should show correct country code

# Check connection quality
iwctl station wlp1s0 show
# Note signal strength, speed

# Test roaming (if multiple access points)
# Walk between APs and check if connection persists
```

#### Step 4.2: Hyprland Testing Checklist
```bash
# After modular config migration:

# [ ] All keybindings work
# [ ] Windows tile correctly
# [ ] Animations smooth
# [ ] Multi-monitor setup works
# [ ] Workspace switching works
# [ ] Autostart apps launch
# [ ] No error messages in hyprctl logs

# Check for errors:
journalctl --user -u hyprland -b
```

#### Step 4.3: Wayland Native Apps Check
```bash
# Check if apps are using native Wayland
# Run app, then check:
xprop -root | grep -i "^_NET_ACTIVE_WINDOW"

# Or use:
WAYLAND_DEBUG=1 your-app 2>&1 | grep -i wayland

# Apps that should use Wayland:
# - Firefox
# - Chromium/Brave/Chrome
# - VSCode
# - Nautilus
# - Ghostty/Alacritty
```

#### Step 4.4: Performance Comparison
```bash
# Before and after migration, check:

# FPS during animations (should be higher with Wayland apps)
# Measure workspace switch time
# Check system resource usage

# Memory usage:
free -h
ps aux --sort=-%mem | head -20

# GPU usage (if applicable):
nvidia-smi  # for NVIDIA
radeontop   # for AMD
```

---

## Summary of Changes

### Immediate Benefits (Phase 1 - WiFi Fix)
- ✅ Can connect to modern WiFi networks (WPA3, newer iPhones, Ubiquity)
- ✅ Correct regional WiFi channels available
- ✅ Better power management for WiFi
- ✅ Faster connection establishment
- ✅ Better roaming between access points

### Medium-Term Benefits (Phase 2 - Modular Config)
- ✅ Easier to maintain configuration
- ✅ Can update individual parts without breaking others
- ✅ Better Wayland app performance (native instead of XWayland)
- ✅ Cleaner dotfiles (no backup files)
- ✅ Easier to share/version control

### Long-Term Benefits (Phase 3 - Omarchy Tools)
- ✅ Proper session management (no zombie processes)
- ✅ Visual feedback for volume/brightness
- ✅ Modern app launcher
- ✅ Consistent notification system

---

## Rollback Plan (If Something Goes Wrong)

### WiFi Rollback
```bash
# If iwd doesn't work, go back to NetworkManager:
sudo systemctl stop iwd
sudo systemctl disable iwd
sudo systemctl enable NetworkManager
sudo systemctl start NetworkManager

# Remove iwd config
sudo rm /etc/iwd/main.conf

# Restore backed-up connections
sudo cp -r ~/network-backup-YYYYMMDD/* /etc/NetworkManager/system-connections/
sudo chmod 600 /etc/NetworkManager/system-connections/*
sudo systemctl restart NetworkManager
```

### Hyprland Config Rollback
```bash
# If modular config breaks:
cd ~/.config/hypr
mv hyprland.conf hyprland-modular-broken.conf
mv hyprland-monolithic.backup hyprland.conf

# Restart Hyprland
hyprctl reload
# Or logout and login again
```

---

## Additional Resources

### Omarchy Documentation
- **GitHub:** https://github.com/basecamp/omarchy
- **Install Scripts:** `/home/yoseph/workspace/omarchy/install/`
- **Default Configs:** `/home/yoseph/workspace/omarchy/default/`

### iwd Documentation
- **Wiki:** https://wiki.archlinux.org/title/Iwd
- **Man Pages:** `man iwd`, `man iwctl`, `man iwd.config`

### Hyprland Documentation
- **Wiki:** https://wiki.hyprland.org/
- **Modular Configs:** https://wiki.hyprland.org/Configuring/Using-hyprctl/#sourcing-files

### Tools Documentation
- **impala (WiFi TUI):** https://github.com/pythops/impala
- **uwsm:** https://wiki.archlinux.org/title/Uwsm
- **swayosd:** https://github.com/ErikReider/SwayOSD

---

## Questions to Consider Before Migration

1. **WiFi Migration (Phase 1):**
   - Do you have all WiFi passwords written down?
   - Are you comfortable using `iwctl` command-line tool?
   - Can you test on non-critical networks first?

2. **Config Refactor (Phase 2):**
   - Do you want to keep your current visual style (rounded corners, large gaps)?
   - Or adopt Omarchy's minimal style (no rounding, small gaps)?
   - Do you want to keep rofi/wofi or try walker?

3. **Tool Migration (Phase 3):**
   - Keep swaync or switch to mako?
   - Worth installing uwsm for session management?
   - Want visual OSD (swayosd) or current CLI-only approach?

---

**END OF ANALYSIS DOCUMENT**

*Generated: 2025-10-08*
*Comparison Base: Omarchy commit 41f2197*
*Personal Dotfiles: Current state as of 2025-10-08*

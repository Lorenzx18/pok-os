# Pok-OS Changelog

## Pok-OS v2.3.2 — DMS reproducible & borders follow DMS theme

**Focus:** make DMS fully declarative/reproducible and let window borders track
the DMS matugen palette (previously they only followed Noctalia).

### 🪟 DMS is now reproducible (no `dms-install`)

- Added pinned flake inputs **`dms`** (DankMaterialShell **v1.5.1** release tag)
  and **`dgop`** (pinned commit), both `follows nixpkgs`.
- Rewrote `modules/home/dank-material-shell/default.nix` to pull the DMS QML
  shell + `bin/dms` backend and `dgop` straight from those flake packages. The
  `dms.service` ExecStarts the store-path backend.
- Removed the imperative `dms-install` / `dms-uninstall` scripts. Switching to
  `barChoice = "dms"` is now a plain rebuild, just like Noctalia.

### 🎨 Borders follow the DMS theme

- New `dms-border-colors` generator reads DMS's active matugen palette from
  `~/.config/gtk-3.0/dank-colors.css` (always reflects dark/light) and writes
  `~/.config/niri/dms-colors.kdl` + `~/.config/hypr/dms-colors.conf`.
- A systemd user **oneshot** + **path unit** regenerate them at session start
  and on every DMS theme change (niri live-reloads; `hyprctl reload` for
  Hyprland). Mirrors Noctalia's border-colors mechanism.

### 🔒 Stylix vs DMS theming

- When `barChoice = "dms"`, Stylix no longer manages GTK/Qt themes
  (`stylix.targets.gtk`/`qt` disabled) — DMS owns that theming, which avoids
  home-manager clobbering DMS's runtime `gtk.css`/Qt color files on `switch`.

## Pok-OS v2.3.1 — Bleeding-edge hardening & Noctalia theming

**Focus:** keep the rolling `nixos-unstable` base but make it robust for
long-term daily use, and make theming follow the wallpaper end-to-end.

### 🎨 Desktop / theming

- **Window borders follow Noctalia's palette.** Noctalia renders the active
  color scheme into color-only include files on every wallpaper/theme change:
  - Niri `include`s `~/.config/niri/noctalia-colors.kdl` (live-reloaded).
  - Hyprland `source`s `~/.config/hypr/noctalia-colors.conf` (re-applied via
    `hyprctl reload` post-hook).
  - Enable *"Use wallpaper colors"* in the Noctalia GUI to track the wallpaper.
- **Noctalia is now the default bar** (`barChoice = "noctalia"`). DMS remains
  available (`barChoice = "dms"`) and is now fully declarative — no `dms-install`.
- Bars run as `graphical-session` **systemd user services**, so switching bars
  via `nixos-rebuild switch` starts/stops them live (no re-login).

### 🔒 Stability for a rolling setup

- **Removed the upstream Hyprland flake input.** Hyprland now comes from
  `nixpkgs-unstable` (still fresh, binary-cached) instead of compiling `main`
  from source — removes ~25 sub-inputs and the biggest breakage vector.
- **`stylix` and `zen-browser` now `follows nixpkgs`** — no duplicate nixpkgs,
  fewer version-mismatch breakages.
- Dropped the now-unused `hyprland.cachix.org` substituter.
- **`boot.loader.systemd-boot.configurationLimit = 10`** — keeps `/boot` from
  filling up on frequent rebuilds.
- **`initialPassword` set for the primary user** so a fresh install can log in
  at SDDM (change it with `passwd` after first login).
- Garbage collection handled automatically by `nh clean` (`--keep-since 7d
  --keep 5`).

### 🏠 Structure

- Single shipped host: **`default`** (rename/duplicate via `mkHost` in
  `flake.nix` for more machines). The old multi-host `dcli`/install-script
  tooling from v1.0 has been removed in favor of plain `nixos-rebuild`.

---

## Pok-OS v1.0 -- Initial Release

**Release Date:** January 2025

### 🎉 Initial Pok-OS Release

Pok-OS is a customized NixOS configuration based on ZaneyOS, tailored for a clean, reproducible multi-host setup and designed for easy sharing and deployment across multiple machines.

### ✨ Key Features

- **Multi-Host Support**: Easy configuration management for multiple computers
- **NVIDIA GPU Optimized**: Full support for NVIDIA graphics with proper drivers
- **Hyprland Desktop**: Modern Wayland compositor with beautiful animations
- **Stylix Integration**: System-wide theming and styling
- **dcli Tool**: Custom CLI utility for multi-host system management
- **Flake-based Configuration**: Reproducible and declarative system management

### 🏠 Host Configurations

- **nixos-leno**: NVIDIA laptop configuration (hybrid graphics)
- **nix-desktop**: NVIDIA desktop configuration (dedicated GPU)
- Removed unused hosts from original ZaneyOS (nixstation, zaneyos-23-vm)

### 🛠️ New Tools & Scripts

- **dcli (Pok CLI)**: Multi-host management utility replacing zcli
  - `dcli build <host>` - Build configuration for specific host
  - `dcli deploy <host>` - Build and switch to configuration
  - `dcli status` - Show current system status
  - `dcli list-hosts` - List available host configurations

- **setup-new-host.sh**: Automated script for adding new host configurations
- **switch-host.sh**: Easy switching between host configurations
- **install-pok-os.sh**: New installation script (replaces install-zaneyos.sh)

### 📦 Package Updates

- Updated flake inputs to latest stable versions
- Enhanced Hyprland configuration with custom animations
- Improved Waybar configurations with multiple themes
- Added comprehensive wallpaper collection
- Updated system packages and services

### 🎨 Visual Enhancements

- Custom Pok-OS branding in fastfetch
- Enhanced wallpaper collection (60+ wallpapers)
- Multiple Waybar themes (ddubs, dwm, simple, curved, etc.)
- Improved Hyprland animations and window rules

### 🔧 Configuration Improvements

- Better hardware detection and GPU profile management
- Improved monitor configuration handling
- Enhanced user environment setup
- Better error handling and logging in scripts

### 📚 Documentation

- **README.md**: Setup and usage guide (flake-based install)

### 🏗️ Installation & Setup

- New automated installation script that correctly points to Pok-OS repository
- Improved hardware detection and configuration
- Better error handling and user guidance
- Automated host configuration setup

### 🔒 Security & Stability

- Updated to latest NixOS 25.05 release
- Enhanced flake lock management
- Improved build stability and error recovery
- Better backup and recovery procedures

---

## Based on ZaneyOS

Pok-OS is built upon the excellent foundation provided by ZaneyOS (originally by Don Williams). Key changes include:

- Multi-host architecture for managing multiple computers
- NVIDIA-focused optimizations
- Custom tooling (dcli) for system management
- Extensive customization for personal workflow
- YouTube channel integration and sharing focus

### Credits

- Original ZaneyOS by Don Williams
- Pok-OS customizations by Pok
- Community contributions and feedback

---

**Note**: This is the initial release of Pok-OS as a standalone project. Future releases will focus on continued improvements, new features, and community feedback integration.
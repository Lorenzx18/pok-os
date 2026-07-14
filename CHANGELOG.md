# Pok-OS Changelog

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
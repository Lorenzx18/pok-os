# 💬 Pok-OS FAQ

Welcome to the Pok-OS FAQ! This guide covers common questions and solutions for managing your Pok-OS system.

## 🚀 Getting Started

### **❄ What is Pok-OS?**

Pok-OS is a customized NixOS configuration designed for multi-host environments with a focus on NVIDIA GPU support and modern desktop experiences. It's built on the foundation of ZaneyOS and tailored for a clean, reproducible desktop experience.

**Key Features:**
- Multi-host configuration management
- NVIDIA GPU optimization (desktop and laptop)
- Hyprland Wayland compositor
- Stylix theming system
- Flake-based reproducible builds

## 🏠 Host Management

### **🖥️ How do I add a new computer to my Pok-OS setup?**

Add a host manually (no installer script needed):

```bash
# From the repo root
mkdir -p hosts/my-host && cp hosts/default/*.nix hosts/my-host/
sudo nixos-generate-config --show-hardware-config > hosts/my-host/hardware.nix
```

Then:
1. Edit `hosts/my-host/variables.nix` (timezone, GPU `intelID`/`nvidiaID`, monitors)
2. Add the host in `flake.nix` via `mkHost { hostname = "my-host"; profile = "nvidia-laptop"; username = "pok"; };`
3. Build: `sudo nixos-rebuild switch --flake .#my-host`

### **⚙️ How do I switch between different host configurations?**

Rebuild and switch to a host configuration with standard NixOS commands:

```bash
sudo nixos-rebuild switch --flake ~/pok-os#nix-desktop
```

### **🔄 How do I update my Pok-OS system?**

```bash
cd ~/pok-os
git pull
nix flake update
sudo nixos-rebuild switch --flake .#your-hostname
```

## 🎮 Hardware & Graphics

### **🎯 How do I configure NVIDIA graphics properly?**

1. **For desktop systems (dedicated GPU):**
   - Use profile: `nvidia`
   - Edit `hosts/your-hostname/variables.nix`
   - Set your GPU PCI IDs if needed

2. **For laptops (hybrid graphics):**
   - Use profile: `nvidia-laptop`
   - Configure both Intel and NVIDIA PCI IDs:
   ```nix
   intelID = "PCI:0:2:0";    # Your integrated GPU
   nvidiaID = "PCI:1:0:0";   # Your NVIDIA GPU
   ```

3. **Find your GPU IDs:**
   ```bash
   lspci | grep VGA
   ```

### **🖥️ How do I configure multiple monitors?**

Edit your host's `variables.nix` file:

```nix
extraMonitorSettings = ''
  monitor=DP-2, 2560x1440@144, 0x0, 1
  monitor=HDMI-A-1, 1920x1080@60, 2560x0, 1
  monitor=eDP-1, 1920x1080@60, 0x1440, 1
'';
```

## 🔧 Configuration & Customization

### **🎨 How do I change the wallpaper and theme?**

Edit your host's `variables.nix` file:

```nix
# Change wallpaper (this also sets the color scheme via Stylix)
stylixImage = ../../wallpapers/your-wallpaper.jpg;

# Change Waybar theme
waybarChoice = ../../modules/home/waybar/waybar-ddubs.nix;

# Change animations
animChoice = ../../modules/home/hyprland/animations-end4.nix;
```

Available wallpapers are in the `wallpapers/` directory.

### **🌍 How do I change my timezone?**

Edit `modules/core/system.nix`:
```nix
time.timeZone = "America/Los_Angeles";  # Change to your timezone
```

Or during installation, it's configured automatically.

### **⌨️ How do I change keyboard layout?**

Edit your host's `variables.nix`:
```nix
keyboardLayout = "us";      # Change to your layout (de, fr, etc.)
consoleKeyMap = "us";       # Usually matches keyboard layout
```

### **📦 How do I install additional software?**

1. **System-wide packages:** Edit `modules/core/packages.nix`
2. **Host-specific packages:** Edit `hosts/your-hostname/host-packages.nix`
3. **Flatpak apps:** Edit `modules/core/flatpak.nix`

Example in `host-packages.nix`:
```nix
home.packages = with pkgs; [
  your-package-here
  another-package
];
```

### **🔧 How do I enable/disable features?**

Edit your host's `variables.nix`:

```nix
# Enable/Disable Features
enableNFS = true;           # Network File System
printEnable = false;        # Printing support
thunarEnable = true;        # Thunar file manager

# Program Options
browser = "vivaldi";        # Default browser
terminal = "kitty";         # Default terminal
```

## 📱 Applications & Tools

### **🌐 How do I change the default browser?**

Edit your host's `variables.nix`:
```nix
browser = "firefox";  # Options: firefox, vivaldi, google-chrome-stable, etc.
```

### **💻 How do I change the default terminal?**

Edit your host's `variables.nix`:
```nix
terminal = "wezterm";  # Options: kitty, alacritty, wezterm, ghostty
```

### **📝 How do I configure development environments?**

Pok-OS includes a Flutter development environment. Access it with:
```bash
cd ~/pok-os
nix develop
```

For other development environments, modify the `devShells` section in `flake.nix`.

## 🚨 Troubleshooting

### **⚠️ My system won't boot after an update**

1. **Select previous generation at boot**
2. **Or roll back:**
   ```bash
   sudo nixos-rebuild switch --rollback
   ```

### **🔍 How do I diagnose system issues?**

```bash
# Check system logs
journalctl -f

# Test configuration without switching
nixos-rebuild build --flake ~/pok-os#your-hostname
```

### **🛠️ Installation failed - what do I do?**

Common solutions:
1. Check network connectivity
2. Verify hardware detection
3. Ensure proper hostname (not "default")
4. Update flake inputs: `nix flake update`

### **💾 How do I free up disk space?**

```bash
# Manual cleanup
nix-collect-garbage -d
sudo nix-collect-garbage -d
```

## 🏗️ Building & Development

### **🔨 How do I test changes without switching?**

```bash
nixos-rebuild build --flake ~/pok-os#your-hostname
```

### **🔄 How do I contribute or share my modifications?**

1. **Fork the repository**
2. **Make your changes**
3. **Test thoroughly**
4. **Submit a merge request**

Or share your configuration as inspiration for others!

### **📋 How do I back up my configuration?**

Your entire configuration is in `~/pok-os/`. Simply:
```bash
# Git-based backup
cd ~/pok-os
git add -A
git commit -m "Backup my configuration"
git push

# Or copy the directory
cp -r ~/pok-os ~/pok-os-backup-$(date +%Y%m%d)
```

## ❓ Still Need Help?

### **📚 Documentation Resources:**
- `README.md` - Main documentation
- `hosts/default/variables.nix` - All per-host options

### **🎥 Video Resources:**
- Check online for setup tutorials and tips
- Visual guides for common configurations

### **🤝 Community:**
- Share your configurations and modifications
- Help others with their setups
- Report issues and suggest improvements

---

**Note:** Pok-OS is based on ZaneyOS and continues to evolve. This FAQ covers the Pok-OS specific features and changes.
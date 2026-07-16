# 💬 Pok-OS FAQ

Welcome to the Pok-OS FAQ! This guide covers common questions and solutions for managing your Pok-OS system.

## 🚀 Getting Started

### **❄ What is Pok-OS?**

Pok-OS is a personal, flake-based NixOS configuration built on the foundation of ZaneyOS. It ships a single host (`default`) and gives you **both Hyprland and Niri** at the login screen, themed with Stylix and Noctalia.

**Key Features:**
- Dual Wayland compositors (Hyprland + Niri), chosen at login — no rebuild
- Noctalia bar/shell by default; window borders follow the wallpaper palette
- NVIDIA GPU optimization (desktop and hybrid laptop), plus AMD/Intel/VM profiles
- Stylix theming system
- Flake-based, reproducible builds

### **🌊 Is Pok-OS stable or bleeding-edge?**

**Bleeding-edge, on purpose.** `nixpkgs` tracks `nixos-unstable` and other inputs follow it. This gives you the newest packages (recent Niri, Noctalia v5, Hyprland from unstable) at the cost of occasional breakage.

Two things keep it safe:
- The committed **`flake.lock` freezes everything** — the system never changes until *you* run `nix flake update` (`nfu`).
- You can always **roll back** instantly: `sudo nixos-rebuild switch --rollback`.

So: update deliberately (not on a schedule), and roll back if an update misbehaves.

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

### **⚙️ How do I rebuild / switch configuration?**

Standard NixOS commands (the shipped host is `default`):

```bash
cd ~/pok-os
sudo nixos-rebuild switch --flake .#default
# convenience alias:
nrs
```

### **🔄 How do I update my Pok-OS system?**

Because this is a rolling/bleeding-edge setup, update **deliberately** and be
ready to roll back:

```bash
cd ~/pok-os
nix flake update                              # bump all inputs to latest
sudo nixos-rebuild switch --flake .#default   # or just: nfu (does both)

# if something breaks:
sudo nixos-rebuild switch --rollback
```

`nfu` = `nix flake update && sudo nixos-rebuild switch --flake .#default`.
If you don't run these, your system stays exactly as-is (the `flake.lock` is
committed).

## 🎮 Hardware & Graphics

### **🎯 How do I configure NVIDIA graphics properly?**

1. **For desktop systems (dedicated GPU):**
   - Use profile: `nvidia`
   - Edit `hosts/default/variables.nix`
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

# Choose the bar/shell
barChoice = "noctalia";   # "noctalia" (default) or "dms"

# Change Hyprland animations
animChoice = ../../modules/home/hyprland/animations-end4.nix;
```

Drop new images into `wallpapers/` and reference them (a pinned default ships
in the repo so builds stay reproducible).

### **🟦 How do the window borders get their color?**

With the Noctalia bar, borders follow Noctalia's active palette automatically.
To make them track the **wallpaper**, open Noctalia settings (`SUPER + ,` →
Color Scheme) and enable **"Use wallpaper colors"**, then re-apply the
wallpaper once. Noctalia writes `~/.config/niri/noctalia-colors.kdl` and
`~/.config/hypr/noctalia-colors.conf`, which Niri/Hyprland pick up live.

### **🌍 How do I change my timezone?**

Edit your host's `variables.nix`:
```nix
timeZone = "America/Los_Angeles";  # Change to your timezone
```

### **⌨️ How do I change keyboard layout?**

Edit your host's `variables.nix`:
```nix
keyboardLayout = "us";      # Change to your layout (de, fr, etc.)
consoleKeyMap = "us";       # Usually matches keyboard layout
```

### **📦 How do I install additional software?**

1. **System-wide packages:** Edit `modules/core/packages.nix`
2. **Host-specific packages:** Edit `hosts/default/host-packages.nix`
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
browser = "zen";  # Options: zen, firefox, vivaldi, brave, chromium
```

### **💻 How do I change the default terminal?**

Edit your host's `variables.nix`:
```nix
terminal = "kitty";  # Options: kitty, alacritty, ghostty
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
nixos-rebuild build --flake .#default
```

### **🔑 I installed it but can't log in — no password works**

`nixos-install` only sets the **root** password. Your user ships with the
fallback `initialPassword = "changeme"` (see `modules/core/user.nix`). Log in
with that, then set your own:

```bash
passwd    # your new password persists across rebuilds (mutableUsers = true)
```

### **🛠️ A build failed - what do I do?**

Common solutions:
1. Read the error: `sudo nixos-rebuild switch --flake .#default --show-trace`
2. Check network connectivity
3. If a recent `nix flake update` caused it, roll back the lock with
   `git checkout flake.lock` and rebuild, or `sudo nixos-rebuild switch --rollback`

### **💾 How do I free up disk space?**

Garbage collection runs automatically via `nh clean` (keeps 7 days / 5
generations). To clean manually:

```bash
nh clean all
# or the classic:
sudo nix-collect-garbage -d
```

## 🏗️ Building & Development

### **🔨 How do I test changes without switching?**

```bash
nixos-rebuild build --flake .#default
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
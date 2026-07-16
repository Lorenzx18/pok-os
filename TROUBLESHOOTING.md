# Pok OS - Troubleshooting Guide

Quick solutions for common issues with Pok OS.

## Installation Issues

### Can't Log In After a Fresh Install

**Problem:** No password works at SDDM on a brand-new install.

**Cause:** `nixos-install` only sets the **root** password. The user ships with
a fallback `initialPassword = "changeme"` (`modules/core/user.nix`).

**Solution:** Log in with `changeme`, then set your own password:
```bash
passwd    # persists across rebuilds (mutableUsers = true)
```

### Install / First Build Fails

**Error:** Build exits with an error during `nixos-install` or first rebuild.

**Solutions:**

1. **Make sure hardware config was generated** (the shipped one is a placeholder):
   ```bash
   sudo ./generate-hardware-config.sh          # or --root / on a live system
   ```

2. **Check network:**
   ```bash
   ping nixos.org
   ```

3. **Build with a trace to see the real error:**
   ```bash
   cd ~/pok-os
   sudo nixos-rebuild switch --flake .#default --show-trace
   ```

### Build Failures

**Error:** `error: builder for '/nix/store/...' failed`

> ⚠️ On this **bleeding-edge (unstable)** setup, a failure right after
> `nix flake update` usually means an input regressed upstream. Don't "fix" it
> by updating again — revert the lock instead.

**Solutions:**

1. **Check detailed errors:**
   ```bash
   sudo nixos-rebuild switch --flake .#default --show-trace
   ```

2. **If it broke after an update, revert the lock:**
   ```bash
   cd ~/pok-os
   git checkout flake.lock          # back to the last known-good pins
   sudo nixos-rebuild switch --flake .#default
   # already switched to a bad generation? roll back:
   sudo nixos-rebuild switch --rollback
   ```

3. **Verify the host exists:**
   ```bash
   ls ~/pok-os/hosts/
   nix flake show
   ```

### Hardware Detection Issues

**Problem:** GPU not detected correctly or display issues after installation

**Solutions:**

1. **For NVIDIA laptops with hybrid graphics:**
   ```bash
   # Find your GPU bus IDs
   lspci | grep VGA
   
   # Update in ~/pok-os/hosts/default/variables.nix:
   intelID = "PCI:0:2:0";    # Your Intel GPU ID
   nvidiaID = "PCI:1:0:0";   # Your NVIDIA GPU ID
   
   # Rebuild
   sudo nixos-rebuild switch --flake .#default
   ```

2. **Regenerate hardware config if needed:**
   ```bash
   sudo nixos-generate-config --show-hardware-config > ~/pok-os/hosts/default/hardware.nix
   sudo nixos-rebuild switch --flake .#default
   ```

## Display Issues

### Monitor Not Working or Wrong Resolution

**Solution:** Update monitor configuration in `~/pok-os/hosts/default/variables.nix`:

```bash
# First, find your monitors (after logging in)
hyprctl monitors  # In Hyprland
niri msg outputs  # In Niri

# Then update extraMonitorSettings in variables.nix:
extraMonitorSettings = ''
  monitor=HDMI-A-1,1920x1080@60,0x0,1
  monitor=DP-1,2560x1440@144,1920x0,1
'';

# Rebuild
sudo nixos-rebuild switch --flake .#default
```

### Black Screen After Login

**Possible Causes:**
- Window manager not starting
- Display configuration issue
- Graphics driver problem

**Solutions:**

1. **Switch to different window manager at login:**
   - At SDDM login screen, select Hyprland or Niri from session menu

2. **Check logs:**
   ```bash
   # Press Ctrl+Alt+F2 to get to TTY
   journalctl -xeu display-manager
   journalctl --user -xeu hyprland  # or niri
   ```

3. **Try rebuilding:**
   ```bash
   sudo nixos-rebuild switch --flake .#default
   ```

## Window Manager Issues

### Can't Switch Between Hyprland and Niri

**Solution:** Both are always available! Just select at login:
1. Log out
2. At SDDM screen, click session icon (top-right or bottom-left)
3. Select "Hyprland" or "Niri"
4. Log in

No rebuild needed!

### Window Borders Don't Follow the Theme

**Problem:** Borders stay a fixed color instead of matching the active bar's
palette.

**Solutions (Noctalia bar):**

1. **Enable wallpaper colors:** Noctalia settings (`SUPER + ,` → Color Scheme)
   → turn on **"Use wallpaper colors"**, then change/re-apply the wallpaper once.
2. **Confirm the color files were written:**
   ```bash
   ls -l ~/.config/niri/noctalia-colors.kdl ~/.config/hypr/noctalia-colors.conf
   ```
   If missing, re-apply the wallpaper or check `noctalia theme --list-templates`
   shows the `niri_colors` / `hyprland_colors` entries.
3. **Niri** live-reloads the include automatically; for **Hyprland** the
   template runs `hyprctl reload`. If borders still don't move, re-login.

**Solutions (DMS bar):**

1. DMS themes borders itself — confirm the generated files exist:
   ```bash
   ls -l ~/.config/niri/dms-colors.kdl ~/.config/hypr/dms-colors.conf
   ```
2. Force a regeneration (e.g. after switching bars or a fresh login):
   ```bash
   dms-border-colors        # regenerates both files + reloads Hyprland
   ```
3. The generator is driven by a systemd user path unit watching DMS's color
   output; it re-runs automatically whenever DMS changes the theme. If it isn't
   running, enable it:
   ```bash
   systemctl --user restart dms-border-colors.path dms-border-colors.service
   ```
4. For **Hyprland**, the generator runs `hyprctl reload`; for **Niri** the
   `include` is live-reloaded, so no manual step is needed.

### Hyprlock Interfering with Other Lock Screens

**Problem:** Using DMS or Noctalia but hyprlock keeps activating

**Solution:** Disable hyprlock in `~/pok-os/hosts/default/variables.nix`:

```nix
enableHyprlock = false;
```

Then rebuild:
```bash
sudo nixos-rebuild switch --flake .#default
```

## Package Issues

### Package Not Found

**Error:** `error: attribute 'packageName' missing`

**Solution:** Check if package is in nixpkgs:
```bash
# Search for package
nix search nixpkgs packagename

# If found, add to host-packages.nix or variables.nix
```

### Optional Apps Missing

**Problem:** Want Discord, extra browsers, or other apps

**Solution:** Enable optional package groups in `~/pok-os/hosts/default/variables.nix`:

```nix
enableCommunicationApps = true;  # Discord, Teams, Zoom, Telegram
enableExtraBrowsers = true;      # Chromium, Firefox, Brave  
enableProductivityApps = true;   # Obsidian, GNOME Boxes
```

Rebuild to install:
```bash
sudo nixos-rebuild switch --flake .#default
```

## System Recovery

### Boot Failure After Update

**Solution:** Boot into previous generation:

1. **At boot menu:**
   - Select "NixOS - All configurations"
   - Choose a previous generation

2. **Rollback permanently:**
   ```bash
   sudo nixos-rebuild switch --rollback
   ```

### System Won't Boot At All

**Solution:** Boot from NixOS ISO and rollback:

1. Boot from NixOS installer USB
2. Mount your system:
   ```bash
   sudo mount /dev/nvme0n1p2 /mnt  # Adjust partition as needed
   sudo mount /dev/nvme0n1p1 /mnt/boot
   ```

3. Rollback:
   ```bash
   sudo nixos-enter --root /mnt
   nixos-rebuild switch --rollback
   ```

## Network Issues

### WiFi Not Working

**Solutions:**

1. **Enable NetworkManager:**
   Already enabled by default, check status:
   ```bash
   systemctl status NetworkManager
   nmtui  # Terminal UI for network configuration
   ```

2. **Check wireless drivers:**
   ```bash
   lspci | grep -i network
   # Ensure appropriate firmware is loaded
   ```

### Bluetooth Not Working

**Solution:** Enable Bluetooth in your variables.nix (if not already enabled):

```bash
# Check current Bluetooth status
systemctl status bluetooth

# Restart if needed
sudo systemctl restart bluetooth
```

## Performance Issues

### Slow Performance or High CPU Usage

**Solutions:**

1. **Check running processes:**
   ```bash
   htop
   # or
   btop
   ```

2. **Disable animations (temporary):**
   In Hyprland: `Super+Shift+A` (if bound)

3. **Check GPU usage:**
   ```bash
   nvidia-smi  # For NVIDIA
   radeontop   # For AMD
   ```

### Screen Tearing

**Solution for NVIDIA:**

Update `~/pok-os/hosts/default/variables.nix`:
```nix
# In Hyprland settings, VRR is already configured
# Try toggling vrr setting in hyprland.nix if needed
```

## Getting More Help

### Collecting Debug Information

Before asking for help, collect this info:

```bash
# System info
uname -a
nix --version

# Hardware
lspci | grep VGA
lsblk

# Current config
cd ~/pok-os
git log --oneline -5
ls hosts/

# Error logs
journalctl -xeu display-manager | tail -50
```

### Resources

- **NixOS Manual:** https://nixos.org/manual/nixos/stable/
- **NixOS Wiki:** https://nixos.wiki/
- **Hyprland Wiki:** https://wiki.hyprland.org/
- **Niri Wiki:** https://github.com/YaLTeR/niri/wiki
- **Original ZaneyOS:** https://gitlab.com/zaney/zaneyos

## Quick Command Reference

```bash
# Rebuild current system
sudo nixos-rebuild switch --flake .#default

# Test build without switching
sudo nixos-rebuild build --flake .#default

# Update flake inputs
cd ~/pok-os
nix flake update

# Clean old generations (automatic via nh clean; manual:)
nh clean all

# List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
```

## Prevention Tips

1. **Test before switching:**
   ```bash
   nixos-rebuild build --flake .#default
   # If successful, then:
   sudo nixos-rebuild switch --flake .#default
   ```

2. **Commit your working configs (and lock):**
   ```bash
   cd ~/pok-os
   git add -A
   git commit -m "Working configuration"
   ```
   Committing `flake.lock` on a known-good build is your safety net — you can
   always `git checkout flake.lock` to return to it.

3. **Update deliberately, not on a schedule.** This is a rolling/unstable
   setup, so only run `nix flake update` (or `nfu`) when you have time to test
   and roll back if needed.

---

*Can't find your issue? Check ~/pok-os/CLAUDE.md for more technical details or consult the NixOS community.*

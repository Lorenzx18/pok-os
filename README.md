# ❄️ Pok OS — Powered by NixOS ❄️

A personal, flake-based [NixOS](https://nixos.org) configuration. It provides a
reproducible Wayland desktop with **both Hyprland and Niri** available at the
login screen, themed with Stylix, and managed entirely through Nix flakes and
Home Manager. It is built on top of [ZaneyOS](https://gitlab.com/zaney/zaneyos).

![Pok OS Desktop](img/desktop-screenshot.png)

## ✨ Features

- 🪟 **Dual Window Managers** — Hyprland and Niri, both available at login (no rebuild to switch)
- 🎨 **Stylix theming** — system-wide color coordination from a single wallpaper
- 📦 **Modular** — enable only the features you need in `variables.nix`
- 🎮 **Multi-GPU** — NVIDIA (desktop + hybrid laptop), AMD, Intel, and VM profiles
- 🔁 **Reproducible** — one `flake.nix`, rebuild anytime, roll back on failure

## 🚀 Installation

Pok OS is installed directly with the NixOS flake, no custom installer or ISO
required.

### 1. Install base NixOS

Use the official [NixOS ISO](https://nixos.org/download) (Graphical or Minimal)
to install a **minimal base NixOS** first (partition, set a user, enable flakes).
Reboot into it.

### 2. Install Pok OS from the flake

From the installer shell (or your freshly installed system):

```bash
sudo nixos-install --flake github:Lorenzx18/pok-os#default
```

This builds and installs the `default` host configuration. After it finishes,
reboot.

> On subsequent machines, or to target a different host, replace `default` with
> that host's name (and make sure it exists in `flake.nix` / `hosts/`).

### 3. Apply updates / rebuild

Once installed, you manage the system with `nixos-rebuild` (Home Manager is
invoked automatically by the flake):

```bash
cd ~/pok-os
sudo nixos-rebuild switch --flake .#default
```

Convenient shell aliases are provided:

```bash
nrs   # sudo nixos-rebuild switch --flake .#default
nfu   # nix flake update && sudo nixos-rebuild switch --flake .#default
```

## 📁 Project Structure

```
pok-os/
├── flake.nix            # Inputs + per-host configurations (mkHost)
├── hosts/
│   └── default/         # The one host (variables.nix, hardware.nix, host-packages.nix)
├── modules/
│   ├── core/            # System configuration (boot, network, drivers, features)
│   ├── drivers/         # GPU drivers (amd, intel, nvidia, nvidia-prime, vm)
│   └── home/            # User environment (Hyprland, Niri, shells, apps)
├── profiles/            # Hardware profiles (amd, intel, nvidia, nvidia-laptop, vm)
├── wallpapers/          # placeholder.png + your own wallpapers
└── img/                 # Screenshots used by this README
```

## 🎨 Customization

Almost everything is controlled from `hosts/default/variables.nix`. After
editing, rebuild with `nrs` (or `sudo nixos-rebuild switch --flake .#default`).

```nix
# hosts/default/variables.nix
timeZone          = "Asia/Manila";
keyboardLayout    = "us";
browser           = "zen";        # zen, firefox, vivaldi, brave, chromium
terminal          = "kitty";      # kitty, alacritty, ghostty
defaultShell      = "zsh";        # zsh, fish
barChoice         = "noctalia";   # noctalia (or dms)
enableHyprlock    = false;        # set false if using DMS/Noctalia lock screen

# Optional features (all default to false except where noted)
gamingSupportEnable   = true;
printEnable           = true;
syncthingEnable       = true;
enableCommunicationApps = true;
enableExtraBrowsers   = true;
enableProductivityApps = true;
aiCodeEditorsEnable   = true;
# flutterdevEnable    = false;   # intentionally off
```

### Wallpaper

The repo ships with a `wallpapers/placeholder.png` so the build works out of the
box. Drop your own image into `wallpapers/` and point Stylix at it:

```nix
stylixImage = ../../wallpapers/my-wallpaper.jpg;
```

### Adding another machine

1. Copy `hosts/default/` to `hosts/<my-host>/` and edit its `variables.nix`
   (set `timeZone`, GPU `intelID`/`nvidiaID`, monitor layout, etc.).
2. Run `sudo nixos-generate-config --show-hardware-config > hosts/<my-host>/hardware.nix`.
3. Add the host in `flake.nix` via `mkHost { hostname = "<my-host>"; profile = "nvidia-laptop"; username = "pok"; };`.
4. Build: `sudo nixos-rebuild switch --flake .#<my-host>`.

## 🪟 Window Managers

Both are always available — choose at the SDDM login screen, no rebuild needed:

- **Hyprland** — modern tiling Wayland compositor with smooth animations.
- **Niri** — scrollable tiling compositor with a unique workflow.

## 🎮 GPU Support

Selected by the `profile` argument in `flake.nix`:

- `nvidia` — dedicated NVIDIA
- `nvidia-laptop` — hybrid Intel/NVIDIA (Prime)
- `amd` — AMDGPU
- `intel` — integrated
- `vm` — virtual machine

## 🆘 Troubleshooting

```bash
# Verbose rebuild
sudo nixos-rebuild switch --flake .#default --show-trace

# Find monitor names (after first login)
hyprctl monitors

# Hybrid laptop GPU IDs
lspci | grep VGA
# → update intelID / nvidiaID in variables.nix

# Roll back if a build breaks
sudo nixos-rebuild switch --rollback
```

## 📜 Credits

- **ZaneyOS** — original configuration by Tyler Kelley (Don Williams)
- **NixOS**, **Hyprland**, **Niri**, **Stylix**, **Home Manager**

## 📄 License

Based on ZaneyOS (MIT). See [LICENSE](LICENSE) for details.

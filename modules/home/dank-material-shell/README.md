# Dank Material Shell (DMS) Module

A home-manager module for [Dank Material Shell](https://github.com/AvengeMedia/DankMaterialShell) — a modern Wayland desktop shell built with Quickshell and Go.

## Features

- **Modern Desktop Shell**: comprehensive replacement for traditional bars/panels
- **20+ Widgets**: app launcher, notification center, control center, and more
- **Auto-theming**: themes GTK, Qt, and terminal apps from its matugen palette
- **Hyprland / Niri optimized**
- **Automatic Conflict Resolution**: disables waybar when enabled
- **Window borders follow the DMS theme** (see below) — no extra setup

## Installation

DMS is **fully declarative** — there is **no** `dms-install` step. Everything
(DMS QML shell, the `dms` backend binary, and `dgop`) comes from pinned flake
inputs (`dms` = DankMaterialShell **v1.5.1** tag, `dgop` = pinned commit), both
`follows nixpkgs`. The `dms.service` systemd user service runs the store-path
backend.

### Per-Host Configuration

Set the bar in your host's `variables.nix`:

```nix
# hosts/default/variables.nix
barChoice = "dms";  # "noctalia" (default) or "dms"
```

Then rebuild:

```bash
sudo nixos-rebuild switch --flake .#default  # alias: nrs
```

No `dms-install`, no `nix profile` commands.

## What's Included

The module installs (all from pinned flake inputs or nixpkgs):

- **DMS QML shell + `bin/dms` backend** (`inputs.dms.packages.${pkgs.system}.default`)
- **dgop** monitor backend (`inputs.dgop.packages.${pkgs.system}.dgop`)
- **Quickshell** — the shell runtime DMS uses (`inputs.quickshell`)
- **Material Symbols Rounded** — Google's variable icon font (required by DMS)
- **Fira Code / JetBrains Mono Nerd Fonts**
- **wl-clipboard**, **cliphist**, **brightnessctl**, **hyprpicker**
- **matugen** — Material Design color generation
- **cava** — audio visualizer
- **Qt5/Qt6 Wayland support**, **gammastep**
- **`dms-border-colors`** — generator that makes window borders follow the DMS
  palette (see below)

## Window Borders Follow the DMS Theme

A `dms-border-colors` generator reads DMS's active matugen palette from
`~/.config/gtk-3.0/dank-colors.css` (the file `gtk.css` symlinks to, always
reflecting the current dark/light mode) and writes:

- `~/.config/niri/dms-colors.kdl`
- `~/.config/hypr/dms-colors.conf`

A systemd user **oneshot** runs it at session start; a systemd user **path
unit** (`dms-border-colors.path`) re-runs it whenever DMS rewrites its colors.
Niri live-reloads the include; Hyprland is reloaded via `hyprctl reload` from
the generator. No wallpaper toggle is needed — borders follow the DMS theme
automatically.

## Configuration

DMS stores its settings in:

```
~/.config/DankMaterialShell/
```

Edit files there to customize DMS after a rebuild (theme, widgets, etc.).

## Waybar Conflict Prevention

When `barChoice = "dms"` (or the legacy `enableDankMaterialShell = true`), this
module:

1. **Automatically disables waybar** using `lib.mkForce false`
2. Prevents both shells from running simultaneously
3. Ensures clean activation without conflicts

To switch back to waybar, set `barChoice = "noctalia"` (or
`enableDankMaterialShell = false`) and rebuild.

## Supported Compositors

- ✅ **Hyprland** (primary support)
- ✅ **Niri** (supported)

## Troubleshooting

### DMS not starting

1. Confirm `barChoice = "dms"` in `hosts/default/variables.nix` and rebuild.
2. Check the service: `systemctl --user status dms.service`
3. Verify DMS config exists: `ls ~/.config/DankMaterialShell/`

### Window borders not following the DMS theme

1. Confirm the generated files exist:
   ```bash
   ls -l ~/.config/niri/dms-colors.kdl ~/.config/hypr/dms-colors.conf
   ```
2. Force a regeneration: `dms-border-colors`
3. Ensure the units are active:
   ```bash
   systemctl --user restart dms-border-colors.path dms-border-colors.service
   ```

### Missing fonts or icons

The module installs Material Symbols Rounded automatically. If icons are still
missing after a rebuild:

1. Verify: `fc-list | grep -i "material symbols"`
2. Rebuild font cache: `fc-cache -fv`
3. Restart your session (log out / in)

## Resources

- [DankMaterialShell GitHub](https://github.com/AvengeMedia/DankMaterialShell)
- [Quickshell Documentation](https://quickshell.outfoxxed.me/)
- [Pok OS Documentation](../../README.md)

## Uninstalling

1. Set `barChoice = "noctalia"` (or `enableDankMaterialShell = false`) in
   `variables.nix`.
2. Rebuild: `sudo nixos-rebuild switch --flake .#default  # alias: nrs`
3. (Optional) clean up config: `rm -rf ~/.config/DankMaterialShell/`

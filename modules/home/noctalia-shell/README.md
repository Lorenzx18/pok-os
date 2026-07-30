# Noctalia Shell

Noctalia Shell is a modern, customizable shell/bar for Wayland compositors built with Quickshell.

## Features

- Material Design 3 inspired interface
- Deep Stylix integration for automatic theming
- Customizable widgets and layout
- Support for multiple window managers (Niri, Hyprland, etc.)

## Configuration

Noctalia is configured through the `programs.noctalia-shell.settings` option in your host's configuration.

### Enabling Noctalia

In your host's `variables.nix`:

```nix
barChoice = "noctalia";
```

### Customization

Noctalia is configured via its own GUI, which writes
`~/.config/noctalia/settings.toml`. Most options live there rather than in Nix
(see `modules/home/noctalia-shell/default.nix` for the systemd service).

Available configuration sections (in the GUI):
- **bar**: Position, density, widget layout
- **general**: Avatar, animations, lock behavior
- **location**: Time zone, weather, date formatting
- **colors**: Color scheme (auto-synced with Stylix by default)
- **audio**: Volume/brightness increments
- **notifications**: Urgency levels, timeouts, locations

## Documentation

Full documentation: https://docs.noctalia.dev

## Switching bars

Change `barChoice` in your `variables.nix`:
- `barChoice = "noctalia"` - Use Noctalia Shell (default)
- `barChoice = "dms"` - Use Dank Material Shell (fully declarative — just rebuild)

Both Hyprland and Niri remain available at login. Then rebuild:
```bash
sudo nixos-rebuild switch --flake .#default   # alias: nrs
```

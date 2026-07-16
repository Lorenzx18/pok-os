{
  config,
  lib,
  pkgs,
  inputs,
  host,
  ...
}:
let
  variables = import ../../../hosts/${host}/variables.nix;
  barChoice = variables.barChoice or "waybar";
  enableNoctalia = barChoice == "noctalia";
in
{
  config = lib.mkIf enableNoctalia {
    # Noctalia v5 is configured via its own GUI, which writes
    # ~/.config/noctalia/settings.toml. The old JSON approach is ignored by
    # v5, so we don't ship a pre-baked config: noctalia runs with its
    # built-in defaults until you customize it from the GUI.
    programs.waybar.enable = lib.mkForce false;
    home.packages = [ inputs.noctalia.packages.${pkgs.system}.default ];

    # Make window-manager border colors follow Noctalia's palette. Noctalia
    # re-renders these user templates every time the wallpaper/theme changes,
    # writing color-only include files that niri and hyprland pick up live.
    # For colors to track the WALLPAPER, enable "Use wallpaper colors" in the
    # Noctalia GUI (SUPER+comma -> Color Scheme); otherwise the active
    # predefined scheme's colors are used.
    xdg.configFile."noctalia/templates.toml".text = ''
      [theme.templates.user.niri_colors]
      input_path  = "$XDG_CONFIG_HOME/noctalia/templates/niri-colors.kdl"
      output_path = "$XDG_CONFIG_HOME/niri/noctalia-colors.kdl"

      [theme.templates.user.hyprland_colors]
      input_path  = "$XDG_CONFIG_HOME/noctalia/templates/hyprland-colors.conf"
      output_path = "$XDG_CONFIG_HOME/hypr/noctalia-colors.conf"
      post_hook   = "hyprctl reload || true"
    '';

    # niri: color-only override, included after the layout block. niri watches
    # included files and live-reloads automatically.
    xdg.configFile."noctalia/templates/niri-colors.kdl".text = ''
      layout {
          border {
              active-color "{{ colors.primary.default.hex }}"
              inactive-color "{{ colors.surface_variant.default.hex }}"
              urgent-color "{{ colors.error.default.hex }}"
          }
          focus-ring {
              active-color "{{ colors.primary.default.hex }}"
              inactive-color "{{ colors.surface_variant.default.hex }}"
          }
      }
    '';

    # hyprland: sourced from hyprland.conf; hyprctl reload applied via post_hook.
    xdg.configFile."noctalia/templates/hyprland-colors.conf".text = ''
      general {
          col.active_border = rgb({{ colors.primary.default.hex_stripped }})
          col.inactive_border = rgb({{ colors.surface_variant.default.hex_stripped }})
      }
    '';

    # Run Noctalia as a graphical-session service so switching bars via
    # `nixos-rebuild switch` starts/stops it live (no re-login needed).
    systemd.user.services.noctalia = {
      Unit = {
        Description = "Noctalia shell/bar";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${inputs.noctalia.packages.${pkgs.system}.default}/bin/noctalia";
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
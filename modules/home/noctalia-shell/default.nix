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

  # Wires Noctalia's matugen palette into GTK/Qt the same way DMS's gtk.sh does
  # for DMS. Noctalia renders `noctalia/gtk-colors.css` from its matugen
  # template (see templates.toml / gtk-colors.css below); this script symlinks
  # gtk.css to it (GTK3) / @imports it (GTK4) and derives qt5ct/qt6ct color
  # schemes from the same palette so Qt apps follow the wallpaper too.
  noctaliaGtkSh = pkgs.writeShellScriptBin "noctalia-gtk-sh" ''
    #!/usr/bin/env bash
    set -uo pipefail

    CFG="$HOME/.config"
    SRC="$CFG/noctalia/gtk-colors.css"
    [ -f "$SRC" ] || exit 0

    # GTK3: symlink gtk.css -> our generated colors
    mkdir -p "$CFG/gtk-3.0"
    ln -sf "$SRC" "$CFG/gtk-3.0/gtk.css"

    # GTK4: @import our colors (prefer-dark is set in gtk.nix)
    mkdir -p "$CFG/gtk-4.0"
    printf '@import url("%s");\n' "$SRC" > "$CFG/gtk-4.0/gtk.css"

    # --- Qt theming: derive a qt5ct/qt6ct color scheme from the same palette ---
    hex_to_argb() { local h="''${1#\#}"; printf '#ff%s' "$h"; }
    get_color() {
      grep -E "@define-color $1 " "$SRC" | grep -oE '#[0-9a-fA-F]{6}' | head -1
    }

    BG=$(get_color bg_color);       FG=$(get_color fg_color)
    SURF=$(get_color surface);      ONSURF=$(get_color on_surface)
    PRIM=$(get_color primary);      ONPRIM=$(get_color on_primary)
    [ -n "$BG" ] || exit 0

    BG_A=$(hex_to_argb "$BG");      FG_A=$(hex_to_argb "$FG")
    SURF_A=$(hex_to_argb "$SURF");  ONSURF_A=$(hex_to_argb "$ONSURF")
    PRIM_A=$(hex_to_argb "$PRIM");  ONPRIM_A=$(hex_to_argb "$ONPRIM")

    # QPalette order (21 entries): Window, WindowText, Base, Text, Button,
    # ButtonText, Highlight, HighlightedText, ToolTipBase, ToolTipText, Link,
    # LinkVisited, Light, Midlight, Dark, Mid, Shadow, ...
    QT="$BG_A, $SURF_A, $BG_A, $FG_A, $SURF_A, $ONSURF_A, $PRIM_A, $ONPRIM_A, $SURF_A, $ONSURF_A, $PRIM_A, $ONSURF_A, $SURF_A, $SURF_A, $BG_A, $SURF_A, $BG_A, $SURF_A, $ONSURF_A, $PRIM_A, $ONPRIM_A"

    mk_qt() {
      local dir="$1" conf="$2"
      mkdir -p "$dir/colors"
      cat > "$dir/colors/noctalia.conf" <<EOF
    [ColorScheme]
    ColorSchemeName=Noctalia
    active_colors=$QT
    inactive_colors=$QT
    disabled_colors=$QT
    EOF
      cat > "$conf" <<EOF
    [Appearance]
    color_scheme_path=$dir/colors/noctalia.conf
    style=gtk2
    EOF
    }

    mk_qt "$CFG/qt5ct" "$CFG/qt5ct/qt5ct.conf"
    mk_qt "$CFG/qt6ct" "$CFG/qt6ct/qt6ct.conf"

    exit 0
  '';
in
{
  config = lib.mkIf enableNoctalia {
    # Noctalia v5 is configured via its own GUI, which writes
    # ~/.config/noctalia/settings.toml. The old JSON approach is ignored by
    # v5, so we don't ship a pre-baked config: noctalia runs with its
    # built-in defaults until you customize it from the GUI.
    programs.waybar.enable = lib.mkForce false;
    home.packages = [
      inputs.noctalia.packages.${pkgs.system}.default
      # Dark GTK theme so libadwaita/GTK3 apps render dark and absorb
      # Noctalia's matugen colors (Stylix's gtk target is now disabled, so we
      # must pick the theme ourselves — same as DMS does).
      pkgs.adw-gtk3
    ];

    # Stylix no longer sets a GTK theme; enable the dark one so apps render
    # dark and pick up Noctalia's colors. Don't let it write gtk.css — Noctalia
    # owns that via the symlink/import created by noctalia-gtk-sh below.
    gtk = {
      enable = lib.mkForce true;
      theme = {
        name = "adw-gtk3-dark";
        package = pkgs.adw-gtk3;
      };
      gtk3.extraConfig = lib.mkForce { };
      gtk4.extraConfig = lib.mkForce { };
    };

    # Make window-manager border colors AND GTK/Qt app colors follow Noctalia's
    # palette. Noctalia re-renders these user templates every time the
    # wallpaper/theme changes, writing color-only files that the WMs and GTK/Qt
    # pick up live. For colors to track the WALLPAPER, enable "Use wallpaper
    # colors" in the Noctalia GUI (SUPER+comma -> Color Scheme); otherwise the
    # active predefined scheme's colors are used.
    xdg.configFile."noctalia/templates.toml".text = ''
      [theme.templates.user.niri_colors]
      input_path  = "$XDG_CONFIG_HOME/noctalia/templates/niri-colors.kdl"
      output_path = "$XDG_CONFIG_HOME/niri/noctalia-colors.kdl"

      [theme.templates.user.hyprland_colors]
      input_path  = "$XDG_CONFIG_HOME/noctalia/templates/hyprland-colors.conf"
      output_path = "$XDG_CONFIG_HOME/hypr/noctalia-colors.conf"
      post_hook   = "hyprctl reload || true"

      [theme.templates.user.gtk_colors]
      input_path  = "$XDG_CONFIG_HOME/noctalia/templates/gtk-colors.css"
      output_path = "$XDG_CONFIG_HOME/noctalia/gtk-colors.css"
      post_hook   = "noctalia-gtk-sh || true"
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

    # GTK/Qt color file generated by Noctalia's matugen from its active palette.
    xdg.configFile."noctalia/templates/gtk-colors.css".text = ''
      @define-color bg_color {{ colors.background.default.hex }};
      @define-color fg_color {{ colors.on_background.default.hex }};
      @define-color surface {{ colors.surface.default.hex }};
      @define-color on_surface {{ colors.on_surface.default.hex }};
      @define-color primary {{ colors.primary.default.hex }};
      @define-color on_primary {{ colors.on_primary.default.hex }};
      @define-color error {{ colors.error.default.hex }};
      @define-color on_error {{ colors.on_error.default.hex }};
    '';

    # Wire Noctalia's palette into GTK/Qt. The oneshot runs at session start;
    # the path unit re-runs whenever Noctalia rewrites its colors (mirrors
    # DMS's gtk-sh units).
    systemd.user.services."noctalia-gtk-sh" = {
      Unit = {
        Description = "Wire Noctalia matugen colors into GTK/Qt";
        PartOf = [ "graphical-session.target" ];
        After = [ "noctalia.service" "graphical-session.target" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${noctaliaGtkSh}/bin/noctalia-gtk-sh";
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
    systemd.user.paths."noctalia-gtk-sh" = {
      Path = {
        PathChanged = [ "%h/.config/noctalia/gtk-colors.css" ];
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

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

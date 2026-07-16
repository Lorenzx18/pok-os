{
  config,
  lib,
  pkgs,
  host,
  inputs,
  ...
}:
let
  variables = import ../../../hosts/${host}/variables.nix;
  barChoice = variables.barChoice or "waybar";
  # Legacy support for enableDankMaterialShell
  enableDMSLegacy = variables.enableDankMaterialShell or false;
  enableDMS = (barChoice == "dms") || enableDMSLegacy;

  # Material Symbols Rounded font derivation
  material-symbols-rounded = pkgs.stdenvNoCC.mkDerivation {
    pname = "material-symbols-rounded";
    version = "2024-09-01";

    src = pkgs.fetchurl {
      url = "https://github.com/google/material-design-icons/raw/819d78680a849ceef4c78f863d8753e3160b7c89/variablefont/MaterialSymbolsRounded%5BFILL%2CGRAD%2Copsz%2Cwght%5D.ttf";
      hash = "sha256-gt8deKs+RHx+IpV3R9kXhLZ196hZJgFiFbHue//AWls=";
    };

    dontUnpack = true;

    installPhase = ''
      runHook preInstall
      install -Dm644 $src $out/share/fonts/truetype/MaterialSymbolsRounded.ttf
      runHook postInstall
    '';

    meta = with lib; {
      description = "Material Symbols Rounded - Variable icon font by Google";
      homepage = "https://fonts.google.com/icons";
      license = licenses.asl20;
      platforms = platforms.all;
    };
  };

  # The DMS flake's `default` package (pinned v1.5.1 release tag) ships both
  # the QML shell and the `bin/dms` backend CLI/API server, all built from the
  # same source — no imperative `dms-install` download is needed.

  # Generate WM window-border colors from DMS's *active* matugen palette so the
  # borders follow the DMS theme (the same job Noctalia's templates do). DMS
  # writes its palette to ~/.config/gtk-3.0/dank-colors.css (the file gtk.css
  # symlinks to), which always reflects the current dark/light mode.
  dmsBorderColors = pkgs.writeShellScriptBin "dms-border-colors" ''
    #!/usr/bin/env bash
    set -uo pipefail

    CSS="$HOME/.config/gtk-3.0/dank-colors.css"

    get_color() {
      local name="$1" fallback="$2" val=""
      if [[ -f "$CSS" ]]; then
        val=$(grep -oE "@define-color[[:space:]]+''${name}[[:space:]]+#?[0-9a-fA-F]{6}" "$CSS" \
              | grep -oE "#?[0-9a-fA-F]{6}" | head -1)
      fi
      [[ -n "$val" ]] && echo "$val" || echo "$fallback"
    }

    ACCENT=$(get_color accent_bg_color "#89b4fa")
    INACTIVE=$(get_color card_bg_color "")
    [[ -z "$INACTIVE" ]] && INACTIVE=$(get_color window_bg_color "#313244")
    URGENT=$(get_color error_bg_color "#f38ba8")

    acc="''${ACCENT#\#}"; inc="''${INACTIVE#\#}"; urg="''${URGENT#\#}"

    mkdir -p "$HOME/.config/niri" "$HOME/.config/hypr"

    cat > "$HOME/.config/niri/dms-colors.kdl" <<KDL
    layout {
        border {
            active-color "#$acc"
            inactive-color "#$inc"
            urgent-color "#$urg"
        }
        focus-ring {
            active-color "#$acc"
            inactive-color "#$inc"
        }
    }
    KDL

    cat > "$HOME/.config/hypr/dms-colors.conf" <<CONF
    general {
        col.active_border = rgb($acc)
        col.inactive_border = rgb($inc)
    }
    CONF

    # Reload the running compositor so borders pick up the new colors.
    if command -v hyprctl >/dev/null 2>&1; then
      if [[ -z "''${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
        sigdir=$(ls -d "$XDG_RUNTIME_DIR"/hypr/*/ 2>/dev/null | head -1)
        [[ -n "$sigdir" ]] && export HYPRLAND_INSTANCE_SIGNATURE="$(basename "$sigdir")"
      fi
      hyprctl reload >/dev/null 2>&1 || true
    fi
    if command -v niri >/dev/null 2>&1; then
      niri msg reload >/dev/null 2>&1 || true
    fi

    exit 0
  '';
in
{
  options.programs.dankMaterialShell = {
    enable = lib.mkEnableOption "Dank Material Shell";
  };

  config = lib.mkIf enableDMS {
    # Disable waybar when DMS is enabled to prevent conflicts
    programs.waybar.enable = lib.mkForce false;

    # DMS + its dependencies, all pinned/reproducible via flake inputs.
    # No imperative `dms-install` is needed — everything comes from the flake.
    home.packages = with pkgs; [
      # Generates WM border colors from DMS's active palette (see systemd units)
      dmsBorderColors

      # Quickshell - the shell engine that runs the DMS QML
      inputs.quickshell.packages.${pkgs.system}.default

      # DMS QML shell + backend CLI (pinned v1.5.1 release tag)
      inputs.dms.packages.${pkgs.system}.default

      # System monitoring backend used by DMS widgets
      inputs.dgop.packages.${pkgs.system}.dgop

      # Required fonts for DMS
      material-symbols-rounded # Material Symbols Rounded (Google icon font)
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono

      # Core utilities (required for DMS functionality)
      wl-clipboard # Clipboard support for Wayland
      cliphist # Clipboard history manager
      brightnessctl # Brightness control
      hyprpicker # Color picker for Hyprland
      matugen # Material Design color generation

      # System monitoring dependencies
      lm_sensors # Hardware temperature monitoring
      pciutils # lspci for GPU detection

      # Network utilities (for WiFi module)
      glib # Provides gdbus command for DBus communication (required for WiFi toggle)
      networkmanager # Network management
      networkmanagerapplet # NM applet for GUI

      # Audio visualization
      cava # Console-based audio visualizer

      # Wayland/Qt support
      qt6.qtwayland # Qt6 Wayland support
      qt5.qtwayland # Qt5 Wayland support

      # Optional but recommended
      gammastep # Screen temperature adjustment (blue light filter)
    ];

    # Run DMS as a graphical-session service so switching bars via
    # `nixos-rebuild switch` starts/stops it live (no re-login needed).
    # Uses the pinned backend derivation (not an imperatively installed binary).
    systemd.user.services.dms = {
      Unit = {
        Description = "Dank Material Shell";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${inputs.dms.packages.${pkgs.system}.default}/bin/dms run";
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    # Keep WM window borders in sync with DMS's matugen palette. The oneshot
    # runs at session start; the path unit re-runs whenever DMS rewrites its
    # colors (mirrors Noctalia's border-colors post_hook).
    systemd.user.services.dms-border-colors = {
      Unit = {
        Description = "Generate WM border colors from DMS palette";
        PartOf = [ "graphical-session.target" ];
        After = [ "dms.service" "graphical-session.target" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${dmsBorderColors}/bin/dms-border-colors";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
    systemd.user.paths."dms-border-colors" = {
      pathConfig = {
        PathChanged = [
          "%h/.cache/DankMaterialShell/dms-colors.json"
          "%h/.config/gtk-3.0/dank-colors.css"
        ];
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    # Font configuration
    fonts.fontconfig.enable = true;

    # Point the shell at the pinned DMS QML from the flake package.
    home.file.".config/quickshell/dms".source =
      "${inputs.dms.packages.${pkgs.system}.default}/share/quickshell/dms";

    # Ensure XDG directories exist for DMS
    xdg.configFile."dms/.keep".text = "";
  };
}

{
  host,
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (import ../../../hosts/${host}/variables.nix)
    extraMonitorSettings
    keyboardLayout
    stylixImage
    startupApps
    ;
  variables = import ../../../hosts/${host}/variables.nix;
  barChoice = variables.barChoice or "waybar";
  # Legacy support
  enableDMSLegacy = variables.enableDankMaterialShell or false;
  actualBarChoice =
    if variables ? barChoice then barChoice else (if enableDMSLegacy then "dms" else "waybar");
in
{
  home.packages = with pkgs; [
    awww
    grim
    slurp
    wl-clipboard
    swappy
    ydotool
    hyprpolkitagent
    hyprland-qtutils # needed for banners and ANR messages
    cliphist # clipboard history (used by exec-once wl-paste watch)
    networkmanagerapplet # provides nm-applet (used by exec-once)
  ];
  systemd.user.targets.hyprland-session.Unit.Wants = [
    "xdg-desktop-autostart.target"
  ];
  systemd.user.services.ydotool = {
    Unit = {
      Description = "ydotool daemon";
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.ydotool}/bin/ydotoold";
      Restart = "always";
    };
    Install.WantedBy = [ "hyprland-session.target" ];
  };
  # Place Files Inside Home Directory
  home.file = {
    ".face.icon".source = ./face.jpg;
    ".config/face.jpg".source = ./face.jpg;
  };
  wayland.windowManager.hyprland = {
    enable = true;
    # Keep legacy hyprlang config format (default changed to "lua" in home-manager)
    configType = "hyprlang";
    # Hyprland package comes from nixpkgs (unstable) by default, which avoids
    # version-parsing issues and source compiles. Do not point this at an
    # upstream Hyprland flake input.
    systemd = {
      enable = true;
      enableXdgAutostart = true;
      variables = [ "--all" ];
    };
    xwayland = {
      enable = true;
    };
    settings = {
      exec-once = [
        "wl-paste --type text --watch cliphist store # Stores only text data"
        "wl-paste --type image --watch cliphist store # Stores only image data"
        "dbus-update-activation-environment --all --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "systemctl --user start hyprpolkitagent"
        "killall -q awww-daemon;sleep .5 && awww-daemon"
      ]
      # noctalia and dms are started as systemd user services (see their
      # modules) so they swap seamlessly on `nixos-rebuild switch`. Only
      # waybar is launched here as a fallback.
      ++ lib.optionals (actualBarChoice == "waybar") [
        "killall -q waybar;sleep .5 && waybar"
      ]
      ++ [
        "killall -q swaync;sleep .5 && swaync"
        "nm-applet --indicator"
        "pypr &"
        # Clear glassmorphism: no background color, transparent terminals show
        # straight through (compositor blurs). Don't set an opaque/solid bg.
        "sleep 1.5 && awww clear 000000"
      ]
      ++ startupApps;

      input = {
        kb_layout = "${keyboardLayout}";
        kb_options = [
          "grp:alt_caps_toggle"
          "caps:super"
        ];
        numlock_by_default = false;
        repeat_delay = 300;
        follow_mouse = 1;
        float_switch_override_focus = 0;
        sensitivity = 0;
        touchpad = {
          natural_scroll = true;
          disable_while_typing = true;
          scroll_factor = 0.8;
        };
      };

      general = {
        layout = "dwindle";
        gaps_in = 5;
        gaps_out = 7;
        border_size = 3;
        resize_on_border = true;
        "col.active_border" =
          "rgb(f7768e) rgb(7dcfff) 45deg";
        "col.inactive_border" = "rgb(16161e)";
      };

      misc = {
        layers_hog_keyboard_focus = true;
        initial_workspace_tracking = 0;
        mouse_move_enables_dpms = true;
        key_press_enables_dpms = false;
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        enable_swallow = false;
        vrr = 0; # Variable Refresh Rate. Set to 0 for NVIDIA stability (1 = fullscreen only, 2 = always)
        # Screen flashing to black momentarily or going black when app is fullscreen
        # Try setting vrr to 1 if you want VRR on fullscreen windows

        #  Application not responding (ANR) settings
        enable_anr_dialog = true;
        anr_missed_pings = 20;
      };

      dwindle = {
        preserve_split = true;
        force_split = 2;
      };

      decoration = {
        rounding = 8;
        blur = {
          enabled = true;
          size = 5;
          passes = 3;
          ignore_opacity = false;
          new_optimizations = true;
        };
        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };
      };

      ecosystem = {
        no_donation_nag = true;
        no_update_news = false;
      };

      cursor = {
        sync_gsettings_theme = true;
        no_hardware_cursors = 2; # change to 1 if want to disable
        enable_hyprcursor = false;
        warp_on_change_workspace = 2;
        no_warps = false;
      };

      master = {
        new_status = "master";
        new_on_top = 1;
        mfact = 0.5;
      };

      # Ensure Xwayland windows render at integer scale; compositor scales them
      xwayland = {
        force_zero_scaling = true;
      };
    };

    extraConfig = ''
      ${extraMonitorSettings}
      ${lib.optionalString (actualBarChoice == "noctalia") ''
        # Border colors generated by Noctalia from the current palette/wallpaper
        # (see modules/home/noctalia-shell). Overrides col.active_border /
        # col.inactive_border above; refreshed via `hyprctl reload` in the
        # template's post_hook when the palette changes.
        source = ~/.config/hypr/noctalia-colors.conf
      ''}
      ${lib.optionalString (actualBarChoice == "dms") ''
        # Border colors generated from DMS's active matugen palette
        # (see modules/home/dank-material-shell). Overrides col.active_border /
        # col.inactive_border above; refreshed by `hyprctl reload` from the
        # dms-border-colors service whenever DMS rewrites its colors.
        source = ~/.config/hypr/dms-colors.conf
      ''}
      # Enable blur on the active bar
      ${
        if actualBarChoice == "dms" then
          "layerrule = blur on, match:namespace quickshell"
        else if actualBarChoice == "noctalia" then
          "layerrule = blur on, match:namespace noctalia"
        else
          "layerrule = blur on, match:namespace waybar"
      }
    '';
  };
}

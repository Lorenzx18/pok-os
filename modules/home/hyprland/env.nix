{ ... }: {
  wayland.windowManager.hyprland = {
    settings = {
      env = [
        "NIXOS_OZONE_WL, 1"
        "NIXPKGS_ALLOW_UNFREE, 1"
        "XDG_CURRENT_DESKTOP, Hyprland"
        "XDG_SESSION_TYPE, wayland"
        "XDG_SESSION_DESKTOP, Hyprland"
        "GDK_BACKEND, wayland, x11"
        "CLUTTER_BACKEND, wayland"
        "QT_QPA_PLATFORM,wayland;xcb"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION, 1"
        "QT_AUTO_SCREEN_SCALE_FACTOR, 1"
        "SDL_VIDEODRIVER, x11"
        "MOZ_ENABLE_WAYLAND, 1"
        # This is to make electron apps start in wayland
        "ELECTRON_OZONE_PLATFORM_HINT,wayland"
        # Hybrid NVIDIA laptop: render on the Intel iGPU (card0), offload to dGPU (card1).
        # Verify with `ls /dev/dri` and swap the order if your iGPU is card1.
        "WLR_DRM_DEVICES,/dev/dri/card0:/dev/dri/card1"
        "GDK_SCALE,1"
        "QT_SCALE_FACTOR,1"
        "EDITOR,zed"
        # Set terminal and xdg_terminal_emulator to kitty
        # To provent yazi from starting xterm when run from rofi menu
        # You can set to your preferred terminal if you you like
        # ToDo: Pull default terminal from config
        "TERMINAL,kitty"
        "XDG_TERMINAL_EMULATOR,kitty"
        # Cursor theme (matches the Bibata set via home.pointerCursor/system)
        "XCURSOR_THEME,Bibata-Modern-Ice"
        "XCURSOR_SIZE,24"
      ];
    };
  };
}

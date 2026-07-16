{
  host,
  lib,
  ...
}: let
  inherit (import ../../hosts/${host}/variables.nix) stylixEnable barChoice;
  # When DMS is the bar it themes GTK/Qt itself (gtk.css symlink ->
  # dank-colors.css, qt*ct color configs). Stylix must not also manage
  # those files, or every `switch` clobbers DMS's runtime edits.
  dmsBar = barChoice == "dms";
in
lib.mkIf stylixEnable {
  stylix.targets = {
    waybar.enable = false;
    rofi.enable = false;
    hyprland.enable = false;
    hyprlock.enable = false;
    ghostty.enable = false;
    # mkForce: Stylix's own targets set enable=true and are applied after
    # this module, so a plain `false` would be overridden. mkForce wins.
    qt.enable = lib.mkForce (!dmsBar);
    gtk.enable = lib.mkForce (!dmsBar);
  };

  # Explicitly enable cursor config generation (silences home-manager deprecation)
  home.pointerCursor.enable = true;

  services.nwg-drawer-stylix.enable = true;

  # Force home-manager to overwrite GTK/Qt config files instead of backing them
  # up. Needed so switching bars (DMS <-> Noctalia) never aborts on a leftover
  # file from the other bar (e.g. DMS's gtk.css symlink, or a stale .backup).
  # gtk.css is only forced when NOT DMS — under DMS home-manager doesn't write
  # it (extraConfig cleared) and forcing it would create an empty file.
  xdg.configFile =
    {
      # settings.ini is written in both bars (gtk.theme is always set).
      "gtk-3.0/settings.ini".force = true;
      "gtk-4.0/settings.ini".force = true;
    }
    // lib.optionalAttrs (!dmsBar) {
      # gtk.css and the Qt configs are only written when NOT DMS (under DMS
      # they're cleared/disabled, so forcing them would create empty files).
      "gtk-3.0/gtk.css".force = true;
      "gtk-4.0/gtk.css".force = true;
      "qt5ct/qt5ct.conf".force = true;
      "qt6ct/qt6ct.conf".force = true;
    };
}

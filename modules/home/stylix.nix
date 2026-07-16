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
}

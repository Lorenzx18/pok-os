{
  host,
  pkgs,
  lib,
  ...
}: let
  inherit (import ../../hosts/${host}/variables.nix) stylixEnable;
  # The active bar (DMS or Noctalia) owns the runtime GTK/Qt color scheme:
  #   - DMS: gtk.css -> dank-colors.css (wired by dms-gtk-sh)
  #   - Noctalia: its matugen templates + noctalia-gtk-sh
  # Stylix must not also manage those files, or every `switch` clobbers the
  # bar's runtime edits. Stylix keeps only its SDDM color target so the
  # astronaut login screen follows the wallpaper palette.
in
lib.mkIf stylixEnable {
  # Every app owns its own hardcoded colors now (see each module); Stylix is
  # only allowed to theme SDDM. Disable all other targets so a `switch` can
  # never clobber the bars' runtime GTK/Qt theming or app colors.
  stylix.targets = {
    waybar.enable = false;
    rofi.enable = false;
    hyprland.enable = false;
    hyprlock.enable = false;
    ghostty.enable = false;
    fish.enable = false;
    kitty.enable = false;
    alacritty.enable = false;
    tmux.enable = false;
    bat.enable = false;
    fzf.enable = false;
    starship.enable = false;
    lazygit.enable = false;
    vscode.enable = false;
    vim.enable = false;
    swaync.enable = false;
    dunst.enable = false;
    gtk.enable = lib.mkForce false;
    qt.enable = lib.mkForce false;
  };

  services.nwg-drawer-stylix.enable = false;

  # The cursor is a system resource (not app color theming) and is already set
  # by the system-level Stylix cursor module. Just enable it explicitly here to
  # silence the home-manager deprecation warning; the package/name/size come
  # from modules/core/stylix.nix.
  home.pointerCursor.enable = true;
}

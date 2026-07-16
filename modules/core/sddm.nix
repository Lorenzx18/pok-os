# SDDM is a display manager for X11 and Wayland
{
  pkgs,
  config,
  lib,
  host,
  ...
}:
let
  inherit (import ../../hosts/${host}/variables.nix) stylixEnable stylixImage;
  # When Stylix is enabled (config.stylix.enable is only set true under
  # mkIf stylixEnable in modules/core/stylix.nix), derive the astronaut theme
  # colors/background from the wallpaper palette. When it's disabled, fall back
  # to neutral hardcoded values so a host can turn Stylix off without the
  # config failing to evaluate (config.stylix.* is undefined otherwise).
  stylixOn = config.stylix.enable or false;
  foreground = if stylixOn then config.stylix.base16Scheme.base00 else "1a1b26";
  textColor = if stylixOn then config.stylix.base16Scheme.base05 else "c0caf5";
  backgroundImage = if stylixOn then "${toString config.stylix.image}" else "${toString stylixImage}";
  sddm-astronaut = pkgs.sddm-astronaut.override {
    embeddedTheme = "pixel_sakura";
    themeConfig =
      if lib.hasSuffix "sakura_static.png" backgroundImage then
        {
          FormPosition = "center";
          Blur = "2.0";
          HourFormat = "h:mm AP";
        }
      else if lib.hasSuffix "studio.png" backgroundImage then
        {
          Background = pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/anotherhadi/nixy-wallpapers/refs/heads/main/wallpapers/studio.gif";
            sha256 = "sha256-qySDskjmFYt+ncslpbz0BfXiWm4hmFf5GPWF2NlTVB8=";
            };
          HeaderTextColor = "#${textColor}";
          DateTextColor = "#${textColor}";
          TimeTextColor = "#${textColor}";
          HourFormat = "h:mm AP";
          LoginFieldTextColor = "#${textColor}";
          PasswordFieldTextColor = "#${textColor}";
          UserIconColor = "#${textColor}";
          PasswordIconColor = "#${textColor}";
          WarningColor = "#${textColor}";
          LoginButtonBackgroundColor = "#${foreground}";
          SystemButtonsIconsColor = "#${foreground}";
          SessionButtonTextColor = "#${textColor}";
          VirtualKeyboardButtonTextColor = "#${textColor}";
          DropdownBackgroundColor = "#${foreground}";
          HighlightBackgroundColor = "#${textColor}";
        }
      else
        {
          FormPosition = "center";
          Blur = "4.0";
          Background = "${backgroundImage}";
          HeaderTextColor = "#${textColor}";
          DateTextColor = "#${textColor}";
          TimeTextColor = "#${textColor}";
          HourFormat = "h:mm AP";
          LoginFieldTextColor = "#${textColor}";
          PasswordFieldTextColor = "#${textColor}";
          UserIconColor = "#${textColor}";
          PasswordIconColor = "#${textColor}";
          WarningColor = "#${textColor}";
          LoginButtonBackgroundColor = "#${if stylixOn then config.stylix.base16Scheme.base01 else "16161e"}";
          SystemButtonsIconsColor = "#${textColor}";
          SessionButtonTextColor = "#${textColor}";
          VirtualKeyboardButtonTextColor = "#${textColor}";
          DropdownBackgroundColor = "#${if stylixOn then config.stylix.base16Scheme.base01 else "16161e"}";
          HighlightBackgroundColor = "#${textColor}";
          FormBackgroundColor = "#${if stylixOn then config.stylix.base16Scheme.base01 else "16161e"}";
        };
  };
in
{
  services.displayManager = {
    sddm = {
      package = pkgs.kdePackages.sddm;
      extraPackages = [ sddm-astronaut ];
      enable = true;
      wayland.enable = true;
      theme = "sddm-astronaut-theme";
    };
  };

  environment.systemPackages = [ sddm-astronaut ];
}

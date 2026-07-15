{
  config,
  lib,
  pkgs,
  helium-browser,
  host,
  ...
}:
let
  inherit (import ../../hosts/${host}/variables.nix) enableExtraBrowsers;

  # Helium ships only a binary (no .desktop/icon), so it never shows up in
  # app launchers. Provide a desktop entry and icon so it is selectable.
  heliumDesktop = pkgs.makeDesktopItem {
    name = "helium";
    desktopName = "Helium";
    genericName = "Web Browser";
    comment = "Access the Internet";
    exec = "helium-browser %U";
    icon = "helium";
    startupWMClass = "helium";
    startupNotify = true;
    terminal = false;
    categories = [ "Network" "WebBrowser" ];
    mimeTypes = [
      "application/pdf"
      "application/xhtml+xml"
      "application/xml"
      "image/gif"
      "image/jpeg"
      "image/png"
      "image/webp"
      "text/html"
      "text/xml"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
    ];
    actions = {
      new-window = {
        name = "New Window";
        exec = "helium-browser";
      };
      new-private-window = {
        name = "New Incognito Window";
        exec = "helium-browser --incognito";
      };
    };
  };

  heliumIcon = pkgs.runCommand "helium-icon" { } ''
    mkdir -p $out/share/icons/hicolor/256x256/apps
    cp ${./assets/helium.png} $out/share/icons/hicolor/256x256/apps/helium.png
  '';
in
{
  config = lib.mkIf enableExtraBrowsers {
    environment.systemPackages = with pkgs; [
      vivaldi # Privacy-focused browser
      brave # Privacy browser with ad blocking
      helium-browser # Helium browser
      heliumDesktop # Helium desktop entry
      heliumIcon # Helium icon
    ];
  };
}

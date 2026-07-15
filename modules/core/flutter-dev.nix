{
  config,
  lib,
  pkgs,
  username,
  host,
  ...
}:
let
  inherit (import ../../hosts/${host}/variables.nix) flutterdevEnable;
in
{
  config = lib.mkIf flutterdevEnable {
    # Install Flutter development packages
    environment.systemPackages = with pkgs; [
      flutter # Flutter SDK
      android-studio # Android Studio IDE
      android-tools # Provides the adb command (systemd 258 handles uaccess automatically)
      androidenv.androidPkgs.emulator # For Android emulator
      androidenv.androidPkgs.ndk-bundle # Android NDK
      jdk # Java Development Kit
    ];
  };
}

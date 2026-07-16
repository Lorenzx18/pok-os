{ host, pkgs, ... }:
let
  inherit (import ../../hosts/${host}/variables.nix) consoleKeyMap timeZone;
in
{
  nix = {
    settings = {
      download-buffer-size = 250000000;
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      # Hyprland comes from nixpkgs (cache.nixos.org), so no extra substituter
      # is needed. Add binary caches here if you later adopt upstream flakes.
      substituters = [ ];
      trusted-public-keys = [ ];
    };
  };
  time.timeZone = "${timeZone}";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };
  environment.variables = {
    ZANEYOS_VERSION = "2.3.1";
    ZANEYOS = "true";
  };
  console.keyMap = "${consoleKeyMap}";
  system.stateVersion = "23.11"; # Do not change!

  # Work around an upstream nixpkgs-unstable regression: cpplint-2.0.2's own
  # test suite fails to build against current Python. Skip its tests so it can
  # be used as a (transitive) build input.
  nixpkgs.overlays = [
    (final: prev: {
      cpplint = prev.cpplint.overrideAttrs (_: {
        doCheck = false;
      });
      python3Packages = prev.python3Packages // {
        cpplint = prev.python3Packages.cpplint.overrideAttrs (_: {
          doCheck = false;
        });
      };
    })
  ];

  # Enable nix-ld for running unpackaged programs like adb
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Common libraries needed for Android tools
    stdenv.cc.cc.lib
    zlib
    openssl
    libGL
    # Android-specific libraries
    jdk21
    android-tools
    androidenv.androidPkgs.platform-tools
  ];
}

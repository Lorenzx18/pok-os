{ ... }:
{
  imports = [
    ./hardware.nix
    ./host-packages.nix
  ];

  # Enable sddm display manager
  services.displayManager.sddm.enable = true;

  # Sysc-greet display manager
  services.sysc-greet.enable = false;

  # niri is installed and configured by the niri-flake NixOS module
  # (imported via modules/core/default.nix). The niri-flake module also
  # provides the display-manager session.
}

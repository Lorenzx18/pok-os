{
  config,
  lib,
  pkgs,
  inputs,
  host,
  ...
}:
let
  variables = import ../../../hosts/${host}/variables.nix;
  barChoice = variables.barChoice or "waybar";
  enableNoctalia = barChoice == "noctalia";
in
{
  config = lib.mkIf enableNoctalia {
    # Noctalia v5 is configured via its own GUI, which writes
    # ~/.config/noctalia/settings.toml. The old JSON approach is ignored by
    # v5, so we don't ship a pre-baked config: noctalia runs with its
    # built-in defaults until you customize it from the GUI.
    programs.waybar.enable = lib.mkForce false;
    home.packages = [ inputs.noctalia.packages.${pkgs.system}.default ];

    # Run Noctalia as a graphical-session service so switching bars via
    # `nixos-rebuild switch` starts/stops it live (no re-login needed).
    systemd.user.services.noctalia = {
      Unit = {
        Description = "Noctalia shell/bar";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${inputs.noctalia.packages.${pkgs.system}.default}/bin/noctalia --daemon";
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
{
  config,
  lib,
  pkgs,
  host,
  ...
}:
let
  variables = import ../../../hosts/${host}/variables.nix;
  barChoice = variables.barChoice or "waybar";
  enableNoctalia = barChoice == "noctalia";
  noctaliaPackage = pkgs.noctalia-shell;
in
{
  config = lib.mkIf enableNoctalia {
    programs.waybar.enable = lib.mkForce false;

    home.packages = [
      noctaliaPackage
      pkgs.adw-gtk3
    ];

    gtk = {
      enable = lib.mkForce true;
      theme = {
        name = "adw-gtk3-dark";
        package = pkgs.adw-gtk3;
      };
      gtk3.extraConfig = lib.mkForce { };
      gtk4.extraConfig = lib.mkForce { };
    };

    systemd.user.services.noctalia = {
      Unit = {
        Description = "Noctalia shell/bar";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${noctaliaPackage}/bin/noctalia-shell";
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}

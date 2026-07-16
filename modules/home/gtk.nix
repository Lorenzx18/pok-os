{ pkgs, lib, ... }:

{
  gtk = {
    iconTheme = {
      name = "Tela-purple-dark";
      package = pkgs.tela-icon-theme;
    };
    # Adopt the 26.05 default (gtk4 reads gtk-theme-name from settings.ini) to
    # silence the legacy-default evaluation warning. mkForce is needed because
    # Stylix's gtk module also sets gtk.gtk4.theme (via mkDefault) and a plain
    # `null` collides with it at equal priority.
    gtk4.theme = lib.mkForce null;
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };
}

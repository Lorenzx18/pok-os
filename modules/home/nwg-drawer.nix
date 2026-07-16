{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.services.nwg-drawer-stylix;
in {
  options.services.nwg-drawer-stylix = {
    enable = mkEnableOption "nwg-drawer with stylix theming";
  };

  config = mkIf cfg.enable {
    xdg.configFile."nwg-drawer/drawer.css".text = ''
      window {
        background-color: rgba(26, 27, 38, 0.9);
        color: #c0caf5;
        font-family: "JetBrainsMono Nerd Font Mono";
        font-size: 11pt;
      }

      #searchbox {
        background-color: #16161e;
        border: 2px solid #34344a;
        color: #c0caf5;
        border-radius: 6px;
        padding: 8px;
        margin: 10px;
      }

      #searchbox:focus {
        border-color: #7aa2f7;
      }

      button {
        background-color: transparent;
        border: none;
        color: #c0caf5;
        padding: 8px;
        border-radius: 6px;
        margin: 2px;
      }

      button:hover {
        background-color: #2a2a37;
      }

      button:focus, button:active {
        background-color: #34344a;
      }

      .category-label {
        color: #7aa2f7;
        font-weight: bold;
        padding: 10px;
      }

      .app-name {
        color: #c0caf5;
      }

      .app-comment {
        color: #565f89;
        font-size: smaller;
      }

      scrolledwindow {
        background-color: transparent;
      }

      .file-item {
        color: #c0caf5;
      }

      .file-item:hover {
        background-color: #2a2a37;
      }
    '';
  };
}

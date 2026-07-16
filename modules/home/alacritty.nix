{ lib, ... }: {
  programs.alacritty =
    let
      font_family = lib.mkForce "Maple Mono NF";
    in
    {
      enable = true;
      settings = {
        background_opacity = 0.8;
        font = {
          normal = {
            family = font_family;
            style = "Regular";
          };
          bold = {
            family = font_family;
            style = "Bold";
          };
          italic = {
            family = font_family;
            style = "Italic";
          };
          bold_italic = {
            family = font_family;
            style = "Bold Italic";
          };
          size = 15;
        };
      };
    };
}

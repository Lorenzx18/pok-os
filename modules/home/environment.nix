{pkgs, ...}: {
  home.sessionVariables = {
    # CHROME_EXECUTABLE used by Flutter development
    CHROME_EXECUTABLE = "/run/current-system/sw/bin/helium-browser";
    # BROWSER used by CLI tools and applications to open URLs
    BROWSER = "xdg-open";
  };
}

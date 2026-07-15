{
  pkgs,
  repoPath,
  ...
}: {
  programs.nh = {
    enable = true;
    clean = {
      enable = true;
      extraArgs = "--keep-since 7d --keep 5";
    };
    flake = "${repoPath}";
  };

  environment.systemPackages = with pkgs; [
    nix-output-monitor
    nvd
  ];
}

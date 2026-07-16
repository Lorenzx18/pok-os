{
  pkgs,
  inputs,
  username,
  host,
  profile,
  repoPath,
  ...
}:
let
  variables = import ../../hosts/${host}/variables.nix;
  inherit (variables) gitUsername;
  defaultShell = variables.defaultShell or "zsh";
  shellPackage = if defaultShell == "fish" then pkgs.fish else pkgs.zsh;
in
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  # Enable Fish and Zsh system-wide for vendor completions
  programs.fish.enable = true;
  programs.zsh.enable = true;

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = false;
    backupFileExtension = "backup";
    extraSpecialArgs = {
      inherit
        inputs
        username
        host
        profile
        repoPath
        ;
    };
    users.${username} = {
      imports = [ ./../home ];
      home = {
        username = "${username}";
        homeDirectory = "/home/${username}";
        stateVersion = "23.11";
      };
    };
  };
  users.mutableUsers = true;
  users.users.${username} = {
    isNormalUser = true;
    description = "${gitUsername}";
    extraGroups = [
      "docker"
      "libvirtd" # For VirtManager
      "lp"
      "networkmanager"
      "wheel" # sudo access
    ];
    # Use configured shell based on defaultShell variable
    shell = shellPackage;
    ignoreShellProgramCheck = true;
    # Fallback password so a freshly installed machine can log in at SDDM
    # (mutableUsers = true means nixos-install only sets root). CHANGE IT after
    # first login with `passwd`; your new password then persists across rebuilds.
    initialPassword = "changeme";
  };
  nix.settings.allowed-users = [ "${username}" ];
}

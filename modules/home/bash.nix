{profile, ...}: {
  programs.bash = {
    enable = false;
    enableCompletion = true;
    initExtra = ''
      fastfetch
      if [ -f $HOME/.bashrc-personal ]; then
        source $HOME/.bashrc-personal
      fi
    '';
    shellAliases = {
      sv = "sudo nvim";
      ncg = "nix-collect-garbage --delete-old && sudo nix-collect-garbage -d && sudo /run/current-system/bin/switch-to-configuration boot";
      nrs = "sudo nixos-rebuild switch --flake .#default";
      nfu = "nix flake update && sudo nixos-rebuild switch --flake .#default";
      v = "nvim";
      cat = "bat";
      ".." = "cd ..";
    };
  };
}

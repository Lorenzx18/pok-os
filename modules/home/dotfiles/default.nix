{
  config,
  lib,
  host,
  ...
}:
{
  # Deploy the user's Neovim config (copied from ~/dotfiles) to ~/.config/nvim.
  # Plugins defined by the `manage` module bootstrap on first launch.
  xdg.configFile."nvim" = {
    source = ./nvim;
    recursive = true;
  };
}
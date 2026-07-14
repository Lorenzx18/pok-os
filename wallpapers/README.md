# Wallpapers

This directory intentionally ships with only `placeholder.png` so the config
builds out of the box.

## Add your own wallpapers

1. Drop your image files into this `wallpapers/` directory, e.g.:
   ```
   wallpapers/my-wallpaper.jpg
   ```
2. Point Stylix at it by editing `hosts/default/variables.nix`:
   ```nix
   stylixImage = ../../wallpapers/my-wallpaper.jpg;
   ```
3. Rebuild:
   ```sh
   sudo nixos-rebuild switch --flake .#default
   ```

You can keep as many wallpapers here as you like; only the one referenced by
`stylixImage` is used for theming.

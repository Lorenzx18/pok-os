{
  description = "Pok OS (Based on ZaneyOS)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    # NOTE: Hyprland is used from nixpkgs (unstable) via home-manager's
    # wayland.windowManager.hyprland, not from the upstream flake. We do NOT
    # pull the Hyprland flake because it compiles bleeding-edge `main` from
    # source and is a frequent breakage source; nixpkgs-unstable already ships
    # a very recent Hyprland with binary cache.
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    quickshell = {
      url = "github:outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Dank Material Shell (optional bar, enabled via barChoice = "dms").
    # Pinned to the v1.5.1 release tag so the QML shell and the dms backend
    # (packaged separately below) stay API-compatible and reproducible.
    dms = {
      url = "github:AvengeMedia/DankMaterialShell/v1.5.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dgop = {
      url = "github:AvengeMedia/dgop/45e8a9430134a6761c7fd3a29b50d351ef7387bf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    helium-browser = {
      url = "github:fpletz/flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, flake-utils, ... }@inputs:
    let
      system = "x86_64-linux";

      # Helper function to create a host configuration
      mkHost =
        {
          hostname,
          profile,
          username,
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
            host = hostname;
            inherit profile;
            inherit username;
            repoPath = inputs.self;
            zen-browser = inputs.zen-browser.packages.${system}.default;
            helium-browser = inputs.helium-browser.packages.${system}.helium-browser;
          };
          modules = [
            ./profiles/${profile}
          ];
        };

    in
    {
      nixosConfigurations = {
        # Default template configuration
        # Users will create their own host configurations during installation
        default = mkHost {
          hostname = "default";
          profile = "nvidia-laptop";
          username = "pok";
        };
      };

      # Flutter development environment
      devShells = (flake-utils.lib.eachDefaultSystem (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config = {
              android_sdk.accept_license = true;
              allowUnfree = true;
            };
          };
          buildToolsVersion = "33.0.2";
          androidComposition = pkgs.androidenv.composeAndroidPackages {
            buildToolsVersions = [ buildToolsVersion ];
            platformVersions = [ "33" ];
            abiVersions = [ "arm64-v8a" ];
          };
          androidSdk = androidComposition.androidsdk;
        in
        {
          devShells.default =
            with pkgs;
            mkShell rec {
              ANDROID_SDK_ROOT = "${androidSdk}/libexec/android-sdk";
              buildInputs = [
                flutter
                androidSdk
                jdk21
              ];
            };
        }
      )).devShells;
    };
}

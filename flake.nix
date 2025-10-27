# =====================================================================
# ❄️ Flake Entry Point
# ---------------------------------------------------------------------
# This file ties together system (hosts/*) and user (home/*) configs.
# Each host is defined under `nixosConfigurations.<hostname>`.
# Run with:
#   sudo nixos-rebuild switch --flake .#zodiac-laptop
# =====================================================================


{
  description = "NixOS + Home Manager setup for zodiac";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations = {
        # Laptop host
        zodiac-laptop = nixpkgs.lib.nixosSystem {
          inherit system;

          modules = [
            ./host/zodiac-laptop/configuration.nix # ✅ Machine-specific setup (boot, DE, drivers, etc.)
            ./modules/common.nix # ✅ Shared CLI tools (git, curl, htop, etc.)
            ./modules/neovim.nix # ✅ Editor setup shared by all systems.

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.zodiac = import ./home/zodiac.nix;
            }

            # ✅ Allow unfree packages properly here instead of specialArgs.pkgs
            {
              nixpkgs.config.allowUnfree = true;
            }
          ];

          # ✅ Pass only `inputs` as specialArgs (not pkgs)
          specialArgs = { inherit inputs; };
        };

        # Server host
        zodiac-server = nixpkgs.lib.nixosSystem {
          inherit system;

          modules = [
            ./host/server/configuration.nix
            ./modules/common.nix
            {
              nixpkgs.config.allowUnfree = true;
            }
          ];

          specialArgs = { inherit inputs; };
        };
      };
    };
}

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
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      nixosConfigurations = {
        # Host
        zodiac-laptop = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs pkgs;
          };

          modules = [
            ./host/zodiac-laptop/configuration.nix
            ./modules/common.nix
            # ./modules/nixvim.nix    # ✅ include nixvim here
            ./modules/neovim.nix  # ✅ new simplified neovim module

            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.zodiac = import ./home/zodiac.nix;
            }
          ];
        };

        zodiac-server = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs pkgs;
          };

          modules = [
            ./host/server/configuration.nix
            ./modules/common.nix
            # ❌ neovim and GUI apps not included here
          ];
        };
      };
    };
}

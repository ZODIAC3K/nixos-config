{ config, pkgs, ... }:

{

  imports = [
    # ./nixvim.nix
     ./neovim.nix
  ];

  # Add base tools that every host should have
  environment.systemPackages = with pkgs; [
    wget
    curl
    git
    htop
    fastfetch
    zsh
    neovim
  ];
}

{ config, pkgs, ... }:

{
  home.username = "zodiac";
  home.homeDirectory = "/home/zodiac";

  programs.home-manager.enable = true;
  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    vscode-fhs
    git
    htop
    fastfetch
    discord
    code-cursor-fhs
    spotify
    spotify-tray
    vlc
    obs-studio
    firefox-devedition
    chrome-token-signing
    postman
  ];

  # Environment variables
  home.sessionVariables = {
    EDITOR = "code --wait";
    VISUAL = "code --wait";
  };

  # Hyprland setup (base)
  wayland.windowManager.hyprland = {
    enable = true;
    # You can later add keybinds, monitor layout, gaps, etc.
  };

  # Enable Waybar, Rofi, Hyprcursor, Hyperpaper later
  # We’ll manage their configs in the next step when you’re ready.
}

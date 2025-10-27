# =====================================================================
# 👤 Home Manager Configuration — zodiac
# ---------------------------------------------------------------------
# This file defines settings that apply only to the user “zodiac”.
# 
# 💡 Think of this like your personal layer on top of NixOS:
#   - What programs *you* want installed (not system-wide)
#   - Your preferred terminal, text editor, and environment variables
#   - UI tweaks (themes, fonts, GTK, etc.)
#
# Each user on the same system can have their own version of this file.
# =====================================================================

{ config, pkgs, lib, unstable, ... }:

{
  # -----------------------------------------------------------
  # 🧱 Basic user info
  # -----------------------------------------------------------
  home.username = "zodiac";                # your Linux username
  home.homeDirectory = "/home/zodiac";     # your home folder path
  programs.home-manager.enable = true;     # enables Home Manager features
  home.stateVersion = "25.05";             # DO NOT CHANGE unless you know why!

  # ===========================================================
  # 🧩 Packages (apps installed only for this user)
  # ===========================================================
  home.packages = with pkgs; [
    discord
    spotify
    vlc
    obs-studio
    firefox-devedition
    postman
    unstable.vscode-fhs      # From unstable channel
    unstable.code-cursor-fhs  # From unstable channel
    spotify-tray
    chrome-token-signing
    neovim
    nano

    # Custom helper script to safely open VSCode as root
    (writeShellScriptBin "root-code" ''
      #!/bin/bash
      if [ $# -lt 1 ]; then
        echo "Usage: root-code <file>"
        exit 1
      fi
      FILE="$1"
      shift
      sudo code --no-sandbox --user-data-dir=/tmp/vscode "$FILE" "$@"
    '')
  ];

  # ===========================================================
  # 🌐 Browser preferences
  # ===========================================================
  programs.firefox.enable = false;  # disable default Firefox, we use Dev Edition
  xdg.mimeApps.defaultApplications = {
    "text/html" = "firefox-devedition.desktop";
    "x-scheme-handler/http" = "firefox-devedition.desktop";
    "x-scheme-handler/https" = "firefox-devedition.desktop";
    "x-scheme-handler/ftp" = "firefox-devedition.desktop";
    "x-scheme-handler/chrome" = "firefox-devedition.desktop";
  };

  # ===========================================================
  # 🧠 Terminal and Editor setup
  # ===========================================================
  programs.kitty = {
    enable = true;          # enable Kitty terminal
    settings = {
      font_size = 14;       # default terminal font size
    };
  };

  # Default text editors for the system
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # ===========================================================
  # ⚙️ Shell (bash) customizations
  # ===========================================================
  programs.bash = {
    enable = true;   # use Bash as shell
    initExtra = ''
      # “root” helper command:
      # - If you run `root code file`, it opens VSCode as root
      # - If you run `root apt install xyz`, it just runs `sudo apt install xyz`
      root() {
        if [ "$1" = "code" ]; then
          shift
          root-code "$@"
        else
          sudo "$@"
        fi
      }
    '';
  };

  # ===========================================================
  # 🖼️ Hyprland (Wayland setup)
  # ===========================================================
  wayland.windowManager.hyprland = {
    enable = true;  # enables Hyprland window manager
    # Add your keybinds, monitor layout, gaps, etc. later
  };

  # ===========================================================
  # 🚀 Future setup placeholders
  # ===========================================================
  # TODO:
  # - Add waybar, rofi, hyprcursor, and hyprpaper configuration
  # - Add GTK/Qt theme and cursor customization
}

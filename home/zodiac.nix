# =====================================================================
# 👤 Home Manager Configuration — zodiac
# ---------------------------------------------------------------------
# This file defines settings that apply only to the user "zodiac".
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

  # -----------------------------------------------------------
  # 📦 Import modular configurations
  # -----------------------------------------------------------
  imports = [
    ../modules/shell
    ../modules/terminal
    ../modules/browser
    ../modules/hyprland
    ../modules/waybar
    ../modules/gtk
  ];

  # -----------------------------------------------------------
  # 📦 User Packages
  # -----------------------------------------------------------
  # These packages are installed for the zodiac user only.
  home.packages = with pkgs; [
    # Media & Communication
    discord
    spotify
    vlc
    obs-studio
    spotify-tray
    
    # Browsers
    firefox-devedition
    chrome-token-signing
    
    # Development Tools
    postman
    unstable.vscode-fhs      # From unstable channel
    unstable.code-cursor-fhs  # From unstable channel
    neovim
    nano
    
    # Programming Languages & Builders
    jdk21                    # Latest Java (JDK 21 LTS)
    python3                  # Latest Python
    gcc                      # C/C++ compiler
    gnumake                  # Make build tool
    cmake                    # CMake build system
    
    # Docker (CLI + Compose + Buildx + Lazydocker)
    # Note: Docker Desktop is Windows/macOS only. On Linux, these tools provide full functionality.
    docker
    docker-compose
    docker-buildx
    lazydocker              # Terminal UI for Docker
    
    # ===========================================================
    # 🪟 Hyprland + Wayland Essentials
    # ===========================================================
    
    # --- Core Hyprland ecosystem ---
    hyprpaper              # 🖼️ Wallpaper manager for Hyprland
    rofi-wayland            # 🚀 App launcher (Wayland version)
    waybar                  # 🧭 Top/bottom bar for Hyprland
    swww                    # 🌀 Animated wallpaper transitions
    mako                    # 🔔 Notification daemon (Wayland)
    wl-clipboard            # 📋 Clipboard (wl-copy / wl-paste)
    grim                    # 📸 Screenshot utility
    slurp                   # ✂️ Region selection (used with grim)
    wf-recorder             # 🎥 Screen recorder
    
    # --- Optional system helpers ---
    xfce.thunar              # 📁 File manager (XFCE)
    brightnessctl            # 💡 Brightness control
    pavucontrol              # 🔊 Audio control GUI
    playerctl                # 🎶 Media controller (for Waybar)
    pamixer                  # 🔉 CLI volume control
    networkmanagerapplet     # 🌐 Tray icon for NetworkManager
    blueman                  # 🔵 Bluetooth manager
    
    # --- Aesthetics / Themes ---
    bibata-cursors           # 🖱️ Cursor theme
    papirus-icon-theme       # 🧩 Icon pack
    lxappearance             # 🎨 GTK theme manager
    pkgs.libsForQt5.qt5ct    # 🎨 QT theme manager (QT5) - explicit reference needed
    
    # --- Portals / Integration ---
    xdg-desktop-portal-gtk
    xdg-desktop-portal-hyprland
    
    # Custom helper script to safely open VSCode as root
    (pkgs.writeShellScriptBin "root-code" ''
      #!/bin/bash
      if [ $# -lt 1 ]; then
        echo "Usage: root-code <file>"
        exit 1
      fi
      FILE="$1"
      shift
      sudo code --no-sandbox --user-data-dir=/tmp/vscode "$FILE" "$@"
    '')

    # Custom helper script to safely open Cursor as root
    (pkgs.writeShellScriptBin "root-cursor" ''
      #!/usr/bin/env bash

      if [ $# -lt 1 ]; then
        echo "Usage: root-cursor <file>"
        exit 1
      fi

      FILE="$1"
      shift

      # Preserve your DISPLAY and BROWSER so Electron can open the GUI
      sudo \
        -E \
        DISPLAY=$DISPLAY \
        XAUTHORITY=$XAUTHORITY \
        BROWSER=$BROWSER \
        cursor --no-sandbox --user-data-dir=/tmp/cursor-root "$FILE" "$@"
    '')


  ];
}
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
    ../modules/packages
    ../modules/shell
    ../modules/terminal
    ../modules/browser
    ../modules/hyprland
    ../modules/waybar
    ../modules/gtk
  ];
}

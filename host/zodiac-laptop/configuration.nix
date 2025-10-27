# =====================================================================
# 🖥️ NixOS System Configuration — zodiac-laptop
# ---------------------------------------------------------------------
# This file controls everything about your NixOS system itself:
#
# 💡 Think of this as the “Operating System” layer.
# It defines:
#   • How your system boots and detects hardware
#   • Internet, audio, and display settings
#   • Which desktop (like GNOME or KDE) is used
#   • What programs are available to *all users*
#   • Which users exist on the system
#
# Every computer can have its own version of this file.
# =====================================================================

{ config, pkgs, lib, ... }:

{
  # -----------------------------------------------------------
  # 🧩 Import hardware configuration
  # -----------------------------------------------------------
  # This file is auto-generated when you install NixOS.
  # It contains driver and hardware setup (disks, GPUs, etc.).
  imports = [ ./hardware-configuration.nix ];

  # -----------------------------------------------------------
  # ⚙️ Bootloader
  # -----------------------------------------------------------
  # This tells your system how to start (boot) NixOS.
  # GRUB is the program that appears when you power on your PC.
  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";       # Replace if your main disk differs (e.g. /dev/nvme0n1)
    useOSProber = true;        # Detects Windows or other OS installations
  };

  # -----------------------------------------------------------
  # 🌐 Networking
  # -----------------------------------------------------------
  # Sets your system name and enables easy Wi-Fi/Ethernet management.
  networking.hostName = "nixos";       # You can rename this to anything
  networking.networkmanager.enable = true;

  # -----------------------------------------------------------
  # 🕒 Time & Language
  # -----------------------------------------------------------
  # Defines your timezone and regional preferences.
  time.timeZone = "Asia/Kolkata";
  i18n = {
    defaultLocale = "en_IN";           # Main language (English, India)
    extraLocaleSettings = {
      LC_TIME = "en_IN";               # Date/time format
      LC_NUMERIC = "en_IN";            # Number format
      LC_MONETARY = "en_IN";           # Currency format
      # ... (you can tweak these for your country)
    };
  };

  # -----------------------------------------------------------
  # 🧠 Nix Configuration
  # -----------------------------------------------------------
  # Enables advanced Nix features and keeps the system tidy.
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];  # Needed for flakes & new CLI
    auto-optimise-store = true;                         # Saves disk space by de-duplicating files
  };

  # -----------------------------------------------------------
  # 🖼️ Desktop Environment (GNOME)
  # -----------------------------------------------------------
  # Enables the graphical interface (X11 + GNOME).
  # If you want Hyprland or KDE later, you can replace this section.
  services.xserver = {
    enable = true;                     # Enables graphical mode
    displayManager.gdm.enable = true;  # GNOME Display Manager (login screen)
    desktopManager.gnome.enable = true;
    xkb.layout = "us";                 # Keyboard layout
  };

  # -----------------------------------------------------------
  # 🔊 Audio (PipeWire)
  # -----------------------------------------------------------
  # Handles all sound and microphone input.
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;               # PulseAudio compatibility
  };
  security.rtkit.enable = true;        # Needed for audio scheduling
  services.pulseaudio.enable = false;  # Disable old PulseAudio (we use PipeWire)

  # -----------------------------------------------------------
  # 👤 User Accounts
  # -----------------------------------------------------------
  # Creates your main user and gives admin (sudo) access.
  users.users.zodiac = {
    isNormalUser = true;                        # Regular user (not system)
    description = "zodiac";                     # Optional full name
    extraGroups = [ "networkmanager" "wheel" "docker" ]; # "wheel" allows using sudo, "docker" for Docker access
  };

  # -----------------------------------------------------------
  # 🐳 Docker
  # -----------------------------------------------------------
  # Enables Docker containerization engine and daemon.
  virtualisation.docker = {
    enable = true;
    daemon.settings = {};      # Allows custom daemon settings
  };

  # -----------------------------------------------------------
  # 📦 System Packages
  # -----------------------------------------------------------
  # These programs are installed for *everyone* on the system.
  environment.systemPackages =
    with pkgs; [
      git
      curl
      wget
      # Add basic CLI tools you want system-wide here
    ]
    # Kitty only if you have a graphical desktop
    ++ (lib.optional (config.services.xserver.enable or false) kitty)
    # Use Neovim/Nano only if you don’t have a GUI
    ++ (lib.optional (!(config.services.xserver.enable or false)) [ neovim nano ]);

  # -----------------------------------------------------------
  # 🔓 Allow Unfree Packages
  # -----------------------------------------------------------
  # Enables software with non-open-source licenses (e.g. Google Chrome, VSCode)
  nixpkgs.config.allowUnfree = true;

  # -----------------------------------------------------------
  # 🧱 System Version
  # -----------------------------------------------------------
  # This defines compatibility with your NixOS release.
  # Do NOT change unless upgrading your system manually.
  system.stateVersion = "25.05";
}

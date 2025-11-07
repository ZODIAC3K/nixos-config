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

{ config, pkgs, lib, unstable, ... }:

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
  # GRUB bootloader configuration
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    useOSProber = true;
  };
  boot.loader.efi.canTouchEfiVariables = true;
  
  # Kernel parameters
  boot.kernelParams = [ "amdgpu.backlight=0" "quiet" "splash" ];


  # --- Latest Kernel ---
  # Use latest stable kernel (or specify a specific LTS version like pkgs.linuxPackages_6_1)
  boot.kernelPackages = pkgs.linuxPackages_latest;

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
  # 🖼️ Desktop Environment (Hyprland + GNOME)
  # -----------------------------------------------------------
  # Enables Hyprland as primary window manager + keeps GNOME available.
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # # Keep GNOME available as a session option
  # services.xserver = {
  #   enable = true;
  #   displayManager.gdm = {
  #     enable = true;
  #     wayland = true;  # Enable both X11 and Wayland sessions
  #   };
  #   desktopManager.gnome.enable = true;
  #   xkb.layout = "us";
    
  #   # Explicitly set video drivers to prevent auto-detection
  #   # When videoDrivers is not set, NixOS/X server may auto-detect and try to load GPU drivers
  #   # Setting to empty list or "modesetting" prevents auto-detection of amdgpu/nvidia
  #   videoDrivers = [ "modesetting" ];  # Use generic modesetting driver, no GPU-specific drivers
  # };

    # Keep GNOME available as a session option
  services.xserver = {
    enable = true;
    displayManager.gdm = {
      enable = true;
      wayland = true;  # Enable both X11 and Wayland sessions
    };
    desktopManager.gnome.enable = true;
    xkb.layout = "us";
    
    # Explicitly set video drivers to prevent auto-detection
    # When videoDrivers is not set, NixOS/X server may auto-detect and try to load GPU drivers
    # Setting to empty list or "modesetting" prevents auto-detection of amdgpu/nvidia
    # videoDrivers = [ "modesetting" ];  # Use generic modesetting driver, no GPU-specific drivers
  };

  # Enable GNOME Keyring for libsecret integration
  services.gnome.gnome-keyring.enable = true;

  # Ensure PAM unlocks the keyring automatically on login
  security.pam.services.gdm.enableGnomeKeyring = true;
  security.pam.services.login.enableGnomeKeyring = true;
  
  services.dbus.packages = [ pkgs.gnome-keyring pkgs.libsecret ];



  
  # Set GNOME as default session (Hyprland still available)
  services.displayManager.defaultSession = "gnome";

  # Required for Hyprland
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
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
    
    # 🔐 Password & UID
    # Option 1: Set password hash here (generate with: mkpasswd -m sha-512)
   initialPassword = "zodiac";              # Temporary password (change after first login!)
    
    # Option 2: Set password after first build:
    #   sudo passwd zodiac
    
    # Optional: Set a specific UID (default: auto-assigned)
    # uid = 1000;                                 # Uncomment and set desired UID
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
  # 🎮 GPU Hardware Configuration (AMD + NVIDIA + PRIME)
  # -----------------------------------------------------------
  # AMD GPU: Integrated GPU (Cezanne [Radeon Vega])
  # NVIDIA GPU: Dedicated GPU (GeForce RTX 3060 Mobile)
  # PRIME: Offload rendering to NVIDIA GPU while using AMD for display
  
  # OpenGL/Vulkan support
  hardware.opengl = {
    enable = true;
    package = unstable.mesa;
    extraPackages = with unstable; [
      mesa
      vulkan-loader
      vulkan-validation-layers
    ];
  };

  # AMD GPU driver
  services.xserver.videoDrivers = [ "amdgpu" "nvidia" ];
  boot.initrd.kernelModules = [ "amdgpu" ];

  # NVIDIA proprietary drivers
  hardware.nvidia = {
    # Enable NVIDIA drivers
    modesetting.enable = true;
    powerManagement.enable = true;
    powerManagement.finegrained = false;
    open = false;  # Use proprietary drivers (not open-source Nouveau)
    nvidiaSettings = true;  # Installs nvidia-settings for GUI tweaks
    package = config.boot.kernelPackages.nvidiaPackages.production;
    
    # NVIDIA PRIME (offload rendering to NVIDIA GPU)
    # AMD GPU handles display, NVIDIA GPU handles rendering
    prime = {
      # AMD GPU (integrated GPU) - PCI:6:0:0
      amdgpuBusId = "PCI:6:0:0";
      # NVIDIA GPU (dedicated GPU) - PCI:1:0:0
      nvidiaBusId = "PCI:1:0:0";
    };
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
      pciutils  # lspci command for hardware detection
      # Add basic CLI tools you want system-wide here
      glxinfo
    ]
    # Kitty only if you have a graphical desktop
    ++ (lib.optional (config.services.xserver.enable or false) kitty)
    # Use Neovim/Nano only if you don't have a GUI
    ++ (lib.optional (!(config.services.xserver.enable or false)) [ neovim nano ]);

  # -----------------------------------------------------------
  # 🔓 Allow Unfree Packages
  # -----------------------------------------------------------
  # Enables software with non-open-source licenses (e.g. Google Chrome, VSCode, NVIDIA drivers)
  # Note: CUDA support is automatically included with NVIDIA drivers package
  nixpkgs.config.allowUnfree = true;

  # -----------------------------------------------------------
  # 🧱 System Version
  # -----------------------------------------------------------
  # This defines compatibility with your NixOS release.
  # Do NOT change unless upgrading your system manually.
  system.stateVersion = "25.05";
}

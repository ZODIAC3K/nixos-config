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
  # 🖼️ Desktop Environment (Hyprland + GNOME)
  # -----------------------------------------------------------
  # Enables Hyprland as primary window manager + keeps GNOME available.
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Keep GNOME available as a session option
  services.xserver = {
    enable = true;
    displayManager.gdm = {
      enable = true;
      wayland = true;  # Enable both X11 and Wayland sessions
    };
    desktopManager.gnome.enable = true;
    xkb.layout = "us";
  };

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
  # 🎮 Hybrid GPU Configuration (AMD + NVIDIA)
  # -----------------------------------------------------------
  # Supports hybrid laptop with AMD integrated/GPU + NVIDIA dedicated GPU.
  # AMD handles display output; NVIDIA available for compute/CUDA tasks.
  
  # Enable AMD GPU kernel support
  boot.initrd.kernelModules = [ "amdgpu" ];
  
  # AMD GPU userspace (OpenGL/Vulkan) - using Mesa from unstable for bleeding-edge
  # Optionally use stable Mesa: hardware.opengl.package = pkgs.mesa.drivers;
  hardware.opengl = {
    enable = true;
    package = unstable.mesa.drivers;  # Mesa 25.2.6+ from nixos-unstable (optional: use pkgs.mesa.drivers for stable)
    driSupport = true;
    driSupport32Bit = true;
  };
  
  # NVIDIA proprietary drivers for 3D acceleration, Vulkan, and CUDA support
  services.xserver.videoDrivers = [ "nvidia" ];
  
  hardware.nvidia = {
    # Enable NVIDIA drivers
    modesetting.enable = true;
    
    # Enable power management (fixes some issues with hybrid graphics)
    powerManagement.enable = true;
    
    # Enable NVIDIA power management (recommended for laptops)
    powerManagement.finegrained = false;
    
    # Enable OpenGL support
    open = false;  # Use proprietary drivers (not open-source Nouveau)
    
    # Enable CUDA support
    nvidiaSettings = true;  # Installs nvidia-settings for GUI tweaks
    
    # Package set for NVIDIA drivers and CUDA
    package = config.boot.kernelPackages.nvidiaPackages.production;
  };
  
  # NVIDIA PRIME (offload rendering to NVIDIA GPU)
  # By default DISABLED - system uses AMD for display, NVIDIA for compute only.
  # Uncomment below to enable GPU offloading (more complex, requires runtime setup):
  # hardware.nvidia.prime = {
  #   # AMD GPU (usually the integrated GPU)
  #   amdgpuBusId = "PCI:1:0:0";  # Find with: lspci | grep -i vga
  #   # NVIDIA GPU (usually the dedicated GPU)
  #   nvidiaBusId = "PCI:2:0:0";  # Find with: lspci | grep -i nvidia
  # };
  
  # CUDA support (for compute tasks)
  hardware.nvidia.cudaSupport = true;
  
  # -----------------------------------------------------------
  # 🔓 Allow Unfree Packages
  # -----------------------------------------------------------
  # Enables software with non-open-source licenses (e.g. Google Chrome, VSCode, NVIDIA drivers)
  nixpkgs.config.allowUnfree = true;

  # -----------------------------------------------------------
  # 🧱 System Version
  # -----------------------------------------------------------
  # This defines compatibility with your NixOS release.
  # Do NOT change unless upgrading your system manually.
  system.stateVersion = "25.05";
}

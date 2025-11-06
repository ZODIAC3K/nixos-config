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

let
  # -----------------------------------------------------------
  # 🖥️ VM & GPU Hardware Detection
  # -----------------------------------------------------------
  # VM Detection: Check hardware-configuration.nix for VM-specific modules
  # VM kernels typically include: ata_piix, mptspi (VMware/VirtualBox)
  # Your hardware-configuration.nix shows: "ata_piix" "mptspi" → VM detected
  
  # VM Detection flags - set manually or auto-detect via hardware-config
  # Check your hardware-configuration.nix: if you see "ata_piix" or "mptspi", it's a VM
  # Since hardware-config shows VM modules, you're in a VM - set to true
  isVMware = true;      # Set to false if bare metal
  isVirtualBox = false;  # Set to true if VirtualBox, false for VMware
  isVM = isVMware || isVirtualBox;
  
  # GPU Hardware Detection - AUTOMATIC
  # Automatically enables GPU drivers based on environment:
  # - In VM: Both GPUs disabled (blacklisted to prevent crashes)
  # - On Bare Metal: Both GPUs enabled (kernel will auto-detect available hardware)
  # 
  # The kernel will automatically load the appropriate drivers for detected hardware.
  # If you have AMD GPU → AMD driver loads, NVIDIA driver stays inactive
  # If you have NVIDIA GPU → NVIDIA driver loads, AMD driver stays inactive  
  # If you have BOTH → Both drivers load (hybrid setup)
  
  # Automatic detection: Enable on bare metal, disable in VM
  hasAMDGPU = !isVM;      # Automatically enable AMD GPU drivers on bare metal
  hasNVIDIAGPU = !isVM;   # Automatically enable NVIDIA GPU drivers on bare metal
  
  # Detection summary for display during rebuild
  vmStatus = if isVMware then "VMware VM"
            else if isVirtualBox then "VirtualBox VM"
            else "Bare Metal";
  
  gpuStatus = lib.concatStringsSep ", " (
    lib.optional hasAMDGPU "AMD GPU" ++
    lib.optional hasNVIDIAGPU "NVIDIA GPU" ++
    lib.optional (!hasAMDGPU && !hasNVIDIAGPU) "No GPU drivers"
  );
  
  # GPU detection details
  amdStatus = if hasAMDGPU then "✅ Enabled" else "❌ Disabled (blacklisted)";
  nvidiaStatus = if hasNVIDIAGPU then "✅ Enabled" else "❌ Disabled (blacklisted)";
  
  # Print detection results during evaluation
  # Force evaluation by using it in an assertion
  _ = builtins.trace ''
    ════════════════════════════════════════════════════════════
    🔍 Hardware Detection Results:
    ════════════════════════════════════════════════════════════
    🖥️  Environment:        ${vmStatus}
    🎮 GPU Detection Logic:
       • AMD GPU Driver:    ${amdStatus}
       • NVIDIA GPU Driver: ${nvidiaStatus}
    📦 GPU Drivers Enabled: ${gpuStatus}
    ════════════════════════════════════════════════════════════
    💡 Note: On bare metal, GPU drivers are enabled automatically.
       Kernel will auto-detect and load appropriate drivers for available hardware.
    ════════════════════════════════════════════════════════════
  '' null;
in
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
  # GRUB bootloader is disabled
  # boot.loader.grub = {
  #   enable = true;
  #   device = "/dev/sda";       # Replace if your main disk differs (e.g. /dev/nvme0n1)
  #   useOSProber = true;        # Detects Windows or other OS installations
  # };
  boot.loader.grub.enable = false;

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
  # 🖥️ VM Tools Configuration
  # -----------------------------------------------------------
  # Enable VM tools based on detected VM type
  virtualisation.vmware.guest.enable = isVMware;  # VMware guest tools
  
  # VirtualBox guest additions
  virtualisation.virtualbox.guest.enable = isVirtualBox;  # VirtualBox guest additions

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
    ]
    # Kitty only if you have a graphical desktop
    ++ (lib.optional (config.services.xserver.enable or false) kitty)
    # Use Neovim/Nano only if you don't have a GUI
    ++ (lib.optional (!(config.services.xserver.enable or false)) [ neovim nano ]);

  # -----------------------------------------------------------
  # 🎮 GPU Hardware Detection & Configuration
  # -----------------------------------------------------------
  # GPU drivers are DISABLED by default - enable manually based on detection output
  # Mesa (graphics library) is always enabled for basic graphics support.
  #
  # To detect your GPUs, run: lspci | grep -iE "vga|3d|display"
  # Look for entries like:
  #   - AMD/ATI devices → enable AMD drivers
  #   - NVIDIA devices → enable NVIDIA drivers
  #
  # Check the detection output when rebuilding to see what was detected!
  #
  # ⚠️  ON BARE METAL: You MUST enable GPU drivers for hardware acceleration!
  #   1. Set isVMware = false; (line 30)
  #   2. Detect GPUs: lspci | grep -iE "vga|3d|display"
  #   3. Uncomment the appropriate GPU driver section below
  #   4. Remove amdgpu/radeon from blacklist below (if you have AMD GPU)
  #
  
  # Explicitly blacklist GPU modules to prevent auto-loading and crashes
  # ✅ CONDITIONAL BLACKLIST: Only blacklists GPUs when disabled (e.g., in VM)
  # When hasAMDGPU/hasNVIDIAGPU = true (bare metal), blacklist is disabled so drivers can load
  # Multiple layers of blacklisting to ensure it NEVER loads, even if hardware is detected:
  # 1. Kernel module blacklist (prevents loading via modprobe)
  # 2. Initrd blacklist (prevents loading during early boot/initrd)
  # 3. Modprobe blacklist with install hook (prevents loading via ANY means including hardware detection)
  
  # AMD GPU blacklist - only active when hasAMDGPU = false
  boot.blacklistedKernelModules = lib.mkMerge [
    (lib.mkIf (!hasAMDGPU) [ 
      "amdgpu"      # Modern AMD GPU driver
      "radeon"      # Legacy AMD/ATI GPU driver (prevent legacy detection)
    ])
    (lib.mkIf (!hasNVIDIAGPU) [
      "nvidia"      # NVIDIA proprietary driver
      "nvidia_drm"  # NVIDIA DRM/KMS driver
      "nvidia_modeset"  # NVIDIA mode setting
      "nvidia_uvm"  # NVIDIA unified memory (CUDA)
      "nouveau"     # Open-source NVIDIA driver (blacklist when using proprietary)
    ])
  ];
  
  
  # Modprobe blacklist - CONDITIONAL: Only active when GPUs are disabled
  # The "install <module> /bin/false" prevents the kernel from loading it even if hardware is detected
  # This creates /etc/modprobe.d/blacklist.conf
  boot.extraModprobeConfig = lib.concatStringsSep "\n" (
    lib.optional (!hasAMDGPU) ''
      # Blacklist AMD GPU modules to prevent crashes in VM/bare metal without AMD GPU
      # The kernel may still detect virtual GPU hardware and try to load these modules
      # These rules prevent that from happening
      blacklist amdgpu
      blacklist radeon
      install amdgpu /bin/false
      install radeon /bin/false
    '' ++
    lib.optional (!hasNVIDIAGPU) ''
      # Blacklist NVIDIA GPU modules to prevent loading when NVIDIA GPU is disabled
      blacklist nvidia
      blacklist nvidia_drm
      blacklist nvidia_modeset
      blacklist nvidia_uvm
      blacklist nouveau
      install nvidia /bin/false
      install nvidia_drm /bin/false
      install nvidia_modeset /bin/false
      install nvidia_uvm /bin/false
      install nouveau /bin/false
    ''
  );
  
  # dm_mod (device mapper) - blacklist if not needed
  # Remove "dm_mod" from blacklist if you use LVM or other device mapper features
  # boot.blacklistedKernelModules = [ "amdgpu" "dm_mod" ];
  # boot.initrd.blacklistedKernelModules = [ "amdgpu" "dm_mod" ];
  
  # AMD GPU kernel module - ENABLED
  # Note: Remove amdgpu from blacklist above if needed (done below)
  boot.initrd.kernelModules = lib.mkMerge [
    (lib.mkIf hasAMDGPU [ "amdgpu" ])
  ];
  
  # Mesa graphics library - always enabled (needed for basic graphics)
  # AMD GPU userspace (OpenGL/Vulkan) - using Mesa from unstable for bleeding-edge
  # Optionally use stable Mesa: hardware.graphics.package = pkgs.mesa;
  hardware.graphics = {
    enable = true;
    package = unstable.mesa;  # Mesa 25.2.6+ from nixos-unstable (optional: use pkgs.mesa for stable)
    enable32Bit = true;  # Enable 32-bit DRI support if needed
  };
  
  # NVIDIA proprietary drivers - ENABLED
  services.xserver.videoDrivers = lib.mkIf hasNVIDIAGPU [ "nvidia" ];
  
  hardware.nvidia = lib.mkIf hasNVIDIAGPU {
    # Enable NVIDIA drivers
    modesetting.enable = true;
    
    # Enable power management (fixes some issues with hybrid graphics)
    powerManagement.enable = true;
    
    # Enable NVIDIA power management (recommended for laptops)
    powerManagement.finegrained = false;
    
    # Enable OpenGL support
    open = false;  # Use proprietary drivers (not open-source Nouveau)
    
    # Enable CUDA support (installed with NVIDIA drivers)
    # CUDA is automatically included with nvidiaPackages.production
    nvidiaSettings = true;  # Installs nvidia-settings for GUI tweaks
    
    # Package set for NVIDIA drivers (includes CUDA support)
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

# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ../../modules/00-common
      ../../modules/01-jellyfin
      ../../modules/02-deluge
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.consoleMode = "max";  # Use highest resolution available
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 4; # Wait max 4 seconds before selecting latest revision

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "dellXps15-9530"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;  # Enable bluetooth on boot
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";  # Audio profiles
        Experimental = true;  # Better codec support
      };
    };
  };
  services.blueman.enable = true;  # Bluetooth manager GUI

  # Set your time zone.
  time.timeZone = "Asia/Kuala_Lumpur";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  
  # KDE Plasma customization packages and machine-specific packages
  environment.systemPackages = with pkgs; [
    # Theme dependencies
    kdePackages.qtstyleplugin-kvantum
    libsForQt5.qtstyleplugin-kvantum
    
    # Machine-specific packages
    spotify
    telegram-desktop
  ];
  
  # KDE Plasma screen lock - lock after 15 minutes of inactivity
  environment.etc."xdg/kscreenlockerrc".text = ''
    [Daemon]
    Autolock=true
    LockOnResume=true
    Timeout=15
  '';

  # KDE Plasma display power management
  # Matches KDE System Settings > Power Management
  environment.etc."xdg/powermanagementprofilesrc".text = ''
    [AC][DimDisplay]
    idleTime=300000

    [AC][DPMSControl]
    idleTime=900000
    lockBeforeTurnOff=900000

    [AC][HandleButtonEvents]
    lidAction=1
    powerButtonAction=8
    triggerLidActionWhenExternalMonitorPresent=false

    [AC][SuspendSession]
    idleTime=259200000
    suspendType=32

    [Battery][DimDisplay]
    idleTime=300000

    [Battery][DPMSControl]
    idleTime=900000
    lockBeforeTurnOff=900000

    [Battery][HandleButtonEvents]
    lidAction=1
    powerButtonAction=8
    triggerLidActionWhenExternalMonitorPresent=false

    [Battery][SuspendSession]
    idleTime=259200000
    suspendType=32

    [LowBattery][DimDisplay]
    idleTime=300000

    [LowBattery][DPMSControl]
    idleTime=900000
    lockBeforeTurnOff=900000

    [LowBattery][HandleButtonEvents]
    lidAction=1
    powerButtonAction=8
    triggerLidActionWhenExternalMonitorPresent=false

    [LowBattery][SuspendSession]
    idleTime=259200000
    suspendType=32
  '';

  # Lid close: lock screen and turn off display (never suspend/hibernate)
  # Prevents sleep/suspend/hibernate - keeps Jellyfin and other services running
  services.logind.settings.Login = {
    HandleLidSwitch = "lock";
    HandleLidSwitchExternalPower = "lock";
    HandleSuspendKey = "ignore";
    HandleHibernateKey = "ignore";
  };

  powerManagement.enable = true;

  # Hibernate after 1 hour of idle time
  ## boot.resumeDevice = "/dev/disk/by-uuid/6d04062b-faa4-4a00-a053-0f532e24139d"; # Swap partition for hibernate
  ## services.logind.extraConfig = ''
  ##   IdleAction=hibernate
  ##   IdleActionSec=1h
  ## '';

  # Dell XPS 15 9530 (2013) hardware configuration
  hardware = {
    # Enable all firmware (including WiFi/Bluetooth)
    enableAllFirmware = true;
    enableRedistributableFirmware = true;

    # Intel HD Graphics 4600
    graphics.enable = true;

    # NVIDIA GeForce GT 750M (Kepler) with Optimus
    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = true;  # Better battery life
      
      # Legacy driver for Kepler architecture
      package = config.boot.kernelPackages.nvidiaPackages.legacy_470;
      
      # NVIDIA Optimus PRIME configuration
      prime = {
        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
        
        # Bus IDs from lspci
        intelBusId = "PCI:0:2:0";   # 00:02.0
        nvidiaBusId = "PCI:2:0:0";  # 02:00.0
      };
    };
  };

  # Touchpad configuration
  services.libinput = {
    enable = true;
    touchpad = {
      tapping = true;
      naturalScrolling = false; # False = Windows-style scrolling, True = macOS-style scrolling
      disableWhileTyping = true;
      accelSpeed = "0.5";
    };
  };

  # Keyboard backlight persistence
  services.upower.enable = true;
  
  # Dell keyboard backlight settings
  boot.kernelModules = [ "dell-laptop" ];
  boot.extraModprobeConfig = ''
    options dell-laptop kbd_backlight=1
  '';

  # Load NVIDIA driver for X11
  services.xserver.videoDrivers = [ "nvidia" ];

  # Thermal management and power optimization
  services.thermald.enable = true;
  services.power-profiles-daemon.enable = false;  # Conflicts with TLP
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      
      # Battery charge thresholds (80% rule)
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };

  # Dell firmware updates
  services.fwupd.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  # Enable sound with pipewire.
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
    jack.enable = true;  # JACK support for pro audio
    
    # Low latency audio configuration
    extraConfig.pipewire = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.quantum" = 1024;
        "default.clock.min-quantum" = 512;
      };
    };
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.jason = {
    isNormalUser = true;
    description = "Jason K.";
    extraGroups = [ "networkmanager" "wheel" "media" ];
    # Password managed imperatively with: sudo passwd jason
    # Or use hashedPassword = "..." with output from: mkpasswd -m sha-512
    packages = with pkgs; [
      kdePackages.kate
    #  thunderbird
    ];
  };
  # Allow jason to run nixos-rebuild and nix commands without sudo password
  security.sudo.extraRules = [
    {
      users = [ "jason" ];    # Add users here, e.g. users = [ "jason" "alice" "bob" ];
      commands = [
        {
          command = "${pkgs.nixos-rebuild}/bin/nixos-rebuild";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # Trust jason for nix daemon operations
  nix.settings.trusted-users = [ "root" "jason" ];
  # Install Firefox.
  programs.firefox.enable = true;

  # Allow unfree packages (also set in 00-common, but kept for clarity)
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.nvidia.acceptLicense = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # Host-specific packages defined in modules/00-common
  # Machine-specific packages are defined above with systemPackages

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.mtr.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Enable Jellyfin media server
  myServices.jellyfin = {
    enable = true;
    openFirewall = true;  # Opens ports 8096, 8920, 1900, 7359
    watchUsername = "jason";  # User who manages media files
    mediaLibraries = [
      "/srv/media"
      "/srv/media/movies"
      "/srv/media/music"
    ];  # System media directory (FHS compliant)
  };

  # Enable Deluge BitTorrent client with VPN isolation
  myServices.deluge = {
    enable = true;
    declarative = true;
    dataDir = "/var/lib/deluge";
    
    config = {
      download_location = "/srv/torrents";
      allow_remote = true;
    };
    
    web = {
      enable = true;
      port = 8112;
      openFirewall = true;
    };
    
    vpn = {
      # enable = true;  # Already defaults to true
      configFile = "/root/wireguard.conf";
      ipv4Address = "10.8.0.2/24";  # Must match your VPN config
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = true;  # Keep firewall enabled for security

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?
}

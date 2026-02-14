# System-wide Nix configuration
{ config, pkgs, ... }:

{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable experimental features (flakes and nix-command)
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Automatic system upgrades for all machines
  system.autoUpgrade = {
    enable = true;                    # Enable automatic upgrades
    allowReboot = false;              # Don't auto-reboot
    dates = "daily";                  # Run daily at 04:00
    operation = "switch";             # Apply changes immediately
    
    flags = [
      "--update-input" "nixpkgs"           # Update stable channel
      "--commit-lock-file"                 # Save lock file changes
    ];
    
    # randomizedDelaySec = "1h";      # Optional: Add random delay
    persistent = true;              # Run missed upgrades after boot
  };

  # Automatic garbage collection
  nix.gc = {
    automatic = true;                 # Enable automatic GC
    dates = "weekly";                 # Run every 14 days (biweekly)
    options = "--delete-older-than 14d";  # Delete generations older than 14 days
  };

  # Keep only last 10 generations
  boot.loader.systemd-boot.configurationLimit = 10;

  # Automatic store optimization
  nix.optimise = {
    automatic = true;                 # Enable auto-optimization
    dates = [ "daily" ];              # Run daily, to increase/tone down this in the future
  };
}

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
}

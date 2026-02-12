# System-wide Nix configuration
{ config, pkgs, ... }:

{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable experimental features (flakes and nix-command)
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Automatic system upgrades for all machines
  system.autoUpgrade = {
    enable = true;              # Enable automatic upgrades
    allowReboot = false;        # Allow system to reboot after upgrade
    
    # dates = "04:00";           # When to run (systemd timer format)
                               # Examples: "daily", "weekly", "04:00", "Sun 03:00"
    
    # operation = "switch";      # What operation to perform
                               # Options: "switch", "boot", "test", "dry-activate"
    
    # flake = "github:user/repo"; # For flake-based configs (your case)
                                # Or: "/path/to/flake"
    
    # flags = [                   # Extra flags passed to nixos-rebuild
    #   "--update-input" "nixpkgs"
    #   "--commit-lock-file"
    # ];
    
    # randomizedDelaySec = "0";  # Random delay before upgrade (prevents all machines upgrading simultaneously)
                               # Example: "1h" = up to 1 hour delay
    
    # persistent = true;         # Run missed upgrades on next boot (if machine was off)
    
    # rebootWindow = {           # Control when reboots can happen (if allowReboot=true)
    ##   lower = "01:00";
    ##   upper = "05:00";
    # };
  };
}

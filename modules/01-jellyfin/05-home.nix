# Home Manager configuration for the jellyfin system user.
# Manages config files and environment for the jellyfin service user
# without touching the service definition (which lives in 04-service.nix).
{ config, lib, ... }:

with lib;

let
  cfg = config.myServices.jellyfin;
in
{
  config = mkIf cfg.enable {
    # Create the nix profile directory for jellyfin so home-manager activation
    # can find a writable profile path (/nix/var/nix/profiles/per-user/jellyfin).
    # The nix daemon normally creates this on first use, but jellyfin never runs nix.
    systemd.tmpfiles.rules = [
      "d /nix/var/nix/profiles/per-user/jellyfin 0755 jellyfin jellyfin -"
    ];

    home-manager.users.jellyfin = {
      # jellyfin's home is its data directory, created by services.jellyfin
      # mkForce overrides home-manager's default of /var/empty for system users
      home.homeDirectory = lib.mkForce cfg.dataDir;

      # Home Manager state version — keep in sync with system stateVersion
      home.stateVersion = config.system.stateVersion;
    };
  };
}

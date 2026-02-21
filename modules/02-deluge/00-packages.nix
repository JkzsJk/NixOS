# Deluge packages
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.myServices.deluge;
in
{
  config = mkIf cfg.enable {
    # Set default deluge package based on stateVersion
    myServices.deluge.package = mkDefault (
      if versionAtLeast config.system.stateVersion "20.09" then
        pkgs.deluge-2_x
      else
        # deluge-1_x is no longer packaged and this will resolve to an error
        # thanks to the alias for this name. This is left here so that anyone
        # using NixOS older than 20.09 receives that error when they upgrade
        # and is forced to make an intentional choice to switch to deluge-2_x.
        pkgs.deluge-1_x
    );

    # Provide a default set of extraPackages for extraction plugins
    myServices.deluge.extraPackages = with pkgs; [
      unzip
      gnutar
      xz
      bzip2
    ];

    # Add deluge to system packages
    environment.systemPackages = [ cfg.package ];
  };
}

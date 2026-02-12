# Common system packages for all machines
{ config, pkgs, ... }:

{
  # Add Jellyfin and utilities to system packages
  environment.systemPackages = with pkgs; [
    jellyfin
    jellyfin-ffmpeg
  ];
}

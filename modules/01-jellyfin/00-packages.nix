# Common system packages for all machines
{ config, pkgs, inputs, ... }:

{
  # Add Jellyfin and utilities to system packages
  environment.systemPackages = with pkgs; [
    jellyfin
    jellyfin-ffmpeg
  ];
}

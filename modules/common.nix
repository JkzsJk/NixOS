# Shared configuration across all hosts
{ config, pkgs, ... }:

{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Common packages for all machines
  environment.systemPackages = with pkgs; [
    wget
    curl
    vivaldi
    vscode
    git
    tmux
    warp-terminal
    openssh
    rquickshare
    zoxide
    fzf
  ];
}

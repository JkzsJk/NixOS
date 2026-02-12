# Common system packages for all machines
{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Core utilities
    vim
    wget
    curl
    git
    tmux
    openssh
    
    # Desktop applications
    vivaldi
    vscode
    warp-terminal
    
    # CLI tools and utilities
    rquickshare
    zoxide
    fzf
    home-manager
    pciutils        # lspci for hardware info
    
    # Cloud/Container tools
    k9s
    cloudlens       # K9s like CLI for AWS and GCP
    
    # Shell customization
    starship        # Modern, fast shell prompt with powerline-like features
  ];
}

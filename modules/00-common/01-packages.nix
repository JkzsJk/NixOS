# Common system packages for all machines
{ config, pkgs, inputs, ... }:

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
    neofetch        # System info display
    
    # Cloud/Container tools
    k9s
    cloudlens       # K9s like CLI for AWS and GCP
    
    # Shell customization
    starship        # Modern, fast shell prompt with powerline-like features
  ];

  # Configure VSCode to use KWallet6 for all managed users.
  # Without this VSCode falls back to a plain-text credential store on Wayland.
  home-manager.sharedModules = [{
    home.file.".vscode/argv.json" = {
      force = true;
      text = builtins.toJSON {
        "password-store" = "kwallet6";
      };
    };
  }];
}

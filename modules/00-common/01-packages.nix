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

  # Configure VSCode for all managed users via home-manager.
  # pkgs.vscode.fhs wraps VSCode in an FHS environment so native extension
  # binaries (language servers, debuggers, etc.) work on NixOS.
  # argv.json is written after home-manager's writeBoundary so it merges safely.
  home-manager.sharedModules = [({ lib, ... }: {
    programs.vscode = {
      enable = true;
      package = pkgs.vscode.fhs;
    };

    # Set password-store=kwallet6 in argv.json.
    # Runs after home-manager writes files to avoid symlink conflicts.
    home.activation.vscodeArgvJson = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p "$HOME/.vscode"
      if [ ! -f "$HOME/.vscode/argv.json" ] || ! grep -q "password-store" "$HOME/.vscode/argv.json" 2>/dev/null; then
        echo '{ "password-store": "kwallet6" }' > "$HOME/.vscode/argv.json"
      fi
    '';
  })];
}

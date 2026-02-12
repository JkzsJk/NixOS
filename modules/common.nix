# Shared configuration across all hosts
{ config, pkgs, ... }:

{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable experimental features (flakes and nix-command)
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Set Zsh as default shell for all users
  users.defaultUserShell = pkgs.zsh;

  # Set Vivaldi as default browser
  environment.sessionVariables.BROWSER = "vivaldi";
  xdg.mime.defaultApplications = {
    "text/html" = "vivaldi-stable.desktop";
    "x-scheme-handler/http" = "vivaldi-stable.desktop";
    "x-scheme-handler/https" = "vivaldi-stable.desktop";
    "x-scheme-handler/about" = "vivaldi-stable.desktop";
    "x-scheme-handler/unknown" = "vivaldi-stable.desktop";
  };
  
  # Set Warp as default terminal
  environment.sessionVariables.TERMINAL = "warp-terminal";

  # Common packages for all machines
  environment.systemPackages = with pkgs; [
    vim
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
    home-manager
    pciutils        # lspci for hardware info
    k9s
    cloudlens       # K9s like CLI for AWS and GCP

  ];

  # Configure zoxide and fzf for all shells
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    interactiveShellInit = ''
      # Initialize fzf
      source ${pkgs.fzf}/share/fzf/completion.zsh
      source ${pkgs.fzf}/share/fzf/key-bindings.zsh
    '';
    promptInit = ''
      # Initialize zoxide with cd command override (must be last)
      eval "$(${pkgs.zoxide}/bin/zoxide init --cmd cd zsh)"
    '';
  };

  programs.bash = {
    interactiveShellInit = ''
      # Initialize fzf
      source ${pkgs.fzf}/share/fzf/completion.bash
      source ${pkgs.fzf}/share/fzf/key-bindings.bash
    '';
    promptInit = ''
      # Initialize zoxide with cd command override (must be last)
      eval "$(${pkgs.zoxide}/bin/zoxide init --cmd cd bash)"
    '';
  };

  programs.fish = {
    interactiveShellInit = ''
      # Initialize fzf
      source ${pkgs.fzf}/share/fzf/key-bindings.fish
    '';
    promptInit = ''
      # Initialize zoxide with cd command override (must be last)
      ${pkgs.zoxide}/bin/zoxide init --cmd cd fish | source
    '';
  };

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

  # Home Manager configuration for all users
  home-manager.sharedModules = [
    {
      # Warp terminal configuration (applies to all users)
      home.file.".warp/launch_configurations/default.yaml".text = ''
        name: Default
        shell:
          program: ${pkgs.zsh}/bin/zsh
      '';

      home.file.".warp/user_preferences.json".text = builtins.toJSON {
        auto_update = true;
        shell = "${pkgs.zsh}/bin/zsh";
      };
    }
  ];

  home-manager.users = {
    jason = { pkgs, ... }: {
      home.packages = with pkgs; [
        # User-specific packages can go here
      ];

      # Shell configuration
      programs.zsh = {
        enable = true;
        enableCompletion = true;
      };

      programs.bash.enable = true;

      # Git configuration
      programs.git = {
        enable = true;
        userName = "JkzsJk";
        userEmail = "jasonkhorzs@outlook.com";
      };

      # Home Manager state version
      home.stateVersion = "25.11";
    };
  };
}

# Home Manager configuration for jason
# Managed from flake.nix — do not import this file directly.
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # User-specific packages can go here
    btop
  ];

  # Default editor and terminal
  home.sessionVariables = {
    EDITOR = "vim";
    VISUAL = "vim";
    TERMINAL = "warp-terminal";
  };

  # Warp terminal configuration
  home.file.".warp/launch_configurations/default.yaml".text = ''
    name: Default
    shell:
      program: ${pkgs.zsh}/bin/zsh
  '';

  home.file.".warp/user_preferences.json".text = builtins.toJSON {
    auto_update = false; # Disable because it's just how Nix works.
    shell = "${pkgs.zsh}/bin/zsh";
  };

  # Shell configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
  };

  programs.bash.enable = true;

  # Git configuration
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "JkzsJk";
        email = "jasonkhorzs@outlook.com";
      };
    };
  };

  home.stateVersion = "25.11";

  # Starship prompt — Powerline-inspired
  home.file.".config/starship.toml".text = ''
    "$schema" = 'https://starship.rs/config-schema.json'

    format = """
    [╭─](bold green)$username$hostname$directory$git_branch$git_status$python$nodejs$rust$golang$java$docker_context
    [╰─](bold green)$character"""

    command_timeout = 500

    [character]
    success_symbol = "[➜](bold green)"
    error_symbol = "[✗](bold red)"

    [username]
    show_always = true
    format = "[$user]($style)@"
    style_user = "bold blue"

    [hostname]
    ssh_only = false
    format = "[$hostname]($style) "
    style = "bold blue"

    [directory]
    truncation_length = 3
    truncate_to_repo = true
    format = "[$path]($style)[$read_only]($read_only_style) "
    style = "bold cyan"

    [git_branch]
    symbol = " "
    format = "on [$symbol$branch]($style) "
    style = "bold purple"

    [git_status]
    format = "([$all_status$ahead_behind]($style) )"
    style = "bold red"

    [python]
    symbol = " "
    format = "via [$symbol$version]($style) "

    [nodejs]
    symbol = " "
    format = "via [$symbol$version]($style) "

    [rust]
    symbol = " "
    format = "via [$symbol$version]($style) "

    [golang]
    symbol = " "
    format = "via [$symbol$version]($style) "

    [java]
    symbol = " "
    format = "via [$symbol$version]($style) "

    [docker_context]
    symbol = " "
    format = "via [$symbol$context]($style) "
  '';
}

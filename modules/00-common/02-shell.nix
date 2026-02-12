# Shell configurations (Zsh, Bash, Fish)
{ config, pkgs, ... }:

{
  # Set Zsh as default shell for all users
  users.defaultUserShell = pkgs.zsh;

  # Configure zoxide, fzf, and starship prompt for Zsh
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    interactiveShellInit = ''
      # Initialize fzf
      source ${pkgs.fzf}/share/fzf/completion.zsh
      source ${pkgs.fzf}/share/fzf/key-bindings.zsh
      
      # Initialize Starship prompt
      eval "$(${pkgs.starship}/bin/starship init zsh)"
    '';
    promptInit = ''
      # Initialize zoxide with cd command override (must be last)
      eval "$(${pkgs.zoxide}/bin/zoxide init --cmd cd zsh)"
    '';
  };

  # Configure Bash with same tools
  programs.bash = {
    interactiveShellInit = ''
      # Initialize fzf
      source ${pkgs.fzf}/share/fzf/completion.bash
      source ${pkgs.fzf}/share/fzf/key-bindings.bash
      
      # Initialize Starship prompt
      eval "$(${pkgs.starship}/bin/starship init bash)"
    '';
    promptInit = ''
      # Initialize zoxide with cd command override (must be last)
      eval "$(${pkgs.zoxide}/bin/zoxide init --cmd cd bash)"
    '';
  };

  # Configure Fish shell
  programs.fish = {
    interactiveShellInit = ''
      # Initialize fzf
      source ${pkgs.fzf}/share/fzf/key-bindings.fish
      
      # Initialize Starship prompt
      ${pkgs.starship}/bin/starship init fish | source
    '';
    promptInit = ''
      # Initialize zoxide with cd command override (must be last)
      ${pkgs.zoxide}/bin/zoxide init --cmd cd fish | source
    '';
  };
}

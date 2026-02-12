# Common Module

Shared configuration across all hosts.

## Structure

```
common/
  ├─ default.nix   - Entry point (imports all modules)
  ├─ system.nix    - Nix configuration and auto-upgrades
  ├─ packages.nix  - Common system packages
  ├─ shell.nix     - Shell configurations (zsh, bash, fish)
  ├─ vivaldi.nix   - Default browser is Vivaldi & its configuration
  └─ users.nix     - Home Manager user configurations
```

## Modules

### system.nix
- Enables unfree packages
- Configures Nix experimental features (flakes, nix-command)
- Sets up automatic system upgrades

### packages.nix
- Core utilities (vim, wget, curl, git, tmux, openssh)
- Desktop applications (Vivaldi, VS Code, Warp Terminal)
- CLI tools (rquickshare, zoxide, fzf, home-manager, pciutils)
- Cloud/Container tools (k9s, cloudlens)
- Shell customization (starship prompt)

### shell.nix
- Sets Zsh as default shell
- Configures Zsh, Bash, and Fish with:
  - fzf (fuzzy finder)
  - zoxide (smart cd replacement)
  - Starship prompt

### vivaldi.nix
- Sets Vivaldi as default browser
- Configures XDG MIME associations for web protocols

### users.nix
- Home Manager configuration for user `jason`
- User-specific packages (btop)
- Editor settings (Vim as default)
- Terminal settings (Warp)
- Git configuration
- Starship prompt configuration (shared across all users)

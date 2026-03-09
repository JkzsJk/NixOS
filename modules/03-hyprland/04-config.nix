# Hyprland user config — writes ~/.config/hypr/hyprland.conf via home-manager.
# Edit this file instead of ~/.config/hypr/hyprland.conf directly; it is the
# declarative, NixOS-managed equivalent of what the installer generates.
{ config, lib, ... }:

with lib;

let
  cfg = config.myDesktop.hyprland;
in
{
  config = mkIf cfg.enable {
    home-manager.users.${cfg.user} = {
      home.file.".config/hypr/hyprland.conf".text = ''
        # ======================================================================
        #  hyprland.conf — managed by NixOS (modules/03-hyprland/04-config.nix)
        # ======================================================================

        # ── Monitors ──────────────────────────────────────────────────────────
        # Format: monitor=<name>,<resolution>@<hz>,<position>,<scale>
        # Use "hyprctl monitors" to list available monitors.
        monitor=,preferred,auto,1

        # ── Autostart ─────────────────────────────────────────────────────────
        exec-once = waybar
        exec-once = mako
        exec-once = swww-daemon
        exec-once = nm-applet --indicator

        # ── Variables ─────────────────────────────────────────────────────────
        $mainMod  = SUPER
        $terminal = kitty
        $menu     = rofi -show drun

        # ── Environment ───────────────────────────────────────────────────────
        env = XCURSOR_SIZE,24
        env = HYPRCURSOR_SIZE,24

        # ── General ───────────────────────────────────────────────────────────
        general {
            gaps_in  = 5
            gaps_out = 20

            border_size = 2
            col.active_border   = rgba(33ccffee) rgba(00ff99ee) 45deg
            col.inactive_border = rgba(595959aa)

            resize_on_border = false
            allow_tearing    = false
            layout           = dwindle
        }

        # ── Decoration ────────────────────────────────────────────────────────
        decoration {
            rounding         = 10
            active_opacity   = 1.0
            inactive_opacity = 1.0

            shadow {
                enabled      = true
                range        = 4
                render_power = 3
                color        = rgba(1a1a1aee)
            }

            blur {
                enabled   = true
                size      = 3
                passes    = 1
                vibrancy  = 0.1696
            }
        }

        # ── Animations ────────────────────────────────────────────────────────
        animations {
            enabled = true

            bezier = myBezier, 0.05, 0.9, 0.1, 1.05

            animation = windows,     1, 7, myBezier
            animation = windowsOut,  1, 7, default, popin 80%
            animation = border,      1, 10, default
            animation = borderangle, 1, 8,  default
            animation = fade,        1, 7, default
            animation = workspaces,  1, 6, default
        }

        # ── Layouts ───────────────────────────────────────────────────────────
        dwindle {
            pseudotile     = true
            preserve_split = true
        }

        master {
            new_status = master
        }

        # ── Misc ──────────────────────────────────────────────────────────────
        misc {
            force_default_wallpaper = 0
            disable_hyprland_logo   = true
        }

        # ── Input ─────────────────────────────────────────────────────────────
        input {
            kb_layout   = us
            follow_mouse = 1
            sensitivity  = 0          # -1.0 to 1.0; 0 = no modification

            touchpad {
                natural_scroll = false
            }
        }

        gestures {
            workspace_swipe = false
        }

        # ── Keybinds ──────────────────────────────────────────────────────────

        # Apps
        bind = $mainMod,       Return, exec,         $terminal
        bind = $mainMod,       S,      exec,         $menu
        bind = $mainMod,       E,      exec,         dolphin

        # Window management
        bind = $mainMod,       C,      killactive
        bind = $mainMod,       V,      togglefloating
        bind = $mainMod,       P,      pseudo
        bind = $mainMod,       J,      togglesplit
        bind = $mainMod SHIFT, E,      exit

        # Focus — arrow keys
        bind = $mainMod, left,  movefocus, l
        bind = $mainMod, right, movefocus, r
        bind = $mainMod, up,    movefocus, u
        bind = $mainMod, down,  movefocus, d

        # Switch workspaces
        bind = $mainMod, 1, workspace, 1
        bind = $mainMod, 2, workspace, 2
        bind = $mainMod, 3, workspace, 3
        bind = $mainMod, 4, workspace, 4
        bind = $mainMod, 5, workspace, 5
        bind = $mainMod, 6, workspace, 6
        bind = $mainMod, 7, workspace, 7
        bind = $mainMod, 8, workspace, 8
        bind = $mainMod, 9, workspace, 9
        bind = $mainMod, 0, workspace, 10

        # Move active window to workspace
        bind = $mainMod SHIFT, 1, movetoworkspace, 1
        bind = $mainMod SHIFT, 2, movetoworkspace, 2
        bind = $mainMod SHIFT, 3, movetoworkspace, 3
        bind = $mainMod SHIFT, 4, movetoworkspace, 4
        bind = $mainMod SHIFT, 5, movetoworkspace, 5
        bind = $mainMod SHIFT, 6, movetoworkspace, 6
        bind = $mainMod SHIFT, 7, movetoworkspace, 7
        bind = $mainMod SHIFT, 8, movetoworkspace, 8
        bind = $mainMod SHIFT, 9, movetoworkspace, 9
        bind = $mainMod SHIFT, 0, movetoworkspace, 10

        # Scratchpad (special workspace)
        bind = $mainMod,       U, togglespecialworkspace, magic
        bind = $mainMod SHIFT, U, movetoworkspace,        special:magic

        # Scroll through workspaces with Super + mouse wheel
        bind = $mainMod, mouse_down, workspace, e+1
        bind = $mainMod, mouse_up,   workspace, e-1

        # Mouse — move and resize windows
        bindm = $mainMod, mouse:272, movewindow
        bindm = $mainMod, mouse:273, resizewindow

        # Screenshot — select region, save to ~/Pictures/
        bind = , Print, exec, grim -g "$(slurp)" ~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png

        # ── Window rules ──────────────────────────────────────────────────────
        windowrulev2 = suppressevent maximize, class:.*
        windowrulev2 = nofocus, class:^$, title:^$, xwayland:1, floating:1, fullscreen:0, pinned:0
      '';
    };
  };
}

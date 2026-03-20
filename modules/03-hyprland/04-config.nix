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
      # Wallpapers — sourced from the repo, linked into ~/Wallpapers/ on rebuild
      home.file."Wallpapers/gow-ragnarok-fimbulwinter.jpg".source =
        ./wallpapers/gow-ragnarok-fimbulwinter.jpg;

      home.file.".config/hypr/start.sh" = {
        force      = true;
        executable = true;
        text = ''
          #!/usr/bin/env bash

          # Initialise wallpaper daemon
          swww-daemon &
          sleep 1  # wait for daemon socket before setting image

          # Set wallpaper
          swww img ~/Wallpapers/gow-ragnarok-fimbulwinter.jpg &

          # Network manager tray applet
          nm-applet --indicator &

          # Status bar
          waybar &

          # Notifications
          mako &
        '';
      };

      home.file.".config/hypr/hyprland.conf" = {
        force = true;
        text = ''
        # ======================================================================
        #  hyprland.conf — managed by NixOS (modules/03-hyprland/04-config.nix)
        # ======================================================================

        # ── Monitors ──────────────────────────────────────────────────────────
        # Format: monitor=<name>,<resolution>@<hz>,<position>,<scale>
        # Use "hyprctl monitors" to list available monitors.
        # Scale: 1 = native, 1.5 = 150% (2133x1200 effective), 2 = 200% (1600x900 effective)
        ## This is for Dell XPS 15 9530's 3K display; adjust as needed for your setup!
        monitor=eDP-1,3200x1800@60,0x0,1.25

        # ── Autostart ─────────────────────────────────────────────────────────
        exec-once = bash ~/.config/hypr/start.sh

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

        # ── Ecosystem ─────────────────────────────────────────────────────────
        ecosystem {
            no_update_news = true
        }

        # ── Input ─────────────────────────────────────────────────────────────
        input {
            kb_layout    = us
            follow_mouse = 1
            sensitivity  = 0.4          # -1.0 to 1.0; 0 = no modification

            touchpad {
                natural_scroll = false
            }
        }

        # ── Gestures ──────────────────────────────────────────────────────────
        # Syntax: gesture = <fingers>, <direction>, <action>
        gesture = 3, horizontal, workspace  # 3-finger swipe to switch workspaces

        # ── Keybinds ──────────────────────────────────────────────────────────
        # Inspired by JaKooLit/Hyprland-Dots

        # ── Apps ──────────────────────────────────────────────────────────────
        bind = $mainMod,       Return, exec,         $terminal
        bind = $mainMod,       D,      exec,         $menu
        bind = $mainMod,       E,      exec,         dolphin

        # ── Window Management ─────────────────────────────────────────────────
        bind = $mainMod,       Q,           killactive
        bind = $mainMod SHIFT, Q,           killactive
        bind = $mainMod,       V,           togglefloating
        bind = $mainMod,       Space,       togglefloating
        bind = $mainMod SHIFT, F,           fullscreen, 0
        bind = $mainMod,       P,           pseudo
        bind = $mainMod SHIFT, I,           togglesplit
        bind = $mainMod,       G,           togglegroup
        bind = CTRL ALT,       L,           exec, hyprlock
        bind = CTRL ALT,       Del,         exit
        bind = $mainMod SHIFT, M,           exit

        # ── Focus Windows ─────────────────────────────────────────────────────
        bind = $mainMod, left,  movefocus, l
        bind = $mainMod, right, movefocus, r
        bind = $mainMod, up,    movefocus, u
        bind = $mainMod, down,  movefocus, d
        bind = ALT,      Tab,   cyclenext
        bind = ALT,      Tab,   bringactivetotop

        # ── Move Windows ──────────────────────────────────────────────────────
        bind = $mainMod CTRL, left,  movewindow, l
        bind = $mainMod CTRL, right, movewindow, r
        bind = $mainMod CTRL, up,    movewindow, u
        bind = $mainMod CTRL, down,  movewindow, d

        # ── Resize Windows ────────────────────────────────────────────────────
        bind = $mainMod SHIFT, left,  resizeactive, -40 0
        bind = $mainMod SHIFT, right, resizeactive, 40 0
        bind = $mainMod SHIFT, up,    resizeactive, 0 -40
        bind = $mainMod SHIFT, down,  resizeactive, 0 40

        # ── Layout Toggle ─────────────────────────────────────────────────────
        bind = $mainMod ALT, L, exec, hyprctl keyword general:layout "$(hyprctl getoption general:layout | grep -q 'dwindle' && echo master || echo dwindle)"

        # ── Workspace Switching ───────────────────────────────────────────────
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

        # Next/Previous workspace
        bind = $mainMod, Tab,       workspace, e+1
        bind = $mainMod SHIFT, Tab, workspace, e-1

        # ── Move Window to Workspace (Follow) ─────────────────────────────────
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

        # Move window to workspace (Silent - no follow)
        bind = $mainMod CTRL, 1, movetoworkspacesilent, 1
        bind = $mainMod CTRL, 2, movetoworkspacesilent, 2
        bind = $mainMod CTRL, 3, movetoworkspacesilent, 3
        bind = $mainMod CTRL, 4, movetoworkspacesilent, 4
        bind = $mainMod CTRL, 5, movetoworkspacesilent, 5
        bind = $mainMod CTRL, 6, movetoworkspacesilent, 6
        bind = $mainMod CTRL, 7, movetoworkspacesilent, 7
        bind = $mainMod CTRL, 8, movetoworkspacesilent, 8
        bind = $mainMod CTRL, 9, movetoworkspacesilent, 9
        bind = $mainMod CTRL, 0, movetoworkspacesilent, 10

        # ── Scratchpad (Special Workspace) ────────────────────────────────────
        bind = $mainMod,       U, togglespecialworkspace, magic
        bind = $mainMod SHIFT, U, movetoworkspace,        special:magic

        # ── Mouse Bindings ────────────────────────────────────────────────────
        # Scroll through workspaces
        bind = $mainMod, mouse_down, workspace, e+1
        bind = $mainMod, mouse_up,   workspace, e-1

        # Move and resize windows
        bindm = $mainMod, mouse:272, movewindow
        bindm = $mainMod, mouse:273, resizewindow

        # ── Screenshot Keybinds ───────────────────────────────────────────────
        # Full monitor screenshot
        bind = $mainMod, Print, exec, grim ~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png && notify-send "Screenshot" "Monitor captured"

        # Region screenshot (select area)
        bind = $mainMod SHIFT, Print, exec, grim -g "$(slurp)" ~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png && notify-send "Screenshot" "Region captured"
        bind = $mainMod SHIFT, S,     exec, grim -g "$(slurp)" ~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png && notify-send "Screenshot" "Region captured"

        # Active window screenshot
        bind = ALT, Print, exec, grim -g "$(hyprctl activewindow -j | jq -r '\"\\(.at[0]),\\(.at[1]) \\(.size[0])x\\(.size[1])\"')" ~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png && notify-send "Screenshot" "Window captured"

        # Screenshot with timer (5 seconds)
        bind = $mainMod CTRL, Print, exec, sleep 5 && grim ~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png && notify-send "Screenshot" "Captured after 5s"

        # Screenshot with timer (10 seconds)
        bind = $mainMod CTRL SHIFT, Print, exec, sleep 10 && grim ~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png && notify-send "Screenshot" "Captured after 10s"

        # ── Window rules ──────────────────────────────────────────────────────
        windowrulev2 = suppressevent maximize, class:.*
        windowrulev2 = nofocus, class:^$, title:^$, xwayland:1, floating:1, fullscreen:0, pinned:0
      '';
      };
    };
  };
}

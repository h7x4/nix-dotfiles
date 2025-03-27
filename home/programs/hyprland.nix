{ config, pkgs, lib, ... }:
let
  cfg = config.wayland.windowManager.hyprland;
in
{
  home.sessionVariables = {
    WLR_NO_HARDWARE_CURSORS = "1";
    WLR_RENDERER_ALLOW_SOFTWARE = "1";
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
    GDK_BACKEND = "wayland,x11,*";
    QT_QPA_PLATFORM = "wayland;xcb";
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    SDL_VIDEODRIVER = "wayland";
    OZONE_PLATFORM = "wayland";
    CLUTTER_BACKEND = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    # QT_QPA_PLATFORMTHEME = "qt6ct";
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";

    # LIBVA_DRIVER_NAME = "nvidia";
    # GBM_BACKEND = "nvidia-drm";
    # __GLX_VENDOR_LIBRARY_NAME = "nvidia";
  };

  home.packages = with pkgs; [
    hyprpolkitagent
    wl-clipboard-rs
  ];

  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        grace = 0;
        hide_cursor = true;
        no_fade_in = false;
      };

      background = [
        {
          path = "screenshot";
          blur_passes = 3;
          blur_size = 8;
        }
      ];

      input-field = [
        {
          size = "200, 50";
          position = "0, -80";
          monitor = "";
          dots_center = true;
          fade_on_empty = false;
          font_color = "rgb(202, 211, 245)";
          inner_color = "rgb(91, 96, 120)";
          outer_color = "rgb(24, 25, 38)";
          outline_thickness = 5;
          placeholder_text = ''Password...'';
          shadow_passes = 2;
        }
      ];

      auth = {
        "pam:enabled" = true;
        "pam:module" = "hyprlock";
      };
    };
  };

  services.hypridle = {
    enable = true;
    settings = {
      general = {
        ignore_dbus_inhibit = false;
        lock_cmd = "pidof hyprlock || ${config.programs.hyprlock.package}/bin/hyprlock";
        before_sleep_cmd = "${pkgs.systemd}/bin/loginctl lock-session";
        after_sleep_cmd = "${cfg.finalPackage}/bin/hyprctl dispatch dpms on";
      };

      listener = [
        {
          timeout = 900;
          on-timeout = "${config.programs.hyprlock.package}/bin/hyprlock";
        }
        {
          timeout = 1200;
          on-timeout = "${cfg.finalPackage}/bin/hyprctl dispatch dpms off";
          on-resume = "${cfg.finalPackage}/bin/hyprctl dispatch dpms on";
        }
      ];
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;

    systemd.enable = false;
    systemd.enableXdgAutostart = false;

    settings = let
      exe = lib.getExe;
      scratchpads = [
        (rec {
          title = "Floating terminal";
          class = "floatingTerminal";
          command = "uwsm app -- ${exe pkgs.alacritty} --class ${class} -e ${exe pkgs.tmux} new-session -A -s f";
          size = { h = 90; w = 95; };
          keys = [
            "$mod, RETURN"
            "$mod, SPACE"
          ];
        })
        (rec {
          title = "Ncmpcpp";
          class = "floatingNcmpcpp";
          command = "uwsm app -- ${exe pkgs.alacritty} --class ${class} -e ${exe pkgs.ncmpcpp}";
          size = { h = 95; w = 95; };
          keys = [ "$mod, Q" ];
        })
        # "$mod, W, emacs"
        # "$mod, E, filebrowser"
        # "$mod, X, taskwarriortui"
      ];
    in {
      "$mod" = "SUPER";

      # https://github.com/xkbcommon/libxkbcommon/blob/master/include/xkbcommon/xkbcommon-keysyms.h
      bind = [
        "$mod SHIFT, Q, exec, ${pkgs.systemd}/bin/loginctl terminate-user \"\""
        "$mod ALT SHIFT, Q, exit"
        "$mod, R, exec, uwsm app -- ${exe config.programs.anyrun.package}"
        "$mod, T, togglefloating"

        "$mod, F, fullscreenstate, 1"
        "$mod SHIFT, F, fullscreenstate, 3"
        "$mod, C, exec, ${cfg.finalPackage}/bin/hyprctl reload"

        "$mod, BACKSPACE, killactive"

        "$mod SHIFT, RETURN, exec, uwsm app -- ${exe pkgs.alacritty} --class termTerminal -e ${exe pkgs.tmux} new-session -A -s term"
        "$mod SHIFT, SPACE, exec, uwsm app -- ${exe pkgs.alacritty} --class termTerminal -e ${exe pkgs.tmux} new-session -A -s term"

        "$mod, j, layoutmsg,cyclenext"
        "$mod, k, layoutmsg,cycleprev"
        "$mod SHIFT, j, layoutmsg, swapnext"
        "$mod SHIFT, k, layoutmsg, swapprev"

        "$mod, 1, focusworkspaceoncurrentmonitor, 1"
        "$mod, 2, focusworkspaceoncurrentmonitor, 2"
        "$mod, 3, focusworkspaceoncurrentmonitor, 3"
        "$mod, 4, focusworkspaceoncurrentmonitor, 4"
        "$mod, 5, focusworkspaceoncurrentmonitor, 5"
        "$mod, 6, focusworkspaceoncurrentmonitor, 6"
        "$mod, 7, focusworkspaceoncurrentmonitor, 7"
        "$mod, 8, focusworkspaceoncurrentmonitor, 8"
        "$mod, 9, focusworkspaceoncurrentmonitor, 9"

        "$mod SHIFT, 1, movetoworkspacesilent, 1"
        "$mod SHIFT, 2, movetoworkspacesilent, 2"
        "$mod SHIFT, 3, movetoworkspacesilent, 3"
        "$mod SHIFT, 4, movetoworkspacesilent, 4"
        "$mod SHIFT, 5, movetoworkspacesilent, 5"
        "$mod SHIFT, 6, movetoworkspacesilent, 6"
        "$mod SHIFT, 7, movetoworkspacesilent, 7"
        "$mod SHIFT, 8, movetoworkspacesilent, 8"
        "$mod SHIFT, 9, movetoworkspacesilent, 9"

        "$mod, b, exec, ${pkgs.fcitx5}/bin/fcitx5-remote -s mozc"
        "$mod, n, exec, ${pkgs.fcitx5}/bin/fcitx5-remote -s keyboard-no"
        "$mod, m, exec, ${pkgs.fcitx5}/bin/fcitx5-remote -s keyboard-us"

        # TODO: ensure exists in environment
        "$mod, l, exec, ${pkgs.systemd}/bin/loginctl lock-session"

        # TODO: fix
        # "super + minus" = "${pkgs.xcalib}/bin/xcalib -invert -alter"

        # TODO: fix
        ", Print, exec, ${exe pkgs.grimblast} copy area"

        # "SHIFT, Print, exec, ${lib.getExe pkgs.grimblast} copy area"
        # "shift + @Print" = "${pkgs.maim}/bin/maim --hidecursor --nokeyboard $SCREENSHOT_DIR/$(date +%s).png"

        # TODO: Add boomer as package
        # "super + @Print" = "boomer"
      ]
      ++
      (lib.pipe scratchpads [
        (map ({ keys, command, class, ... }:
          (map (key: let
            # TODO: rewrite this to take arguments instead of creating n copies
            invokeIfNotRunningAndToggleWorkspace = pkgs.writeShellApplication {
              name = "hyprland-toggle-scratchpad-${class}";
              runtimeInputs = [ cfg.finalPackage pkgs.jq ];
              text = ''
                SCRATCHPAD_PROGRAM_EXISTS=$(hyprctl clients -j | jq -r '[.[].class]|any(. == "${class}")')
                CURRENT_WORKSPACE_ID=$(hyprctl activeworkspace -j | jq -r '.id')

                if [ "$SCRATCHPAD_PROGRAM_EXISTS" != "true" ]; then
                  ${command} &
                  hyprctl dispatch movetoworkspacesilent "''${CURRENT_WORKSPACE_ID},class:${class}"
                  hyprctl dispatch focuswindow "class:${class}"
                else
                  SCRATCHPAD_PROGRAM_WORKSPACE_ID=$(hyprctl clients -j | jq '.[] | select( .class == "${class}") | .workspace.id')
                  if [ "$SCRATCHPAD_PROGRAM_WORKSPACE_ID" != "$CURRENT_WORKSPACE_ID" ]; then
                    hyprctl dispatch movetoworkspacesilent "''${CURRENT_WORKSPACE_ID},class:${class}"
                    hyprctl dispatch focuswindow "class:${class}"
                  else
                    hyprctl dispatch movetoworkspacesilent "special:${class}Ws,class:${class}"
                  fi
                fi
              '';
            };
          in "${key}, exec, ${lib.getExe invokeIfNotRunningAndToggleWorkspace}"
          ) keys)
        ))
        lib.flatten
      ]);

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, Control_L, movewindow"
        "$mod, mouse:273, resizewindow"
        "$mod, ALT_L, resizewindow"
      ];

      bindl = [
        "$mod, p, exec, ${exe pkgs.mpc_cli} toggle"
        ",XF86AudioPlay, exec, ${exe pkgs.mpc_cli} toggle"
        ",XF86AudioPrev, exec, ${exe pkgs.mpc_cli} prev"
        ",XF86AudioNext, exec, ${exe pkgs.mpc_cli} next"
      ];

      bindle = [
        ",XF86MonBrightnessUp, exec, ${exe pkgs.brightnessctl} s +5%"
        ",XF86MonBrightnessDown, exec, ${exe pkgs.brightnessctl} s 5%-"
        ",XF86AudioLowerVolume, exec, ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"
        ",XF86AudioRaiseVolume, exec, ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+"
        "$mod ,F7, exec, ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-"
        "$mod ,F8, exec, ${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+"
      ];

      exec-once = [
        "uwsm finalize"
      ];

      windowrulev2 = [
        "float, class:^(Rofi)$"
        "float, class:^(xdg-desktop-portal-gtk)$"
        "float, title:^(.*Bitwarden Password Manager.*)$"
        "tile, class:^(Nsxiv)$"

        "dimaround, class:^(xdg-desktop-portal-gtk)$"

        "workspace special silent, title:^(Firefox — Sharing Indicator)$"
        "workspace special silent, title:^(Zen — Sharing Indicator)$"
        "workspace special silent, title:^(.*is sharing (your screen|a window)\.)$"

        "workspace 2, class:^(firefox)$"
        "workspace 2, class:^(google-chrome)$"

        "workspace 3, class:^(Emacs)$"
        "workspace 3, class:^(code)$"
        "workspace 3, class:^(code-url-handler)$"
        "workspace 3, class:^(dev.zed.Zed)$"

        "workspace 5, class:^(discord)$"
        "workspace 5, class:^(Element)$"
      ]
      ++
      (lib.pipe scratchpads [
        (map ({ class, size, ... }: [
          "workspace special:${class}Ws, class:^${class}$"
          "float, class:^${class}$"
          "size ${toString size.w}% ${toString size.h}%, class:^${class}$"
          "move ${toString ((100 - size.w) / 2)}% ${toString ((100 - size.h) / 2)}%, class:^${class}$"
        ]))
        lib.flatten
      ]);

      monitor = [
        # TODO: host specific
        "eDP-1, 3840x2400@90.00Hz, 0x0, 2"

        # PVV Demiurgen
        "desc:Hewlett Packard HP ZR24w CNT01711G6, 1920x1200, 0x-1200, 1"
        "desc:Hewlett Packard HP ZR24w CNT018103H, 1920x1200, 1920x-1200, 1"

        # PVV Eirin
        "desc:Hewlett Packard HP ZR24w CNT01710L4, 1920x1200, 0x-1200, 1"
        "desc:Hewlett Packard HP ZR24w CNT0181039, 1920x1200, 1920x-1200, 1"

        ",preferred,auto,1"
      ];

      general = {
        gaps_in = 5;
        gaps_out = 15;

        border_size = 2;

        "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        "col.inactive_border" = "rgba(595959aa)";

        resize_on_border = false;
        allow_tearing = false;
        layout = "master";
      };

      decoration = {
        rounding = 10;

        # Change transparency of focused and unfocused windows
        active_opacity = 1.0;
        inactive_opacity = 1.0;

        # drop_shadow = true;
        # shadow_range = 4;
        # shadow_render_power = 3;
        # "col.shadow" = "rgba(1a1a1aee)";

        # https://wiki.hyprland.org/Configuring/Variables/#blur
        blur = {
          enabled = true;
          size = 3;
          passes = 1;

          vibrancy = 0.1696;
        };
      };

      animations.enabled = false;

      master = {
          new_status = "slave";
      };

      misc = {
        force_default_wallpaper = 0; # Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo = false; # If true disables the random hyprland logo / anime girl background. :(
      };

      input ={
        kb_layout = "us";
        kb_variant = "";
        kb_model = "";
        kb_options = "caps:escape";
        kb_rules = "";

        follow_mouse = 1;

        sensitivity = 0; # -1.0 - 1.0, 0 means no modification.

        touchpad = {
          natural_scroll = false;
        };
      };
    };
  };

  # UWSM
  systemd.user.services = {
    hypridle.Unit.After = lib.mkForce "graphical-session.target";
    waybar.Unit.After = lib.mkForce "graphical-session.target";
    network-manager-applet.Unit.After = lib.mkForce "graphical-session.target";
    fcitx5-daemon.Unit.After = lib.mkForce "graphical-session.target";
    # hyprpaper.Unit.After = lib.mkForce "graphical-session.target";
  };
}

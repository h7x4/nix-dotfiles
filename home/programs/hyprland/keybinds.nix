{ config, pkgs, lib, ... }:
let
  cfg = config.wayland.windowManager.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = let
      exe = lib.getExe;
    in {
      "$mod" = "SUPER";

      # https://github.com/xkbcommon/libxkbcommon/blob/master/include/xkbcommon/xkbcommon-keysyms.h
      bind = [
        "$mod SHIFT, Q, exec, uwsm stop"
        "$mod ALT SHIFT, Q, exec, ${pkgs.systemd}/bin/loginctl terminate-user \"${config.home.username}\""
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

        "$mod, l, exec, ${pkgs.systemd}/bin/loginctl lock-session"

        # TODO: fix
        # "super + minus" = "${pkgs.xcalib}/bin/xcalib -invert -alter"

        ", Print, exec, ${exe pkgs.grimblast} copy area"

        # "SHIFT, Print, exec, ${lib.getExe pkgs.grimblast} copy area"
        # "shift + @Print" = "${pkgs.maim}/bin/maim --hidecursor --nokeyboard $SCREENSHOT_DIR/$(date +%s).png"

        "$mod, Print, exec, ${exe pkgs.woomer}"
      ];

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
    };
  };
}

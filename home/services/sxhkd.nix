{ config, pkgs, lib, ... }:
let
  cfg = config.services.sxhkd;
  keybindingsStr = lib.concatStringsSep "\n" (lib.mapAttrsToList (hotkey: command:
    lib.optionalString (command != null) ''
      ${hotkey}
        ${command}
    '') cfg.keybindings);
in
{
  services.sxhkd = {
    enable = false;
    keybindings = {

      # make sxhkd reload its configuration files:
      "super + Escape" = "pkill -USR1 -x sxhkd && ${pkgs.libnotify}/bin/notify-send -t 3000 \"sxhkd configuration reloaded\"";

      # Applications
      "super + s" = "$BROWSER";

      "super + r" = "${pkgs.rofi}/bin/rofi -show drun";

      # Volume

      "super + {@F7,@F8}" = "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%{-,+}";

      "{XF86AudioLowerVolume,XF86AudioRaiseVolume}" = "${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%{-,+}";

      "XF86AudioMute" = "${pkgs.wireplumber}/bin/wpctl set-mute toggle";

      # Music

      "super + p" = "${pkgs.mpc_cli}/bin/mpc toggle";

      "XF86AudioPlay" = "${pkgs.mpc_cli}/bin/mpc toggle";
      "XF86AudioPrev" = "${pkgs.mpc_cli}/bin/mpc prev";
      "XF86AudioNext" = "${pkgs.mpc_cli}/bin/mpc next";

      # Monitor

      "XF86MonBrightnessUp"   = "${pkgs.light}/bin/light -A 5";
      "XF86MonBrightnessDown" = "${pkgs.light}/bin/light -U 5";

      "@Print" = "${pkgs.maim}/bin/maim --hidecursor --nokeyboard --select | ${pkgs.xclip}/bin/xclip -selection clipboard -target image/png -in";

      "shift + @Print" = "${pkgs.maim}/bin/maim --hidecursor --nokeyboard $SCREENSHOT_DIR/$(date +%s).png";

      # TODO: Add boomer as package
      # "super + @Print" = "boomer";

      # Misc

      "super + l" = "loginctl lock-session";

      "super + a" = "${pkgs.copyq}/bin/copyq toggle";

      # fcitx "super + {b,n,m}" = "${pkgs.fcitx}/bin/fcitx-remote -s {mozc,fcitx-keyboard-no,fcitx-keyboard-us}";

      # fcitx5
      "super + {b,n,m}" = "${pkgs.fcitx5}/bin/fcitx5-remote -s {mozc,keyboard-no,keyboard-us}";

      # TODO: fix
      # "super + v" = "${pkgs.rofi}/bin/rofi -modi lpass:$HOME/.scripts/rofi/lpass/rofi-lpass -show lpass";

      "super + minus" = "${pkgs.xcalib}/bin/xcalib -invert -alter";

      # ¯\_(ツ)_/¯
      # "super + shift + s"
      # 	sleep 0.3; \
      # 	${pkgs.xdotool}/bin/xdotool key U00AF; \
      # 	${pkgs.xdotool}/bin/xdotool key U005C; \
      # 	${pkgs.xdotool}/bin/xdotool key U005F; \
      # 	${pkgs.xdotool}/bin/xdotool key U0028; \
      # 	${pkgs.xdotool}/bin/xdotool key U30C4; \
      # 	${pkgs.xdotool}/bin/xdotool key U0029; \
      # 	${pkgs.xdotool}/bin/xdotool key U005F; \
      # 	${pkgs.xdotool}/bin/xdotool key U002F; \
      # 	${pkgs.xdotool}/bin/xdotool key U00AF

      # é
      "super + shift + e" = "sleep 0.3; ${pkgs.xdotool}/bin/xdotool key U00E9";
    };
  };

  xdg.configFile."sxhkd/sxhkdrc".text =
    lib.concatStringsSep "\n" [ keybindingsStr cfg.extraConfig ];

  home.packages = [ cfg.package ];

  systemd.user.services.sxhkd = {
    Unit = {
      Description = "Simple X hotkey daemon";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${cfg.package}/bin/sxhkd ${toString cfg.extraOptions}";
      Restart = "always";
    };

    Install.WantedBy = [ "graphical-session.target" ];
  };
}

{ pkgs, ... }:
{
  services.sxhkd = {
    enable = true;
    keybindings = {

      # make sxhkd reload its configuration files:
      "super + Escape" = "pkill -USR1 -x sxhkd && ${pkgs.libnotify}/bin/notify-send -t 3000 \"sxhkd configuration reloaded\"";

      # Applications
      "super + s" = "$BROWSER";

      "super + r" = "${pkgs.rofi}/bin/rofi -show drun";

      # Volume

      "super + {@F7,@F8}" = "${pkgs.alsaUtils}/bin/amixer set Master 2%{-,+}";

      "{XF86AudioLowerVolume,XF86AudioRaiseVolume}" = "${pkgs.alsaUtils}/bin/amixer set Master 2%{-,+}";

      "XF86AudioMute" = "${pkgs.pulseaudio}/bin/pactl set-sink-mute @DEFAULT_SINK@ toggle";

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

      "super + a" = "${pkgs.copyq}/bin/copyq toggle";

      # fcitx
      "super + {b,n,m}" = "${pkgs.fcitx}/bin/fcitx-remote -s {mozc,fcitx-keyboard-no,fcitx-keyboard-us}";

      # fcitx5
      # "super + {b,n,m}" = "${pkgs.fcitx5}/bin/fcitx5-remote -s {mozc,keyboard-no,keyboard-us}";

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
}

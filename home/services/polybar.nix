{ pkgs, config, ... }: let
  colors = config.colors.defaultColorSet;
  inherit (config) machineVars;
in {
  services.polybar = {
    enable = true;

    script = ''
      polybar top &
    '';

    package = pkgs.polybar.override {
      githubSupport = true;
      mpdSupport = true;
    };

    settings = {
      "bar/top" = {
        bottom = false;
        # monitor =
        tray.position = "right";

        background = colors.background;
        foreground = colors.foreground;

        padding = {
          left = 2;
          right = 2;
        };
        width = "100%";
        height = 40;

        fixed-center = true;

        font = map (f: f + ":pixelsize=12:antialias=true:hinting=true") [
          "Fira Code Retina"
          "Noto Sans CJK JP"
          "FiraCode Nerd Font"
        ];

        modules = {
          left = "xmonad";
          center = "date";
          right = builtins.concatStringsSep " " [
            "filesystem "
            (if machineVars.wlanInterface != null then "wlan " else "")
            (if machineVars.battery != null then "batt " else "")
            "vol"
            "mpd"
          ];
        };

        tray = {
          padding = 4;
          maxsize = 25;
          background = colors.background;
        };
      };

      "module/xmonad" = {
        type = "custom/script";
        exec = "${pkgs.xmonad-log}/bin/xmonad-log";
        tail = "true";
      };

      "module/date" = {
        type = "internal/date";
        interval = 1.0;

        format-padding = 1;

        label = "%date% | %time%";
        label-padding = 1;

        date = "W%W | %Y.%m.%d | %A";
        time = "%R";
      };

      "module/wlan" = {
        type = "internal/network";
        interval = 1.0;
        unknown-as-up = true;
        # Wireless interfaces often start with `wl` and ethernet interface with `eno` or `eth`. Check " ifconfig/iwconfig "
        interface = pkgs.lib.mkIf (machineVars.wlanInterface != null) machineVars.wlanInterface;

        format = {
          connected = "<label-connected>";
          connected-padding = 1;
          # connected-suffix = "%{A1:networkmanager_dmenu &:}%{A}"
          # connected-suffix-padding = 1
          # connected-suffix-foreground = ${colors.fg-alt}
          # connected-suffix-background = ${colors.accent}

          disconnected = "<label-disconnected>";
          disconnected-padding = 1;
          # disconnected-suffix = "%{A1:networkmanager_dmenu &:}%{A}"
          # disconnected-suffix-padding = 1
          # disconnected-suffix-foreground = ${colors.fg-alt}
          # disconnected-suffix-background = ${colors.accent}

          label = {
            connected = "%essid%";
            connected-padding = 1;
            # connected-background = ${colors.fg-alt}

            disconnected = "OFF";
            disconnected-padding = 1;
            # disconnected-background = ${colors.fg-alt}
          };
        };
      };

      "module/batt" = {
        type = "internal/battery";
        full-at = 99;

        battery = pkgs.lib.mkIf (machineVars.battery != null) machineVars.battery;
        adapter = "AC";

        poll.interval = 5;

        # format-charging = "<label-charging>"
        format.charging.padding = 1;

        # format-charging-suffix = "%{A1:xfce4-power-manager-settings &:}%{A}"
        # format-charging-suffix-padding = 1
        # format-charging-suffix-foreground = ${colors.fg-alt}
        # format-charging-suffix-background = ${colors.accent}
        #
        # format-discharging = "<label-discharging>"
        # format-discharging-padding = 1
        #
        # format-discharging-suffix = "%{A1:xfce4-power-manager-settings &:}%{A}"
        # format-discharging-suffix-padding = 1
        # format-discharging-suffix-foreground = ${colors.fg-alt}
        # format-discharging-suffix-background = ${colors.accent}
        #

        label-charging = "%percentage%%";
        label-discharging = "%percentage%%";
        label-full = "FULL";
        label = {
          charging = {
            padding = 1;
            foreground = colors.green;
            # background = ${colors.fg-alt}
          };
          discharging = {
            padding = 1;
            foreground = colors.yellow;
          };
          full = {
            padding = 1;
            foreground = colors.blue;
          };
        };
      };

      "module/vol" = {
        type = "internal/alsa";
        # format-volume = "<bar-volume>}"
        # format-volume = "%{A1:bash -c '~/.scripts/get-volume' &:}<bar-volume>%{A}"
        # format-volume = <label-volume> <bar-volume>

        # format-volume-padding = 1
        # format-muted-padding = 1
        format-volume = "%{T3}%{T-} <label-volume> <bar-volume>";
        # label-volume = 
        label-volume-foreground = colors.magenta;
        # format-muted-foreground = "${colors.foreground-alt}";
        label-muted = "mute";

        bar.volume = {
          width = 8;
          foreground = [
            "#55aa55"
            "#55aa55"
            "#55aa55"
            "#55aa55"
            "#55aa55"
            "#f5a70a"
            "#ff5555"
          ];
          gradient = false;
          indicator = "|";
          # indicator-font = 1
          fill = "─";
          # fill-font = 1
          empty = "─";
          # empty-font = 1
          # empty-foreground = "${colors.foreground-alt}";
        };

        #
        # format-volume-prefix = "%{A3:pavucontrol &:}%{A}"
        # format-volume-prefix-padding = 1
        # format-volume-prefix-background = ${colors.fg-alt}
        #
        #
        # format-muted-prefix = "%{A3:pavucontrol &:}%{A}"
        # format-muted-prefix-padding = 1
        # format-muted-prefix-background = ${colors.fg-alt}
        #
        # label-muted = " "
        # label-muted-background = ${colors.fg-alt}
        #
        # bar-volume-width = 5
        # bar-volume-indicator = ""
        # bar-volume-empty = ""
        # bar-volume-fill = ""
        #
        # bar-volume-indicator-foreground = ${colors.fg}
        # bar-volume-indicator-background = ${colors.fg-alt}
        #
        # bar-volume-empty-foreground = ${colors.fg-alt}
        # bar-volume-empty-background = ${colors.fg-alt}
        #
        # bar-volume-fill-foreground = ${colors.accent-alt}
        # bar-volume-fill-background = ${colors.fg-alt}
      };

      "module/mpd" = {
        type = "internal/mpd";

        # your port and host here
        host = "127.0.0.1";
        port = "6600";

        format-online = "<toggle> <label-song>";

        # These are opposite, because polybar expects you to click the icon to change state,
        # instead of showing the current state.

        icon-pause = "";
        icon.pause = {
          font = 3;
          padding = 1;
          foreground = colors.green;
        } ;

        icon-play = "";
        icon.play = {
          font = 3;
          padding = 1;
          foreground = colors.red;
        } ;

        label-song = "%title%";
        label.song = {
          maxlen = 30;
          ellipsis = true;
          padding = 1;
        };
      };

      "module/filesystem" = {
        type = "internal/fs";

        # Mountpoints to display
        mount = [
          "/"
        ];
        # ] ++ (builtins.values machineVars.dataDrives.drives);

        format.mount = [
          { background = "#101010"; }
        ];

        # Seconds to sleep between updates
        # Default: 30
        interval = 10;

        # Display fixed precision values
        # Default: false
        fixed-values = true;

        # Spacing (number of spaces, pixels, points) between entries
        # Default: 2
        spacing = 4;

        # Default: 90
        # New in version 3.6.0
        warn-percentage = 75;
      };

      "settings" = {
        screenchange-reload = true;
      };
    };
  };
}

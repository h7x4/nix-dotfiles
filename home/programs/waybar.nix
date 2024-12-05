{ config, pkgs, lib, ... }:
let
  cfg = config.programs.waybar;
  cfgs = cfg.settings.mainBar;
in
{
  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;

        # TODO: configure this per machine
        # output = [ "DP-2" ];

        modules-left = [ "hyprland/workspaces"  ];
        modules-center = [ "clock" ];
        modules-right = [ "mpd" "cpu" "memory" "wireplumber" "pulseaudio/slider" "battery" "tray" ];

        "hyprland/workspaces" = {
          all-outputs = true;
          disable-scroll = true;
          persistent-workspaces = {
            ${lib.head cfgs.output} = [ 1 2 3 4 5 6 7 8 ];
          };
        };

        "mpd" = {
          format = "{filename}";
        };

        "cpu" = {
          format = "[#] {usage}%";
        };

        "memory" = {
          format = "{used}/{total}Gb";
        };

        "wireplumber" = {
          format = "{volume}% {icon}";
          format-muted = "[M]";
        };

        "pulseaudio/slider" = {
          orientation = "horizontal";
        };

        "tray" = {
          icon-size = 20;
          spacing = 8;
        };
      };
    };

    style = let
      c = config.colors.defaultColorSet;
    in ''
      * {
          font-family: FiraCode, FontAwesome, Roboto, Helvetica, Arial, sans-serif;
          font-size: 13px;
      }

      window#waybar {
          background-color: ${c.background};
          color: ${c.foreground};
      }

      #pulseaudio-slider trough {
          min-height: 10px;
          min-width: 100px;
      }

      /**** DEFAULT ****/

      window#waybar.hidden {
          opacity: 0.2;
      }

      button {
          /* Use box-shadow instead of border so the text isn't offset */
          box-shadow: inset 0 -3px transparent;
          /* Avoid rounded borders under each button name */
          border: none;
          border-radius: 0;
      }

      /* https://github.com/Alexays/Waybar/wiki/FAQ#the-workspace-buttons-have-a-strange-hover-effect */
      button:hover {
          background: inherit;
          box-shadow: inset 0 -3px #ffffff;
      }


      #workspaces button.empty {
          color: ${c.yellow};
      }

      #workspaces button {
          padding: 0 5px;
          color: ${c.magenta};
          background-color: transparent;
      }

      #workspaces button.visible {
          color: ${c.green};
      }

      #workspaces button.urgent {
          background-color: ${c.red};
      }

      #workspaces button:hover {
          background: rgba(0, 0, 0, 0.2);
      }

      #mode {
          background-color: #64727D;
          box-shadow: inset 0 -3px #ffffff;
      }

      #clock,
      #battery,
      #cpu,
      #memory,
      #disk,
      #temperature,
      #backlight,
      #network,
      #pulseaudio,
      #wireplumber,
      #custom-media,
      #tray,
      #mode,
      #idle_inhibitor,
      #scratchpad,
      #power-profiles-daemon,
      #mpd {
          padding: 0 10px;
          color: ${c.foreground};
      }

      #window,
      #workspaces {
          margin: 0 4px;
      }

      /* If workspaces is the leftmost module, omit left margin */
      .modules-left > widget:first-child > #workspaces {
          margin-left: 0;
      }

      /* If workspaces is the rightmost module, omit right margin */
      .modules-right > widget:last-child > #workspaces {
          margin-right: 0;
      }

      #clock {
          background-color: #64727D;
      }

      #cpu {
          background-color: ${c.cyan};
          color: #000000;
      }

      #memory {
          background-color: ${c.yellow};
          color: #000000;
      }

      #network {
          background-color: #2980b9;
      }

      #network.disconnected {
          background-color: #f53c3c;
      }

      #pulseaudio {
          background-color: #f1c40f;
          color: #000000;
      }

      #pulseaudio.muted {
          background-color: #90b1b1;
          color: #2a5c45;
      }

      #wireplumber {
          background-color: #fff0f5;
          color: #000000;
      }

      #wireplumber.muted {
          background-color: #f53c3c;
      }

      #tray {
          background-color: #2980b9;
      }

      #tray > .passive {
          -gtk-icon-effect: dim;
      }

      #tray > .needs-attention {
          -gtk-icon-effect: highlight;
          background-color: #eb4d4b;
      }

      #mpd {
          background-color: #66cc99;
          color: #2a5c45;
      }

      #mpd.disconnected {
          background-color: #f53c3c;
      }

      #mpd.stopped {
          background-color: #90b1b1;
      }

      #mpd.paused {
          background-color: #51a37a;
      }
    '';
    # background-color: rgba(0,0,0,0);
    # border-bottom: 3px solid rgba(100, 114, 125, 0.5);

    #style = ''
    #'';
  };

  systemd.user.services.waybar = {
    Service.Environment = [
      "DISPLAY=:0"
    ];
  };
}

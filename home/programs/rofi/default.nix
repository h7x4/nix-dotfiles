{ pkgs, ... }:
{
  programs.rofi = {
    enable = true;

    # plugins = with pkgs; [
    #   rofi-emoji
    #   rofi-mpd
    #   rofi-pass
    #   rofi-calc
    #   rofi-systemd
    #   rofi-power-menu
    #   rofi-file-browser
    # ];

    font = "Droid Sans 12";
    theme = ./blank.rasi;

    extraConfig = {
      modi = "window,run,drun,ssh,windowcd";
      show-icons = true;
      drun-display-format = "{name}";
      # fullscreen = false;
      threads = 0;
      matching = "fuzzy";
      scroll-method = 0;
      disable-history = false;
      window-thumbnail = true;
      kb-row-up = "Up,Alt+k";
      kb-row-down = "Down,Alt+j";
      kb-row-left = "Alt+h";
      kb-row-right = "Alt+l";
    };
  };
}

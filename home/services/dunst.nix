{ config, pkgs, lib, machineVars, ... }:
{
  services.dunst = {
    enable = true;
    iconTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
      size = "32x32";
    };
    settings = {
      global = {
        title = "Dunst";
        class = "Dunst";
        browser = "${pkgs.xdg-utils}/bin/xdg-open";

        offset = lib.mkIf (!machineVars.wayland) (let
          status-bar-height = config.services.polybar.settings."bar/top".height;
        in "15x${toString (status-bar-height + 10)}");

        corner_radius = 0;
        font = "Droid Sans 9";
        geometry = "300x5-30+50";
        indicate_hidden = "yes";
        markup = "full";
        origin = "top-right";
        separator_color = "frame";
        separator_height = 2;
        transparency = 10;
        word_wrap = "yes";

        alignment = "center";
        vertical_alignment = "center";

        progress_bar = true;
        progress_bar_height = 10;
        progress_bar_min_width = 150;
        progress_bar_max_width = 300;

        mouse_left_click = "close_current";
        mouse_middle_click = "close_all";
        mouse_right_click = "do_action, close_current";
      };

      urgency_low = {
        frame_color = config.colors.defaultColorSet.blue;
        foreground = config.colors.defaultColorSet.foreground;
        background = config.colors.defaultColorSet.background;
        timeout = 4;
      };

      urgency_normal = {
        frame_color = config.colors.defaultColorSet.green;
        foreground = config.colors.defaultColorSet.foreground;
        background = config.colors.defaultColorSet.background;
        timeout = 6;
      };

      urgency_critical = {
        frame_color = config.colors.defaultColorSet.red;
        foreground = config.colors.defaultColorSet.red;
        background = config.colors.defaultColorSet.background;
        timeout = 8;
      };
    };
  };
}

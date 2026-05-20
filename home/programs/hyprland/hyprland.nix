{ lib, ... }:
{
  wayland.windowManager.hyprland = {
    systemd.enable = false;
    systemd.enableXdgAutostart = false;
    configType = "lua";

    settings = {
      on._args = [
        "hyprland.start"
        (lib.generators.mkLuaInline ''
          function()
            hl.exec_cmd("uwsm finalize")
          end
        '')
      ];

      monitor = [
        # TODO: host specific
        {
          output = "eDP-1";
          mode = "3840x2400@90.00Hz";
          position = "0x0";
          scale = "2";
        }

        # PVV Demiurgen
        {
          output = "desc:Hewlett Packard HP ZR24w CNT01711G6";
          mode = "1920x1200";
          position = "1920x-1200";
          scale = "1";
        }
        {
          output = "desc:Hewlett Packard HP ZR24w CNT018103H";
          mode = "1920x1200";
          position = "0x-1200";
          scale = "1";
        }

        # PVV Eirin
        {
          output = "desc:Hewlett Packard HP ZR24w CNT01710L4";
          mode = "1920x1200";
          position = "1920x-1200";
          scale = "1";
        }
        {
          output = "desc:Hewlett Packard HP ZR24w CNT0181039";
          mode = "1920x1200";
          position = "0x-1200";
          scale = "1";
        }

        {
          output = "";
          mode = "preferred";
          position = "auto";
          scale = "auto";
        }
      ];

      config = {
        general = {
          gaps_in = 5;
          gaps_out = 15;

          border_size = 2;

          "col.active_border" = {
            colors = [
              "rgba(33ccffee)"
              "rgba(00ff99ee)"
            ];
            angle = 45;
          };
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
  };
}

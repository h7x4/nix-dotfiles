{ config, pkgs, lib, ... }:
let
  cfg = config.wayland.windowManager.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = let
      exe = lib.getExe;
    in {
      mod._var = "SUPER";

      # https://github.com/xkbcommon/libxkbcommon/blob/master/include/xkbcommon/xkbcommon-keysyms.h
      bind = let
        lua = lib.generators.mkLuaInline;
        mod = key: args: {
          _args = [
            (lua "mod .. \" + ${key}\"")
          ] ++ args;
        };
      in [
        (mod "SHIFT + Q" [
          (lua "hl.dsp.exec_cmd(\"uwsm stop\")")
        ])
        (mod "ALT + SHIFT + Q" [
          (lua "hl.dsp.exec_cmd(\"${pkgs.systemd}/bin/loginctl terminate-user '${config.home.username}'\")")
        ])
        (mod "R" [
          (lua "hl.dsp.exec_cmd(\"uwsm app -- ${exe config.programs.anyrun.package}\")")
        ])
        (mod "T" [
          (lua "hl.dsp.window.float({ action = \"toggle\" })")
        ])

        (mod "F" [
          (lua "hl.dsp.window.fullscreen({ action = \"toggle\", mode = \"maximized\" })")
        ])
        (mod "SHIFT + F" [
          (lua "hl.dsp.window.fullscreen({ action = \"toggle\", mode = \"fullscreen\" })")
        ])

        (mod "C" [
          (lua "hl.dsp.exec_cmd(\"${cfg.finalPackage}/bin/hyprctl reload\")")
        ])

        (mod "BACKSPACE" [
          (lua "hl.dsp.window.close()")
        ])

        (mod "SHIFT + BACKSPACE" [
          (lua "hl.dsp.window.kill()")
        ])

        (mod "SHIFT + RETURN" [
          (lua "hl.dsp.exec_cmd(\"${exe pkgs.app2unit} -t service -C -s app-graphical.slice -- ${exe pkgs.alacritty} --class termTerminal -e ${exe pkgs.tmux} new-session -A -s term\")")
        ])
        (mod "SHIFT + SPACE" [
          (lua "hl.dsp.exec_cmd(\"${exe pkgs.app2unit} -t service -C -s app-graphical.slice -- ${exe pkgs.alacritty} --class termTerminal -e ${exe pkgs.tmux} new-session -A -s term\")")
        ])

        (mod "j" [(lua "hl.dsp.layout(\"cyclenext\")")])
        (mod "k" [(lua "hl.dsp.layout(\"cycleprev\")")])
        (mod "SHIFT + j" [(lua "hl.dsp.layout(\"swapnext\")")])
        (mod "SHIFT + k" [(lua "hl.dsp.layout(\"swapprev\")")])

        (mod "1" [(lua "hl.dsp.focus({ workspace = 1, on_current_monitor = true })")])
        (mod "2" [(lua "hl.dsp.focus({ workspace = 2, on_current_monitor = true })")])
        (mod "3" [(lua "hl.dsp.focus({ workspace = 3, on_current_monitor = true })")])
        (mod "4" [(lua "hl.dsp.focus({ workspace = 4, on_current_monitor = true })")])
        (mod "5" [(lua "hl.dsp.focus({ workspace = 5, on_current_monitor = true })")])
        (mod "6" [(lua "hl.dsp.focus({ workspace = 6, on_current_monitor = true })")])
        (mod "7" [(lua "hl.dsp.focus({ workspace = 7, on_current_monitor = true })")])
        (mod "8" [(lua "hl.dsp.focus({ workspace = 8, on_current_monitor = true })")])
        (mod "9" [(lua "hl.dsp.focus({ workspace = 9, on_current_monitor = true })")])

        (mod "SHIFT + 1" [(lua "hl.dsp.window.move({ workspace = 1 })")])
        (mod "SHIFT + 2" [(lua "hl.dsp.window.move({ workspace = 2 })")])
        (mod "SHIFT + 3" [(lua "hl.dsp.window.move({ workspace = 3 })")])
        (mod "SHIFT + 4" [(lua "hl.dsp.window.move({ workspace = 4 })")])
        (mod "SHIFT + 5" [(lua "hl.dsp.window.move({ workspace = 5 })")])
        (mod "SHIFT + 6" [(lua "hl.dsp.window.move({ workspace = 6 })")])
        (mod "SHIFT + 7" [(lua "hl.dsp.window.move({ workspace = 7 })")])
        (mod "SHIFT + 8" [(lua "hl.dsp.window.move({ workspace = 8 })")])
        (mod "SHIFT + 9" [(lua "hl.dsp.window.move({ workspace = 9 })")])

        (mod "b" [(lua "hl.dsp.exec_cmd(\"${pkgs.fcitx5}/bin/fcitx5-remote -s mozc\")")])
        (mod "n" [(lua "hl.dsp.exec_cmd(\"${pkgs.fcitx5}/bin/fcitx5-remote -s keyboard-no\")")])
        (mod "m" [(lua "hl.dsp.exec_cmd(\"${pkgs.fcitx5}/bin/fcitx5-remote -s keyboard-us\")")])

        (mod "l" [(lua "hl.dsp.exec_cmd(\"${pkgs.systemd}/bin/loginctl lock-session\")")])

        # TODO: fix
        # "super + minus" = "${pkgs.xcalib}/bin/xcalib -invert -alter"

        {
          _args = [
            (lua "\"PRINT\"")
            (lua "hl.dsp.exec_cmd(\"${exe pkgs.grimblast} copy area\")")
          ];
        }
        {
          _args = [
            (lua "\"SHIFT + PRINT\"")
            (lua "hl.dsp.exec_cmd(\"${lib.getExe pkgs.grimblast} save\")")
          ];
        }

        # "SHIFT, Print, exec, ${lib.getExe pkgs.grimblast} save"
        # "shift + @Print" = "${pkgs.maim}/bin/maim --hidecursor --nokeyboard $SCREENSHOT_DIR/$(date +%s).png"

        # "$mod, Print, exec, ${exe pkgs.woomer}"

        (mod "mouse:272" [
          (lua "hl.dsp.window.drag()")
          (lua "{ mouse = true }")
        ])

        (mod "Control_L" [
          (lua "hl.dsp.window.drag()")
          (lua "{ mouse = true }")
        ])

        (mod "mouse:273" [
          (lua "hl.dsp.window.resize()")
          (lua "{ mouse = true }")
        ])

        (mod "ALT_L" [
          (lua "hl.dsp.window.resize()")
          (lua "{ mouse = true }")
        ])

        (mod "p" [
          (lua "hl.dsp.exec_cmd(\"${exe pkgs.mpc} toggle\")")
          (lua "{ locked = true }")
        ])
        {
          _args = [
            (lua "\"XF86AudioPlay\"")
            (lua "hl.dsp.exec_cmd(\"${exe pkgs.mpc} toggle\")")
            (lua "{ locked = true }")
          ];
        }
        {
          _args = [
            (lua "\"XF86AudioPrev\"")
            (lua "hl.dsp.exec_cmd(\"${exe pkgs.mpc} prev\")")
            (lua "{ locked = true }")
          ];
        }
        {
          _args = [
            (lua "\"XF86AudioNext\"")
            (lua "hl.dsp.exec_cmd(\"${exe pkgs.mpc} next\")")
            (lua "{ locked = true }")
          ];
        }
        {
          _args = [
            (lua "\"XF86MonBrightnessUp\"")
            (lua "hl.dsp.exec_cmd(\"${exe pkgs.brightnessctl} s +5%\")")
            (lua "{ locked = true, repeating = true }")
          ];
        }
        {
          _args = [
            (lua "\"XF86MonBrightnessDown\"")
            (lua "hl.dsp.exec_cmd(\"${exe pkgs.brightnessctl} s 5%-\")")
            (lua "{ locked = true, repeating = true }")
          ];
        }
        {
          _args = [
            (lua "\"XF86AudioLowerVolume\"")
            (lua "hl.dsp.exec_cmd(\"${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-\")")
            (lua "{ locked = true, repeating = true }")
          ];
        }
        {
          _args = [
            (lua "\"XF86AudioRaiseVolume\"")
            (lua "hl.dsp.exec_cmd(\"${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+\")")
            (lua "{ locked = true, repeating = true }")
          ];
        }
        (mod "F7" [
          (lua "hl.dsp.exec_cmd(\"${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%-\")")
          (lua "{ locked = true, repeating = true }")
        ])
        (mod "F8" [
          (lua "hl.dsp.exec_cmd(\"${pkgs.wireplumber}/bin/wpctl set-volume @DEFAULT_AUDIO_SINK@ 2%+\")")
          (lua "{ locked = true, repeating = true }")
        ])
      ];
    };
  };
}

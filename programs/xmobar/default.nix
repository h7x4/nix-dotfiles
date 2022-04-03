{ pkgs, colorTheme, ... }: let
  inherit (pkgs) lib;
in {
  programs.xmobar = let
    networkCard = "wlp2s0f0u7u4";
    disks = [
      "/"
      "/data"
      "/data/disks/data2"
    ];
  in {
    enable = true;
    extraConfig = ''
      Config {
        font = "xft:Fira Code Retina:pixelsize=15:antialias=true:hinting=true"
        , additionalFonts = [
          "xft:Droid Sans Japanese:pixelsize=20:antialias=true:hinting=true",
          "xft:Symbola:pixelsize=20",
          "xft:Asana Math:pixelsize=20",
          "xft:Noto Sans Symbols2",
          "xft:FiraCode Nerd Font"
          ]
        , borderColor = "black"
        , border = TopB
        , bgColor = "#272822"
        , fgColor = "grey"
        , alpha = 255
        , position = Static { xpos = 0 , ypos = 0, width = 1920, height = 40 }
        , textOffset = -1
        , iconOffset = -1
        , lowerOnStart = True
        , pickBroadest = False
        , persistent = False
        , hideOnStart = False
        , allDesktops = True
        , overrideRedirect = True
        , commands = [
      
          Run Network "${networkCard}"
            [
      				"-t", "<rx><fn=3>↓</fn> <tx><fn=3>↑</fn>",
              "-L","0",
              "-H","32",
              "--normal","green",
              "--high","red"
            ] 10,
      
          Run Memory ["-t","<usedratio>%"] 10,
          Run Swap ["-t", "<usedratio>%"] 100,
          Run Date "%a %_d %b - %H:%M - W%W" "date" 10,
      		Run Com "${./scripts/mpd_status.sh}" [] "mpc" 10,
      		-- Run Com "${./scripts/wireless.sh}" [] "wi" 100,
      		Run Com "${./scripts/volume.py}" [] "vol" 10,
          Run UnsafeStdinReader,
          Run DiskU [
            ${ lib.concatStringsSep ",\n" (map (d: ''("${d}", "[<used>/<size>]")'') disks) }
          ]
          ["-L", "20", "-H", "50", "-m", "1", "-p", "3",
          "--low", "#a6e22e",
          "--normal", "#f8f8f2",
          "--high", "#f92672"] 20,
      
          Run Battery
            [
              "-t", "<fn=2><acstatus></fn> (<left>%)",
              "--Low", "20",
              "--High", "50",
              "--low", "red",
              "--normal", "yellow",
              "--high", "green",
              "--",
              "-O", "<fc=green>🔌</fc>",
              "-i", "<fc=#00b7ff>🔌</fc>",
              "-o", "<fc=yellow>🔋</fc>"
            ] 50
      
        ]
        , sepChar = "%"
        , alignSep = "}{"
        , template = " <icon=${./lambda.xpm}/> %mpc% %UnsafeStdinReader% }\
          \ <fc=#ee9a00>%date%</fc> \
          \{ %disku% | <fc=lightgreen><fn=2>🐏</fn> %memory%</fc> | <fc=cyan>%${networkCard}%</fc> | <fc=#f5f1bc><fn=3>%vol%</fn></fc>                                    "
      }
    '';

  };
}

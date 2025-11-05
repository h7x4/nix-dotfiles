{ config, pkgs, lib, extendedLib, inputs, ... }: let
    sedColor =
      color:
      inputPattern: # sed regex.
      outputPattern@{ before ? "" , middle ? "", after ? ""}:
      "-e \"s|${inputPattern}|${before}$(tput setaf ${toString color})${middle}$(tput op)${after}|g\"";

    colorRed = sedColor 1;

    colorSlashes = colorRed "/" { middle = "/"; };

    p = name: let
      pkg = pkgs.${name};
      exe = if pkg.meta ? mainProgram then pkg.meta.mainProgram else name;
    in "${pkg}/bin/${exe}";
in {
  systemd.user.tmpfiles.settings."10-shell"."${config.xdg.configHome}/mutable_env.sh".f = {
    user = config.home.username;
    mode = "0700";
  };

  local.shell.aliases = {

    # ░█▀▄░█▀▀░█▀█░█░░░█▀█░█▀▀░█▀▀░█▄█░█▀▀░█▀█░▀█▀░█▀▀
    # ░█▀▄░█▀▀░█▀▀░█░░░█▀█░█░░░█▀▀░█░█░█▀▀░█░█░░█░░▀▀█
    # ░▀░▀░▀▀▀░▀░░░▀▀▀░▀░▀░▀▀▀░▀▀▀░▀░▀░▀▀▀░▀░▀░░▀░░▀▀▀

    # Replacing all of coreutils with rust, lol

    "System Tool Replacements" = {

      # Convention: if replaced tool is useful in some situations, let it be available
      #             as its own command with an underscore appended
      #
      #             Example:   cp -> cp_

      cd_ = "builtin cd";
      cd = lib.mkIf config.programs.zoxide.enable "z";

      cp_ = "${pkgs.coreutils}/bin/cp";
      cp  = p "xcp";

      cloc_ = p "cloc";
      cloc = p "tokei";

      df_ = "${pkgs.coreutils}/bin/df";
      df = p "duf";

      scp_ = "/run/current-system/sw/bin/scp";
      scp = "${p "rsync"} --progress --human-readable --recursive";

      cat_ = "${pkgs.coreutils}/bin/cat";
      cat  = p "bat";

      htop_ = p "htop";
      htop = p "bottom";

      dig_ = p "dig";
      dig = p "dogdns";

      man_ = p "man";
      man = "${pkgs.bat-extras.batman}/bin/batman";

      strace_ = p "strace";
      strace = p "intentrace";

      lsusb_ = p "usbutils";
      lsusb = p "cyme";

      # Flags are incompatible, so they are suffixed by -x
      psx = p "procs";
      findx = p "fd";

      grep_ = p "gnugrep";
      grep = p "ripgrep";

      ag = p "ripgrep";
      sxiv = p "nsxiv";

      ls_ = "${pkgs.coreutils}/bin/ls --color=always";
      ls = p "eza";
      la = "${p "eza"} -lah --changed --time-style long-iso --git --group";
      lsa = "la";

      killall_ = p "killall";
      killall = {
        type = ";";
        alias = [
          ''echo "killall is dangerous on non-gnu platforms. Using 'pkill -x'"''
          "pkill -x"
        ];
      };

      watch_ = "${pkgs.procps}/bin/watch";
      watch = p "viddy";
    };

    # ░█▀▀░█▀█░█░░░█▀█░█▀▄░▀█▀░▀▀█░█▀▀░█▀▄
    # ░█░░░█░█░█░░░█░█░█▀▄░░█░░▄▀░░█▀▀░█░█
    # ░▀▀▀░▀▀▀░▀▀▀░▀▀▀░▀░▀░▀▀▀░▀▀▀░▀▀▀░▀▀░

    # Normal commands, just with colors.

    "Colorized" = {
      ip = "ip --color=always";
      diff = "diff --color=auto";
      grep = "grep --color=always";
      # TODO: doesn't work
      # make = "${colormake}/bin/colormake";
    };

    # ░█▀█░▀█▀░█░█
    # ░█░█░░█░░▄▀▄
    # ░▀░▀░▀▀▀░▀░▀

    # Nix related aliases

    "Nix Stuff" = {
      nxr = "sudo nixos-rebuild switch";
      nxrl = "sudo nixos-rebuild switch --option builders '' -L";

      nix-check-syntax = "nix-instantiate --parse-only";

      nxr-hm = "sudo nixos-rebuild switch --flake ~/nix#home-manager-tester";
      nxr-ks = "sudo nixos-rebuild switch --flake ~/nix#kasei";

      # TODO: does this need to be a function?
      # ofborg-build = {};

      ofborg-nixos-eval = {
        type = " ";
        alias = [
          "HOME=/homeless-shelter"
          "NIX_PATH=ofborg-nixpkgs-pr=$(pwd)"
          "nix-instantiate"
          "./nixos/release.nix"
          "-A manual"
          "--option restrict-eval true"
          "--option build-timeout 1800"
          "--argstr system ${pkgs.system}"
          "--show-trace"
        ];
      };

      ofborg-pkgs-eval = {
        type = " ";
        alias = [
          "HOME=/homeless-shelter"
          "NIX_PATH=ofborg-nixpkgs-pr=$(pwd)"
          "nix-instantiate"
          "./pkgs/top-level/release.nix"
          "-A manual"
          "--option restrict-eval true"
          "--option build-timeout 1800"
          "--argstr system ${pkgs.system}"
          "--show-trace"
        ];
      };
    };

    # ░█▀▀░█░█░█▀▀░▀█▀░█▀▀░█▄█░█▀▄
    # ░▀▀█░░█░░▀▀█░░█░░█▀▀░█░█░█░█
    # ░▀▀▀░░▀░░▀▀▀░░▀░░▀▀▀░▀░▀░▀▀░

    # Systemd related aliases

    "Systemd Stuff" = {
      sc = "systemctl";
      scu = "systemctl --user";

      scs = "systemctl status";
      scus = "systemctl --user status";

      scc = "systemctl cat";
      scuc = "systemctl --user cat";

      jeu = "journalctl -eu";
      jeuu = "journalctl --user -eu";
    };

    # ░█▀▀░█▀█░█▀▀░▀█▀░█░█░█▀█░█▀▄░█▀▀
    # ░▀▀█░█░█░█▀▀░░█░░█▄█░█▀█░█▀▄░█▀▀
    # ░▀▀▀░▀▀▀░▀░░░░▀░░▀░▀░▀░▀░▀░▀░▀▀▀

    # Aliases that are so long/piped that they could be considered new software.

    "Software" = {
      skusho = "${p "maim"} --hidecursor --nokeyboard $(echo $SCREENSHOT_DIR)/$(date_%s).png";
      skushoclip = {
        type = "|";
        alias = [
          "${p "maim"} --hidecursor --nokeyboard --select"
          "${p "xclip"} -selection clipboard -target image/png -in"
        ];
      };

      dp-check = lib.mkIf config.services.dropbox.enable {
        type = "|";
        alias = [
          "ls -l /proc/$(pidof dropbox)/fd"
          "egrep -v 'pipe:|socket:|/dev'"
          "grep \"${config.services.dropbox.path}/[^.]\""
        ];
      };

      subdirs-to-cbz = {
        type = " ";
        alias = [
          ''for dir in "./*";''
          ''  ${p "zip"} -r "$dir.cbz" "$d";''
          ''done''
        ];
      };

      connectedIps = {
        type = "|";
        alias = [
          "netstat -tn 2>/dev/null"
          "grep :$1"
          "awk '{print $5}'"
          "cut -d: -f1"
          "sort"
          "uniq -c"
          "sort -nr"
          "head"
        ];
      };

      path = {
        type = "|";
        alias = [
          "echo $PATH"
          "sed -e 's/:/\n/g' ${colorSlashes}"
          "sort"
        ];
      };

      aliasc = let
        colorAliasNames = colorRed "\\(^[^=]*\\)=" { middle = "\\1"; after = "\\t"; };
        # The '[^]]' (character before /nix should not be ']') is there so that this
        # alias definition won't be removed.
        removeNixLinks = "-e 's|\\([^]]\\)/nix/store/.*/bin/|\\1|'";
      in {
        type = "|";
        alias = [
          "alias"
          "sed ${colorAliasNames} ${removeNixLinks}"
          "column -ts $'\\t'"
        ];
      };

      ports = let
        colorFirstColumn = colorRed "(^[^ ]+)" {middle = "\\1";};
      in {
        type = "|";
        alias = [
          "sudo netstat -tulpn"
          "grep LISTEN"
          "sed -r 's/\\s+/ /g'"
          "cut -d' ' -f 4,7"
          "column -t"
          "sed -r ${colorFirstColumn} ${colorSlashes}"
        ];
      };
    };

    # ░█▀█░█░░░▀█▀░█▀█░█▀▀░█▀▀░█▀▀
    # ░█▀█░█░░░░█░░█▀█░▀▀█░█▀▀░▀▀█
    # ░▀░▀░▀▀▀░▀▀▀░▀░▀░▀▀▀░▀▀▀░▀▀▀

    # Normal commands that are just shortened. What would normally be considered
    # the "technically correct definition" of an alias

    "Actual Aliases" = {
      # dp = "${dropbox-cli}/bin/dropbox";

      # Having 'watch' with a space after as an alias, enables it to expand other aliases
      watch = "${pkgs.procps}/bin/watch ";

      concatPdfs = {
        type = ";";
        alias = [
          ''echo "${extendedLib.termColors.front.red "Concatenating all pdfs in current directory to 'out.pdf'"}"''
          "${pkgs.poppler_utils}/bin/pdfunite *.pdf out.pdf"
        ];
      };

      cdtmp = "cd \"$(mktemp -d)\"";

      open = "${pkgs.xdg-utils}/bin/xdg-open";

      e = "$EDITOR";
      m = p "ncmpcpp";
      g = "${pkgs.gitoxide}/bin/gix";
      p = "${pkgs.python3Packages.ipython}/bin/ipython";
      s = p "nsxiv";
      v = p "mpv";
      zt = p "zathura";
    };

    # ░█▄█░▀█▀░█▀▀░█▀▀
    # ░█░█░░█░░▀▀█░█░░
    # ░▀░▀░▀▀▀░▀▀▀░▀▀▀

    # I didn't know where else to put these ¯\_(ツ)_/¯

    "Misc" = {
      youtube-dl-list = {
        type = " ";
        alias = [
          (p "yt-dlp")
          "-f \"bestvideo[ext=mp4]+bestaudio[e=m4a]/bestvideo+bestaudio\""
          "-o \"%(playlist_index)s-%(title)s.%(ext)s\""
        ];
      };

      music-dl = "${p "yt-dlp"} --extract-audio -f \"bestaudio[ext=m4a]/best\"";
      music-dl-list = {
        type = " ";
        alias = [
          (p "yt-dlp")
          "--extract-audio"
          "-f \"bestaudio[ext=m4a]/best\""
          "-o \"%(playlist_index)s-%(title)s.%(ext)s\""
        ];
      };

      list-applications = {
        type = ";";
        alias = map (x: "${p "eza"} -lah ${x}") [
          "/run/current-system/sw/share/applications"
          "~/.local/share/applications"
          "~/.local/state/nix/profiles/home-manager/home-path/share/applications"
        ];
      };

      cdr = "$(git rev-parse --show-toplevel)";

      view-latex = "${pkgs.texlive.combined.scheme-full}/bin/latexmk -pdf -pvc main.tex";

      reload-tmux = "${p "tmux"} source $HOME/.config/tmux/tmux.conf";
    };

    # ░█▀▀░█▀▀░█▀█░█▀▀░█▀▄░█▀█░▀█▀░█▀▀░█▀▄
    # ░█░█░█▀▀░█░█░█▀▀░█▀▄░█▀█░░█░░█▀▀░█░█
    # ░▀▀▀░▀▀▀░▀░▀░▀▀▀░▀░▀░▀░▀░░▀░░▀▀▀░▀▀░

    # Code generated commands

    "Generated" = {
      "cds" = lib.pipe (lib.range 1 9) [
        (map
          (n: {
            realCommand = "cd " + (builtins.concatStringsSep "/" (lib.replicate n ".."));
            aliases = [
              ("cd" + (lib.strings.replicate (n + 1) "."))
              ("cd." + toString n)
              (lib.strings.replicate (n + 1) ".")
              ("." + toString n)
              (".." + toString n)
            ];
          })
        )
        (map
          ({ realCommand, aliases }: map (alias: {
            name = alias;
            value = {
              alias = [ realCommand ];
              shells = [
                "bash"
                "zsh"
                "fish"
              ];
            };
          }) aliases)
        )
        builtins.concatLists
        builtins.listToAttrs
      ];
    };
  };

  # TODO: create arbitrarily nested function tree, like aliases
  home.packages = [
    (pkgs.writeShellApplication {
      name = "md-to-pdf";
      runtimeInputs = [ pkgs.pandoc ];
      text = ''
        if [[ "$#" != 1 && "$#" != 2 ]]; then
          (>&2 echo "Usage: md-to-pdf <IN-PATH> [<OUT-PATH>]")
          exit 2
        fi

        IN_PATH="$1"

        if [[ "$#" != 1 ]]; then
          OUT_PATH="''${1%.md}.pdf"
        else
          OUT_PATH="$1"
        fi

        ARGS=(
          "$IN_PATH"
          -f gfm
          -V linkcolor:blue
          -V geometry:a4paper
          -V geometry:margin=2cm
          -V mainfont="Droid Sans"
          --pdf-engine=xelatex
          -o "$OUT_PATH"
        )

        pandoc "''${ARGS[@]}"
      '';
    })
    # md-to-pdf = functors.shellJoin.wrap [
    #   "pandoc \"$1\""
    #   "-f gfm"
    #   "-V linkcolor:blue"
    #   "-V geometry:a4paper"
    #   "-V geometry:margin=2cm"
    #   "-V mainfont=\"Droid Sans\""
    #   "--pdf-engine=xelatex"
    #   "-o \"$2\""
    # ];

    (pkgs.writeShellApplication {
      name = "rwhich";
      runtimeInputs = [
        pkgs.coreutils
        pkgs.findutils
      ];
      text = ''
        if [[ "$#" != 1 ]]; then
          (>&2 echo "Usage: rwhich <PATH>")
          exit 2
        fi

        which "$1" | xargs realpath
      '';
    })
    # rwhich = functors.shellJoin.wrap [
    #   "which \"$@\""
    #   "xargs realpath --"
    # ];

    # move $1 into $1.bak, copy $1.bak into $1.
    (pkgs.writeShellApplication {
      name = "bak";
      runtimeInputs = [ pkgs.coreutils ];
      text = ''
        if [[ "$#" != 1 ]]; then
          (>&2 echo "Usage: bak <PATH>")
          exit 2
        fi

        mv "$1" "$1.bak" && cp "$1.bak" "$1"
      '';
    })
  ];

  # local.shell.variables = {
    # POWERLEVEL9K_LEFT_PROMPT_ELEMENTS = ["dir" "vcs"];
    # NIX_PATH = ''$HOME/.nix-defexpr/channels$\{NIX_PATH:+:}$NIX_PATH'';
  # };
}

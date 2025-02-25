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
  sops.secrets."nordicsemi/envvars" = {
    sopsFile = ../secrets/home.yaml;
  };


  programs.bash.bashrcExtra = ''
    source "${config.sops.secrets."nordicsemi/envvars".path}"
  '';

  programs.zsh.envExtra = ''
    source "${config.sops.secrets."nordicsemi/envvars".path}"
  '';

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

      m = p "ncmpcpp";
      g = p "gitoxide";
      p = "${pkgs.python3Packages.ipython}/bin/ipython";
      s = p "nsxiv";
      v = p "mpv";
      zed = p "zed-editor";
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

      view-latex = "${pkgs.texlive.combined.scheme-full}/bin/latexmk -pdf -pvc main.tex";

      reload-tmux = "${p "tmux"} source $HOME/.config/tmux/tmux.conf";

      nordic-vpn = lib.concatStringsSep " | " [
        "${p "gpauth"} \"$NORDIC_VPN_ENDPOINT\" --gateway --browser default 2>/dev/null"
        "sudo ${p "gpclient"} connect \"$NORDIC_VPN_ENDPOINT\" --as-gateway --cookie-on-stdin"
      ];
    };

    # ░█▀▀░█▀▀░█▀█░█▀▀░█▀▄░█▀█░▀█▀░█▀▀░█▀▄
    # ░█░█░█▀▀░█░█░█▀▀░█▀▄░█▀█░░█░░█▀▀░█░█
    # ░▀▀▀░▀▀▀░▀░▀░▀▀▀░▀░▀░▀░▀░░▀░░▀▀▀░▀▀░

    # Code generated commands

    "Generated" = {
      "cds" = let
        inherit (lib.strings) concatStringsSep;
        inherit (extendedLib.strings) repeatString;

        inherit (lib.lists) range flatten replicate;
        inherit (lib.attrsets) nameValuePair listToAttrs;

        nthCds = n: [
          ("cd" + (repeatString "." (n + 1)))
          ("cd." + toString n)
          (repeatString "." (n + 1))
          ("." + toString n)
          (".." + toString n)
        ];
        realCommand = n: "cd " + (concatStringsSep "/" (replicate n ".."));

        nthCdsAsNameValuePairs = n: map (cmd: nameValuePair cmd (realCommand n)) (nthCds n);
        allCdNameValuePairs = flatten (map nthCdsAsNameValuePairs (range 1 9));
      in
        listToAttrs allCdNameValuePairs;
    };
  };

  # TODO: flatten functions
  # local.shell.functions = {
  #   all = {
  #     md-to-pdf = functors.shellJoin.wrap [
  #       "pandoc \"$1\""
  #       "-f gfm"
  #       "-V linkcolor:blue"
  #       "-V geometry:a4paper"
  #       "-V geometry:margin=2cm"
  #       "-V mainfont=\"Droid Sans\""
  #       "--pdf-engine=xelatex"
  #       "-o \"$2\""
  #     ];
  #   };
  # };

  # local.shell.variables = {
    # POWERLEVEL9K_LEFT_PROMPT_ELEMENTS = ["dir" "vcs"];
    # NIX_PATH = ''$HOME/.nix-defexpr/channels$\{NIX_PATH:+:}$NIX_PATH'';
  # };
}

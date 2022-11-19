{ pkgs, lib, extendedLib, config, ... }: let

  sedColor =
    color:
    inputPattern:
    outputPattern:
    "-e \"s|${inputPattern}|${outputPattern.before or ""}$(tput setaf ${toString color})${outputPattern.middle}$(tput op)${outputPattern.after or ""}|g\"";

  colorRed = sedColor 1;

  colorSlashes = colorRed "/" {middle = "/";};

  # Context Functors
  functors = let
    inherit (lib.strings) concatStringsSep;
    inherit (extendedLib.termColors.front) blue;
    genWrapper = type: value: { inherit type; inherit value; };
  in
    {
      shellPipe = {
        wrap = genWrapper "shellPipe";
        apply = f: concatStringsSep " | " f.value;
        stringify = f: concatStringsSep (blue "\n| ") f.value;
      };
      shellAnd = {
        wrap = genWrapper "shellAnd";
        apply = f: concatStringsSep " && " f.value;
        stringify = f: concatStringsSep (blue "\n&& ") f.value;
      };
      shellThen = {
        wrap = genWrapper "shellThen";
        apply = f: concatStringsSep "; " f.value;
        stringify = f: concatStringsSep (blue ";\n  ") f.value;
      };
      shellJoin = {
        wrap = genWrapper "shellJoin";
        apply = f: concatStringsSep " " f.value;
        stringify = f: concatStringsSep " \\\n   " f.value;
      };
    };

  # AttrSet -> Bool
  isFunctor = let
    inherit (lib.lists) any;
    inherit (lib.attrsets) attrValues;
  in
    attrset:
      if !(attrset ? "type")
      then false
      else any (f: (f.wrap "").type == attrset.type) (attrValues functors);

in rec {
  _module.args.shellOptions = {
    aliases = let
      shellPipe = functors.shellPipe.wrap;
      shellJoin = functors.shellJoin.wrap;
      shellAnd = functors.shellAnd.wrap;
      shellThen = functors.shellThen.wrap;
    in with pkgs; {

      # ░█▀▄░█▀▀░█▀█░█░░░█▀█░█▀▀░█▀▀░█▄█░█▀▀░█▀█░▀█▀░█▀▀
      # ░█▀▄░█▀▀░█▀▀░█░░░█▀█░█░░░█▀▀░█░█░█▀▀░█░█░░█░░▀▀█
      # ░▀░▀░▀▀▀░▀░░░▀▀▀░▀░▀░▀▀▀░▀▀▀░▀░▀░▀▀▀░▀░▀░░▀░░▀▀▀

      # Replacing all of coreutils with rust, lol

      "System Tool Replacements" = {

        # Convention: if replaced tool is useful in some situations, let it be available
        #             as its own command with its first character doubled.
        #
        #             Example:   cp -> ccp

        cd = "z";

        ccp = "${coreutils}/bin/cp";
        cp  = "${rsync}/bin/rsync --progress --human-readable";
        cpr = "${rsync}/bin/rsync --progress --human-readable --recursive";

        ccat = "${coreutils}/bin/cat";
        cat  = "${bat}/bin/bat";

        htop = "${bottom}/bin/btm";
        hhtop = "${htop}/bin/htop";

        # This is potentially dangerous, as procs flags are totally different
        ps = "${procs}/bin/procs";

        # Find flags are so different that I've renamed fd to fin for time being
        fin = "${fd}/bin/fd";

        ag="${ripgrep}/bin/rg";

        lls = "${coreutils}/bin/ls --color=always";
        ls = "${exa}/bin/exa";
        la = "${exa}/bin/exa -lah --changed --time-style long-iso --git --group";
        lsa = "la";

        killall = "echo \"killall is dangerous on non-gnu platforms. Using 'pkill -x'\"; pkill -x";
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

      # ░█▀▄░█▀▀░█▄█░▀█▀░█▀█░█▀▄░█▀▀░█▀▄░█▀▀
      # ░█▀▄░█▀▀░█░█░░█░░█░█░█░█░█▀▀░█▀▄░▀▀█
      # ░▀░▀░▀▀▀░▀░▀░▀▀▀░▀░▀░▀▀░░▀▀▀░▀░▀░▀▀▀

      # Stuff that I constantly forget...

      "Reminders" = {
        regex-escapechars = "echo \"[\\^$.|?*+()\"";
        aliases = "${coreutils}/bin/cat $HOME/${config.xdg.dataFile.aliases.target}";
      };

      # ░█▀█░▀█▀░█░█
      # ░█░█░░█░░▄▀▄
      # ░▀░▀░▀▀▀░▀░▀

      # Nix related aliases

      "Nix Stuff" = {

        # FIXME: This for some reason uses an outdated version of home-manager and nixos-rebuild
        # hs = "${pkgs.home-manager}/bin/home-manager switch";
        # nxr = "sudo ${nixos-rebuild}/bin/nixos-rebuild switch";

        hms = "home-manager switch";
        nxr = "sudo nixos-rebuild switch";
        nxp = "nix-shell -p ";

        nxc = "sudoedit /etc/nixos/configuration.nix";
        nxh = "vim ~/.config/nixpkgs/home.nix";
        ns = "nix-shell";
      };

      # ░█▀▀░█▀█░█▀▀░▀█▀░█░█░█▀█░█▀▄░█▀▀
      # ░▀▀█░█░█░█▀▀░░█░░█▄█░█▀█░█▀▄░█▀▀
      # ░▀▀▀░▀▀▀░▀░░░░▀░░▀░▀░▀░▀░▀░▀░▀▀▀

      # Aliases that are so long/piped that they could be considered new software.

      "Software" = {

        skusho = "${maim}/bin/maim --hidecursor --nokeyboard $(echo $SCREENSHOT_DIR)/$(date_%s).png";
        skushoclip = shellPipe [
          "${maim}/bin/maim --hidecursor --nokeyboard --select"
          "${xclip}/bin/xclip -selection clipboard -target image/png -in"
        ];

        dp-check = shellPipe [
          "ls -l /proc/$(pidof dropbox)/fd"
          "egrep -v 'pipe:|socket:|/dev'"
          "grep \"${config.services.dropbox.path}/[^.]\""
        ];

        subdirs-to-cbz = shellJoin [
          "for dir in \"./*\";"
          "  ${zip}/bin/zip -r \"$dir.cbz\" \"$d\";"
          "done"
        ];

        connectedIps = shellPipe [
          "netstat -tn 2>/dev/null"
          "grep :$1"
          "awk '{print $5}'"
          "cut -d: -f1"
          "sort"
          "uniq -c"
          "sort -nr"
          "head"
        ];

        path = "echo $PATH | sed -e 's/:/\\n/g' ${colorSlashes} | sort";

        wowify = "${toilet}/bin/toilet -f pagga | ${lolcat}/bin/lolcat";

        aliasc = let
          colorAliasNames = colorRed "\\(^[^=]*\\)=" {middle = "\\1"; after = "\\t";};
          # The '[^]]' (character before /nix should not be ']') is there so that this
          # alias definition won't be removed.
          removeNixLinks = "-e 's|\\([^]]\\)/nix/store/.*/bin/|\\1|'";
        in
          shellPipe [
            "alias"
            "sed ${colorAliasNames} ${removeNixLinks}"
            "column -ts $'\\t'"
          ];

        ports = let
          colorFirstColumn = colorRed "(^[^ ]+)" {middle = "\\1";};
        in
          shellPipe [
            "sudo netstat -tulpn"
            "grep LISTEN"
            "sed -r 's/\\s+/ /g'"
            "cut -d' ' -f 4,7"
            "column -t"
            "sed -r ${colorFirstColumn} ${colorSlashes}"
          ];
      };

      # ░█▀█░█░░░▀█▀░█▀█░█▀▀░█▀▀░█▀▀
      # ░█▀█░█░░░░█░░█▀█░▀▀█░█▀▀░▀▀█
      # ░▀░▀░▀▀▀░▀▀▀░▀░▀░▀▀▀░▀▀▀░▀▀▀

      # Normal commands that are just shortened. What would normally be considered
      # the "technically correct definition" of an alias

      "Actual Aliases" = {
        dp = "${dropbox-cli}/bin/dropbox";

        # Having 'watch' with a space after as an alias, enables it to expand other aliases
        watch = "${procps}/bin/watch ";

        concatPdfs = shellThen [
          "echo \"${extendedLib.termColors.front.red "Concatenating all pdfs in current directory to 'out.pdf'"}\""
          "${poppler_utils}/bin/pdfunite *.pdf out.pdf"
        ];

        m = "${ncmpcpp}/bin/ncmpcpp";
        p = "${python39Packages.ipython}/bin/ipython";
        s = "${sxiv}/bin/sxiv";
        v = "${mpv}/bin/mpv";
        zt = "${zathura}/bin/zathura";
      };

      # ░█▄█░▀█▀░█▀▀░█▀▀
      # ░█░█░░█░░▀▀█░█░░
      # ░▀░▀░▀▀▀░▀▀▀░▀▀▀

      # I didn't know where else to put these ¯\_(ツ)_/¯

      "Misc" = {
        youtube-dl-list = shellJoin [
          "${yt-dlp}/bin/yt-dlp"
          "-f \"bestvideo[ext=mp4]+bestaudio[e=m4a]/bestvideo+bestaudio\""
          "-o \"%(playlist_index)s-%(title)s.%(ext)s\""
        ];

        music-dl = "${yt-dlp}/bin/yt-dlp --extract-audio -f \"bestaudio[ext=m4a]/best\"";
        music-dl-list = shellJoin [
          "${yt-dlp}/bin/yt-dlp"
          "--extract-audio"
          "-f \"bestaudio[ext=m4a]/best\""
          "-o \"%(playlist_index)s-%(title)s.%(ext)s\""
        ];

        view-latex = "${texlive.combined.scheme-full}/bin/latexmk -pdf -pvc main.tex";

        reload-tmux = "${tmux}/bin/tmux source $HOME/.config/tmux/tmux.conf";
      };

      # ░█▀▀░█▀▀░█▀█░█▀▀░█▀▄░█▀█░▀█▀░█▀▀░█▀▄
      # ░█░█░█▀▀░█░█░█▀▀░█▀▄░█▀█░░█░░█▀▀░█░█
      # ░▀▀▀░▀▀▀░▀░▀░▀▀▀░▀░▀░▀░▀░░▀░░▀▀▀░▀▀░

      # Code generated commands

      "Generated" = {
        "cds" = let
          inherit (lib.strings) concatStringsSep;
          inherit (extendedLib.strings) repeatString;

          inherit (lib.lists) range flatten;
          inherit (extendedLib.lists) repeat;

          inherit (lib.attrsets) nameValuePair listToAttrs;

          nthCds = n: [
            ("cd" + (repeatString "." (n + 1)))
            ("cd." + toString n)
            (repeatString "." (n + 1))
            ("." + toString n)
            (".." + toString n)
          ];
          realCommand = n: "cd " + (concatStringsSep "/" (repeat ".." n));

          nthCdsAsNameValuePairs = n: map (cmd: nameValuePair cmd (realCommand n)) (nthCds n);
          allCdNameValuePairs = flatten (map nthCdsAsNameValuePairs (range 1 9));
        in
          listToAttrs allCdNameValuePairs;

        "Package Managers" = let
          inherit (lib.attrsets) nameValuePair listToAttrs;

          packageManagers = [
            "apt"
            "dpkg"
            "flatpak"
            "pacman"
            "pamac"
            "paru"
            "rpm"
            "snap"
            "xbps"
            "yay"
            "yum"
          ];

          command = "${coreutils}/bin/cat $HOME/${config.xdg.dataFile.packageManagerLecture.target}";
          nameValuePairs = map (pm: nameValuePair pm command) packageManagers;
        in listToAttrs nameValuePairs;
      };
    };

    # TODO: flatten functions
    functions = {
      all = {
        md-to-pdf = functors.shellJoin.wrap [
          "pandoc \"$1\""
          "-f gfm"
          "-V linkcolor:blue"
          "-V geometry:a4paper"
          "-V geometry:margin=2cm"
          "-V mainfont=\"Droid Sans\""
          "--pdf-engine=xelatex"
          "-o \"$2\""
        ];
      };
    };

    variables = {
      POWERLEVEL9K_LEFT_PROMPT_ELEMENTS = ["dir" "vcs"];
      # NIX_PATH = ''$HOME/.nix-defexpr/channels$\{NIX_PATH:+:}$NIX_PATH'';
    };

    flattened.aliases = let
      inherit (lib.attrsets) mapAttrs attrValues filterAttrs isAttrs;
      inherit (extendedLib.attrsets) concatAttrs;
      inherit (lib.strings) isString concatStringsSep;

      applyFunctor = attrset: functors.${attrset.type}.apply attrset;

      # TODO: better naming
      allAttrValuesAreStrings = attrset: let

        # [ {String} ]
        filteredAliases = [(filterAttrs (n: v: isString v) attrset)];

        # [ {String} ]
        remainingFunctors = let
          functorSet = filterAttrs (n: v: isAttrs v && isFunctor v) attrset;
          appliedFunctorSet = mapAttrs (n: v: applyFunctor v) functorSet;
        in [ appliedFunctorSet ];

        # [ {AttrSet} ]
        remainingAliasSets = attrValues (filterAttrs (n: v: isAttrs v && !(isFunctor v)) attrset);

        # [ {String} ]
        recursedAliasSets = filteredAliases
                          ++ (remainingFunctors)
                          ++ (map allAttrValuesAreStrings remainingAliasSets);
      in concatAttrs recursedAliasSets;

    in
      allAttrValuesAreStrings _module.args.shellOptions.aliases;
  };

  xdg.dataFile = {
    aliases = {
      text = let
        inherit (lib.strings) stringLength;
        inherit (extendedLib.strings) unlines wrap' replaceStrings' repeatString;
        inherit (lib.attrsets) attrValues mapAttrs isAttrs;
        inherit (lib.lists) remove;
        inherit (lib.trivial) mapNullable;
        inherit (extendedLib.termColors.front) red green blue;

        # int -> String -> AttrSet -> String
        stringifyCategory = level: name: category:
        unlines
          (["${repeatString "  " level}[${green name}]"] ++
          (attrValues (mapAttrs (n: v: let
            # String
            indent = repeatString "  " level;

            # String -> String
            removeNixLinks = text: let
              maybeMatches = builtins.match "(|.*[^)])(/nix/store/.*/bin/).*" text;
              matches = mapNullable (remove "") maybeMatches;
            in
              if (maybeMatches == null)
              then text
              else replaceStrings' matches "" text;

            applyFunctor = attrset: let
              applied = functors.${attrset.type}.stringify attrset;
              indent' = indent + (repeatString " " ((stringLength " -> \"") + (stringLength n))) + " ";
            in
              replaceStrings' ["\n"] ("\n" + indent') applied;

            recurse = stringifyCategory (level + 1) n v;
          in
          if !(isAttrs v) then "${indent}  ${red n} -> ${wrap' (blue "\"") (removeNixLinks v)}" else
          if isFunctor v  then "${indent}  ${red n} -> ${wrap' (blue "\"") (removeNixLinks (applyFunctor v))}" else
          recurse) category)));
      in
        (stringifyCategory 0 "Aliases" _module.args.shellOptions.aliases) + "\n";
      };
      packageManagerLecture = {
      target = "package-manager.lecture";
      text = let
        inherit (extendedLib.strings) unlines;
        inherit (extendedLib.termColors.front) red blue;
      in unlines [
        ((red "This package manager is not installed on ") + (blue "NixOS") + (red "."))
        ((red "Either use ") + ("\"nix-env -i\"") + (red " or install it through a configuration file."))
        ""
      ];
    };
  };
}

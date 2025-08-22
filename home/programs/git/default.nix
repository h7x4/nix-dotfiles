{ config, pkgs, lib, ... }:
let
  cfg = config.programs.git;

  github-uri-prefixes =  [
    # Preferred
    "github:"

    # Alternative
    "https://github.com/"
    "ssh://git@github.com:"
    "git@github.com:"
    "github.com:"
  ];
in
lib.mkIf cfg.enable {
  programs.git = lib.mkMerge [
    {
      package = pkgs.gitFull;

      userName = "h7x4";
      userEmail = "h7x4@nani.wtf";

      signing = {
        key = "46B9228E814A2AAC";
        # format = "openpgp";
        signByDefault = true;
      };

      maintenance.enable = true;

      lfs.enable = true;

      delta = {
        enable = true;
        options = {
          line-numbers = true;
          side-by-side = true;
          theme = "Monokai Extended Origin";
        };
      };

      aliases = {
        aliases = "!git config --get-regexp alias | sed -re 's/alias\\.(\\S*)\\s(.*)$/\\1 = \\2/g'";
        authors = "shortlog --summary --numbered --email";
        delete-merged = "!git branch --merged | grep -v '\\*' | xargs -n 1 git branch -d";
        ff = "fixup-fixup";
        fi = "fixup-interactive";
        forcepush = "push --force-with-lease --force-if-includes";
        git = "!git";
        pp = "post-pr";
        rebase-author = "rebase -i -x \"git commit --amend --reset-author -CHEAD\"";
        reset-to-upstream = "!git reset --hard \"origin/$(git rev-parse --abbrev-ref HEAD)\"";
        rf = "rebase-fixups";
        si = "switch-interactive";
        subs = "submodule update --init --recursive";
      } // (let
        c = c: s: "%C(${c})${s}%C(reset)";
      in {
        graph = let
          fmt = lib.concatStringsSep "" [
            " - "
            (c "bold blue" "%h")
            " - "
            (c "bold green" "(%ar)")
            " "
            (c "white" "> %s")
            " "
            (c "dim white" "- %an")
            (c "bold yellow" "%d")
          ];
        in "log --graph --abbrev-commit --decorate --format=format:'${fmt}' --all";

        graphv = let
          fmt = lib.concatStringsSep "" [
            (c "bold blue" "%h")
            " - "
            (c "bold cyan" "%aD")
            " "
            (c "bold green" "(%ar)")
            (c "bold yellow" "%d")
            "%n"
            "          "
            (c "white" "%s")
            " "
            (c "dim white" "- %an")
          ];
        in "log --graph --abbrev-commit --decorate --format=format:'${fmt}' --all";

        l = let
          fmt = lib.concatStringsSep "%n" (map (x: if builtins.isList x then lib.concatStringsSep " " x else x) [
            [ (c "bold yellow" "%H") (c "auto" "%d") ]
            [ (c "bold white" "Author:") (c "bold cyan" "%aN <%aE>") (c "bold green" "(%ah)") ]
            [ (c "bold white" "Committer:") (c "bold cyan" "%cN <%cE>") (c "bold green" "(%ah)") ]
            [ (c "bold white" "GPG: (%G?)") (c "bold magenta" "%GF") "-" (c "bold cyan" "%GS") (c "bold blue" "(%GT) ") ]
            ""
            (c "bold white" "# %s")
            "%+b"
            (c "dim yellow" "%+N")
          ]);
          # sedExpressions = let
          #   colorExpr = "\\x1B\\[([0-9]{1,3}(;[0-9]{1,2};?)?)?[mGK]";
          #   colorEndExpr = "\\x1B\\[m";
          #   colored = x: "${colorExpr}${x}${colorEndExpr}";
          # in lib.concatMapStringsSep " " (x: "-e '${x}'") [
          #   "s|${colored "GPG: \\(N\\)"} ${colored "F3CDA86CC55A9F10D7A069819F2F7D8250F35146"} - ${colored "h7x4 <h7x4@nani.wtf>"} ${colored "\\(ultimate\\)"}|GPG: h7x4|"
          #   "s|${colored "GPG: \\(N\\)"} ${colored ""} - ${colored ""} ${colored "\\(undefined\\)"}||"
          # ];
        in "log --decorate --format=tformat:'${fmt}'";
        # in "!git log --color=always --format=format:'${fmt}' | sed -E ${sedExpressions} | $PAGER";
      });

      extraConfig = {
        core = {
          whitespace = lib.concatStringsSep "," [
            "space-before-tab"
            "-indent-with-non-tab"
            "trailing-space"
            "blank-at-eof"
          ];
          untrackedCache = true;
          editor = "nvim";
        };

        safe.directory = "*";

        interactive.singleKey = true;

        advice.detachedHead = false;

        rerere.enabled = true;

        branch = {
          sort = "-committerdate";
          autoSetupRebase = "always";
        };

        "color \"branch\"".upstream = "cyan";
        color.ui = "auto";

        init.defaultBranch = "main";

        fetch = {
          prune = true;
          fsckObjects = true;
        };

        maintenance.strategy = "incremental";

        scalar = {
          repo = [ "${config.home.homeDirectory}/nixpkgs" ];
        };

        transfer.fsckObjects = true;

        receive.fsckObjects = true;

        pull.rebase = true;

        rebase = {
          autoStash = true;
          autoSquash = true;
          abbreviateCommands = true;
          updateRefs = true;
        };

        push = {
          default = "current";
          autoSetupRemote = true;
          followTags = true;
        };

        merge = {
          tool = "nvimdiff";
          conflictstyle = "diff3";
          colorMoved = "zebra";
        };

        mergetool.keepBackup = false;
        "mergetool \"nvimdiff\"".cmd = "nvim -d $BASE $LOCAL $REMOTE $MERGED -c '$wincmd w' -c 'wincmd J'";

        diff = {
          mnemonicPrefix = true;
          renames = true;
          compactionHeuristic = true;
          tool = "nvimdiff";
          submodule = "log";
        };

        pager.show = lib.getExe pkgs.bat;

        status = {
          showUntrackedFiles = "all";
          relativePaths = true;
          submoduleSummary = true;
        };

        log.date = "iso";

        submodule.recurse = true;

        grep = {
          break = true;
          heading= true;
          lineNumber = true;
          extendedRegexp = true;
        };

        "notes \"rewrite\"" = {
          amend = true;
          rebase = true;
        };

        versionsort = {
          prereleaseSuffix = lib.mapCartesianProduct ({ binding, suffix }: "${binding}${suffix}") {
            binding = [ "-" "." "/" ];
            suffix = [ "pre" "alpha" "beta" "rc" ];
          };
        };

        # Run autocorrected command after 3 seconds
        help.autocorrect = "30";

        github.user = "h7x4";

        "url \"${lib.head github-uri-prefixes}\"".insteadOf = lib.tail github-uri-prefixes;

        "url \"git@gist.github.com:\"".insteadOf = [
          "git://gist.github.com/"
          "https://gist.github.com/"
        ];

        "url \"aur@aur.archlinux.org:\"".insteadOf = [
          "aur:"
          "https://aur.archlinux.org/"
        ];

        gc = {
          reflogExpire = "90 days";
          reflogExpireUnreachable = "90 days";
        };

        web.browser = "google-chrome-stable";

        "filter \"lfs\"" = {
          required = true;
          smudge = "git-lfs smudge -- %f";
          process = "git-lfs filter-process";
          clean = "git-lfs clean -- %f";
        };
      };

      ignores = [
        ".vscode"
        ".direnv"
        ".envrc"
        "shell.nix"
      ];
    }

    (let
      uri-prefixes = [
        # Preferred
        "pvv-git:"

        # Alternative
        "https://git.pvv.org/"
        "ssh://gitea@git.pvv.ntnu.no:2222/"
        "gitea@git.pvv.ntnu.no:2222/"
        "gitea@git.pvv.ntnu.no:"
        "git.pvv.ntnu.no:"
      ];

      prefixes-per-org = let
        organizations = [
          "Drift"
          "Projects"
        ];
      in lib.genAttrs organizations (org: map (uri-prefix: "${uri-prefix}${org}") uri-prefixes);
    in {
      extraConfig."url \"${lib.head uri-prefixes}\"".insteadOf = lib.tail uri-prefixes;

      includes = map (x: {
        contentSuffix = "pvv.gitconfig";
        condition = "hasconfig:remote.*.url:${x}**";
        contents = {
          user = {
            email = "oysteikt@pvv.ntnu.no";
            name = "Øystein Tveit";
          };
        };
      }) (lib.flatten (lib.attrValues prefixes-per-org));
    })
  ];

  systemd.user.services."git-maintenance@".Service = lib.mkIf cfg.maintenance.enable {
    ExecStartPre = let
      repoDirs = lib.escapeShellArgs [
        "${config.home.homeDirectory}/git"
        "${config.home.homeDirectory}/work"
        "${config.home.homeDirectory}/pvv"
      ];

      script = pkgs.writeShellApplication {
        name = "discover-git-maintenance-repos";
        text = ''
          {
            echo "[maintenance]"
            for repoLocation in ${repoDirs}; do
              for repo in "$repoLocation"/*/.git; do
                echo "repo = $('${pkgs.coreutils}/bin/realpath' "''${repo%"/.git"}")"
              done
            done
          } > "$1"
        '';
      };
    in "${lib.getExe script} %t/maintenance-repos";

    ExecStart = lib.mkForce ''
      "${lib.getExe cfg.package}" -c include.path="%t/maintenance-repos" for-each-repo --keep-going --config=maintenance.repo maintenance run --schedule=%i
    '';
  };


  home.packages = [
    (pkgs.writeShellApplication {
      name = "git-tcommit";
      runtimeInputs = with pkgs; [ cfg.package coreutils ];
      text = lib.fileContents ./scripts/git-tcommit.sh;
    })
    (pkgs.writeShellApplication {
      name = "git-tmcommit";
      runtimeInputs = with pkgs; [ cfg.package coreutils ];
      text = lib.pipe ./scripts/git-tcommit.sh [
        lib.fileContents
        (builtins.replaceStrings ["hours" "tcommit"] ["minutes" "tmcommit"])
      ];
    })
    (pkgs.writeShellApplication {
      name = "git-fixup-fixup";
      runtimeInputs = with pkgs; [ cfg.package ];
      text = lib.fileContents ./scripts/git-fixup-fixup.sh;
    })
    (pkgs.writeShellApplication {
      name = "git-rebase-fixups";
      runtimeInputs = with pkgs; [ cfg.package gnused ];
      text = lib.fileContents ./scripts/git-rebase-fixups.sh;
    })
    (pkgs.writeShellApplication {
      name = "git-fixup-interactive";
      runtimeInputs = with pkgs; [ cfg.package gnused gnugrep skim ];
      text = lib.fileContents ./scripts/git-fixup-interactive.sh;
    })
    (pkgs.writeShellApplication {
      name = "git-switch-interactive";
      runtimeInputs = with pkgs; [ cfg.package skim gnused gnugrep uutils-coreutils-noprefix ];
      text = lib.fileContents ./scripts/git-switch-interactive.sh;
      excludeShellChecks = [
        "SC2001" # (style): See if you can use ${variable//search/replace} instead. (sed invocation)
      ];
    })
    ((pkgs.writers.writePython3Bin "git-post-pr" {
      libraries = with pkgs.python3Packages; [
        tkinter
      ];
      flakeIgnore = [
        "E501" # I like long lines grr
      ];
    } (lib.fileContents ./scripts/git-post-pr.py)).overrideAttrs (_: {
      postFixup = ''
        wrapProgram $out/bin/git-post-pr \
          --prefix PATH : ${lib.makeBinPath [
            pkgs.github-cli
          ]}
      '';
    }))

    pkgs.git-absorb
  ];
}

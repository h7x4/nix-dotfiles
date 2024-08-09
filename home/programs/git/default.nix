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
{
  imports = [
    ./maintenance-timers.nix
  ];

  # TODO: convert to template once nix-sops supports it in hm module
  sops.secrets."git/nordicsemi-config" = { };

  programs.git = lib.mkMerge [
    {
      enable = true;
      package = pkgs.gitFull;

      userName = "h7x4";
      userEmail = "h7x4@nani.wtf";

      signing = {
        key = "46B9228E814A2AAC";
        signByDefault = true;
      };

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
        delete-merged = "!git branch --merged | grep -v '\\*' | xargs -n 1 git branch -d";
        graph = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all";
        graphv = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all";
        forcepush = "push --force-with-lease --force-if-includes";
        authors = "shortlog --summary --numbered --email";
        si = "switch-interactive";
        rebase-author = "rebase -i -x \"git commit --amend --reset-author -CHEAD\"";
      };

      extraConfig = {
        core = {
          whitespace = "space-before-tab,-indent-with-non-tab,trailing-space";
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
          tool = "nvimdiff";
          submodule = "log";
        };

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

    (let
      bitbucket-uri-prefixes = [
        # Preferred
        "bitbucket-nordicsemi:"

        # Alternative
        "ssh://git@bitbucket.nordicsemi.no:7999"
        "https://projecttools.nordicsemi.no/bitbucket/scm"
      ];

      prefixes-per-org = let
        organizations = [
          "NordicSemiconductor"
          "NordicPlayground"
          "nrfconnect"
          "oysteintveit-nordicsemi"
        ];
      in lib.genAttrs organizations (org: map (uri-prefix: "${uri-prefix}${org}") github-uri-prefixes);
    in {
      extraConfig = lib.mergeAttrs
        {
          "url \"${lib.head bitbucket-uri-prefixes}\"".insteadOf = lib.tail bitbucket-uri-prefixes;
        }
        (lib.mapAttrs' (org: uri-prefixes: {
          name = "url \"github-nordicsemi:${org}\"";
          value.insteadOf = uri-prefixes;
        }) prefixes-per-org)
        ;

      includes = map (x: {
        contentSuffix = "nordicsemi.gitconfig";
        condition = "hasconfig:remote.*.url:${x}/**";
        path = config.sops.secrets."git/nordicsemi-config".path;
      }) (bitbucket-uri-prefixes ++ (lib.flatten (lib.attrValues prefixes-per-org)));
    })
  ];

  home.packages = [
    (pkgs.writeShellApplication {
      name = "git-tcommit";
      runtimeInputs = with pkgs; [ cfg.package coreutils ];
      text = lib.fileContents ./scripts/git-tcommit.sh;
    })
    (pkgs.writeShellApplication {
      name = "git-switch-interactive";
      runtimeInputs = with pkgs; [ cfg.package fzf gnused coreutils ];
      text = lib.fileContents ./scripts/git-switch-interactive.sh;
      excludeShellChecks = [
        "SC2001" # (style): See if you can use ${variable//search/replace} instead. (sed invocation)
      ];
    })

    pkgs.git-absorb
  ];
}

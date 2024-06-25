{ pkgs, ... }:
{
  programs.git = {
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
      switch-interactive = "!cat <(git branch) <(git branch -r) | grep -v '^\\*\\|HEAD ->' | ${pkgs.fzf}/bin/fzf --reverse --info=inline --preview 'echo {} | xargs git show --color' | sed 's|\\s*.*/||' | xargs git switch";
      si = "switch-interactive";
      rebase-author = "rebase -i -x \"git commit --amend --reset-author -CHEAD\"";
    };

    extraConfig = {
      core = {
        whitespace = "space-before-tab,-indent-with-non-tab,trailing-space";
        untrackedCache = true;
        editor = "nvim";
      };

      rerere.enabled = true;

      branch.sort = "-committerdate";

      "color \"branch\"".upstream = "cyan";
      color.ui = "auto";

      init.defaultBranch = "main";
      fetch.prune = true;
      pull.rebase = true;

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
      };

      grep = {
        break = true;
        heading= true;
        lineNumber = true;
        extendedRegexp = true;
      };

      github.user = "h7x4";

      "url \"github:\"".insteadOf = "https://github.com/";


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
  };
}

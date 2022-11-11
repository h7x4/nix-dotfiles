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
        uncommit = "reset --soft HEAD^";
        rev = "checkout HEAD -- ";
        revall = "checkout .";
        # unstage = "rm --cached ";
        unstage = "restore --staged ";
        delete-merged = "!git branch --merged | grep -v '\\*' | xargs -n 1 git branch -d";

        mkbr = "checkout -b";
        mvbr = "branch -m";
        rmbr = "branch -d";
        rrmbr = "push origin --delete";

        graph = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all";
        graphv = "log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all";
        g = "!git graph";
    };

    extraConfig = {
      core = {
        whitespace = "space-before-tab,-indent-with-non-tab,trailing-space";

        precomposeunicode = false;
        untrackedCache = true;

        editor = "nvim";
      };

      "color \"branch\"".upstream = "cyan";
      color.ui = "auto";

      init.defaultBranch = "main";
      fetch.prune = true;
      pull.rebase = true;
      push.default = "current";

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

      web.browser = "google-chrome-stable";

      "filter \"lfs\"" = {
        required = true;
        smudge = "git-lfs smudge -- %f";
        process = "git-lfs filter-process";
        clean = "git-lfs clean -- %f";
      };
    };
  };
}

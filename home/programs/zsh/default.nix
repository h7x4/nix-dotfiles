{ config, pkgs, lib, ... }:
let
  cfg = config.programs.zsh;
in
{
  home.file."${cfg.dotDir}/.zshrc".onChange = ''
    ${lib.getExe (pkgs.writeTextFile {
      name = "zsh-compinit-oneshot.zsh";
      executable = true;
      destination = "/bin/zsh-compinit-oneshot.zsh";
      text = ''
        #!${lib.getExe cfg.package}

        autoload -Uz compinit && compinit -C -d "${config.xdg.cacheHome}/zsh/zcompdump-$ZSH_VERSION"
      '';
    })}
  '';

  systemd.user.tmpfiles.settings."10-zsh"."${config.xdg.cacheHome}/zsh".d = {
    mode = "0770";
    user = config.home.username;
  };

  programs.zsh = {
    enable = true;
    dotDir = ".config/zsh";
    # enableSyntaxHighlighting = true;
    defaultKeymap = "viins";
    enableCompletion = true;

    completionInit = "";

    history = {
      extended = true;
      ignoreDups = false;
      size = 100000;
      path = "${config.xdg.dataHome}/zsh/zsh_history";
    };

    plugins = [
      # {
      #   name = "nix-zsh-shell-integration";
      #   src = pkgs.nix-zsh-shell;
      # }
      {
        name = "fzf-tab";
        src = pkgs.zsh-fzf-tab;
        file = "share/fzf-tab/fzf-tab.plugin.zsh";
      }
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "zsh-fast-syntax-highlighting";
        src = pkgs.zsh-fast-syntax-highlighting;
        file = "share/zsh/site-functions/fast-syntax-highlighting.plugin.zsh";
      }
      {
        name = "zsh-completions";
        src = pkgs.zsh-completions;
      }
      {
        name = "zsh-you-should-use";
        src = pkgs.zsh-you-should-use;
        file = "share/zsh/plugins/you-should-use/you-should-use.plugin.zsh";
      }
      {
        name = "zsh-autosuggestions";
        src = pkgs.zsh-autosuggestions;
        file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
      }
    ];

    initContent = lib.mkMerge [
      (lib.mkOrder 550 ''
        fpath+=(${pkgs.zsh-completions}/share/zsh/site-functions)
      '')
      ''
        source ${./p10k.zsh}

        enable-fzf-tab

        zstyle ':fzf-tab:complete:cd:*' fzf-preview '${lib.getExe pkgs.eza} -1 --color=always $realpath'

        # Use tmux buffer if we are inside tmux
        if ! { [ "$TERM" = "screen" ] && [ -n "$TMUX" ]; } then
          zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
        fi

        source "${config.xdg.configHome}/mutable_env.sh"
      ''
    ];
  };
}

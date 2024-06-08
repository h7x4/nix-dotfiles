{ pkgs, lib, config, ... }:
{
  programs.zsh = {

    enable = true;
    dotDir = ".config/zsh";
    # enableSyntaxHighlighting = true;
    defaultKeymap = "viins";
    enableCompletion = true;

    initExtraBeforeCompInit = ''
      fpath+=(${pkgs.zsh-completions}/share/zsh/site-functions)
    '';

    # TODO: Regenerate zcompdump with a systemd timer
    completionInit = ''
      autoload -Uz compinit && compinit -C -d "${config.xdg.cacheHome}/zsh/zcompdump-$ZSH_VERSION"
    '';

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

    initExtra = ''
      source ${./p10k.zsh}

      enable-fzf-tab

      zstyle ':fzf-tab:complete:cd:*' fzf-preview '${lib.getExe pkgs.eza} -1 --color=always $realpath'

      # Use tmux buffer if we are inside tmux
      if ! { [ "$TERM" = "screen" ] && [ -n "$TMUX" ]; } then
        zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
      fi
    '';
  };
}

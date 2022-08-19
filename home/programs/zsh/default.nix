{ pkgs, lib, config, shellOptions, ... }:
{
  programs.zsh = rec {
    enable = true;
    dotDir = ".config/zsh";
    # enableSyntaxHighlighting = true;
    defaultKeymap = "viins";

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
        name = "zsh-fast-syntax-highlighting";
        src = pkgs.zsh-fast-syntax-highlighting;
      }
      {
        name = "zsh-completions";
        src = pkgs.zsh-completions;
      }
      {
        name = "zsh-you-should-use";
        src = pkgs.zsh-you-should-use;
      }
      {
        name = "zsh-autosuggestions";
        src = pkgs.zsh-autosuggestions;
      }
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "fzf-tab";
        src = pkgs.zsh-fzf-tab;
      }
    ];

    localVariables = shellOptions.variables;

    shellAliases = shellOptions.flattened.aliases;

    initExtra = ''
      source ${./p10k.zsh}
    '';
  };
}

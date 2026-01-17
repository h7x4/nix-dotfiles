{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    configure = {
      packages.myVimPackage = with pkgs.vimPlugins; {
        start = [
          direnv-vim
          vim-nix
          vim-polyglot
        ];

        opt = [
          vim-monokai
        ];
      };

      customRC = ''
        set number relativenumber

        set undofile
        set undodir = vim.fn.expand("~/.cache/vim/undodir")
        set backupdir = vim.fn.expand("~/.cache/vim/backup")

        packadd! vim-monokai
        colorscheme monokai
      '';
    };
  };
}

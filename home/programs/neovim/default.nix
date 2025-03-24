{ pkgs, lib, machineVars, ... }:
{
  imports = [
    ./auto-clean-swapfiles.nix
  ];

  programs.neovim = {
    enable = true;

    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    plugins = with pkgs.vimPlugins; [
      direnv-vim
      fzf-vim
      vim-commentary
      vim-css-color
      vim-fugitive
      vim-gitgutter
      vim-nix
      vim-surround
      vim-trailing-whitespace
      vim-which-key
    ] ++ (lib.optionals machineVars.wayland [
      vim-wayland-clipboard
    ]) ++ [
      semshi
      {
        plugin = goyo-vim;

        # TODO: The mapleader definition should be in extraConfig, but setting
        #       the mapleader before defining keymaps messes things up.
        config = ''
          let mapleader = " "

          let g:goyo_width = '90%'
          let g:goyo_height = '85%'
          let g:goyo_linenr = 1

          function! s:goyo_enter()
            if executable('tmux') && strlen($TMUX)
              silent !tmux set status off
              silent !tmux list-panes -F '\#F' | grep -q Z || tmux resize-pane -Z
            endif
            set noshowmode
            set noshowcmd
            set scrolloff=999
            Limelight
            " ...
          endfunction

          function! s:goyo_leave()
            if executable('tmux') && strlen($TMUX)
              silent !tmux set status on
              silent !tmux list-panes -F '\#F' | grep -q Z && tmux resize-pane -Z
            endif
            set showmode
            set showcmd
            set scrolloff=5
            Limelight!
            " ...
          endfunction

          autocmd! User GoyoEnter nested call <SID>goyo_enter()
          autocmd! User GoyoLeave nested call <SID>goyo_leave()

          nnoremap <leader>z :Goyo<CR>
        '';
      }
      limelight-vim
      vim-tmux-navigator
      lightline-vim
      vim-better-whitespace
      {
        plugin = nvim-treesitter.withAllGrammars;
        config = ''
        packadd! nvim-treesitter
        lua << EOF
          require'nvim-treesitter.configs'.setup {
            highlight = {
              enable = true,
            },
          }
        EOF
        '';
      }
      {
        plugin = rainbow-delimiters-nvim;
        config = ''
        lua << EOF
          local rainbow_delimiters = require 'rainbow-delimiters'
          vim.g.rainbow_delimiters = {
            ["highlight"] = {
              'RainbowDelimiterRed',
              'RainbowDelimiterYellow',
              'RainbowDelimiterBlue',
              'RainbowDelimiterGreen',
              'RainbowDelimiterViolet',
              'RainbowDelimiterCyan',
            },
          }
        EOF
        '';
      }
      {
        plugin = vim-monokai;
        config = ''
          colorscheme monokai

          autocmd ColorScheme monokai highlight Normal ctermbg=0
          autocmd ColorScheme monokai highlight LineNr ctermbg=0
          autocmd ColorScheme monokai highlight CursorLineNR ctermbg=0 ctermfg=208
          autocmd ColorScheme monokai highlight SignColumn ctermbg=0
          autocmd ColorScheme monokai highlight GitGutterAdd ctermbg=0
          autocmd ColorScheme monokai highlight GitGutterChange ctermbg=0
          autocmd ColorScheme monokai highlight GitGutterDelete ctermbg=0

          autocmd ColorScheme monokai highlight RainbowDelimiterRed    { fg = g:terminal_color_9 }
          autocmd ColorScheme monokai highlight RainbowDelimiterYellow { fg = g:terminal_color_11 }
          autocmd ColorScheme monokai highlight RainbowDelimiterBlue   { fg = g:terminal_color_12 }
          autocmd ColorScheme monokai highlight RainbowDelimiterGreen  { fg = g:terminal_color_10 }
          autocmd ColorScheme monokai highlight RainbowDelimiterViolet { fg = g:terminal_color_13 }
          autocmd ColorScheme monokai highlight RainbowDelimiterCyan   { fg = g:terminal_color_14 }
        '';
      }
    ];

    extraConfig =  ''
      set clipboard+=unnamedplus
      set number relativenumber

      set undofile
      set undodir=~/.cache/vim/undodir

      nnoremap <A-j> :m .+1<CR>==
      nnoremap <A-k> :m .-2<CR>==
      inoremap <A-j> <Esc>:m .+1<CR>==gi
      inoremap <A-k> <Esc>:m .-2<CR>==gi
      vnoremap <A-j> :m '>+1<CR>gv=gv
      vnoremap <A-k> :m '<-2<CR>gv=gv
    '';

    extraLuaConfig = ''
      local function paste_buf()
        local content = os.getenv("NVIM_CLIPBOARD")

        local line = vim.api.nvim_get_current_line()
        local indent = string.match(line, " +")

        vim.fn.setreg("a", indent .. content)
        vim.cmd("put a")
      end

      vim.keymap.set('n', ';', paste_buf)
    '';
  };

  home.sessionVariables = { EDITOR = "nvim"; };
}

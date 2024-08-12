{ pkgs, home, ... }:
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
      vim-commentary
      vim-gitgutter
      fzf-vim
      vim-which-key
      vim-nix
      vim-surround
      vim-fugitive
      vim-css-color
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
      vim-polyglot
      lightline-vim
      {
        plugin = rainbow;
        config = ''
          let g:rainbow_active = 1
        '';
      }
      {
        plugin = vim-monokai;
        config = ''
          colorscheme monokai
          autocmd ColorScheme * highlight Normal ctermbg=0
          autocmd ColorScheme * highlight LineNr ctermbg=0
          autocmd ColorScheme * highlight CursorLineNR ctermbg=0 ctermfg=208
          autocmd ColorScheme * highlight SignColumn ctermbg=0
          autocmd ColorScheme * highlight GitGutterAdd ctermbg=0
          autocmd ColorScheme * highlight GitGutterChange ctermbg=0
          autocmd ColorScheme * highlight GitGutterDelete ctermbg=0
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

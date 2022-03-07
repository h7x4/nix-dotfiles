{pkgs, ...}:
{
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    clock24 = true;
    escapeTime = 0;
    keyMode = "vi";
    prefix = "C-a";
    plugins = with pkgs.tmuxPlugins; [
      fingers
      fpp
      pain-control
      prefix-highlight
      sidebar
      tmux-fzf
      urlview
    ];
    extraConfig = ''
      # Don't rename windows automatically after rename with ','
      set-option -g allow-rename off

      set -g mouse on
      set -q -g status-utf8 on
      setw -q -g utf8 on
      set-option -g default-terminal screen-256color
      set -g base-index 1 # windows starts at 1
      setw -g monitor-activity on
      set -g visual-activity on

      # Length of tmux status line
      set -g status-left-length 30
      set -g status-right-length 150

      set -g base-index 1
      set -g pane-base-index 0

      ######################
      ######## KEYS ########
      ######################

      # Split panes using $P-[gh]
      bind h split-window -h -c "#{pane_current_path}"
      bind g split-window -v -c "#{pane_current_path}"
      unbind '"' # Unbind default vertical split
      unbind %   # Unbind default horizontal split

      # Reload config using $P-r
      unbind r
      bind r \
        source-file $XDG_CONFIG_HOME/tmux/tmux.conf\;\
        display-message 'Reloaded tmux.conf'

      # Switch panes using Alt-[hjkl]
      bind -n C-h select-pane -L
      bind -n C-j select-pane -D
      bind -n C-k select-pane -U
      bind -n C-l select-pane -R

      # Resize pane using Alt-Shift-[hjkl]
      bind -n M-H resize-pane -L 5
      bind -n M-J resize-pane -D 5
      bind -n M-K resize-pane -U 5
      bind -n M-L resize-pane -R 5

      # Fullscreen current pane using $P-Alt-z
      unbind z
      bind M-z resize-pane -Z

      # Kill pane using $P-Backspace
      unbind &
      bind BSpace killp

      # Swap clock-mode and new-window
      # New tab: $P-t
      # Clock mode: $P-c
      unbind c
      unbind t
      bind c clock-mode
      bind t new-window

      # Setup 'y' to yank (copy)
      bind-key -T copy-mode-vi 'y' send -X copy-pipe-and-cancel "pbcopy"
      bind-key -T copy-mode-vi 'V' send -X select-line
      bind-key -T copy-mode-vi 'r' send -X rectangle-toggle

      ######################
      ### DESIGN CHANGES ###
      ######################

      set-option -g status-left '#{prefix_highlight} #[bg=blue]#[fg=black,bold] ###S #[bg=default]  #[fg=green]#(~/.scripts/tmux/fcitx)  #[fg=red]%H:%M   '
      set-option -g status-right '#[fg=red]#(~/.scripts/tmux/mpd)'
      set-window-option -g window-status-current-style fg=magenta
      set-option -g status-style 'bg=black fg=default'
      set-option -g default-shell '${pkgs.zsh}/bin/zsh'

      set -g status-position bottom
      set -g status-interval 4
      set -g status-justify centre # center align window list

      setw -g status-bg default
      setw -g window-status-format '#[bg=#888888]#[fg=black,bold] #I #[bg=default] #[fg=#888888]#W  '
      setw -g window-status-current-format '#[fg=black,bold]#[bg=cyan] #I #[fg=cyan]#[bg=default] #W  '
    '';
  };
}

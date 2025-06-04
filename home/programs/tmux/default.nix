{ pkgs, lib, ... }:
{
  programs.tmux = {
    baseIndex = 1;
    clock24 = true;
    escapeTime = 0;
    keyMode = "vi";
    prefix = "C-a";
    mouse = true;
    terminal = "screen-256color";

    plugins = with pkgs.tmuxPlugins; [
      copycat
      fingers
      fpp
      jump
      open
      pain-control
      prefix-highlight
      sidebar
      tmux-fzf
      urlview
    ];

    extraConfig = let
      fileContentsWithoutShebang = script: lib.pipe script [
        lib.fileContents
        (lib.splitString "\n")
        (lib.drop 3) # remove shebang
        (lib.concatStringsSep "\n")
      ];

      fcitx5-status = (pkgs.writeShellApplication {
        name = "tmux-fcitx5-status";
        runtimeInputs = with pkgs; [ dbus ];
        text = fileContentsWithoutShebang ./scripts/fcitx5-status.sh;
      });
      mpd-status = (pkgs.writeShellApplication {
        name = "tmux-mpd-status";
        runtimeInputs = with pkgs; [ mpc-cli gawk gnugrep ];
        text = fileContentsWithoutShebang ./scripts/mpd-status.sh;
      });
    in ''
      # Don't rename windows automatically after rename with ','
      set-option -g allow-rename off

      set -q -g status-utf8 on
      setw -q -g utf8 on
      setw -g monitor-activity on
      set -g visual-activity on

      # Length of tmux status line
      set -g status-left-length 30
      set -g status-right-length 150

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

      set-option -g status-left '#{prefix_highlight} #[bg=blue]#[fg=black,bold] ###S #[bg=default]  #[fg=green]#(${lib.getExe fcitx5-status})  #[fg=red]%H:%M   '
      set-option -g status-right '#[fg=red]#(${lib.getExe mpd-status})'
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

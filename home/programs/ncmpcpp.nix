{pkgs, ...}:
{
  programs.ncmpcpp = {
    enable = true;
    package = pkgs.ncmpcpp.override { visualizerSupport = true; };

    bindings = [
      # { key = "j"; command = "scroll_down"; }
      { key = "mouse"; command = "mouse_event"; }

      { key = "up"; command = "scroll_up"; }
      { key = "shift-up"; command = ["select_item" "scroll_up"]; }

      { key = "down"; command = "scroll_down"; }
      { key = "shift-down"; command = ["select_item" "scroll_down"]; }

      { key = "["; command = "scroll_up_album"; }
      { key = "]"; command = "scroll_down_album"; }
      { key = "{"; command = "scroll_up_artist"; }
      { key = "}"; command = "scroll_down_artist"; }

      { key = "page_up"; command = "page_up"; }
      { key = "page_down"; command = "page_down"; }

      { key = "home"; command = "move_home"; }
      { key = "end"; command = "move_end"; }
      { key = "insert"; command = "select_item"; }

      { key = "enter"; command = "enter_directory"; }
      { key = "enter"; command = "toggle_output"; }
      { key = "enter"; command = "run_action"; }
      { key = "enter"; command = "play_item"; }

      { key = "space"; command = "add_item_to_playlist"; }
      { key = "space"; command = "toggle_lyrics_update_on_song_change"; }
      { key = "space"; command = "toggle_visualization_type"; }

      #CHANGE
      { key = "d"; command = "delete_playlist_items"; }

      { key = "delete"; command = "delete_browser_items"; }
      { key = "delete"; command = "delete_stored_playlist"; }

      { key = "right"; command = "next_column"; }
      { key = "right"; command = "slave_screen"; }
      { key = "right"; command = "volume_up"; }
      { key = "+"; command = "volume_up"; }

      { key = "left"; command = "previous_column"; }
      { key = "left"; command = "master_screen"; }
      { key = "left"; command = "volume_down"; }
      { key = "-"; command = "volume_down"; }

      { key = ":"; command = "execute_command"; }
      { key = "tab"; command = "next_screen"; }
      { key = "shift-tab"; command = "previous_screen"; }
      { key = "f1"; command = "show_help"; }

      { key = "1"; command = "show_playlist"; }
      { key = "2"; command = "show_browser"; }
      { key = "2"; command = "change_browse_mode"; }
      { key = "3"; command = "show_search_engine"; }
      { key = "3"; command = "reset_search_engine"; }
      { key = "4"; command = "show_media_library"; }
      { key = "4"; command = "toggle_media_library_columns_mode"; }
      { key = "5"; command = "show_playlist_editor"; }
      { key = "6"; command = "show_tag_editor"; }
      { key = "7"; command = "show_outputs"; }
      { key = "8"; command = "show_visualizer"; }
      { key = "="; command = "show_clock"; }
      { key = "@"; command = "show_server_info"; }

      { key = "s"; command = "stop"; }
      { key = "p"; command = "pause"; }
      { key = ">"; command = "next"; }
      { key = "<"; command = "previous"; }

      { key = "ctrl-h"; command = "jump_to_parent_directory"; }
      { key = "ctrl-h"; command = "replay_song"; }
      { key = "backspace"; command = "jump_to_parent_directory"; }
      { key = "backspace"; command = "replay_song"; }

      { key = "f"; command = "seek_forward"; }
      { key = "b"; command = "seek_backward"; }

      { key = "r"; command = "toggle_repeat"; }
      { key = "z"; command = "toggle_random"; }
      { key = "y"; command = "save_tag_changes"; }
      { key = "y"; command = "start_searching"; }
      { key = "y"; command = "toggle_single"; }
      { key = "R"; command = "toggle_consume"; }
      { key = "Y"; command = "toggle_replay_gain_mode"; }
      { key = "T"; command = "toggle_add_mode"; }
      { key = "|"; command = "toggle_mouse"; }
      { key = "#"; command = "toggle_bitrate_visibility"; }
      { key = "Z"; command = "shuffle"; }
      { key = "x"; command = "toggle_crossfade"; }
      { key = "X"; command = "set_crossfade"; }
      { key = "u"; command = "update_database"; }
      { key = "ctrl-s"; command = "sort_playlist"; }
      { key = "ctrl-s"; command = "toggle_browser_sort_mode"; }
      { key = "ctrl-s"; command = "toggle_media_library_sort_mode"; }
      { key = "ctrl-r"; command = "reverse_playlist"; }
      { key = "ctrl-f"; command = "apply_filter"; }
      { key = "ctrl-_"; command = "select_found_items"; }
      { key = "/"; command = "find"; }
      { key = "/"; command = "find_item_forward"; }
      # { key = "?"; command = "find"; }
      # { key = "?"; command = "find_item_backward"; }
      { key = "."; command = "next_found_item"; }
      { key = ","; command = "previous_found_item"; }
      { key = "w"; command = "toggle_find_mode"; }
      { key = "e"; command = "edit_song"; }
      { key = "e"; command = "edit_library_tag"; }
      { key = "e"; command = "edit_library_album"; }
      { key = "e"; command = "edit_directory_name"; }
      { key = "e"; command = "edit_playlist_name"; }
      { key = "e"; command = "edit_lyrics"; }
      { key = "i"; command = "show_song_info"; }
      { key = "I"; command = "show_artist_info"; }
      # { key = "g"; command = "jump_to_position_in_song"; }
      { key = "l"; command = "show_lyrics"; }
      { key = "ctrl-v"; command = "select_range"; }
      { key = "v"; command = "reverse_selection"; }
      { key = "V"; command = "remove_selection"; }
      { key = "B"; command = "select_album"; }
      { key = "a"; command = "add_selected_items"; }
      { key = "c"; command = "clear_playlist"; }
      { key = "c"; command = "clear_main_playlist"; }
      { key = "C"; command = "crop_playlist"; }
      { key = "C"; command = "crop_main_playlist"; }
      { key = "m"; command = "move_sort_order_up"; }
      { key = "m"; command = "move_selected_items_up"; }
      { key = "n"; command = "move_sort_order_down"; }
      { key = "n"; command = "move_selected_items_down"; }
      { key = "M"; command = "move_selected_items_to"; }
      { key = "A"; command = "add"; }
      { key = "S"; command = "save_playlist"; }
      { key = "o"; command = "jump_to_playing_song"; }
      # { key = "G"; command = "jump_to_browser"; }
      # { key = "G"; command = "jump_to_playlist_editor"; }
      { key = "~"; command = "jump_to_media_library"; }
      { key = "E"; command = "jump_to_tag_editor"; }
      { key = "U"; command = "toggle_playing_song_centering"; }
      { key = "P"; command = "toggle_display_mode"; }
      { key = "\\\\"; command = "toggle_interface"; }
      { key = "!"; command = "toggle_separators_between_albums"; }
      { key = "L"; command = "toggle_lyrics_fetcher"; }
      { key = "F"; command = "fetch_lyrics_in_background"; }
      { key = "alt-l"; command = "toggle_fetching_lyrics_in_background"; }
      { key = "ctrl-l"; command = "toggle_screen_lock"; }
      { key = "`"; command = "toggle_library_tag_type"; }
      { key = "`"; command = "refetch_lyrics"; }
      { key = "`"; command = "add_random_items"; }
      { key = "ctrl-p"; command = "set_selected_items_priority"; }
      { key = "q"; command = "quit"; }

      # the t key isn't used and it's easier to press than /, so lets use it
      { key = "t"; command = "find"; }
      { key = "t"; command = "find_item_forward"; }

      { key = "+"; command = "show_clock"; }
      { key = "="; command = "volume_up"; }

      { key = "j"; command = "scroll_down"; }
      { key = "k"; command = "scroll_up"; }

      { key = "ctrl-u"; command = "page_up"; }
      #push_characters "kkkkkkkkkkkkkkk"
      { key = "ctrl-d"; command = "page_down"; }
      #push_characters "jjjjjjjjjjjjjjj"

      { key = "h"; command = "previous_column"; }
      { key = "l"; command = "next_column"; }

      { key = "."; command = "show_lyrics"; }

      { key = "n"; command = "next_found_item"; }
      { key = "N"; command = "previous_found_item"; }

      # not used but bound
      { key = "J"; command = "move_sort_order_down"; }
      { key = "K"; command = "move_sort_order_up"; }

      { key = "g"; command = "move_home"; }
      { key = "G"; command = "move_end"; }

      { key = "?"; command = "show_help"; }
    ];

    settings = {
      lyrics_directory = "~/music/.lyrics";

      playlist_disable_highlight_delay = 0;
      message_delay_time = 5;

      # - 0 - default window color (discards all other colors)
      # - 1 - black
      # - 2 - red
      # - 3 - green
      # - 4 - yellow
      # - 5 - blue
      # - 6 - magenta
      # - 7 - cyan
      # - 8 - white
      # - 9 - end of current color
      # - b - bold text
      # - u - underline text
      # - r - reverse colors
      # - a - use alternative character set

      song_list_format = "{%a - }{%t}|{$8%f$9}$R{$3(%l)$9}";
      song_status_format = "{{%a{ \"%b\"{ (%y)}} - }{%t}}|{%f}";
      song_library_format = "{%n - }{%t}|{%f}";
      alternative_header_first_line_format = "$b$1$aqqu$/a$9 {%t}|{%f} $1$atqq$/a$9$/b";
      alternative_header_second_line_format = "{{$4$b%a$/b$9}{ - $7%b$9}{ ($4%y$9)}}|{%D}";
      current_item_prefix = "$(yellow)$r";
      current_item_suffix = "$/r$(end)";
      current_item_inactive_column_prefix = "$(white)$r";
      current_item_inactive_column_suffix = "$/r$(end)";
      now_playing_prefix = "$b";
      now_playing_suffix = "$/b";
      browser_playlist_prefix = "$2[P] $9";
      selected_item_prefix = "$6";
      selected_item_suffix = "$9";
      modified_item_prefix = "$3> $9";

      song_window_title_format = "{%a - }{%t}|{%f}";

      browser_sort_mode = "name";
      browser_sort_format = "{%a - }{%t}|{%f} {(%l)}";

      song_columns_list_format = "(10)[green]{a} (50)[white]{t|f:Title} (20)[cyan]{b} (7f)[magenta]{l}";
      # song_columns_list_format = "(10)[green]{a} (50)[black]{t|f:Title} (20)[cyan]{b} (7f)[magenta]{l}";

      execute_on_song_change = "";

      execute_on_player_state_change = "";
      playlist_show_mpd_host = "no";
      playlist_show_remaining_time = "no";
      playlist_shorten_total_times = "no";
      playlist_separate_albums = "no";

      playlist_display_mode = "columns";
      browser_display_mode = "classic";
      search_engine_display_mode = "classic";
      playlist_editor_display_mode = "classic";
      discard_colors_if_item_is_selected = "yes";
      show_duplicate_tags = "yes";
      incremental_seeking = "yes";
      seek_time = 1;
      volume_change_step = 2;
      autocenter_mode = "no";
      centered_cursor = "no";

      progressbar_look = "─⊙╶";
      # progressbar_look = "◾◾◽";
      # progressbar_look = "=> ";

      default_place_to_search_in = "database";
      user_interface = "classic";
      data_fetching_delay = "yes";
      media_library_primary_tag = "artist";
      media_library_albums_split_by_date = "yes";
      default_find_mode = "wrapped";
      default_tag_editor_pattern = "%n - %t";
      header_visibility = "yes";
      statusbar_visibility = "yes";
      titles_visibility = "yes";
      header_text_scrolling = "yes";
      cyclic_scrolling = "no";
      lines_scrolled = 2;

      # lyrics_fetchers = "azlyrics, genius, sing365, lyricsmania, metrolyrics, justsomelyrics, jahlyrics, plyrics, tekstowo, internet";
      follow_now_playing_lyrics = "no";
      fetch_lyrics_for_current_song_in_background = "no";
      store_lyrics_in_song_dir = "no";
      generate_win32_compatible_filenames = "yes";
      allow_for_physical_item_deletion = "no";

      lastfm_preferred_language = "en";
      space_add_mode = "add_remove";
      show_hidden_files_in_local_browser = "no";

      screen_switcher_mode = "playlist, browser";
      startup_screen = "playlist";
      startup_slave_screen = "";
      startup_slave_screen_focus = "no";

      locked_screen_width_part = "50";
      ask_for_locked_screen_width_part = "yes";
      jump_to_now_playing_song_at_start = "yes";
      ask_before_clearing_playlists = "yes";
      clock_display_seconds = "no";
      display_volume_level = "yes";
      display_bitrate = "yes";
      display_remaining_time = "no";

      ignore_leading_the = "no";

      ignore_diacritics = "no";
      block_search_constraints_change_if_items_found = "yes";
      mouse_support = "yes";
      mouse_list_scroll_whole_page = "yes";
      empty_tag_marker = "<empty>";
      tags_separator = " | ";
      tag_editor_extended_numeration = "no";
      media_library_sort_by_mtime = "no";
      enable_window_title = "no";

      search_engine_default_search_mode = 1;
      external_editor = "vim";
      use_console_editor = "yes";

      colors_enabled = "yes";
      empty_tag_color = "cyan";
      header_window_color = "cyan";
      volume_color = "red";
      state_line_color = "yellow";
      state_flags_color = "red";
      # This one is probably the one you're looking for
      main_window_color = "white";
      # main_window_color = "black";
      color1 = "white";
      color2 = "green";
      progressbar_color = "yellow";
      progressbar_elapsed_color = "green:b";
      statusbar_color = "cyan";
      statusbar_time_color = "default:b";
      player_state_color = "default:b";
      alternative_ui_separator_color = "black:b";
      window_border_color = "green";
      active_window_border = "red";

      # visualizer_fifo_path = "/tmp/mpd.fifo";
      # visualizer_output_name = "my_fifo";
      # visualizer_sync_interval = "30";
      # visualizer_in_stereo = "no";
      # visualizer_type = "spectrum"; # spectrum, ellipse, wave_filled, wave
      # visualizer_look = "+█"; # wave | spectrum, ellipse, wave_filled
    };
  };
}

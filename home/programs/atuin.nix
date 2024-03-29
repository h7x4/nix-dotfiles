{ config, ... }:
{
  programs.atuin = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;

    settings = {
      db_path = "${config.xdg.dataHome}/atuin/history.db";
      key_path = "${config.xdg.configHome}/atuin/key";
      session_path = "${config.xdg.configHome}/atuin/session_key";
      dialect = "uk";
      search_mode = "fuzzy";
      style = "auto";
      inline_height = 13;
      sync_address = "https://atuin.nani.wtf";
      sync_frequency = "1h";
      auto_sync = true;
      update_check = true;
    };
  };
}

{ config, ... }:
let
  cfg = config.programs.atuin;
  xdg_runtime_dir = "/run/user/${toString config.home.uid}";
in
{
  programs.atuin = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    enableNushellIntegration = config.programs.nushell.enable;

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

      daemon = {
        enabled = true;
        socket_path = "${xdg_runtime_dir}/atuin.socket";
        # systemd = true;
      };
    };
  };

  # TODO: fix socket activation
  # systemd.user.sockets.atuin-daemon = {
  #   Unit.Description = "Socket activation for atuin shell history daemon";

  #   Socket = {
  #     ListenStream = "%t/atuin.socket";
  #     SocketMode = "0600";
  #     RemoveOnStop = true;
  #   };

  #   Install.WantedBy = [ "sockets.target" ];
  # };

  systemd.user.services.atuin-daemon = {
    Unit = {
      Description = "Atuin shell history daemon";
      # Requires = "atuin-daemon.socket";
    };

    Service = {
      ExecStart = "${cfg.package}/bin/atuin daemon";
      # Environment = [
      #   "ATUIN_DAEMON__SYSTEMD_SOCKET=true"
      # ];
    };

    Install = {
      # Also = [ "atuin-daemon.socket" ];
      WantedBy = [ "default.target" ];
    };
  };
}

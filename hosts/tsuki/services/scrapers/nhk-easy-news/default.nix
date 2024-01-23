{ config, pkgs, lib, ... }: let
  cfg = config.systemd.services.scrape-nhk-easy-news;
  script = pkgs.writers.writePython3 "scrape-nhk-easy-news.py" {
    libraries = with pkgs.python3Packages; [ requests wget ];
  } (lib.fileContents ./script.py);
in {
  systemd.services.scrape-nhk-easy-news = {
    after = [ "network.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = script;
      DynamicUser = true;
      PrivateTmp = true;
      ProtectHome = true;
      ProtectProc = "invisible";
      ProtectSystem = "strict";
      WorkingDirectory = "/data/scrapers/nhk-easy-news";
    };
  };

  systemd.timers.scrape-nhk-easy-news = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      Unit = "scrape-nhk-easy-news.service";
      OnCalendar = "*-*-* 03:00:00";
    };
  };
}

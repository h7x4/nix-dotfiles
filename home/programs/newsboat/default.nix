{ config, pkgs, lib, ... }:
let
  cfg = config.programs.newsboat;

  # package = cfg.package;
  package = pkgs.newsboat;

  defaultBrowser = "google-chrome-stable %u";
  videoViewer = "mpv %u";
in {
  imports = [ ./sources.nix ];

  programs.newsboat = {
    enable = true;
    autoReload = true;
    maxItems = 50;
    browser = ''"${defaultBrowser}"'';
    extraConfig = lib.strings.concatStringsSep "\n" [
      ''
        macro m set browser "${videoViewer}"; open-in-browser ; set browser "${defaultBrowser}"
        macro l set browser "${defaultBrowser}"; open-in-browser ; set browser "${defaultBrowser}"
      ''

      # Unbind keys
      ''
        unbind-key ENTER
        unbind-key j
        unbind-key k
        unbind-key J
        unbind-key K
      ''

      # Bind keys - vim style
      ''
        bind-key j down
        bind-key k up
        bind-key l open
        bind-key h quit
      ''

      # Theme
      ''
        color background         default   default
        color listnormal         default   default
        color listnormal_unread  default   default
        color listfocus          black     cyan
        color listfocus_unread   black     cyan
        color info               default   black
        color article            default   default
      ''

      # Highlights
      ''
        highlight all "---.*---" yellow
        highlight feedlist ".*(0/0))" black
        highlight article "(^Feed:.*|^Title:.*|^Author:.*)" cyan default bold
        highlight article "(^Link:.*|^Date:.*)" default default
        highlight article "https?://[^ ]+" green default
        highlight article "^(Title):.*$" blue default
        highlight article "\\[[0-9][0-9]*\\]" magenta default bold
        highlight article "\\[image\\ [0-9]+\\]" green default bold
        highlight article "\\[embedded flash: [0-9][0-9]*\\]" green default bold
        highlight article ":.*\\(link\\)$" cyan default
        highlight article ":.*\\(image\\)$" blue default
        highlight article ":.*\\(embedded flash\\)$" magenta default
      ''
    ];
  };

  systemd.user.slices.app-newsboat = {
    Unit = {
      Description = "Newsboat automation";
      Documentation = [ "man:newsboat(1)" ];
    };
  };

  # TODO: wait for internet
  systemd.user.services.newsboat-fetch-articles = {
    Unit = {
      Description = "Automatically fetch new articles for newsboat";
      Documentation = [ "man:newsboat(1)" ];
    };

    Service = {
      Type = "oneshot";
      Slice = "app-newsboat.slice";
      CPUSchedulingPolicy = "idle";
      IOSchedulingClass = "idle";
      ExecStart = "${lib.getExe pkgs.flock} %t/newsboat.lock ${lib.getExe package} --execute=reload";
    };
  };

  systemd.user.timers.newsboat-fetch-articles = {
    Unit = {
      Description = "Automatically fetch new articles for newsboat";
      Documentation = [ "man:newsboat(1)" ];
      After = [ "network.target" ];
    };

    Timer = {
      Unit = "newsboat-fetch-articles.service";
      OnCalendar = lib.mkDefault "daily";
      Persistent = true;
    };

    Install = {
      WantedBy = [ "timers.target" ];
    };
  };

  systemd.user.services.newsboat-vacuum = {
    Unit = {
      Description = "Automatically clean newsboat cache";
      Documentation = [ "man:newsboat(1)" ];
    };

    Service = {
      Type = "oneshot";
      Slice = "app-newsboat.slice";
      CPUSchedulingPolicy = "idle";
      IOSchedulingClass = "idle";
      ExecStart = "${lib.getExe pkgs.flock} %t/newsboat.lock ${lib.getExe package} --vacuum";
    };
  };

  systemd.user.timers.newsboat-vacuum = {
    Unit = {
      Description = "Automatically clean newsboat cache";
      Documentation = [ "man:newsboat(1)" ];
    };

    Timer = {
      Unit = "newsboat-vacuum.service";
      OnCalendar = lib.mkDefault "weekly";
      Persistent = true;
    };

    Install = {
      WantedBy = [ "timers.target" ];
    };
  };
}

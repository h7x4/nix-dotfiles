{ pkgs, config, ... }: let
  inherit (config) machineVars;
in {
  home.packages = with pkgs; [
    beets
    cloc
    czkawka
    delta
    diskonaut
    duf
    duff
    ffmpeg
    gpg-tui
    graphviz
    httpie
    imagemagick
    jq
    kepubify
    # keybase
    keymapviz
    libwebp
    lolcat
    mdcat
    mediainfo
    mkvtoolnix
    mmv
    mtr
    neofetch
    nix-diff
    nix-index
    nix-output-monitor
    nix-tree
    nix-update
    nixpkgs-review
    # nixops
    nmap
    ouch
    pandoc
    parallel
    pinentry
    pinentry-curses
    progress
    python3
    rclone
    ripgrep
    rsync
    # sc-im
    slack-term
    taskwarrior
    taskwarrior-tui
    tea
    tealdeer
    terminal-parrot
    termtosvg
    toilet
    tokei
    unpaper
    usbutils
    waifu2x-converter-cpp
    wavemon
    wiki-tui
    yt-dlp
    yubico-pam
    yubikey-agent
    yubikey-manager
    zip

    # Needed for VSCode liveshare
    desktop-file-utils
    krb5
    zlib
    icu
    openssl
    xorg.xprop
  ] ++ (
    lib.optionals (!machineVars.headless) [
      ahoviewer
      # anki
      ark
      birdtray
      calibre
      cool-retro-term
      # darktable
      discord
      element-desktop
      geogebra
      gimp
      # gnome.gnome-font-viewer
      gnome.seahorse
      google-chrome
      inkscape
      # insomnia
      iwgtk
      # keybase-gui
      kid3
      koreader
      # krita
      ktouch
      libnotify
      libreoffice
      light
      # maim
      mopidy
      mopidy-mpd
      mopidy-soundcloud
      mopidy-youtube
      mpc_cli
      nyxt
      # obsidian
      # pcloud
      pulseaudio
      pulsemixer
      # scrcpy
      shellcheck
      slack
      # sublime3
      # swiPrologWithGui
      sxiv
      # tagainijisho
      teams
      tenacity
      thunderbird
      # transcribe
      wireshark
      xcalib
      xclip
      xdotool
      (xfce.thunar.override {
        thunarPlugins = with xfce; [
          thunar-volman
          # thunar-dropbox-plugin
          thunar-archive-plugin
          thunar-media-tags-plugin
        ];
      })
      xmonad-log

      # xsnow # Wait until christmas
      yubioath-flutter
      zotero
    ] ++ lib.optionals (machineVars.laptop) [
      touchegg
    ] ++ lib.optionals (machineVars.gaming) [
      citra
      desmume
      minecraft
      osu-lazer
      retroarchFull
      steam
      steam-tui
      stepmania
      taisei
    ]
  );
}


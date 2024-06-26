{ pkgs, config, machineVars, ... }:
{
  home.packages = with pkgs; [
    beets
    binutils
    cloc
    czkawka
    delta
    diskonaut
    duf
    duff
    ffmpeg
    file
    gh-dash
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
    meli
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
    progress
    python3
    rclone
    ripgrep
    rsync
    # sc-im
    slack-term
    tea
    tealdeer
    terminal-parrot
    termtosvg
    toilet
    tokei
    unpaper
    unzip
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
    # krb5
    zlib
    icu
    openssl
    xorg.xprop
  ] ++ (
    lib.optionals (!machineVars.headless) [
      ahoviewer
      alsa-utils
      # anki
      ark
      birdtray
      calibre
      cool-retro-term
      darktable
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
      pwvucontrol
      # scrcpy
      shellcheck
      slack
      # sublime3
      # swiPrologWithGui
      sxiv
      # tagainijisho

      tenacity
      thunderbird
      # transcribe
      wireshark
      xcalib
      xclip
      xdotool
      xorg.xmodmap
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
      desmume
      osu-lazer
      (prismlauncher.override {
        jdk17 = jdk21;
      })
      retroarchFull
      steam
      steam-tui
      stepmania
      taisei
    ]
  );
}


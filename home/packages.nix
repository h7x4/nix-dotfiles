{ pkgs, config, machineVars, ... }:
{
  home.packages = with pkgs; [
    binutils
    cloc
    cyme
    czkawka
    delta
    diskonaut
    duf
    duff
    ffmpeg
    file
    glances
    gpg-tui
    gping
    graphviz
    hexyl
    httpie
    imagemagick
    kepubify
    # keybase
    keymapviz
    libwebp
    lnav
    lolcat
    mdcat
    mediainfo
    meli
    mkvtoolnix
    mmv
    mtr
    neofetch
    nix-diff
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
    pwntools
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
    uutils-coreutils
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
      anki
      ark
      calibre
      cool-retro-term
      darktable
      discord
      element-desktop
      geogebra
      ghidra
      gimp
      gnome.gnome-font-viewer
      gnome.seahorse
      google-chrome
      imhex
      inkscape
      insomnia
      iwgtk
      kid3
      koreader
      krita
      ktouch
      libnotify
      libreoffice
      light
      mopidy
      mopidy-mpd
      mopidy-soundcloud
      mopidy-youtube
      mpc_cli
      naps2
      nsxiv
      nyxt
      obsidian
      # pcloud
      pdfarranger
      pwvucontrol
      # scrcpy
      shellcheck
      slack
      # sublime3
      # swiPrologWithGui
      tagainijisho

      tenacity
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


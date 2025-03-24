{ pkgs, config, machineVars, ... }:
{
  home.packages = with pkgs; [
    bandwhich
    binutils
    cloc
    cyme
    czkawka
    difftastic
    diskonaut
    duf
    duff
    fclones
    ffmpeg
    file
    fselect
    gitoxide
    glances
    gpauth
    gpclient
    gpg-tui
    gping
    graphviz
    hexyl
    htmlq
    httpie
    huniq
    hyperfine
    imagemagick
    kepubify
    keymapviz
    libwebp
    lnav
    lolcat
    lurk
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
    parallel
    pipr
    progress
    pwntools
    python3
    rclone
    rip2
    rnr
    rsync
    # sc-im
    skim
    slack-term
    tea
    terminal-parrot
    termtosvg
    toilet
    tokei
    trippy
    unpaper
    unzip
    usbutils
    uutils-coreutils-noprefix
    waifu2x-converter-cpp
    watchexec
    wavemon
    wiki-tui
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
      gnome-font-viewer
      seahorse
      google-chrome
      imhex
      imv
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
      mission-center
      mopidy
      mopidy-mpd
      mopidy-soundcloud
      mopidy-youtube
      mpc_cli
      naps2
      nsxiv
      nyxt
      obsidian
      pcloud
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
      webcamoid
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


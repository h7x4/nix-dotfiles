{ pkgs, config, ... }: let
  inherit (config) machineVars;
in {
  home.packages = with pkgs; [
    asciidoctor
    beets
    biber
    broot
    castnow
    catdocx
    cheat
    cli-visualizer
    cloc
    czkawka
    delta
    diskonaut
    diskus
    docker
    dogdns
    du-dust
    duf
    duff
    epr
    fd
    ffmpeg
    glances
    googler
    gpg-tui
    gping
    graphviz
    hck
    hexyl
    httpie
    icdiff
    imagemagick
    ipcalc
    jq
    kepubify
    keybase
    keymapviz
    kondo
    lastpass-cli
    lazydocker
    libwebp
    lolcat
    manix
    mcfly
    mdcat
    mdp
    mediainfo
    megacmd
    megasync
    micro
    mkvtoolnix
    mmv
    mtr
    navi
    neofetch
    nix-diff
    nix-index
    nix-output-monitor
    nix-tree
    nix-zsh-completions
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
    rust-motd
    sc-im
    sd
    slack-term
    taskwarrior
    taskwarrior-tui
    tea
    tealdeer
    terminal-parrot
    termtosvg
    # tv-renamer
    toilet
    tokei
    tsukae
    unpaper
    usbutils
    w3m
    waifu2x-converter-cpp
    watchexec
    wavemon
    wiki-tui
    youtube-dl
    yq
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
  ] ++ (with pkgs.python3Packages; [
    bpython
  ]) ++ (with pkgs.haskellPackages; [
    # bhoogle
  ]) ++ (
    lib.optionals (!machineVars.headless) [
      ahoviewer
      anki
      ark
      calibre
      cool-retro-term
      copyq
      darktable
      discord
      element-desktop
      fcitx
      geogebra
      gimp
      gnome.gnome-font-viewer
      gnome.seahorse
      google-chrome
      inkscape
      insomnia
      iwgtk
      keybase-gui
      kid3
      koreader
      krita
      ktouch
      libreoffice-fresh
      light
      maim
      mopidy
      mopidy-mpd
      mopidy-soundcloud
      mopidy-youtube
      mpc_cli
      nyxt
      # obsidian
      pcloud
      pulseaudio
      pulsemixer
      scrcpy
      shellcheck
      slack
      sublime3
      swiPrologWithGui
      sxiv
      tagainijisho
      teams
      tenacity
      thunderbird
      transcribe
      wireshark
      xcalib
      xclip
      xdotool
      (xfce.thunar.override {
        thunarPlugins = with xfce; [
          thunar-volman
          thunar-dropbox-plugin
          thunar-archive-plugin
          thunar-media-tags-plugin
        ];
      })
      xmonad-log

      # xsnow # Wait until christmas
      yubioath-desktop
      yuzu-mainline
      zeal
      zoom-us
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


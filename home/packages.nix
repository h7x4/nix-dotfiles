{ pkgs, yet-unstabler-pkgs, config, machineVars, machineName, ... }:
{
  home.packages = with pkgs; [
    bandwhich
    binutils
    cloc
    cyme
    czkawka
    difftastic
    # diskonaut
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
      kdePackages.ark
      calibre
      cool-retro-term
      darktable
      yet-unstabler-pkgs.discord
      element-desktop
      foliate
      geogebra
      ghidra
      gimp3-with-plugins
      gnome-font-viewer
      google-chrome
      imhex
      imv
      inkscape
      insomnia
      iwgtk
      kid3
      koreader
      krita
      # kdePackages.ktouch
      libnotify
      libreoffice
      light
      mission-center
      mopidy
      mopidy-mpd
      mopidy-soundcloud
      mopidy-youtube
      mpc_cli
      mumble
      naps2
      nsxiv
      nyxt
      obsidian
      pdfarranger
      pwvucontrol
      # scrcpy
      seahorse
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
      # osu-lazer
      # retroarchFull
      steam
      steam-tui
      stepmania
      taisei
    ] ++ lib.optionals (machineName != "dosei") [
      # Source blocked by external firewall on dosei
      pcloud
    ]
  );
}


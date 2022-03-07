{ pkgs, ... }:
{
  home.packages = with pkgs; [
    ahoviewer
    anki
    asciidoctor
    audacity
    beets
    biber
    calibre
    castnow
    citra
    cool-retro-term
    copyq
    czkawka
    darktable
    desmume
    discord
    diskonaut
    diskus
    docker
    du-dust
    fcitx
    fd
    ffmpeg
    geogebra
    gnome.gnome-font-viewer
    google-chrome
    # gpgtui
    graphviz
    # hck
    hexyl
    imagemagick
    inkscape
    insomnia
    jq
    kepubify
    kid3
    koreader
    krita
    ktouch
    lastpass-cli
    lazydocker
    libreoffice-fresh
    light
    lolcat
    maim
    manix
    mdcat
    mdp
    mediainfo
    megacmd
    megasync
    micro
    minecraft
    mkvtoolnix
    mmv
    mopidy
    mopidy-mpd
    mopidy-soundcloud
    mopidy-spotify
    mopidy-youtube
    mpc_cli
    mps-youtube
    neofetch
    nmap
    nyxt
    osu-lazer
    ouch
    pandoc
    pulseaudio
    pulsemixer
    python3
    ripgrep
    rsync
    rust-motd
    sc-im
    scrcpy
    slack
    slack-term
    # steam-tui
    sxiv
    tagainijisho
    taisei
    tealdeer
    teams
    # tenacity
    # tv-renamer
    toilet
    tokei
    touchegg
    w3m
    waifu2x-converter-cpp
    wavemon
    xcalib
    xclip
    xdotool
    xfce.thunar
    xfce.thunar-archive-plugin
    xfce.thunar-dropbox-plugin
    xfce.thunar-media-tags-plugin
    xfce.thunar-volman
    youtube-dl
    # yuzu-mainline
    zeal
    zoom-us
    zotero

    # Needed for VSCode liveshare
    desktop-file-utils
    krb5
    zlib
    icu
    openssl
    xorg.xprop
  ];
}


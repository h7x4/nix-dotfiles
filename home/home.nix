{ config, pkgs, lib, extendedLib, inputs, machineVars, ... } @ args: let
  inherit (lib) mkForce mkIf optionals;
  graphics = !machineVars.headless;
in {
  imports = [
    ./shell.nix
    ./packages.nix
    ./breakerbox.nix

    ./config/xdg
    ./config/ensure-homedir-structure.nix
    ./config/downloads-sorter.nix
  ];

  sops.defaultSopsFile = ../secrets/home.yaml;
  sops.age.sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519_home_sops" ];

  home = {
    username = "h7x4";
    homeDirectory = "/home/h7x4";

    sessionPath = [
      "$HOME/.local/bin"
    ];

    # TODO: fix overriding home.file in home-manager
    # file = mkIf graphics {
    #   ".icons/default/index.theme".source = lib.mkForce null;
    #   ".icons/default/${config.home.pointerCursor.name}.theme".source = lib.mkForce null;
    # };

    pointerCursor = mkIf graphics  {
      package = pkgs.capitaine-cursors;
      name = "capitaine-cursors";
      size = 16;
      dotIcons.enable = false;
    };

    keyboard.options = [ "caps:escape" ];

    sessionVariables = {
      DO_NOT_TRACK = "1";
      _JAVA_AWT_WM_NONREPARENTING = "1";
    };
  };

  dconf.settings = mkIf graphics {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  xsession = {
    enable = !machineVars.wayland;
    # TODO: declare using xdg config home
    scriptPath = ".config/X11/xsession";
    profilePath = ".config/X11/xprofile";
  };

  xdg.configFile = {
    "ghc/ghci.conf".text = ''
      :set prompt "${extendedLib.termColors.front.magenta "[GHCi]λ"} "
    '';
  };

  news.display = "silent";

  fonts.fontconfig.enable = mkForce true;

  manual = {
    html.enable = true;
    manpages.enable = true;
    json.enable = true;
  };

  qt = mkIf graphics {
    enable = true;
    platformTheme.name = "adwaita";
    style.name = "adwaita-dark";
  };
}

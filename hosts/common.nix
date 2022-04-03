{ pkgs, config, inputs, specialArgs, ... }:
let
  inherit (pkgs) lib;
in {
  time.timeZone = "Europe/Oslo";

  i18n.defaultLocale = "en_US.UTF-8";

  # nixpkgs.config = {
  #   allowUnfree = true;
  # };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
	    builders-use-substitutes = true
    '';
  };

  environment = {
    variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    shells = with pkgs; [
      bashInteractive
      zsh
      dash
    ];

    etc = {
      # TODO: move this out of etc, and reference it directly in sudo config.
      sudoLecture = {
        target = "sudo.lecture";
        text = lib.termColors.front.red "Be careful or something, idk...\n";
      };

      "resolv.conf".source = let
        inherit (lib.strings) concatStringsSep;
        inherit (pkgs) writeText;
      in writeText "resolv.conf" ''
        ${concatStringsSep "\n" (map (ns: "nameserver ${ns}") config.networking.nameservers)}
        options edns0
      '';

      currentSystemPackages = {
        target = "current-system-packages";
        text = let
          inherit (lib.strings) concatStringsSep;
          inherit (lib.lists) sort;
          inherit (lib.trivial) lessThan;
          packages = map (p: "${p.name}") config.environment.systemPackages;
          sortedUnique = sort lessThan (lib.unique packages);
        in concatStringsSep "\n" sortedUnique;
      };
    };
  };

  fonts = {
    enableDefaultFonts = true;

    fonts = with pkgs; [
      cm_unicode
      dejavu_fonts
      fira-code
      fira-code-symbols
      powerline-fonts
      iosevka
      symbola
      corefonts
      ipaexfont
      ipafont
      liberation_ttf
      migmix
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      open-sans
      source-han-sans
      source-sans
      ubuntu_font_family
      victor-mono
      (nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; })
      inputs.fonts
    ];

    fontconfig = {
      defaultFonts = {
        serif = [ "Droid Sans Serif" "Ubuntu" ];
        sansSerif = [ "Droid Sans" "Ubuntu" ];
        monospace = [ "Fira Code" "Ubuntu" ];
        emoji = [ "Noto Sans Emoji" ];
      };
    };
  };

  users.users.h7x4 = {
    isNormalUser = true;
    shell = pkgs.zsh;
  };

  home-manager = {
    useGlobalPkgs = true;
    extraSpecialArgs = specialArgs;

    # TODO: figure out why specialArgs isn't accessible from the root home file.
    users.h7x4 = import ../home.nix {
      inherit pkgs;
      inherit (specialArgs) machineVars inputs;
    };
  };

  security.sudo.extraConfig = ''
    Defaults    lecture = always
    Defaults    lecture_file = /etc/${config.environment.etc.sudoLecture.target}
  '';
 
  system.stateVersion = "21.11";
}

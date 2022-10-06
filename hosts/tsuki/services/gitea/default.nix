{ config, pkgs, unstable-pkgs, lib, secrets, ... }:
{
  security.pam.services."gitea".unixAuth = true;

  users.users.git = {
    description = "Gitea service";
    home = config.services.gitea.stateDir;
    useDefaultShell = true;

    group = "gitea";
    isSystemUser = true;
    uid = config.ids.uids.git;
  };

  services.gitea = {
    enable = true;
    user = "git";
    cookieSecure = true;
    rootUrl = "https://git.nani.wtf/";
    domain = "git.nani.wtf";
    httpPort = secrets.ports.gitea;
    disableRegistration = true;

    package = unstable-pkgs.gitea;

    dump = {
      enable = true;
      interval = "hourly";
    };

    database = {
      user = "git";
    };

    settings = {
      server = {
        BUILTIN_SSH_SERVER_USER="git";
        LANDING_PAGE = "/explore/repos";
      };

      ui = {
        DEFAULT_THEME = "monokai";
        THEMES = lib.strings.concatStringsSep "," [
          "gitea"
          "arc-green"

          # Custom
          "monokai"
        ];
      };
      indexer.REPO_INDEXER_ENABLED = true;
      mailer = {
        ENABLED = true;
        FROM = "gitea@nani.wtf";
      };

      # TODO: fix

      # markup = let
      #   docutils = pkgs.python37.withPackages (ps: with ps; [
      #       docutils # Provides rendering of ReStructured Text files
      #       pygments # Provides syntax highlighting
      #   ]);
      # in {
      #   restructuredtext = {
      #     ENABLED = true;
      #     FILE_EXTENSIONS = ".rst";
      #     RENDER_COMMAND = "${docutils}/bin/rst2html.py";
      #     IS_INPUT_FILE = false;
      #   };
      #   asciidoc = {
      #     ENABLED = true;
      #     FILE_EXTENSIONS = ".adoc,.asciidoc";
      #     RENDER_COMMAND = "${pkgs.asciidoctor}/bin/asciidoctor -e -a leveloffset=-1 --out-file=- -";
      #     IS_INPUT_FILE = false;
      #   };
      # };
    };
  };

  system.activationScripts.linkGiteaThemes.text = let
    themes = pkgs.stdenv.mkDerivation {
      pname = "gitea-themes";
      version = "1.0.0";
      src = ./themes;

      buildInputs = with pkgs; [ lessc ];
      buildPhase = ''
        mkdir out
        for f in $(find -name 'theme-*.less')
        do
          lessc $f out/''${f%.less}.css
        done;
      '';
      installPhase = "mv out $out";
    };
    cssParentPath = "${config.services.gitea.stateDir}/custom/public";
    cssPath = "${cssParentPath}/css";
  in ''
    if [[ ! -e "${cssPath}" ]]; then
      printf "creating symlink at %s...\n" "${cssPath}"
      mkdir -p "${cssParentPath}"
      ln -s "${themes}" "${cssPath}"
    elif [ -L "${cssPath}" ]; then
      printf "replacing symlink at %s...\n" "${cssPath}"
      rm ${cssPath}
      ln -s "${themes}" "${cssPath}"
    else
      printf "ERROR: %s already exists and it is not a symlink\n" "${cssPath}"
      _localstatus=1;
    fi
  '';
}

{config, pkgs, lib, secrets, ...}:
let

  # TODO: Include monokai

  # pkgs.writeTextFile 
  # {
  #   name = "monokai.css";
  #   text = '''';

  # }
in
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
    appName = "Git Gud";
    cookieSecure = true;
    rootUrl = "https://git.nani.wtf/";
    domain = "git.nani.wtf";
    httpPort = secrets.ports.gitea;
    disableRegistration = true;

    database = {
      user = "git";
    };

    settings = {
      server = {
        BUILTIN_SSH_SERVER_USER="git";
      };

      ui = {
        DEFAULT_THEME = "arc-green";
        THEMES = lib.strings.concatStringsSep "," [
          "gitea"
          "arc-green"
          # "monokai"
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
}

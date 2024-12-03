{ config, pkgs, lib, ... }:
{
  nix.settings.use-xdg-base-directories = true;

  home.sessionVariables = let
    inherit (config.xdg) dataHome cacheHome configHome userDirs;
    runtimeDir = "/run/user/${toString config.home.uid}";
  in {
    TEXMFHOME = "${dataHome}/texmf";
    TEXMFVAR = "${cacheHome}/texlive";
    TEXMFCONFIG = "${configHome}/texlive";

    PSQL_HISTORY = "${dataHome}/psql_history";
    SQLITE_HISTORY= "${dataHome}/sqlite_history";
    MYSQL_HISTFILE = "${dataHome}/mysql_history";
    NODE_REPL_HISTORY = "${dataHome}/node_repl_history";
    GDB_HISTFILE = "${dataHome}/gdb_history";
    PYTHON_HISTORY = "${dataHome}/python_history";

    GHCUP_USE_XDG_DIRS = "true";

    __GL_SHADER_DISK_CACHE_PATH = "${cacheHome}/nv";
    ANDROID_USER_HOME = "${dataHome}/android";
    AZURE_CONFIG_DIR = "${dataHome}/azure";
    BZRPATH = "${configHome}/bazaar";
    BZR_PLUGIN_PATH = "${dataHome}/bazaar";
    BZR_HOME = "${cacheHome}/bazaar";
    CARGO_HOME = "${dataHome}/cargo";
    CUDA_CACHE_PATH = "${cacheHome}/nv";
    DOCKER_CONFIG = "${configHome}/docker";
    DOTNET_CLI_HOME = "${dataHome}/dotnet";
    DOT_SAGE = "${configHome}/sagemath";
    ELM_HOME = "${configHome}/";
    GOPATH = "${dataHome}/go";
    GRIPHOME = "${configHome}/grip";
    GRADLE_USER_HOME = "${dataHome}/gradle";
    ICEAUTHORITY = "${cacheHome}/ICEauthority";
    NIMBLE_DIR = "${dataHome}/nimble";
    NLTK_DATA = "${dataHome}/nltk_data";
    NPM_CONFIG_CACHE="${cacheHome}/npm";
    NPM_CONFIG_INIT_MODULE="${configHome}/npm/config/npm-init.js";
    NPM_CONFIG_TMP="${runtimeDir}/npm";
    NRFUTIL_HOME = "${dataHome}/nrfutil";
    NUGET_PACKAGES = "${cacheHome}/nuget-packages";
    PARALLEL_HOME = "${configHome}/parallel";
    PYENV_ROOT = "${dataHome}/pyenv";
    RUSTUP_HOME = "${dataHome}/rustup";
    RYE_HOME = "${dataHome}/rye";
    STACK_ROOT = "${dataHome}/stack";
    W3M_DIR = "${dataHome}/w3m";
    WINEPREFIX = "${dataHome}/wine";

    # TODO: these needs to be set before the user session has fully initialized
    # XINITRC = "$XDG_CONFIG_HOME/x11/initrc";
    # XAUTHORITY
    # ERRFILE = "${cacheHome}/X11/xsession-errors";
    # USERXSESSION
    # XCOMPOSECACHE="${cacheHome}/X11/xcompose";
    # XCURSOR_PATH
  };

  xdg.configFile = {
    "npm/npmrc".text = ''
      prefix=${config.xdg.dataHome}/npm
      cache=${config.xdg.cacheHome}/npm
      init-module=${config.xdg.configHome}/npm/config/npm-init.js
    '';
    "bpython/config".text = ''
      [general]
      hist_file = ${config.xdg.dataHome}/bpython_history
    '';
  };
}

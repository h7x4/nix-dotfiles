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
    MYSQL_HISTFILE = "${dataHome}/mysql_history";
    NODE_REPL_HISTORY = "${dataHome}/node_repl_history";
    GDB_HISTFILE = "${dataHome}/gdb_history";
    HISTFILE = "${dataHome}/bash_history";

    GHCUP_USE_XDG_DIRS = "true";

    __GL_SHADER_DISK_CACHE_PATH = "${cacheHome}/nv";
    _JAVA_OPTIONS = "-Djava.util.prefs.userRoot=${configHome}/java";
    ANDROID_USER_HOME = "${dataHome}/android";
    AZURE_CONFIG_DIR = "${dataHome}/azure";
    BZRPATH = "${configHome}/bazaar";
    BZR_PLUGIN_PATH = "${dataHome}/bazaar";
    BZR_HOME = "${cacheHome}/bazaar";
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
    NPM_CONFIG_CACHE = "${cacheHome}/npm";
    NPM_CONFIG_INIT_MODULE = "${configHome}/npm/config/npm-init.js";
    NPM_CONFIG_TMP = "${runtimeDir}/npm";
    NODE_COMPILE_CACHE = "${cacheHome}/node-compile-cache";
    NRFUTIL_HOME = "${dataHome}/nrfutil";
    NUGET_PACKAGES = "${cacheHome}/nuget-packages";
    PARALLEL_HOME = "${configHome}/parallel";
    PYENV_ROOT = "${dataHome}/pyenv";
    RUSTUP_HOME = "${dataHome}/rustup";
    RYE_HOME = "${dataHome}/rye";
    STACK_ROOT = "${dataHome}/stack";
    W3M_DIR = "${dataHome}/w3m";
    WINEPREFIX = "${dataHome}/wine";

    SBT_OPTS = lib.concatStringsSep " " [
      "-Dsbt.ivy.home=${cacheHome}/ivy"
      "-Dsbt.boot.directory=${cacheHome}/sbt/boot"
      "-Dsbt.preloaded=${cacheHome}/sbt/preloaded"
      "-Dsbt.global.base=${cacheHome}/sbt"
      "-Dsbt.global.staging=${cacheHome}/sbt/staging"
      "-Dsbt.global.zinc=${cacheHome}/sbt/zinc"
      "-Dsbt.dependency.base=${cacheHome}/sbt/dependency"
      "-Dsbt.repository.config=${configHome}/sbt/repositories"
      "-Dsbt.global.settings=${configHome}/sbt/global"
      "-Dsbt.global.plugins=${configHome}/sbt/plugins"
      "-Dmaven.repo.local=${cacheHome}/maven/repository"
      "-Divy.settings.dir=${configHome}/ivy2"
      "-Divy.home=${cacheHome}/ivy2"
      "-Divy.cache.dir=${cacheHome}/ivy2/cache"
    ];

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

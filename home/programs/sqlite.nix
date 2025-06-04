{ config, lib, pkgs, ... }:
let
  cfg = config.programs.sqlite;
in
{
  options.programs.sqlite.enable = lib.mkEnableOption "sqlite";

  config = lib.mkIf cfg.enable {
    xdg.configFile."sqlite3/sqliterc".text = ''
      .bail on
      .changes on
      .headers on
      .mode box
      .nullvalue '<NULL>'
      .timer on
    '';

    home.packages = [
      pkgs.sqlite-interactive
    ];

    home.sessionVariables.SQLITE_HISTORY= "${config.xdg.dataHome}/sqlite_history";
  };
}

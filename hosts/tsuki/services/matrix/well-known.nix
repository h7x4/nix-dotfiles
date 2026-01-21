{ config, pkgs, lib, ... }:
let
  cfg = config.services.matrix-well-known;
  format = pkgs.formats.json { };
  matrixDomain = "matrix.nani.wtf";
in
{
  options.services.matrix-well-known = {
    client = lib.mkOption {
      type = lib.types.submodule { freeformType = format.type; };
      default = { };
      example = {
        "m.homeserver".base_url = "https://${matrixDomain}/";
      };
    };

    server = lib.mkOption {
      type = lib.types.submodule { freeformType = format.type; };
      default = { };
      example = {
        "m.server" = "https://${matrixDomain}/";
      };
    };
  };

  config = {
    services.nginx.virtualHosts.${matrixDomain} = {
      locations."= /.well-known/matrix/client" = lib.mkIf (cfg.client != { }) {
        alias = format.generate "nginx-well-known-matrix-server.json" cfg.client;
        extraConfig = ''
          default_type application/json;
          add_header Access-Control-Allow-Origin *;
        '';
      };
      locations."= /.well-known/matrix/server" = lib.mkIf (cfg.server != { }) {
        alias = format.generate "nginx-well-known-matrix-server.json" cfg.server;
        extraConfig = ''
          default_type application/json;
          add_header Access-Control-Allow-Origin *;
        '';
      };
    };

    # TODO: modularize
    services.nginx.virtualHosts."nani.wtf" = {
      locations."= /.well-known/matrix/client" = lib.mkIf (cfg.client != { }) {
        alias = format.generate "nginx-well-known-matrix-server.json" cfg.client;
        extraConfig = ''
          default_type application/json;
          add_header Access-Control-Allow-Origin *;
        '';
      };
      locations."= /.well-known/matrix/server" = lib.mkIf (cfg.server != { }) {
        alias = format.generate "nginx-well-known-matrix-server.json" cfg.server;
        extraConfig = ''
          default_type application/json;
          add_header Access-Control-Allow-Origin *;
        '';
      };
    };
  };
}

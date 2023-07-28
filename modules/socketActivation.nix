{ config, pkgs, lib, ... }:
let
  inherit (lib) mkOption types mdDoc;
  cfg = lib.filterAttrs (_: value: value.enable) config.local.socketActivation;
in
{
  options.local.socketActivation = mkOption {
    type = types.attrsOf (types.submodule ({ name, ... }: {
      options = {
        enable = lib.mkEnableOption "socket activation for <name>";

        service = mkOption {
          type = types.str;
          default = name;
          defaultText = "<name>";
          example = "myservice";
          description = mdDoc "Systemd service name";
        };

        privateNamespace = mkOption {
          type = types.bool;
          default = true;
          example = false;
          description = mdDoc ''
            Whether to isolate the network of the original service.

            This is recommended, but might be impractical if the original
            service also uses networking for its own operation.
          '';
        };

        originalSocketAddress = mkOption {
          type = types.str;
          example = "localhost:8080";
          description = mdDoc ''
            Socket that the original service is listening to.

            This could be a TCP or UNIX socket.
          '';
        };

        newSocketAddress = mkOption {
          type = with types; either str port;
          example = "localhost:8080";
          description = mdDoc ''
            Addres of the new systemd socket.

            This could be a TCP or UNIX socket.
          '';
        };

        connectionsMax = mkOption {
          type = types.int;
          default = 256;
          example = 1024;
          description = mdDoc ''
            Sets the maximum number of simultaneous connections.
            If the limit of concurrent connections is reached further connections will be refused.

            See <https://www.freedesktop.org/software/systemd/man/systemd-socket-proxyd.html#--connections-max=>
          '';
        };

        exitIdleTime = mkOption {
          type = types.nullOr types.str;
          default = "5m";
          example = "1h";
          description = mdDoc ''
            Amount of inactivity time, before systemd shuts down the service.
            If this is set to `null`, the service will never stop.

            See <https://www.freedesktop.org/software/systemd/man/systemd-socket-proxyd.html#--exit-idle-time=>
          '';
        };
      };
    }));
    description = mdDoc "Forcefully socket activated systemd services";
    default = { };
  };

  config = {
    assertions = lib.mapAttrsToList (name: value: {
      # NOTE: This assertion is missing a lot of invalid cases.
      #       The original socket address could've been "localhost:1234" and now only 1234,
      #         while still meaning the same thing.
      #       Also, if the originalSocketAddress and newSocketAddress is the same UNIX socket path
      #         it doesn't matter whether they're in different namespaces AFAIK, they'll still clash.
      assertion = !value.privateNamespace -> (value.originalSocketAddress != value.newSocketAddress);
      message = ''
        The new proxied socket address of "${name}" clashes with its original socket address.
        Either enable `privateNamespace` to isolate the original service' network, or use a separate
          socket address.
      '';
    }) cfg;

    systemd = lib.mkMerge ((lib.flip lib.mapAttrsToList) cfg (name: value: let
      originalService = config.systemd.services.${value.service};
    in {
      sockets."${name}-proxy" = {
        wantedBy = [ "sockets.target" ];
        socketConfig = {
          ListenStream = value.newSocketAddress;
        };
      };

      services."${name}-proxy" = rec {
        requires = [
          "${name}.service"
          "${name}-proxy.socket"
        ];
        after = requires;

        unitConfig = lib.mkIf value.privateNamespace {
          JoinsNamespaceOf = "${value.service}.service";
        };

        serviceConfig = {
          ExecStart = let
            args = lib.cli.toGNUCommandLineShell { } {
              exit-idle-time = if value.exitIdleTime != null then value.exitIdleTime else "infinity";
              connections-max = value.connectionsMax;
            };
          in ''${pkgs.systemd}/lib/systemd/systemd-socket-proxyd ${args} "${cfg.${name}.originalSocketAddress}"'';
          PrivateNetwork = value.privateNamespace;
        };
      };

      services.${name} = {
        unitConfig = {
          StopWhenUnneeded = true;
        };

        serviceConfig = lib.mkIf value.privateNamespace {
          PrivateNetwork = true;
        };
      };
    }));
  };
}

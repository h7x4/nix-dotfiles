{ lib, config, ... }:
{
  services.postgresql = let
    o = lib.optional;
    cfg = config.services;
    db = name: {
      inherit name;
      ensurePermissions = {
        "DATABASE \"${name}\"" = "ALL PRIVILEGES";
      };
    };
  in {
    enable = true;

    ensureDatabases = 
      (o cfg.matrix-synapse.enable "matrix-synapse")
      ++ (o cfg.mx-puppet-discord.enable "mx-puppet-discord")
      ++ (o cfg.matrix-appservice-irc.enable "matrix-appservice-irc");
    ensureUsers =
      (o cfg.matrix-synapse.enable (db "matrix-synapse"))
      ++ (o cfg.mx-puppet-discord.enable (db "mx-puppet-discord"))
      ++ (o cfg.matrix-appservice-irc.enable (db "matrix-appservice-irc"));
  };
}

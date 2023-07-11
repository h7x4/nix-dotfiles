{ secrets, ... }:
{
  services.mx-puppet-discord = {
    enable = false;
    serviceDependencies = [
      "matrix-synapse.service"
      "postgresql.service"
    ];

    settings = {

      bridge = {
        bindAddress = "localhost";
        domain = "nani.wtf";
        # TODO: connect via localhost
        homeserverUrl = "https://matrix.nani.wtf";

        port = secrets.ports.matrix.mx-puppet-discord;
        enableGroupSync = true;
      };

      database.connString = "postgres://mx-puppet-discord:@localhost:${toString secrets.ports.postgres}/mx-puppet-discord?sslmode=disable";

      namePatterns = {
        room = ":name";
        user = ":name";
        userOverride = ":displayname";
        group = ":name";
      };

      presence = {
        enabled = true;
        interval = 500;
      };

      logging = {
        console = "info";
        lineDateFormat = "MMM-D HH:mm:ss.SSS";
      };

      provisioning.whitelist = [ "@h7x4:nani\\.wtf" ];
      relay.whitelist = [ "@h7x4:nani\\.wtf" ];
      selfService.whitelist = [ "@h7x4:nani\\.wtf" ];
    };
  };
}

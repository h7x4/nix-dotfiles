{ secrets, ... }:
{
  services.matrix-appservice-irc = {
    enable = true;

    settings = {
      database = {
        engine = "postgres";
        connectionString = "postgres://matrix-appservice-irc:@localhost:${toString secrets.ports.postgres}/matrix-appservice-irc?sslmode=disable";
      };
    };
  };
}

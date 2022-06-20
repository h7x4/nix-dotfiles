{ }:
{
  services.keycloak = {
    enable = true;
    database = {
      type = "postgresql";
    };
  };
}

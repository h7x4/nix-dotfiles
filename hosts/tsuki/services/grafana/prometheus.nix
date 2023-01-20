{ secrets, ... }: {
  # TODO: Autogenerate port infrastructure

  imports = [
    ./prometheus-exporters/matrix-synapse.nix
    ./prometheus-exporters/node.nix
    ./prometheus-exporters/postgres.nix
    ./prometheus-exporters/redis.nix
    ./prometheus-exporters/systemd.nix
    ./prometheus-exporters/minecraft.nix
  ];

  services.prometheus = {
    enable = true;
    port = secrets.ports.prometheus;
  };
}

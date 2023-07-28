{ secrets, ... }: {
  # TODO: Autogenerate port infrastructure

  imports = [
    ./prometheus-exporters/gitea.nix
    ./prometheus-exporters/hedgedoc.nix
    ./prometheus-exporters/matrix-synapse.nix
    ./prometheus-exporters/minecraft.nix
    ./prometheus-exporters/nginx.nix
    ./prometheus-exporters/node.nix
    # TODO: activate when php-fpm exporter is backported
    # ./prometheus-exporters/php-fpm.nix
    ./prometheus-exporters/postgres.nix
    ./prometheus-exporters/redis.nix
    ./prometheus-exporters/systemd.nix
  ];

  services.prometheus = {
    enable = true;
    port = secrets.ports.prometheus;
  };
}

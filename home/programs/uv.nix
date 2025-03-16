{ pkgs, ... }:
{
  home.packages = [
    pkgs.uv
  ];

  # https://docs.astral.sh/uv/configuration/files/
  # https://docs.astral.sh/uv/reference/settings/
  xdg.configFile."uv/uv.toml".source = (pkgs.formats.toml { }).generate "uv-config" {
    python-downloads = "never";
    python-preference = "only-system";
    pip.index-url = "https://test.pypi.org/simple";
  };
}

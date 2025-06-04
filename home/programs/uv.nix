{ ... }:
{
  programs.uv = {
    # https://docs.astral.sh/uv/configuration/files/
    # https://docs.astral.sh/uv/reference/settings/
    settings = {
      python-downloads = "never";
      python-preference = "only-system";
      pip.index-url = "https://test.pypi.org/simple";
    };
  };
}

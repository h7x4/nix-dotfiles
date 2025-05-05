{ ... }:
{
  services.downloads-sorter = {
    enable = true;
    mappings = {
      "pictures" = [
        "*.jpg"
        "*.png"
        "*.gif"
      ];
    };
  };
}

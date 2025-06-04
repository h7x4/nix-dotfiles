{ pkgs, ... }:
{
  programs.prism-launcher = {
    package = pkgs.prismlauncher.override {
      jdk17 = pkgs.jdk21;
    };

    screenshotMover.enable = true;
  };
}

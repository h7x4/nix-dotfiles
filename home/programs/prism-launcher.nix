{ pkgs, ... }:
{
  programs.prism-launcher = {
    enable = true;

    package = pkgs.prismlauncher.override {
      jdk17 = pkgs.jdk21;
    };

    screenshotMover.enable = true;
  };
}

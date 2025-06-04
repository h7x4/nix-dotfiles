{ config, lib, pkgs, ... }:
let
  cfg = config.programs.taskwarrior;
in
lib.mkIf cfg.enable {
  programs.taskwarrior = {
    package = pkgs.taskwarrior3;
    config = rec {
      report.minimal.filter = "(status:pending or status:waiting)";
      report.minimal.labels = "ID,Project,Tags,Description";
      report.minimal.sort = "project+,id+";

      uda.taskwarrior-tui.task-report.next.filter = report.minimal.filter;
    };
  };

  home.packages = with pkgs; [ taskwarrior-tui ];
}

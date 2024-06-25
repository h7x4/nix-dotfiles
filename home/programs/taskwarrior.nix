{ pkgs, ... }:
{
  programs.taskwarrior = {
    enable = true;
    package = pkgs.taskwarrior3;
    config = rec {
      report.minimal.filter = "(status:pending or status:waiting)";
      report.minimal.labels = "ID,Project,Tags,Description";
      report.minimal.sort = "project+,id+";

      uda.taskwarrior-tui.task-report.next.filter = report.minimal.filter;
    };
  };
}

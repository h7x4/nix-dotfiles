{ ... }:
{
  programs.zathura = {
    enable = true;
    options = {
      selection-clipboard = "clipboard";

      default-bg = "#f2e3bd";

      completion-bg = "#f2e3bd";
      completion-fg = "#5fd7a7";

      statusbar-bg = "#f2e3bd";
      statusbar-fg = "#008ec4";

      inputbar-bg = "#f2e3bd";
      inputbar-fg = "#c30771";

      recolor = true;
      recolor-lightcolor = "#f2e3bd";
      # recolor-darkcolor = "#000000";
      recolor-darkcolor = "#101010";
      recolor-keephue = true;
    };
  };
}

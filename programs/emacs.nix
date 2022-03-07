{ ... }:
{
  programs.emacs = {
    enable = true;
    # socketActivation.enable = true;
    extraPackages = epkgs: with epkgs; [
      # package
      use-package
      evil
      evil-collection
      evil-nerd-commenter
      # org
      evil-org
      monokai-theme
      gruber-darker-theme
      company
      flycheck
      projectile
      yasnippet
      magit
      # recentf
      which-key
    ];
  };
}

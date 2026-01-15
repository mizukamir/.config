{ config, pkgs, lib, gitName, gitEmail, ... }:

{
  programs.git = {
    enable = true;
    userName = gitName;
    userEmail = gitEmail;
    ignores = [ ".DS_Store" ];
    extraConfig = {
      init.templateDir = "${config.home.homeDirectory}/.config/.git-template";
    };
  };

  home.activation = {
    installGitHooks = lib.hm.dag.entryAfter ["writeBoundary"] ''
      echo "Running pre-commit init-templatedir..."
      ${pkgs.pre-commit}/bin/pre-commit init-templatedir ${config.home.homeDirectory}/.config/.git-template
    '';
  };
}

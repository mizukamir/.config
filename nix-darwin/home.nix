{ user, ... }:

{ 
  # importsを使って分割したファイルを読み込みます
  imports = [
    ./modules/packages.nix
    ./modules/git.nix
    ./modules/zsh.nix
    ./modules/wezterm.nix
    ./modules/aerospace.nix
  ];

  home.username = user;
  home.homeDirectory = "/Users/${user}";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true; 
}

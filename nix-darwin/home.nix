{ config, pkgs, user, gitName, gitEmail,... }:

{ 
  home.packages= with pkgs; [
    ripgrep
    gh
    lazygit
    bottom
    gdu
    nodejs_24
    pyenv
    wezterm
    neovim
    fd 
    obsidian
    firefox-bin
    google-chrome
    visidata
    mise
  ];
  
  home.username = user;
  home.homeDirectory = "/Users/${user}";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true; 
  
  programs.git = {
    enable = true;
    userName = gitName;
    userEmail = gitEmail;
    ignores = [ ".DS_Store" ];
  };
  programs.zsh = {
    enable = true; 

    # プラグインとしてPowerlevel10kを読み込む設定
    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];

    # .p10k.zsh（設定ファイル）が存在する場合、それを読み込む
    initContent = ''
      # --- 既存の .zshrc からの移植 ---
      export PYENV_ROOT="$HOME/.pyenv"
      export PATH="$PYENV_ROOT/bin:$PATH"
      eval "$(pyenv init --path)"
      eval "$(pyenv init -)"

      # --- Powerlevel10k の設定 ---
      # ウィザードで生成された設定ファイルがあれば読み込む
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
    '';  };
    
 programs.direnv = {
    enable = true;
    nix-direnv.enable = true; # Nixとの連携を高速化・強化
    enableZshIntegration = true; # zshを使っているため必須
  };
}

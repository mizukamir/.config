{ pkgs, ... }:

{
  programs.zsh = {
    enable = true; 

    # Powerlevel10k
    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];

    initContent = ''
      # --- Powerlevel10k の設定 ---
      [[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh

      # --- Rust (Cargo) のパス設定 ---
      if [ -d "$HOME/.cargo/bin" ]; then
        export PATH="$HOME/.cargo/bin:$PATH"
      fi
    '';
  };

  programs.direnv = {
     enable = true;
     nix-direnv.enable = true;
     enableZshIntegration = true;
   };
}

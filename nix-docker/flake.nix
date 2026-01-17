{
  description = "nix-docker(linux)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      # --- 設定変数の定義 ---
      # settings = builtins.fromJSON (builtins.readFile (builtins.getEnv "PWD" + "/../nix/mysettings.json"));
      user = "root";  # Dockerコンテナ内のユーザー
      gitName = "AI Agent";
      # gitEmail = settings.gitEmail; 
      gitEmail = "example@example.com"; 
      system = "aarch64-linux"; # M4 Mac上のDocker用

      pkgs = nixpkgs.legacyPackages.${system};

      # CodeLLDBのラッパー定義
      codelldb-wrapper = pkgs.writeShellScriptBin "codelldb" ''
        exec "${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb" "$@"
      '';
    in {
	    formatter.${system} = pkgs.nixfmt-rfc-style;
	    
      homeConfigurations."${user}" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        modules = [
          ({ pkgs, config, lib, ... }: {
            
            # --- ユーザー設定 ---
            home.username = user;
            home.homeDirectory = "/${user}";
            home.stateVersion = "24.05"; 
            
            home.sessionVariables = {
	          LANG = "ja_JP.UTF-8";
	          LC_ALL = "ja_JP.UTF-8";
	          EDITOR = "nvim";
	          SHELL = "${pkgs.zsh}/bin/zsh";  
	        };

            # --- パッケージ ---
            home.packages = with pkgs; [
              # System Utils
              vim
              neovim
              git
              ripgrep
              gh
              lazygit
              bottom
              gdu
              fd
              visidata
	            gitleaks
	            pre-commit
              
              # Runtime / Languages
              nodejs_20
              mise
              rustup
              gcc 

              # Debug
              codelldb-wrapper
            ];

            # --- プログラム設定 ---
            programs.home-manager.enable = true;

            # Git設定
            programs.git = {
              enable = true;
              userName = gitName;
              userEmail = gitEmail;
              ignores = [ ".DS_Store" ]; # Linuxでも共有フォルダ用に残す
              extraConfig = {
                init.templateDir = "${config.home.homeDirectory}/.config/.git-template";
              };
            };
            home.activation = {
              installGitHooks = lib.hm.dag.entryAfter ["writeBoundary"] ''
                echo "Running pre-commit init-templatedir..."
                # pre-commitコマンドを使ってテンプレートディレクトリを初期化・更新
                # ${pkgs.pre-commit} でNixストア内の正確なパスを参照
                ${pkgs.pre-commit}/bin/pre-commit init-templatedir ${config.home.homeDirectory}/.config/.git-template
	            '';
	          };

            # Direnv設定
            programs.direnv = {
              enable = true;
              nix-direnv.enable = true;
              enableZshIntegration = true;
            };

            # Zsh設定
            programs.zsh = {
              enable = true;
              
              # Powerlevel10kプラグイン
              plugins = [
                {
                  name = "powerlevel10k";
                  src = pkgs.zsh-powerlevel10k;
                  file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
                }
              ];

              # 初期化スクリプト
              initExtra = ''
                # --- Powerlevel10k ---
                # p10k.zshがない場合の対策
                if [[ -f "$HOME/.config/zsh/.p10k.zsh" ]]; then
                  source "$HOME/.config/zsh/.p10k.zsh"
                fi 

                # --- Rust (Cargo) ---
                if [ -d "$HOME/.cargo/bin" ]; then
                  export PATH="$HOME/.cargo/bin:$PATH"
                fi
                
                # --- Mise (Linux用) ---
                eval "$(mise activate zsh)"
              '';
            };

            # zellij設定
            programs.zellij = {
              enable = true;
              settings = {
                default_shell = "${pkgs.zsh}/bin/zsh";
                keybinds = {
                  normal = {
                    # コンテナ側のロック開始キーを Ctrl+i に変更
                    "bind \"Ctrl i\"" = { SwitchToMode = "Locked"; };
                    # デフォルトの Ctrl+g を無効化
                    "unbind \"Ctrl g\"" = {}; 
                  };
                  locked = {
                    # コンテナ側のロック解除キーを Ctrl+i に変更
                    "bind \"Ctrl i\"" = { SwitchToMode = "Normal"; };
                    # デフォルトの Ctrl+g を無効化
                    "unbind \"Ctrl g\"" = {};
                  };
                };
              };
            };
	          # シンボリックリンク
	          xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/nvim";
            xdg.configFile."mise".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/mise";
          })
        ];
      };
    };
}

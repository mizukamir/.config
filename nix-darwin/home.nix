{ config, pkgs, lib, user, gitName, gitEmail,... }:
let
  # CodeLLDBのラッパー定義 
  # VSCode拡張機能のフォルダ奥深くにあるバイナリを 'codelldb' コマンドとして呼び出せるように
  codelldb-wrapper = pkgs.writeShellScriptBin "codelldb" ''
    exec "${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb" "$@"
  '';
in
{ 
  home.packages= with pkgs; [
    ripgrep
    gh
    lazygit
    bottom
    gdu
    nodejs_24
    wezterm
    neovim
    fd 
    obsidian
    firefox-bin
    google-chrome
    visidata
    mise
    rustup
    gitleaks
    pre-commit
	  zellij

    # Debug
    codelldb-wrapper
    
    # Python
    # pyright
    # ruff
    
    # Lua
    # lua-language-server
    # stylua

    # TOML
    # taplo

    # JavaaScript/TypeScript
    # eslint
    # prettier

    # TypeScript
    # typescript-language-server

    # Nix
    # nil
    # nixfmt-rfc-style
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
      # --- Powerlevel10k の設定 ---
      # ウィザードで生成された設定ファイルがあれば読み込む
      [[ ! -f ~/.config/zsh/.p10k.zsh ]] || source ~/.config/zsh/.p10k.zsh

      # --- Rust (Cargo) のパス設定 ---
      if [ -d "$HOME/.cargo/bin" ]; then
        export PATH="$HOME/.cargo/bin:$PATH"
      fi
    '';  };
 
 
  programs.direnv = {
     enable = true;
     nix-direnv.enable = true; # Nixとの連携を高速化・強化
     enableZshIntegration = true; # zshを使っているため必須
   };

  # WezTerm
  programs.wezterm = {
    enable = true;
    
    extraConfig = ''
      local wezterm = require 'wezterm'
      local act = wezterm.action
      local config = {}
       
      if wezterm.config_builder then
        config = wezterm.config_builder()
      end
 
      config.default_prog = { "${pkgs.zellij}/bin/zellij" }
 
      -- 装飾系設定
      config.enable_tab_bar = false        -- Zellijのバーと重複するので消す
      config.window_decorations = "RESIZE" -- 枠線をシンプルに
      
      -- MacのOptionキーをMetaとして扱う（Zellij用）
      config.send_composed_key_when_left_alt_is_pressed = true
      config.send_composed_key_when_right_alt_is_pressed = true

      -- 【キーマッピング設定】
      -- Macの "Commandキー" でZellijを操作するための変換定義
      config.keys = {
        -- Cmd+h/j/k/l でペイン移動 (Zellijには Alt+h/j/k/l を送る)
        { key = 'h', mods = 'CMD', action = act.SendKey { key = 'h', mods = 'ALT' } },
        { key = 'j', mods = 'CMD', action = act.SendKey { key = 'j', mods = 'ALT' } },
        { key = 'k', mods = 'CMD', action = act.SendKey { key = 'k', mods = 'ALT' } },
        { key = 'l', mods = 'CMD', action = act.SendKey { key = 'l', mods = 'ALT' } },

        -- Cmd+n で新規ペイン (Zellijの Alt+n)
        { key = 'n', mods = 'CMD', action = act.SendKey { key = 'n', mods = 'ALT' } },
        
        -- Cmd+t で新規タブ (Zellijの Alt+t)
        { key = 't', mods = 'CMD', action = act.SendKey { key = 't', mods = 'ALT' } },
        
        -- Cmd+[ / ] でタブ切り替え (Zellijの Alt+Left/Right または n/p)
        -- Zellijのデフォルト: Alt+Left / Alt+Right ではない場合が多い
        -- Zellij側で Alt+h/l をタブ移動にするか、ここで調整必要かも。
      } 
      return config
    '';
  };

  xdg.configFile."aerospace/aerospace.toml".text = ''
    # Place a copy of this config to ~/.aerospace.toml
    # After that, you can edit ~/.aerospace.toml to your liking

    # Config version for compatibility and deprecations
    # Fallback value (if you omit the key): config-version = 1
    config-version = 2

    # You can use it to add commands that run after AeroSpace startup.
    # Available commands : https://nikitabobko.github.io/AeroSpace/commands
    after-startup-command = []

    # Start AeroSpace at login
    start-at-login = false

    # Normalizations. See: https://nikitabobko.github.io/AeroSpace/guide#normalization
    enable-normalization-flatten-containers = true
    enable-normalization-opposite-orientation-for-nested-containers = true

    # See: https://nikitabobko.github.io/AeroSpace/guide#layouts
    # The 'accordion-padding' specifies the size of accordion padding
    # You can set 0 to disable the padding feature
    accordion-padding = 30

    # Possible values: tiles|accordion
    default-root-container-layout = 'tiles'

    # Possible values: horizontal|vertical|auto
    # 'auto' means: wide monitor (anything wider than high) gets horizontal orientation,
    #               tall monitor (anything higher than wide) gets vertical orientation
    default-root-container-orientation = 'auto'

    # Mouse follows focus when focused monitor changes
    # Drop it from your config, if you don't like this behavior
    # See https://nikitabobko.github.io/AeroSpace/guide#on-focus-changed-callbacks
    # See https://nikitabobko.github.io/AeroSpace/commands#move-mouse
    # Fallback value (if you omit the key): on-focused-monitor-changed = []
    on-focused-monitor-changed = ['move-mouse monitor-lazy-center']

    # You can effectively turn off macOS "Hide application" (cmd-h) feature by toggling this flag
    # Useful if you don't use this macOS feature, but accidentally hit cmd-h or cmd-alt-h key
    # Also see: https://nikitabobko.github.io/AeroSpace/goodies#disable-hide-app
    automatically-unhide-macos-hidden-apps = false

    # List of workspaces that should stay alive even when they contain no windows,
    # even when they are invisible.
    # This config version is only available since 'config-version = 2'
    # Fallback value (if you omit the key): persistent-workspaces = []
    persistent-workspaces = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B",
                            "C", "D", "E", "F", "G", "I", "M", "N", "O", "P", "Q",
                            "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]

    # A callback that runs every time binding mode changes
    # See: https://nikitabobko.github.io/AeroSpace/guide#binding-modes
    # See: https://nikitabobko.github.io/AeroSpace/commands#mode
    on-mode-changed = []

    # Possible values: (qwerty|dvorak|colemak)
    # See https://nikitabobko.github.io/AeroSpace/guide#key-mapping
    [key-mapping]
        preset = 'qwerty'

    # Gaps between windows (inner-*) and between monitor edges (outer-*).
    # Possible values:
    # - Constant:     gaps.outer.top = 8
    # - Per monitor:  gaps.outer.top = [{ monitor.main = 16 }, { monitor."some-pattern" = 32 }, 24]
    #                 In this example, 24 is a default value when there is no match.
    #                 Monitor pattern is the same as for 'workspace-to-monitor-force-assignment'.
    #                 See:
    #                 https://nikitabobko.github.io/AeroSpace/guide#assign-workspaces-to-monitors
    [gaps]
        inner.horizontal = 0
        inner.vertical =   0
        outer.left =       0
        outer.bottom =     0
        outer.top =        0
        outer.right =      0

    # 'main' binding mode declaration
    # See: https://nikitabobko.github.io/AeroSpace/guide#binding-modes
    # 'main' binding mode must be always presented
    # Fallback value (if you omit the key): mode.main.binding = {}
    [mode.main.binding]

        # All possible keys:
        # - Letters.        a, b, c, ..., z
        # - Numbers.        0, 1, 2, ..., 9
        # - Keypad numbers. keypad0, keypad1, keypad2, ..., keypad9
        # - F-keys.         f1, f2, ..., f20
        # - Special keys.   minus, equal, period, comma, slash, backslash, quote, semicolon,
        #                   backtick, leftSquareBracket, rightSquareBracket, space, enter, esc,
        #                   backspace, tab, pageUp, pageDown, home, end, forwardDelete,
        #                   sectionSign (ISO keyboards only, european keyboards only)
        # - Keypad special. keypadClear, keypadDecimalMark, keypadDivide, keypadEnter, keypadEqual,
        #                   keypadMinus, keypadMultiply, keypadPlus
        # - Arrows.         left, down, up, right

        # All possible modifiers: cmd, alt, ctrl, shift

        # All possible commands: https://nikitabobko.github.io/AeroSpace/commands

        # See: https://nikitabobko.github.io/AeroSpace/commands#exec-and-forget
        # You can uncomment the following lines to open up terminal with alt + enter shortcut
        # (like in i3)
        # alt-enter = '''exec-and-forget osascript -e '
        # tell application "Terminal"
        #     do script
        #     activate
        # end tell'
        # '''

        # See: https://nikitabobko.github.io/AeroSpace/commands#layout
        alt-slash = 'layout tiles horizontal vertical'
        alt-comma = 'layout accordion horizontal vertical'

        # See: https://nikitabobko.github.io/AeroSpace/commands#focus
        alt-h = 'focus left'
        alt-j = 'focus down'
        alt-k = 'focus up'
        alt-l = 'focus right'

        # See: https://nikitabobko.github.io/AeroSpace/commands#move
        alt-shift-h = 'move left'
        alt-shift-j = 'move down'
        alt-shift-k = 'move up'
        alt-shift-l = 'move right'

        # See: https://nikitabobko.github.io/AeroSpace/commands#resize
        alt-minus = 'resize smart -50'
        alt-equal = 'resize smart +50'

        # See: https://nikitabobko.github.io/AeroSpace/commands#workspace
        alt-1 = 'workspace 1'
        alt-2 = 'workspace 2'
        alt-3 = 'workspace 3'
        alt-4 = 'workspace 4'
        alt-5 = 'workspace 5'
        alt-6 = 'workspace 6'
        alt-7 = 'workspace 7'
        alt-8 = 'workspace 8'
        alt-9 = 'workspace 9'
        alt-a = 'workspace A' # In your config, you can drop workspace bindings that you don't need
        alt-b = 'workspace B'
        alt-c = 'workspace C'
        alt-d = 'workspace D'
        alt-e = 'workspace E'
        alt-f = 'workspace F'
        alt-g = 'workspace G'
        alt-i = 'workspace I'
        alt-m = 'workspace M'
        alt-n = 'workspace N'
        alt-o = 'workspace O'
        alt-p = 'workspace P'
        alt-q = 'workspace Q'
        alt-r = 'workspace R'
        alt-s = 'workspace S'
        alt-t = 'workspace T'
        alt-u = 'workspace U'
        alt-v = 'workspace V'
        alt-w = 'workspace W'
        alt-x = 'workspace X'
        alt-y = 'workspace Y'
        alt-z = 'workspace Z'

        # See: https://nikitabobko.github.io/AeroSpace/commands#move-node-to-workspace
        alt-shift-1 = 'move-node-to-workspace 1'
        alt-shift-2 = 'move-node-to-workspace 2'
        alt-shift-3 = 'move-node-to-workspace 3'
        alt-shift-4 = 'move-node-to-workspace 4'
        alt-shift-5 = 'move-node-to-workspace 5'
        alt-shift-6 = 'move-node-to-workspace 6'
        alt-shift-7 = 'move-node-to-workspace 7'
        alt-shift-8 = 'move-node-to-workspace 8'
        alt-shift-9 = 'move-node-to-workspace 9'
        alt-shift-a = 'move-node-to-workspace A'
        alt-shift-b = 'move-node-to-workspace B'
        alt-shift-c = 'move-node-to-workspace C'
        alt-shift-d = 'move-node-to-workspace D'
        alt-shift-e = 'move-node-to-workspace E'
        alt-shift-f = 'move-node-to-workspace F'
        alt-shift-g = 'move-node-to-workspace G'
        alt-shift-i = 'move-node-to-workspace I'
        alt-shift-m = 'move-node-to-workspace M'
        alt-shift-n = 'move-node-to-workspace N'
        alt-shift-o = 'move-node-to-workspace O'
        alt-shift-p = 'move-node-to-workspace P'
        alt-shift-q = 'move-node-to-workspace Q'
        alt-shift-r = 'move-node-to-workspace R'
        alt-shift-s = 'move-node-to-workspace S'
        alt-shift-t = 'move-node-to-workspace T'
        alt-shift-u = 'move-node-to-workspace U'
        alt-shift-v = 'move-node-to-workspace V'
        alt-shift-w = 'move-node-to-workspace W'
        alt-shift-x = 'move-node-to-workspace X'
        alt-shift-y = 'move-node-to-workspace Y'
        alt-shift-z = 'move-node-to-workspace Z'

        # See: https://nikitabobko.github.io/AeroSpace/commands#workspace-back-and-forth
        alt-tab = 'workspace-back-and-forth'
        # See: https://nikitabobko.github.io/AeroSpace/commands#move-workspace-to-monitor
        alt-shift-tab = 'move-workspace-to-monitor --wrap-around next'

        # See: https://nikitabobko.github.io/AeroSpace/commands#mode
        alt-shift-semicolon = 'mode service'

    # 'service' binding mode declaration.
    # See: https://nikitabobko.github.io/AeroSpace/guide#binding-modes
    [mode.service.binding]
        esc = ['reload-config', 'mode main']
        r = ['flatten-workspace-tree', 'mode main'] # reset layout
        f = ['layout floating tiling', 'mode main'] # Toggle between floating and tiling layout
        backspace = ['close-all-windows-but-current', 'mode main']

        # sticky is not yet supported https://github.com/nikitabobko/AeroSpace/issues/2
        #s = ['layout sticky tiling', 'mode main']

        alt-shift-h = ['join-with left', 'mode main']
        alt-shift-j = ['join-with down', 'mode main']
        alt-shift-k = ['join-with up', 'mode main']
        alt-shift-l = ['join-with right', 'mode main']
  ''; 
}

return {
  -- 1. Treesitter: シンタックスハイライトの強化
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if opts.ensure_installed ~= "all" then
        opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "nix" })
      end
    end,
  },

  -- 2. LSP (nil_ls): 補完と賢い機能の設定
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}

      -- nil_ls (Nix Language Server) の詳細設定
      opts.servers.nil_ls = {
        settings = {
          ["nil"] = {
            -- これを有効にすると、flake.nixの inputs/outputs を解析して補完候補に出してくれます
            flake = {
              autoArchive = true,
              autoEvalInputs = true,
            },
            -- フォーマッターの設定（mason-null-lsを使っている場合はなくても動きますが、念の為）
            formatting = {
              command = { "nixfmt" },
            },
          },
        },
      }
    end,
  },

  -- 3. ファイル保存時に自動整形を有効化 (AstroNvim標準機能の設定)
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      autocmds = {
        -- .nix ファイルを開いたときにタブ幅を2にする（Nixの標準）
        nix_indent = {
          {
            event = "FileType",
            pattern = "nix",
            command = "setlocal shiftwidth=2 tabstop=2 softtabstop=2",
          },
        },
      },
    },
  },
}

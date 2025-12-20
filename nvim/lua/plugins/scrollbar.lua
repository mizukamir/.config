return {
  "petertriho/nvim-scrollbar",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = {
    -- hlslensを依存関係として定義
    {
      "kevinhwang91/nvim-hlslens",
      config = function() require("hlslens").setup() end,
    },
    -- 色取得のためにCatppuccinも依存に入れておくと安全です
    "catppuccin/nvim",
  },
  config = function()
    local scrollbar = require "scrollbar"
    local colors = require("catppuccin.palettes").get_palette "latte"

    -- 1. hlslensと連携するためのキーマップ設定 (ここが重要！)
    -- これを設定しないと、n/Nを押したときにスクロールバーの表示が更新されません
    local opts = { noremap = true, silent = true }
    local function set_keymap(lhs, rhs) vim.keymap.set("n", lhs, rhs, opts) end

    -- 検索実行時に hlslens を起動し、スクロールバーにも通知
    set_keymap("n", [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]])
    set_keymap("N", [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]])
    set_keymap("*", [[*<Cmd>lua require('hlslens').start()<CR>]])
    set_keymap("#", [[#<Cmd>lua require('hlslens').start()<CR>]])
    set_keymap("g*", [[g*<Cmd>lua require('hlslens').start()<CR>]])
    set_keymap("g#", [[g#<Cmd>lua require('hlslens').start()<CR>]])

    -- 検索ハイライトを消すときに hlslens も停止する
    set_keymap("<Leader>h", ":nohlsearch<CR><Cmd>lua require('hlslens').stop()<CR>")

    -- 2. Scrollbarのセットアップ
    scrollbar.setup {
      show = true,
      show_in_active_only = false,
      set_highlights = true,
      folds = 1000,
      max_lines = false,
      hide_if_all_visible = false,
      throttle_ms = 100,
      handle = {
        text = " ",
        blend = 30,
        color = colors.blue, -- Catppuccin Latte Blue
        color_nr = nil,
        highlight = "CursorColumn",
        hide_if_all_visible = true,
      },
      marks = {
        Cursor = {
          text = "•",
          priority = 0,
          color = nil,
          highlight = "Normal",
        },
        Search = {
          text = { "-", "=" },
          priority = 1,
          color = colors.peach, -- Search -> Peach
          highlight = "Search",
        },
        Error = {
          text = { "-", "=" },
          priority = 2,
          color = colors.red, -- Error -> Red
          highlight = "DiagnosticVirtualTextError",
        },
        Warn = {
          text = { "-", "=" },
          priority = 3,
          color = colors.yellow, -- Warn -> Yellow
          highlight = "DiagnosticVirtualTextWarn",
        },
        Info = {
          text = { "-", "=" },
          priority = 4,
          color = colors.blue, -- Info -> Blue
          highlight = "DiagnosticVirtualTextInfo",
        },
        Hint = {
          text = { "-", "=" },
          priority = 5,
          color = colors.teal, -- Hint -> Teal
          highlight = "DiagnosticVirtualTextHint",
        },
        Misc = {
          text = { "-", "=" },
          priority = 6,
          color = colors.mauve,
          highlight = "Normal",
        },
        GitAdd = {
          text = "┆",
          priority = 7,
          highlight = "GitSignsAdd",
        },
        GitChange = {
          text = "┆",
          priority = 7,
          highlight = "GitSignsChange",
        },
        GitDelete = {
          text = "▁",
          priority = 7,
          highlight = "GitSignsDelete",
        },
      },
      excluded_buftypes = {
        "terminal",
      },
      excluded_filetypes = {
        "cmp_docs",
        "cmp_menu",
        "noice",
        "prompt",
        "TelescopePrompt",
        "alpha",
        "neo-tree",
      },
      autocmd = {
        render = {
          "BufWinEnter",
          "TabEnter",
          "TermEnter",
          "WinEnter",
          "CmdwinLeave",
          "TextChanged",
          "VimResized",
          "WinScrolled",
          "CursorMoved",
        },
        clear = {
          "BufWinLeave",
          "TabLeave",
          "TermLeave",
          "WinLeave",
        },
      },
      handlers = {
        cursor = true,
        diagnostic = true,
        gitsigns = false, -- Gitsignsを使う場合はここをtrueにしてください
        handle = true,
        search = true, -- 【重要】hlslensと連携するために必須
        ale = false,
      },
    }
  end,
}

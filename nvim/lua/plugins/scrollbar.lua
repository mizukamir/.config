return {
  "petertriho/nvim-scrollbar",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = {
    {
      "kevinhwang91/nvim-hlslens",
      config = function()
        require("hlslens").setup {
          calm_down = false, -- 自動でレンズを消さない
          nearest_only = false, -- 全体を表示する
        }
      end,
    },
    "catppuccin/nvim",
  },
  config = function()
    local scrollbar = require "scrollbar"
    local colors = require("catppuccin.palettes").get_palette "latte"

    -- 1. キーマップ設定 (文字列コマンド方式 + 強制ハイライトON)
    local opts = { noremap = true, silent = true }

    -- 【解説】
    -- <Cmd>execute(...)<CR>: 通常のn動作
    -- <Cmd>set hlsearch<CR>: ここが重要。移動するたびに強制的にハイライトを有効化します。
    -- <Cmd>lua require('hlslens').start()<CR>: その上でレンズを起動します。

    vim.keymap.set(
      "n",
      "n",
      [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>set hlsearch<CR><Cmd>lua require('hlslens').start()<CR>]],
      opts
    )
    vim.keymap.set(
      "n",
      "N",
      [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>set hlsearch<CR><Cmd>lua require('hlslens').start()<CR>]],
      opts
    )
    vim.keymap.set("n", "*", [[*<Cmd>set hlsearch<CR><Cmd>lua require('hlslens').start()<CR>]], opts)
    vim.keymap.set("n", "#", [[#<Cmd>set hlsearch<CR><Cmd>lua require('hlslens').start()<CR>]], opts)
    vim.keymap.set("n", "g*", [[g*<Cmd>set hlsearch<CR><Cmd>lua require('hlslens').start()<CR>]], opts)
    vim.keymap.set("n", "g#", [[g#<Cmd>set hlsearch<CR><Cmd>lua require('hlslens').start()<CR>]], opts)

    -- ハイライト解除
    vim.keymap.set("n", "<Leader>h", ":nohlsearch<CR><Cmd>lua require('hlslens').stop()<CR>", opts)

    -- 2. Scrollbar設定
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
        color = colors.blue,
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
          color = colors.peach,
          highlight = "Search",
        },
        Error = {
          text = { "-", "=" },
          priority = 2,
          color = colors.red,
          highlight = "DiagnosticVirtualTextError",
        },
        Warn = {
          text = { "-", "=" },
          priority = 3,
          color = colors.yellow,
          highlight = "DiagnosticVirtualTextWarn",
        },
        Info = {
          text = { "-", "=" },
          priority = 4,
          color = colors.blue,
          highlight = "DiagnosticVirtualTextInfo",
        },
        Hint = {
          text = { "-", "=" },
          priority = 5,
          color = colors.teal,
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
          "CursorMoved", -- 【最重要】これを追加しました
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
        gitsigns = false,
        handle = true,
        search = true, -- hlslens連携用
      },
    }
  end,
}

return {
  "echasnovski/mini.trailspace",
  version = "*",
  event = { "BufRead", "BufNewFile" },
  config = function()
    require("mini.trailspace").setup {}

    -- 保存時に自動で空白削除を実行する設定（autocmd）
    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = "*",
      callback = function()
        require("mini.trailspace").trim()
        require("mini.trailspace").trim_last_lines()
      end,
    })
  end,
}

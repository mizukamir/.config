return {
  "mfussenegger/nvim-dap",
  opts = function(_, opts)
    local dap = require "dap"

    -- --- CodeLLDB の設定 ---
    -- Masonを使わず、PATHにある 'codelldb' コマンドを使用する
    dap.adapters.codelldb = {
      type = "server",
      port = "${port}",
      executable = {
        -- ここで home.nix で作ったラッパーコマンドを指定
        command = "codelldb",
        args = { "--port", "${port}" },
      },
    }
  end,
}

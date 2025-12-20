return {
  "mfussenegger/nvim-dap-python",
  dependencies = { "mfussenegger/nvim-dap" },
  ft = "python", -- Pythonファイルを開いたときだけ読み込む
  config = function()
    -- 【重要】
    -- 引数に "python" を渡すことで、現在のPATHにあるpython（direnvで有効化したpython）を使います。
    -- これにより、flake.nixに入れたdebugpyが自動的に使われます。
    require("dap-python").setup("python")
  end,
}

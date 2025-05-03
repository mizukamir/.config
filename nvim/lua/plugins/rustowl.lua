return {
  "cordx56/rustowl",
  version = "*",
  build = "cargo install --path . --locked",
  lazy = false,
  opts = {
    client = {
      on_attach = function(_, buffer)
        vim.keymap.set(
          "n",
          "<leader>uo",
          function() require("rustowl").toggle(buffer) end,
          { buffer = buffer, desc = "Toggle RustOwl" }
        )
      end,
    },
  },
}

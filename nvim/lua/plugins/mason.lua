-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- Customize Mason plugins

---@type LazySpec
return {
  -- use mason-lspconfig to configure LSP installations
  {
    "williamboman/mason-lspconfig.nvim",
    -- overrides `require("mason-lspconfig").setup(...)`
    opts = {
      ensure_installed = {
        -- Lua
        "lua_ls",

        -- Python
        "pyright",

        -- TOML
        "taplo",

        -- JavaScript/TypeScript
        "ts_ls",
        "eslint",

        -- Nix
        -- "nil_ls",
      },
    },
  },
  -- use mason-null-ls to configure Formatters/Linter installation for null-ls sources
  {
    "jay-babu/mason-null-ls.nvim",
    -- overrides `require("mason-null-ls").setup(...)`
    opts = {
      ensure_installed = {
        -- Lua
        "stylua",

        -- Python
        "ruff",

        -- JavaScript/TypeScript
        "prettier",

        -- Nix
        -- "nixfmt", -- nixfmt-rfc-style相当
      },
    },
  },
  -- {
  --   "jay-babu/mason-nvim-dap.nvim",
  --   -- overrides `require("mason-nvim-dap").setup(...)`
  --   opts = {
  --     ensure_installed = {
  --       -- "python", -- debugpy
  --     },
  --   },
  -- },
}

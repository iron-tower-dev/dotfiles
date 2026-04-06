vim.pack.add({
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/mason-org/mason.nvim",
})

require("mason").setup()
require("plugins.lsp.lua_ls")

vim.lsp.enable({
  "gopls",
  "ts_ls",
})

vim.diagnostic.config({ signs = true })

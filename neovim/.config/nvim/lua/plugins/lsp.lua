vim.pack.add({
  "https://github.com/neovim/nvim-lspconfig",
  "https://github.com/mason-org/mason.nvim",
})

require("mason").setup()

vim.lsp.enable({
  "gopls",
  "lua_ls",
  "ts_ls",
})

vim.diagnostic.config({ signs = true })

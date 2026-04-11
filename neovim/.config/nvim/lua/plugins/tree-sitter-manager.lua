vim.pack.add({{ src = "https://github.com/romus204/tree-sitter-manager.nvim" }})

require("tree-sitter-manager").setup({
  ensure_installed = { "bash", "lua", "go" },
})

vim.o.number = true
vim.o.relativenumber = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.o.softtabstop = 2
vim.o.autoindent = true
vim.o.signcolumn = "yes:1"
vim.o.confirm = true
vim.o.showmode = false

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.pack.add {
  {
		src = "https://github.com/nvim-treesitter/nvim-treesitter",
		branch = "main",
		build = ":TSUpdate",
	},
}

require("nvim-treesitter").setup {
  install_dir = vim.fn.stdpath("data") .. "/site"
}
require("nvim-treesitter").install { "go", "lua" }
require("plugins")


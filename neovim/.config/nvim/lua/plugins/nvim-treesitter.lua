return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function () 
        local configs = require("nvim-treesitter.configs")

        configs.setup({
            ensure_installed = {
                "c", "lua", "vim", "vimdoc", "query", 
                "elixir", "heex", "surface",  -- Elixir
                "javascript", "typescript", "tsx", "html", "css", -- JS/TS/Angular
                "go", "gomod", "gowork", -- Go
                "c_sharp", -- C#
                "json", "yaml", "toml", "xml", -- Data formats
                "markdown", "markdown_inline", "rst", -- Documentation
                "bash", "fish", "nu", -- Shell scripts
                "dockerfile", "gitignore", "gitcommit", -- DevOps
            },
            auto_install = true,
            sync_install = false,
            highlight = { enable = true },
            indent = { enable = true },  

            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<Enter>", -- set to `false` to disable one of the mappings
                    node_incremental = "<Enter>",
                    scope_incremental = false,
                    node_decremental = "<Backspace>",
                },
            },
        })
    end
}

return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    preset = "modern",
    delay = 300,
    plugins = {
      marks = true,
      registers = true,
      spelling = {
        enabled = true,
        suggestions = 20,
      },
      presets = {
        operators = true,
        motions = true,
        text_objects = true,
        windows = true,
        nav = true,
        z = true,
        g = true,
      },
    },
    icons = {
      breadcrumb = "»",
      separator = "➜",
      group = "+",
    },
    win = {
      border = "rounded",
      padding = { 1, 2 },
      wo = {
        winblend = 10,
      },
    },
    layout = {
      spacing = 6,
      align = "left",
    },
  },
  config = function(_, opts)
    local which_key = require("which-key")
    which_key.setup(opts)
    
    -- Register global key groups
    which_key.add({
      -- Core leader groups
      { "<leader>c", group = "Code/LSP" },
      { "<leader>d", group = "Diagnostics" },
      { "<leader>f", group = "Find/Format" },
      { "<leader>g", group = "Go to/Git" },
      { "<leader>l", group = "LSP" },
      { "<leader>r", group = "REPL/Refactor" },
      { "<leader>t", group = "Test/Toggle" },
      { "<leader>w", group = "Workspace" },
      { "<leader>v", group = "View/Visual" },
      { "<leader>e", group = "Evaluate/Edit" },
      
      -- Language-specific groups
      { "<leader>a", group = "Angular" },
      { "<leader>j", group = "Jack-in/REPL" },
      { "<leader>k", group = "Kotlin" },
      { "<leader>g", group = "Go" },
      { "<leader>e", group = "Elixir/Evaluate" },
      
      -- Debug groups
      { "<leader>b", group = "Debug/Breakpoint" },
      { "<F1>", desc = "Debug: Step Into" },
      { "<F2>", desc = "Debug: Step Over" },
      { "<F3>", desc = "Debug: Step Out" },
      { "<F5>", desc = "Debug: Start/Continue" },
    })
  end,
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer Local Keymaps (which-key)",
    },
  },
}

-- ================================================================================================
-- TITLE : LSP Configuration
-- ABOUT : Complete LSP setup with nvim-lspconfig, mason, and debugging support
-- ================================================================================================

return {
  -- Mason: Package manager for LSP servers, formatters, and debuggers
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = {
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
      registries = {
        "github:mason-org/mason-registry",
        "github:Crashdummyy/mason-registry", -- For Roslyn LSP
      },
    },
  },

  -- Mason-lspconfig: Bridge between mason and lspconfig
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      -- Servers to automatically install via Mason
      ensure_installed = {
        "lua_ls",           -- Lua
        "ts_ls",            -- TypeScript/JavaScript  
        "angularls",        -- Angular
        "elixirls",         -- Elixir
        "gopls",            -- Go
        -- Note: roslyn is installed via custom Mason registry
      },
      -- Automatically setup servers installed via Mason
      automatic_installation = true,
    },
    config = function(_, opts)
      local mason_lspconfig = require("mason-lspconfig")
      mason_lspconfig.setup(opts)
      
      -- Setup handlers for automatic server configuration
      if mason_lspconfig.setup_handlers then
        mason_lspconfig.setup_handlers({
        -- Default handler for servers
        function(server_name)
          -- Try to load server-specific configuration
          local server_config_ok, server_config = pcall(require, "lsp.servers." .. server_name)
          
          if server_config_ok and server_config then
            -- Use server-specific configuration
            require("lspconfig")[server_name].setup(server_config)
          else
            -- Fallback to default configuration
            local defaults_ok, defaults = pcall(require, "lsp.utils.defaults")
            
            if defaults_ok then
              require("lspconfig")[server_name].setup(defaults.get_default_config())
              
              -- Notify user about fallback (scheduled to avoid setup interruption)
              vim.schedule(function()
                vim.notify(
                  string.format("LSP server '%s' using default config (custom config not found or failed to load)", server_name),
                  vim.log.levels.WARN,
                  { title = "LSP Setup" }
                )
              end)
            else
              -- Last resort: basic setup with minimal config
              require("lspconfig")[server_name].setup({})
              
              vim.schedule(function()
                vim.notify(
                  string.format("LSP server '%s' using minimal config (defaults failed to load)", server_name),
                  vim.log.levels.ERROR,
                  { title = "LSP Setup" }
                )
              end)
            end
            
            -- Log the original error for debugging if config load failed
            if not server_config_ok then
              vim.schedule(function()
                vim.notify(
                  string.format("Debug: Failed to load config for '%s': %s", server_name, server_config or "unknown error"),
                  vim.log.levels.DEBUG,
                  { title = "LSP Debug" }
                )
              end)
            end
          end
        end,
        })
        
        -- Manual setup for Roslyn (from custom registry)
        local roslyn_ok, roslyn_config = pcall(require, "lsp.servers.roslyn")
        if roslyn_ok and roslyn_config then
          require("lspconfig").roslyn.setup(roslyn_config)
        end
      else
        vim.notify("mason-lspconfig.setup_handlers not available", vim.log.levels.ERROR)
      end
    end,
  },

  -- Core LSP configuration
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "saghen/blink.cmp", -- For completion capabilities
    },
    config = function()
      -- Setup LSP keymaps and autocommands
      require("lsp.utils.keymaps")
      require("lsp.utils.autocmds")
    end,
  },

  -- Enhanced LSP UI
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {
      notification = {
        window = {
          winblend = 100,
          border = "rounded",
        },
      },
    },
  },

  -- Debugging support
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      -- UI for DAP
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-neotest/nvim-nio",
      
      -- Language-specific adapters
      "leoluz/nvim-dap-go",           -- Go debugging
      "mxsdev/nvim-dap-vscode-js",    -- JavaScript/TypeScript debugging
    },
    config = function()
      require("lsp.utils.dap")
    end,
    keys = {
      { "<F5>", function() require("dap").continue() end, desc = "Debug: Start/Continue" },
      { "<F1>", function() require("dap").step_into() end, desc = "Debug: Step Into" },
      { "<F2>", function() require("dap").step_over() end, desc = "Debug: Step Over" },
      { "<F3>", function() require("dap").step_out() end, desc = "Debug: Step Out" },
      { "<leader>b", function() require("dap").toggle_breakpoint() end, desc = "Debug: Toggle Breakpoint" },
      { "<leader>B", function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc = "Debug: Set Conditional Breakpoint" },
      { "<leader>dr", function() require("dap").repl.open() end, desc = "Debug: Open REPL" },
      { "<leader>dl", function() require("dap").run_last() end, desc = "Debug: Run Last" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "Debug: Toggle UI" },
    },
  },
}

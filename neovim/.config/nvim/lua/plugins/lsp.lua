-- ================================================================================================
-- TITLE : LSP Configuration
-- ABOUT : Complete LSP setup with nvim-lspconfig, mason, and debugging support
-- ================================================================================================

return {
  -- Mason: Package manager for LSP servers, formatters, and debuggers
  {
    "williamboman/mason.nvim",
    lazy = false,
    priority = 900,
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
    lazy = false,
    priority = 800,
    opts = {
      -- Servers to automatically install via Mason
      ensure_installed = {
        "lua_ls",           -- Lua
        "ts_ls",            -- TypeScript/JavaScript  
        "angularls",        -- Angular
        "elixirls",         -- Elixir
        "gopls",            -- Go
        "omnisharp",        -- C#
        "clojure_lsp",      -- Clojure
      },
      -- Automatically setup servers installed via Mason
      automatic_installation = true,
    },
    config = function(_, opts)
      local mason_lspconfig = require("mason-lspconfig")
      mason_lspconfig.setup(opts)
      
      -- Function to setup a single server using new vim.lsp.config API
      local function setup_server(server_name)
        
        -- Try to load server-specific configuration
        local server_config_ok, server_config = pcall(require, "lsp.servers." .. server_name)
        
        local config
        if server_config_ok and server_config then
          -- Use server-specific configuration
          config = server_config
        else
          -- Fallback to default configuration
          local defaults_ok, defaults = pcall(require, "lsp.utils.defaults")
          config = (defaults_ok and defaults) and defaults.get_default_config() or {}
        end
        
        -- Use new vim.lsp.config API if available, fallback to lspconfig
        local setup_ok = pcall(function()
          if vim.lsp.config and vim.lsp.config[server_name] then
            vim.lsp.config[server_name](config)
          else
            -- Fallback to lspconfig for compatibility
            require("lspconfig")[server_name].setup(config)
          end
        end)
        
        if not setup_ok then
          vim.schedule(function()
            vim.notify(
              string.format("Failed to setup LSP server: %s", server_name),
              vim.log.levels.WARN,
              { title = "LSP Setup" }
            )
          end)
        end
      end
      
      -- Setup handlers for automatic server configuration
      local setup_handlers_ok, _ = pcall(function()
        if mason_lspconfig.setup_handlers then
          mason_lspconfig.setup_handlers({
            -- Default handler for servers
            setup_server,
          })
        else
          -- Fallback: manually setup servers from ensure_installed list
          for _, server_name in ipairs(opts.ensure_installed or {}) do
            setup_server(server_name)
          end
        end
      end)
      
      if not setup_handlers_ok then
        vim.schedule(function()
          vim.notify(
            "Failed to setup LSP handlers, falling back to manual setup",
            vim.log.levels.WARN,
            { title = "LSP Setup" }
          )
        end)
        
        -- Fallback: manually setup essential servers
        local essential_servers = { "lua_ls", "ts_ls", "gopls" }
        for _, server_name in ipairs(essential_servers) do
          pcall(setup_server, server_name)
        end
      end
      
    end,
  },

  -- Core LSP configuration
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    priority = 700,
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

-- ================================================================================================
-- TITLE : Angular LSP Configuration
-- ABOUT : Configuration for Angular Language Server (angularls)
-- ================================================================================================

local defaults = require("lsp.utils.defaults")

-- Angular-specific configuration
local config = {
  -- Angular LSP settings
  settings = {
    angular = {
      forceStrictTemplates = true,
      enableIvy = true,
      suggest = {
        includeCompletionsForImport = true,
      },
      experimental = {
        enableStandaloneComponents = true, -- Enable for standalone components
      },
    },
  },

  -- Custom on_attach for Angular-specific functionality
  on_attach = function(client, bufnr)
    -- Call the default on_attach
    defaults.on_attach(client, bufnr)

    -- Angular-specific keymaps
    local function buf_map(mode, lhs, rhs, opts)
      opts = opts or {}
      opts.buffer = bufnr
      opts.desc = "Angular: " .. (opts.desc or "")
      vim.keymap.set(mode, lhs, rhs, opts)
    end

    -- Go to component/template/style files
    buf_map("n", "<leader>ac", function()
      vim.lsp.buf.code_action({
        context = {
          only = { "angular.goToComponent" },
          diagnostics = {},
        },
      })
    end, { desc = "Go to Component" })

    buf_map("n", "<leader>at", function()
      vim.lsp.buf.code_action({
        context = {
          only = { "angular.goToTemplate" },
          diagnostics = {},
        },
      })
    end, { desc = "Go to Template" })

    buf_map("n", "<leader>as", function()
      vim.lsp.buf.code_action({
        context = {
          only = { "angular.goToStyle" },
          diagnostics = {},
        },
      })
    end, { desc = "Go to Style" })

    -- Extract component
    buf_map("n", "<leader>ae", function()
      vim.lsp.buf.code_action({
        context = {
          only = { "angular.extractComponent" },
          diagnostics = {},
        },
      })
    end, { desc = "Extract Component" })

    -- Show Angular version
    buf_map("n", "<leader>av", function()
      vim.lsp.buf.execute_command({
        command = "angular.getVersion",
        arguments = {},
      })
    end, { desc = "Show Angular Version" })

    -- Restart Angular server
    buf_map("n", "<leader>ar", function()
      vim.lsp.buf.execute_command({
        command = "angular.restartNgServer",
        arguments = {},
      })
    end, { desc = "Restart Angular Server" })
  end,

  -- File types for Angular files
  filetypes = {
    "html", -- Angular templates
    "typescript", -- Angular components/services
    "typescriptreact", -- JSX components if using React-like syntax
  },

  -- Root directory detection for Angular projects
  root_dir = function(fname)
    local lspconfig = require("lspconfig")
    return lspconfig.util.root_pattern(
      "angular.json",
      "project.json", -- Nx workspaces
      "package.json"
    )(fname)
  end,

  -- Additional initialization options
  init_options = {
    legacyNgcc = true,
    -- Enable/disable various Angular features
    angularCoreVersion = "auto",
  },

  -- Commands specific to Angular
  commands = {
    AngularVersion = {
      function()
        vim.lsp.buf.execute_command({
          command = "angular.getVersion",
          arguments = {},
        })
      end,
      description = "Get Angular version",
    },
    AngularRestart = {
      function()
        vim.lsp.buf.execute_command({
          command = "angular.restartNgServer", 
          arguments = {},
        })
      end,
      description = "Restart Angular Language Server",
    },
  },
}

-- Return the enhanced configuration
return defaults.get_enhanced_config(config)

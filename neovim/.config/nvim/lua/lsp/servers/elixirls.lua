-- ================================================================================================
-- TITLE : Elixir LSP Configuration
-- ABOUT : Configuration for Elixir Language Server (ElixirLS)
-- ================================================================================================

local defaults = require("lsp.utils.defaults")

-- Elixir-specific configuration
local config = {
  -- ElixirLS settings
  settings = {
    elixirLS = {
      -- Dialyzer options
      dialyzerEnabled = true,
      dialyzerWarnOpts = {},
      dialyzerFormat = "dialyzer",
      
      -- Formatter options
      mixEnv = "dev",
      mixTarget = "host",
      projectDir = "",
      
      -- Auto format on save
      enableTestLenses = true,
      
      -- Suggest completions
      suggestSpecs = true,
      
      -- Additional compiler options
      additionalWatchedExtensions = {},
      
      -- Auto insert end blocks
      autoInsertRequiredAlias = true,
      
      -- Signature help
      signatureAfterComplete = true,
      
      -- Incremental dialyzer
      incrementalDialyzer = true,
      
      -- Fetch dependencies automatically
      fetchDeps = false,
    },
  },

  -- Custom on_attach for Elixir-specific functionality
  on_attach = function(client, bufnr)
    -- Call the default on_attach
    defaults.on_attach(client, bufnr)

    -- Elixir-specific keymaps
    local function buf_map(mode, lhs, rhs, opts)
      opts = opts or {}
      opts.buffer = bufnr
      opts.desc = "Elixir: " .. (opts.desc or "")
      vim.keymap.set(mode, lhs, rhs, opts)
    end

    -- Run tests
    buf_map("n", "<leader>et", function()
      vim.lsp.buf.code_action({
        context = {
          only = { "elixir.test" },
          diagnostics = {},
        },
      })
    end, { desc = "Run Tests" })

    -- Run test under cursor
    buf_map("n", "<leader>eT", function()
      vim.lsp.buf.execute_command({
        command = "spec:run",
        arguments = { vim.fn.expand("%:p"), vim.fn.line(".") },
      })
    end, { desc = "Run Test Under Cursor" })

    -- Pipe operator
    buf_map("n", "<leader>ep", function()
      vim.lsp.buf.code_action({
        context = {
          only = { "elixir.toPipe" },
          diagnostics = {},
        },
      })
    end, { desc = "Convert to Pipe" })

    -- From pipe operator
    buf_map("n", "<leader>eP", function()
      vim.lsp.buf.code_action({
        context = {
          only = { "elixir.fromPipe" },
          diagnostics = {},
        },
      })
    end, { desc = "Convert from Pipe" })

    -- Expand macro
    buf_map("n", "<leader>em", function()
      vim.lsp.buf.code_action({
        context = {
          only = { "elixir.expandMacro" },
          diagnostics = {},
        },
      })
    end, { desc = "Expand Macro" })

    -- Mix format
    buf_map("n", "<leader>ef", function()
      vim.lsp.buf.format({ timeout_ms = 5000 })
    end, { desc = "Format with Mix" })

    -- Restart ElixirLS
    buf_map("n", "<leader>er", function()
      vim.lsp.buf.execute_command({
        command = "elixir.restart",
        arguments = {},
      })
    end, { desc = "Restart ElixirLS" })

    -- Show docs for module under cursor
    buf_map("n", "<leader>ed", function()
      local word = vim.fn.expand("<cword>")
      vim.cmd("split | terminal h " .. word)
    end, { desc = "Show Documentation" })

    -- IEx integration
    buf_map("n", "<leader>ei", function()
      vim.cmd("split | terminal iex -S mix")
    end, { desc = "Open IEx" })
  end,

  -- File types for Elixir files
  filetypes = { "elixir", "eelixir", "heex", "surface" },

  -- Root directory patterns for Elixir projects
  root_dir = function(fname)
    local lspconfig = require("lspconfig")
    return lspconfig.util.root_pattern(
      "mix.exs",
      ".git"
    )(fname)
  end,

  -- Commands specific to Elixir
  commands = {
    ElixirRestart = {
      function()
        vim.lsp.stop_client(vim.lsp.get_clients())
        vim.cmd("edit")
      end,
      description = "Restart ElixirLS",
    },
    ElixirExpandMacro = {
      function()
        local params = vim.lsp.util.make_position_params()
        vim.lsp.buf_request(0, "elixirDocument/expandMacro", params, function(err, result)
          if err then
            print("Error expanding macro: " .. vim.inspect(err))
            return
          end
          
          if result then
            -- Create a new buffer with the expanded macro
            local buf = vim.api.nvim_create_buf(false, true)
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(result, "\n"))
            vim.api.nvim_buf_set_option(buf, "filetype", "elixir")
            vim.cmd("split")
            vim.api.nvim_win_set_buf(0, buf)
          end
        end)
      end,
      description = "Expand macro under cursor",
    },
    ElixirRunTests = {
      function()
        local file = vim.fn.expand("%:p")
        vim.cmd("split | terminal mix test " .. file)
      end,
      description = "Run tests for current file",
    },
    ElixirFormat = {
      function()
        vim.lsp.buf.format({ timeout_ms = 5000 })
      end,
      description = "Format current buffer with mix format",
    },
  },
  
  -- Additional settings for better completion
  init_options = {
    elixirLS = {
      dialyzerEnabled = true,
    },
  },
}

-- Return the enhanced configuration
return defaults.get_enhanced_config(config)

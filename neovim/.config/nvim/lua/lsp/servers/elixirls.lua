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
      local file = vim.fn.expand("%:p")
      local line = vim.fn.line(".")
      vim.cmd("split | terminal mix test " .. vim.fn.fnameescape(file) .. ":" .. line)
    end, { desc = "Run Test Under Cursor" })

    -- Pipe operator
    buf_map("n", "<leader>ep", function()
      vim.lsp.buf.execute_command({
        command = "manipulatePipes:toPipe",
        arguments = { vim.uri_from_fname(vim.fn.expand("%:p")) },
      })
    end, { desc = "Convert to Pipe" })

    -- From pipe operator
    buf_map("n", "<leader>eP", function()
      vim.lsp.buf.execute_command({
        command = "manipulatePipes:fromPipe",
        arguments = { vim.uri_from_fname(vim.fn.expand("%:p")) },
      })
    end, { desc = "Convert from Pipe" })

    -- Expand macro
    buf_map("n", "<leader>em", function()
      local params = vim.lsp.util.make_position_params()
      vim.lsp.buf.execute_command({
        command = "expandMacro",
        arguments = {
          vim.uri_from_bufnr(0),
          params.position,
        },
      })
    end, { desc = "Expand Macro" })

    -- Mix format
    buf_map("n", "<leader>ef", function()
      vim.lsp.buf.format({ timeout_ms = 5000 })
    end, { desc = "Format with Mix" })

    -- Restart ElixirLS
    buf_map("n", "<leader>er", function()
      local elixir_clients = vim.lsp.get_clients({ name = "elixirls" })
      if #elixir_clients == 0 then
        vim.notify("No ElixirLS clients found", vim.log.levels.WARN)
        return
      end
      
      for _, client in ipairs(elixir_clients) do
        vim.lsp.stop_client(client.id, true)
      end
      
      vim.notify(string.format("Restarted %d ElixirLS client(s)", #elixir_clients), vim.log.levels.INFO)
    end, { desc = "Restart ElixirLS" })

    -- Show docs for module under cursor
    buf_map("n", "<leader>ed", function()
      vim.lsp.buf.hover()
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
        local elixir_clients = vim.lsp.get_clients({ name = "elixirls" })
        for _, client in ipairs(elixir_clients) do
          vim.lsp.stop_client(client.id, true)
        end
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
        local escaped_file = vim.fn.shellescape(file)
        vim.cmd("split | terminal mix test " .. escaped_file)
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

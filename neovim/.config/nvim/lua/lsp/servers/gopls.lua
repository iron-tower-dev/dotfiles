-- ================================================================================================
-- TITLE : Go LSP Configuration
-- ABOUT : Configuration for Go Language Server (gopls)
-- ================================================================================================

local defaults = require("lsp.utils.defaults")

-- Go-specific configuration
local config = {
  -- Gopls settings
  settings = {
    gopls = {
      -- Analysis settings
      analyses = {
        unusedparams = true,
        unreachable = true,
        fillstruct = true,
        undeclaredname = true,
        nonewvars = true,
        fieldalignment = true,
        shadow = true,
        unusedvariable = true,
        useany = true,
      },
      
      -- Experimental features
      experimentalPostfixCompletions = true,
      experimentalWorkspaceModule = true,
      experimentalTemplateSupport = true,
      
      -- Code completion
      completeUnimported = true,
      usePlaceholders = true,
      deepCompletion = true,
      matcher = "Fuzzy",
      
      -- Static check
      staticcheck = true,
      
      -- Semantic tokens
      semanticTokens = true,
      
      -- Inlay hints
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
      
      -- Formatting
      gofumpt = true, -- Use gofumpt for more strict formatting
      
      -- Code lenses
      codelenses = {
        gc_details = true,
        generate = true,
        regenerate_cgo = true,
        run_govulncheck = true,
        test = true,
        tidy = true,
        upgrade_dependency = true,
        vendor = true,
      },
      
      -- Hover settings
      hoverKind = "Structured",
      linkTarget = "pkg.go.dev",
      linksInHover = true,
      
      -- Build tags
      buildFlags = { "-tags", "integration" },
      
      -- Environment variables
      env = {
        GOFLAGS = "-tags=integration",
      },
    },
  },

  -- Custom on_attach for Go-specific functionality
  on_attach = function(client, bufnr)
    -- Call the default on_attach
    defaults.on_attach(client, bufnr)

    -- Go-specific keymaps
    local function buf_map(mode, lhs, rhs, opts)
      opts = opts or {}
      opts.buffer = bufnr
      opts.desc = "Go: " .. (opts.desc or "")
      vim.keymap.set(mode, lhs, rhs, opts)
    end

    -- Go imports
    buf_map("n", "<leader>gi", function()
      vim.lsp.buf.code_action({
        context = {
          only = { "source.organizeImports" },
          diagnostics = {},
        },
      })
    end, { desc = "Organize Imports" })

    -- Go mod tidy
    buf_map("n", "<leader>gt", function()
      vim.lsp.buf.execute_command({
        command = "gopls.tidy",
        arguments = { { URIs = { vim.uri_from_fname(vim.fn.expand("%:p")) } } },
      })
    end, { desc = "Go Mod Tidy" })

    -- Generate tests
    buf_map("n", "<leader>gT", function()
      vim.lsp.buf.code_action({
        context = {
          only = { "source.test" },
          diagnostics = {},
        },
      })
    end, { desc = "Generate Tests" })

    -- Run tests
    buf_map("n", "<leader>gr", function()
      local file = vim.fn.expand("%:.")
      vim.cmd("split | terminal go test ./" .. vim.fn.fnamemodify(file, ":h"))
    end, { desc = "Run Tests" })

    -- Run test function under cursor
    buf_map("n", "<leader>gR", function()
      local func_name = vim.fn.expand("<cword>")
      if func_name:match("^Test") then
        vim.cmd("split | terminal go test -run " .. func_name)
      else
        print("Not a test function")
      end
    end, { desc = "Run Test Function" })

    -- Fill struct
    buf_map("n", "<leader>gf", function()
      vim.lsp.buf.code_action({
        context = {
          only = { "refactor.rewrite" },
          diagnostics = {},
        },
      })
    end, { desc = "Fill Struct" })

    -- Add tags to struct
    buf_map("n", "<leader>ga", function()
      vim.lsp.buf.code_action({
        context = {
          only = { "refactor.extract" },
          diagnostics = {},
        },
      })
    end, { desc = "Add Struct Tags" })

    -- Go to alternate file (implementation/test)
    buf_map("n", "<leader>gA", function()
      local file = vim.fn.expand("%")
      local alternate
      
      if file:match("_test%.go$") then
        alternate = file:gsub("_test%.go$", ".go")
      else
        alternate = file:gsub("%.go$", "_test.go")
      end
      
      if vim.fn.filereadable(alternate) == 1 then
        vim.cmd("edit " .. alternate)
      else
        print("Alternate file not found: " .. alternate)
      end
    end, { desc = "Go to Alternate File" })

    -- Benchmark
    buf_map("n", "<leader>gb", function()
      vim.cmd("split | terminal go test -bench=.")
    end, { desc = "Run Benchmarks" })

    -- Go vulnerability check
    buf_map("n", "<leader>gv", function()
      vim.lsp.buf.execute_command({
        command = "gopls.run_govulncheck",
        arguments = { { URI = vim.uri_from_fname(vim.fn.expand("%:p")) } },
      })
    end, { desc = "Vulnerability Check" })

    -- Regenerate cgo
    buf_map("n", "<leader>gc", function()
      vim.lsp.buf.execute_command({
        command = "gopls.regenerate_cgo",
        arguments = { { URI = vim.uri_from_fname(vim.fn.expand("%:p")) } },
      })
    end, { desc = "Regenerate CGO" })
  end,

  -- File types for Go files
  filetypes = { "go", "gomod", "gowork", "gotmpl" },

  -- Root directory patterns for Go projects
  root_dir = function(fname)
    local lspconfig = require("lspconfig")
    return lspconfig.util.root_pattern(
      "go.work",
      "go.mod",
      ".git"
    )(fname)
  end,

  -- Commands specific to Go
  commands = {
    GoImports = {
      function()
        vim.lsp.buf.code_action({
          context = {
            only = { "source.organizeImports" },
            diagnostics = {},
          },
        })
      end,
      description = "Organize imports",
    },
    GoTidy = {
      function()
        vim.lsp.buf.execute_command({
          command = "gopls.tidy",
          arguments = { { URIs = { vim.uri_from_fname(vim.fn.expand("%:p")) } } },
        })
      end,
      description = "Run go mod tidy",
    },
    GoTest = {
      function()
        local file = vim.fn.expand("%:.")
        vim.cmd("split | terminal go test ./" .. vim.fn.fnamemodify(file, ":h"))
      end,
      description = "Run tests for current package",
    },
    GoBench = {
      function()
        vim.cmd("split | terminal go test -bench=.")
      end,
      description = "Run benchmarks",
    },
    GoVulnCheck = {
      function()
        vim.lsp.buf.execute_command({
          command = "gopls.run_govulncheck",
          arguments = { { URI = vim.uri_from_fname(vim.fn.expand("%:p")) } },
        })
      end,
      description = "Run vulnerability check",
    },
  },
  
  -- Single file support
  single_file_support = true,
}

-- Return the enhanced configuration
return defaults.get_enhanced_config(config)

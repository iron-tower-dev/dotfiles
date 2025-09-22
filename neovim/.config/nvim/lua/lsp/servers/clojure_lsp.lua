-- ================================================================================================
-- TITLE : Clojure LSP Configuration
-- ABOUT : Configuration for Clojure Language Server with REPL integration
-- ================================================================================================

local defaults = require("lsp.utils.defaults")

-- Clojure-specific configuration
local config = {
  -- Clojure LSP settings
  settings = {
    ["clojure-lsp"] = {
      -- Source paths configuration
      ["source-paths"] = {"src", "test", "dev"},
      
      -- Formatting configuration
      ["cljfmt"] = {
        ["indents"] = {
          ["defn"] = "inner",
          ["defmacro"] = "inner",
          ["defprotocol"] = "inner",
          ["defrecord"] = "inner",
          ["deftype"] = "inner",
          ["extend-protocol"] = "inner",
          ["extend-type"] = "inner",
          ["reify"] = "inner",
        },
      },
      
      -- Linting configuration
      ["linters"] = {
        ["clj-kondo"] = {
          ["level"] = "info",
        },
      },
      
      -- REPL configuration
      ["repl"] = {
        ["host"] = "localhost",
        ["port"] = 7888,
      },
      
      -- Completion settings
      ["completion"] = {
        ["analysis-type"] = "fast-and-full-set",
      },
      
      -- Semantic tokens
      ["semantic-tokens?"] = true,
      
      -- Document formatting
      ["document-formatting?"] = true,
      ["document-range-formatting?"] = true,
      
      -- Hover documentation
      ["hover"] = {
        ["hide-file-location?"] = false,
        ["clojuredocs"] = true,
      },
      
      -- Code lens
      ["lens"] = {
        ["segregate-lens-by-type?"] = true,
      },
      
      -- Clean namespace configuration
      ["clean"] = {
        ["automatically-after-ns-refactor"] = true,
        ["ns-inner-blocks-indentation"] = "next-line",
        ["ns-import-classes-indentation"] = "next-line",
      },
    },
  },

  -- Custom on_attach for Clojure-specific functionality
  on_attach = function(client, bufnr)
    -- Call the default on_attach
    defaults.on_attach(client, bufnr)

    -- Clojure-specific keymaps
    local function buf_map(mode, lhs, rhs, opts)
      opts = opts or {}
      opts.buffer = bufnr
      opts.desc = "Clojure: " .. (opts.desc or "")
      vim.keymap.set(mode, lhs, rhs, opts)
    end

    -- Helper function to get project root
    local function get_root_dir()
      return client.config.root_dir or vim.fn.getcwd()
    end

    -- REPL operations
    buf_map("n", "<leader>rj", function()
      -- Start nREPL server (Leiningen)
      vim.cmd("split")
      vim.fn.termopen({"lein", "repl"}, {
        cwd = get_root_dir(),
      })
    end, { desc = "Start Lein REPL" })

    buf_map("n", "<leader>rJ", function()
      -- Start nREPL server (deps.edn/Clojure CLI)
      vim.cmd("split")
      vim.fn.termopen({"clj", "-M:repl"}, {
        cwd = get_root_dir(),
      })
    end, { desc = "Start Clj REPL" })

    buf_map("n", "<leader>rc", function()
      -- Connect to running REPL
      vim.lsp.buf.execute_command({
        command = "clojure-lsp.connect-to-repl",
        arguments = {},
      })
    end, { desc = "Connect to REPL" })

    buf_map("n", "<leader>re", function()
      -- Evaluate current form
      vim.lsp.buf.execute_command({
        command = "clojure-lsp.evaluate-code",
        arguments = { vim.fn.expand("<cexpr>") },
      })
    end, { desc = "Evaluate Expression" })

    buf_map("n", "<leader>rb", function()
      -- Evaluate entire buffer
      local content = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), "\n")
      vim.lsp.buf.execute_command({
        command = "clojure-lsp.evaluate-code",
        arguments = { content },
      })
    end, { desc = "Evaluate Buffer" })

    buf_map("v", "<leader>re", function()
      -- Evaluate visual selection
      local start_pos = vim.fn.getpos("'<")
      local end_pos = vim.fn.getpos("'>")
      local lines = vim.fn.getline(start_pos[2], end_pos[2])
      local selection = table.concat(lines, "\n")
      vim.lsp.buf.execute_command({
        command = "clojure-lsp.evaluate-code",
        arguments = { selection },
      })
    end, { desc = "Evaluate Selection" })

    -- Namespace operations
    buf_map("n", "<leader>cn", function()
      -- Clean namespace
      vim.lsp.buf.execute_command({
        command = "clojure-lsp.clean-ns",
        arguments = { vim.uri_from_bufnr(0) },
      })
    end, { desc = "Clean Namespace" })

    buf_map("n", "<leader>ca", function()
      -- Add missing import
      vim.lsp.buf.code_action({
        context = {
          only = { "source.addMissingLibspec" },
          diagnostics = {},
        },
      })
    end, { desc = "Add Missing Import" })

    -- Testing
    buf_map("n", "<leader>tt", function()
      -- Run tests for current namespace
      local ns = vim.fn.expand("%:t:r")
      vim.cmd("split")
      vim.fn.termopen({"lein", "test", ns}, {
        cwd = get_root_dir(),
      })
    end, { desc = "Run Namespace Tests" })

    buf_map("n", "<leader>ta", function()
      -- Run all tests
      vim.cmd("split")
      vim.fn.termopen({"lein", "test"}, {
        cwd = get_root_dir(),
      })
    end, { desc = "Run All Tests" })

    -- Documentation
    buf_map("n", "<leader>cd", function()
      -- Show ClojureDocs
      vim.lsp.buf.execute_command({
        command = "clojure-lsp.clojuredocs",
        arguments = { vim.fn.expand("<cword>") },
      })
    end, { desc = "Show ClojureDocs" })

    -- Refactoring
    buf_map("n", "<leader>cf", function()
      -- Extract function
      vim.lsp.buf.code_action({
        context = {
          only = { "refactor.extract.function" },
          diagnostics = {},
        },
      })
    end, { desc = "Extract Function" })

    buf_map("n", "<leader>ci", function()
      -- Introduce let
      vim.lsp.buf.code_action({
        context = {
          only = { "refactor.introduce.let" },
          diagnostics = {},
        },
      })
    end, { desc = "Introduce Let" })

    -- Threading macros
    buf_map("n", "<leader>c-", function()
      -- Thread first
      vim.lsp.buf.code_action({
        context = {
          only = { "refactor.thread.first" },
          diagnostics = {},
        },
      })
    end, { desc = "Thread First" })

    buf_map("n", "<leader>c=", function()
      -- Thread last
      vim.lsp.buf.code_action({
        context = {
          only = { "refactor.thread.last" },
          diagnostics = {},
        },
      })
    end, { desc = "Thread Last" })
  end,

  -- File types for Clojure files
  filetypes = { "clojure", "clojurescript", "clojurec", "fennel" },

  -- Root directory patterns for Clojure projects with fallback
  root_dir = function(fname)
    local lspconfig = require("lspconfig")
    local util = lspconfig.util
    
    -- First try to find project files
    local root = util.root_pattern(
      "project.clj",      -- Leiningen
      "deps.edn",         -- Clojure CLI/deps.edn
      "bb.edn",          -- Babashka
      "shadow-cljs.edn",  -- Shadow CLJS
      "build.boot",      -- Boot
      ".nrepl-port",     -- Running nREPL
      ".git"
    )(fname)
    
    -- If no project root found, use the directory containing the file
    if not root then
      root = util.path.dirname(fname)
      -- Create a minimal deps.edn if it doesn't exist to help LSP
      local deps_file = root .. "/deps.edn"
      if vim.fn.filereadable(deps_file) == 0 then
        -- Only create it if we're in a writable directory
        if vim.fn.filewritable(root) == 2 then
          local deps_content = '{:deps {org.clojure/clojure {:mvn/version "1.11.1"}}}'
          vim.fn.writefile({deps_content}, deps_file)
          vim.notify("Created minimal deps.edn for LSP support", vim.log.levels.INFO)
        end
      end
    end
    
    return root
  end,

  -- Commands specific to Clojure
  commands = {
    ClojureStartREPL = {
      function()
        local lspconfig = require("lspconfig")
        local root_dir = lspconfig.util.root_pattern("project.clj", "deps.edn", ".git")(vim.fn.expand("%:p")) or vim.fn.getcwd()
        vim.cmd("split")
        
        -- Choose REPL based on project type
        if vim.fn.filereadable(root_dir .. "/project.clj") == 1 then
          vim.fn.termopen({"lein", "repl"}, { cwd = root_dir })
        elseif vim.fn.filereadable(root_dir .. "/deps.edn") == 1 then
          vim.fn.termopen({"clj", "-M:repl"}, { cwd = root_dir })
        else
          vim.fn.termopen({"clj"}, { cwd = root_dir })
        end
      end,
      description = "Start Clojure REPL",
    },
    ClojureRunTests = {
      function()
        local lspconfig = require("lspconfig")
        local root_dir = lspconfig.util.root_pattern("project.clj", "deps.edn", ".git")(vim.fn.expand("%:p")) or vim.fn.getcwd()
        vim.cmd("split")
        
        -- Choose test runner based on project type
        if vim.fn.filereadable(root_dir .. "/project.clj") == 1 then
          vim.fn.termopen({"lein", "test"}, { cwd = root_dir })
        else
          vim.fn.termopen({"clj", "-M:test"}, { cwd = root_dir })
        end
      end,
      description = "Run Clojure tests",
    },
    ClojureFormat = {
      function()
        vim.lsp.buf.format({ timeout_ms = 5000 })
      end,
      description = "Format Clojure code",
    },
  },

  -- Single file support
  single_file_support = true,
}

-- Return the enhanced configuration
return defaults.get_enhanced_config(config)

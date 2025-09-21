-- ================================================================================================
-- TITLE : C# Roslyn LSP Configuration
-- ABOUT : Configuration for C# Roslyn Language Server
-- ================================================================================================

local defaults = require("lsp.utils.defaults")

-- C# Roslyn-specific configuration
local config = {
  -- Roslyn settings
  settings = {
    ["csharp|inlay_hints"] = {
      csharp_enable_inlay_hints_for_implicit_object_creation = true,
      csharp_enable_inlay_hints_for_implicit_variable_types = true,
      csharp_enable_inlay_hints_for_lambda_parameter_types = true,
      csharp_enable_inlay_hints_for_types = true,
      dotnet_enable_inlay_hints_for_indexer_parameters = true,
      dotnet_enable_inlay_hints_for_literal_parameters = true,
      dotnet_enable_inlay_hints_for_object_creation_parameters = true,
      dotnet_enable_inlay_hints_for_other_parameters = true,
      dotnet_enable_inlay_hints_for_parameters = true,
      dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
      dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
      dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true,
    },
    ["csharp|code_lens"] = {
      dotnet_enable_references_code_lens = true,
      dotnet_enable_tests_code_lens = true,
    },
    ["csharp|completion"] = {
      dotnet_provide_regex_completions = true,
      dotnet_show_completion_items_from_unimported_namespaces = true,
      dotnet_show_name_completion_suggestions = true,
    },
    ["csharp|highlighting"] = {
      dotnet_highlight_related_json_components = true,
      dotnet_highlight_related_regex_components = true,
    },
    ["csharp|quick_info"] = {
      dotnet_show_remarks_in_quick_info = true,
    },
    ["csharp|symbol_search"] = {
      dotnet_search_reference_assemblies = true,
    },
  },

  -- Custom on_attach for C#-specific functionality
  on_attach = function(client, bufnr)
    -- Call the default on_attach
    defaults.on_attach(client, bufnr)

    -- Helper function to get LSP root directory
    local function get_root_dir()
      return client.config.root_dir or vim.fn.getcwd()
    end

    -- Helper function to run dotnet commands securely
    local function run_dotnet_command(args, desc)
      vim.cmd("split")
      vim.fn.termopen({"dotnet", unpack(args)}, {
        cwd = get_root_dir(),
        on_exit = function(_, code)
          if code ~= 0 then
            vim.notify(string.format("%s failed with exit code %d", desc, code), vim.log.levels.ERROR)
          else
            vim.notify(string.format("%s completed successfully", desc), vim.log.levels.INFO)
          end
        end,
      })
    end

    -- C#-specific keymaps
    local function buf_map(mode, lhs, rhs, opts)
      opts = opts or {}
      opts.buffer = bufnr
      opts.desc = "C#: " .. (opts.desc or "")
      vim.keymap.set(mode, lhs, rhs, opts)
    end

    -- Build project
    buf_map("n", "<leader>cb", function()
      run_dotnet_command({"build"}, "Build")
    end, { desc = "Build Project" })

    -- Run project
    buf_map("n", "<leader>cr", function()
      run_dotnet_command({"run"}, "Run")
    end, { desc = "Run Project" })

    -- Test project
    buf_map("n", "<leader>ct", function()
      run_dotnet_command({"test"}, "Test")
    end, { desc = "Test Project" })

    -- Test with coverage
    buf_map("n", "<leader>cT", function()
      run_dotnet_command({"test", "--collect:XPlat Code Coverage"}, "Test with Coverage")
    end, { desc = "Test with Coverage" })

    -- Restore packages
    buf_map("n", "<leader>cR", function()
      run_dotnet_command({"restore"}, "Restore")
    end, { desc = "Restore Packages" })

    -- Clean project
    buf_map("n", "<leader>cC", function()
      run_dotnet_command({"clean"}, "Clean")
    end, { desc = "Clean Project" })

    -- Add package
    buf_map("n", "<leader>cp", function()
      local package = vim.fn.input("Package name: ")
      if package ~= "" then
        run_dotnet_command({"add", "package", package}, "Add Package")
      end
    end, { desc = "Add Package" })

    -- Remove package
    buf_map("n", "<leader>cP", function()
      local package = vim.fn.input("Package name to remove: ")
      if package ~= "" then
        run_dotnet_command({"remove", "package", package}, "Remove Package")
      end
    end, { desc = "Remove Package" })

    -- Create new class
    buf_map("n", "<leader>cn", function()
      local class_name = vim.fn.input("Class name: ")
      if class_name ~= "" then
        local template = {
          "using System;",
          "",
          "namespace " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t") .. ";",
          "",
          "public class " .. class_name,
          "{",
          "    // TODO: Implement",
          "}",
        }
        local filename = class_name .. ".cs"
        vim.cmd("edit " .. filename)
        vim.api.nvim_buf_set_lines(0, 0, -1, false, template)
      end
    end, { desc = "New Class" })

    -- Generate constructor
    buf_map("n", "<leader>cg", function()
      vim.lsp.buf.code_action({
        context = {
          only = { "refactor.generate.constructor" },
          diagnostics = {},
        },
      })
    end, { desc = "Generate Constructor" })

    -- Extract method
    buf_map("n", "<leader>ce", function()
      vim.lsp.buf.code_action({
        context = {
          only = { "refactor.extract.method" },
          diagnostics = {},
        },
      })
    end, { desc = "Extract Method" })

    -- Format document
    buf_map("n", "<leader>cf", function()
      vim.lsp.buf.format({ timeout_ms = 5000 })
    end, { desc = "Format Document" })

    -- Go to alternate file (implementation/test)
    buf_map("n", "<leader>cA", function()
      local file = vim.fn.expand("%")
      local alternate
      
      if file:match("Tests?%.cs$") then
        alternate = file:gsub("Tests?%.cs$", ".cs")
      else
        local base = file:gsub("%.cs$", "")
        if vim.fn.filereadable(base .. "Test.cs") == 1 then
          alternate = base .. "Test.cs"
        elseif vim.fn.filereadable(base .. "Tests.cs") == 1 then
          alternate = base .. "Tests.cs"
        end
      end
      
      if alternate and vim.fn.filereadable(alternate) == 1 then
        vim.cmd("edit " .. alternate)
      else
        print("Alternate file not found")
      end
    end, { desc = "Go to Alternate File" })

    -- Show project info
    buf_map("n", "<leader>ci", function()
      run_dotnet_command({"--info"}, "Project Info")
    end, { desc = "Show Project Info" })
  end,

  -- File types for C# files
  filetypes = { 
    "cs", 
    "csharp",
    -- Project files
    "csproj",
    "sln",
    "props",
    "targets",
  },

  -- Root directory patterns for C# projects
  root_dir = function(fname)
    local lspconfig = require("lspconfig")
    return lspconfig.util.root_pattern(
      "*.sln",
      "*.csproj", 
      "omnisharp.json",
      "function.json",
      ".git"
    )(fname)
  end,

  -- Commands specific to C#
  commands = {
    CSharpBuild = {
      function()
        local lspconfig = require("lspconfig")
        local root_dir = lspconfig.util.root_pattern("*.sln", "*.csproj", ".git")(vim.fn.expand("%:p")) or vim.fn.getcwd()
        vim.cmd("split")
        vim.fn.termopen({"dotnet", "build"}, {
          cwd = root_dir,
          on_exit = function(_, code)
            local msg = code == 0 and "Build completed successfully" or "Build failed with exit code " .. code
            vim.notify(msg, code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR)
          end,
        })
      end,
      description = "Build C# project",
    },
    CSharpRun = {
      function()
        local lspconfig = require("lspconfig")
        local root_dir = lspconfig.util.root_pattern("*.sln", "*.csproj", ".git")(vim.fn.expand("%:p")) or vim.fn.getcwd()
        vim.cmd("split")
        vim.fn.termopen({"dotnet", "run"}, {
          cwd = root_dir,
          on_exit = function(_, code)
            local msg = code == 0 and "Run completed successfully" or "Run failed with exit code " .. code
            vim.notify(msg, code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR)
          end,
        })
      end,
      description = "Run C# project",
    },
    CSharpTest = {
      function()
        local lspconfig = require("lspconfig")
        local root_dir = lspconfig.util.root_pattern("*.sln", "*.csproj", ".git")(vim.fn.expand("%:p")) or vim.fn.getcwd()
        vim.cmd("split")
        vim.fn.termopen({"dotnet", "test"}, {
          cwd = root_dir,
          on_exit = function(_, code)
            local msg = code == 0 and "Test completed successfully" or "Test failed with exit code " .. code
            vim.notify(msg, code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR)
          end,
        })
      end,
      description = "Test C# project",
    },
    CSharpRestore = {
      function()
        local lspconfig = require("lspconfig")
        local root_dir = lspconfig.util.root_pattern("*.sln", "*.csproj", ".git")(vim.fn.expand("%:p")) or vim.fn.getcwd()
        vim.cmd("split")
        vim.fn.termopen({"dotnet", "restore"}, {
          cwd = root_dir,
          on_exit = function(_, code)
            local msg = code == 0 and "Restore completed successfully" or "Restore failed with exit code " .. code
            vim.notify(msg, code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR)
          end,
        })
      end,
      description = "Restore NuGet packages",
    },
    CSharpClean = {
      function()
        local lspconfig = require("lspconfig")
        local root_dir = lspconfig.util.root_pattern("*.sln", "*.csproj", ".git")(vim.fn.expand("%:p")) or vim.fn.getcwd()
        vim.cmd("split")
        vim.fn.termopen({"dotnet", "clean"}, {
          cwd = root_dir,
          on_exit = function(_, code)
            local msg = code == 0 and "Clean completed successfully" or "Clean failed with exit code " .. code
            vim.notify(msg, code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR)
          end,
        })
      end,
      description = "Clean C# project",
    },
    CSharpFormat = {
      function()
        vim.lsp.buf.format({ timeout_ms = 5000 })
      end,
      description = "Format C# code",
    },
  },

  -- Handler overrides for better C# experience
  handlers = {
    ["textDocument/definition"] = function(err, result, method, ...)
      -- Custom definition handler to handle C# metadata and deduplicate results
      if vim.tbl_islist(result) and #result > 1 then
        local filtered_result = {}
        local seen_uris = {}
        local fallback_counter = 0
        
        for _, res in ipairs(result) do
          -- Handle both Location and LocationLink objects
          local uri = res.uri or res.targetUri
          
          -- Guard against nil uri with unique fallback
          if not uri then
            fallback_counter = fallback_counter + 1
            uri = "__fallback__" .. fallback_counter
          end
          
          -- Deduplicate while preserving original order
          if not seen_uris[uri] then
            table.insert(filtered_result, res)
            seen_uris[uri] = true
          end
        end
        
        return vim.lsp.handlers["textDocument/definition"](err, filtered_result, method, ...)
      end
      
      -- Pass through original result when no filtering needed
      return vim.lsp.handlers["textDocument/definition"](err, result, method, ...)
    end,
  },

  -- Additional initialization options
  init_options = {
    -- Enable enhanced colorization
    semanticHighlighting = true,
  },
}

-- Return the enhanced configuration
return defaults.get_enhanced_config(config)

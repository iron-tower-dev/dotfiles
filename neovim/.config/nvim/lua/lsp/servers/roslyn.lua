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

    -- C#-specific keymaps
    local function buf_map(mode, lhs, rhs, opts)
      opts = opts or {}
      opts.buffer = bufnr
      opts.desc = "C#: " .. (opts.desc or "")
      vim.keymap.set(mode, lhs, rhs, opts)
    end

    -- Build project
    buf_map("n", "<leader>cb", function()
      vim.cmd("split | terminal dotnet build")
    end, { desc = "Build Project" })

    -- Run project
    buf_map("n", "<leader>cr", function()
      vim.cmd("split | terminal dotnet run")
    end, { desc = "Run Project" })

    -- Test project
    buf_map("n", "<leader>ct", function()
      vim.cmd("split | terminal dotnet test")
    end, { desc = "Test Project" })

    -- Test with coverage
    buf_map("n", "<leader>cT", function()
      vim.cmd("split | terminal dotnet test --collect:\"XPlat Code Coverage\"")
    end, { desc = "Test with Coverage" })

    -- Restore packages
    buf_map("n", "<leader>cR", function()
      vim.cmd("split | terminal dotnet restore")
    end, { desc = "Restore Packages" })

    -- Clean project
    buf_map("n", "<leader>cC", function()
      vim.cmd("split | terminal dotnet clean")
    end, { desc = "Clean Project" })

    -- Add package
    buf_map("n", "<leader>cp", function()
      local package = vim.fn.input("Package name: ")
      if package ~= "" then
        vim.cmd("split | terminal dotnet add package " .. package)
      end
    end, { desc = "Add Package" })

    -- Remove package
    buf_map("n", "<leader>cP", function()
      local package = vim.fn.input("Package name to remove: ")
      if package ~= "" then
        vim.cmd("split | terminal dotnet remove package " .. package)
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
      vim.cmd("split | terminal dotnet --info")
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
        vim.cmd("split | terminal dotnet build")
      end,
      description = "Build C# project",
    },
    CSharpRun = {
      function()
        vim.cmd("split | terminal dotnet run")
      end,
      description = "Run C# project",
    },
    CSharpTest = {
      function()
        vim.cmd("split | terminal dotnet test")
      end,
      description = "Test C# project",
    },
    CSharpRestore = {
      function()
        vim.cmd("split | terminal dotnet restore")
      end,
      description = "Restore NuGet packages",
    },
    CSharpClean = {
      function()
        vim.cmd("split | terminal dotnet clean")
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
      -- Custom definition handler to handle C# metadata
      if vim.tbl_islist(result) and #result > 1 then
        local filtered_result = {}
        local seen_uris = {}
        
        for _, res in ipairs(result) do
          if not seen_uris[res.uri] then
            table.insert(filtered_result, res)
            seen_uris[res.uri] = true
          end
        end
        
        return vim.lsp.handlers["textDocument/definition"](err, filtered_result, method, ...)
      end
      
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

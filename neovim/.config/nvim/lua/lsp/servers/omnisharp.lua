-- ================================================================================================
-- TITLE : C# OmniSharp LSP Configuration
-- ABOUT : Configuration for C# OmniSharp Language Server
-- ================================================================================================

local defaults = require("lsp.utils.defaults")

-- C# OmniSharp-specific configuration
local config = {
  -- OmniSharp settings
  settings = {
    FormattingOptions = {
      -- Enables support for reading code style, naming convention and analyzer
      -- settings from .editorconfig.
      EnableEditorConfigSupport = true,
      -- Specifies whether 'using' directives should be grouped and sorted during
      -- document formatting.
      OrganizeImports = true,
    },
    MsBuild = {
      -- If true, MSBuild project system will only load projects for files that
      -- were opened in the editor. This setting is useful for big C# codebases
      -- and allows for faster initialization of code navigation features only
      -- for projects that are relevant to code that is being edited. With this
      -- setting enabled OmniSharp will also avoid loading projects that could
      -- not be loaded successfully.
      LoadProjectsOnDemand = nil,
    },
    RoslynExtensionsOptions = {
      -- Enables support for roslyn analyzers, code fixes and rulesets.
      EnableAnalyzersSupport = true,
      -- Enables support for showing unimported types and unimported extension
      -- methods in completion lists. When committed, the appropriate using
      -- directive will be added at the top of the current file. This option can
      -- have a negative impact on initial completion responsiveness,
      -- particularly for the first few completion sessions after opening a
      -- solution.
      EnableImportCompletion = true,
      -- Only run analyzers against open files when 'enableRoslynAnalyzers' is
      -- true
      AnalyzeOpenDocumentsOnly = nil,
    },
    Sdk = {
      -- Specifies whether to include preview versions of the .NET SDK when
      -- determining which version to use for project loading.
      IncludePrereleases = true,
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
        local namespace = vim.fn.fnamemodify(get_root_dir(), ":t")
        local template = {
          "using System;",
          "",
          "namespace " .. namespace .. ";",
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

    -- OmniSharp specific commands
    buf_map("n", "<leader>cD", function()
      vim.lsp.buf.code_action({
        context = { only = { "refactor.rewrite" } }
      })
    end, { desc = "Decompile" })

    -- Fix usings
    buf_map("n", "<leader>cu", function()
      vim.lsp.buf.code_action({
        context = { only = { "source.organizeImports" } }
      })
    end, { desc = "Organize Imports" })
  end,

  -- File types for C# files
  filetypes = { "cs" },

  -- Root directory patterns for C# projects
  root_dir = function(fname)
    local util = require("lspconfig.util")
    return util.root_pattern(
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
        local util = require("lspconfig.util")
        local root_dir = util.root_pattern("*.sln", "*.csproj", ".git")(vim.fn.expand("%:p")) or vim.fn.getcwd()
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
        local util = require("lspconfig.util")
        local root_dir = util.root_pattern("*.sln", "*.csproj", ".git")(vim.fn.expand("%:p")) or vim.fn.getcwd()
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
        local util = require("lspconfig.util")
        local root_dir = util.root_pattern("*.sln", "*.csproj", ".git")(vim.fn.expand("%:p")) or vim.fn.getcwd()
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
        local util = require("lspconfig.util")
        local root_dir = util.root_pattern("*.sln", "*.csproj", ".git")(vim.fn.expand("%:p")) or vim.fn.getcwd()
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
        local util = require("lspconfig.util")
        local root_dir = util.root_pattern("*.sln", "*.csproj", ".git")(vim.fn.expand("%:p")) or vim.fn.getcwd()
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

  -- Initialize OmniSharp with some useful init_options
  init_options = {
    -- Improve startup time by analyzing only opened files
    analyzeOpenDocumentsOnly = true,
  },
}

-- Return the enhanced configuration
return defaults.get_enhanced_config(config)

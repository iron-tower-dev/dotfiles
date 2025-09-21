-- ================================================================================================
-- TITLE : Kotlin LSP Configuration
-- ABOUT : Configuration for Kotlin Language Server with multiplatform support
-- ================================================================================================

local defaults = require("lsp.utils.defaults")

-- Kotlin-specific configuration
local config = {
  -- Kotlin LSP settings
  settings = {
    kotlin = {
      -- Compiler configuration
      compiler = {
        jvm = {
          target = "17", -- Java target version
        },
      },
      
      -- Completion settings
      completion = {
        snippets = {
          enabled = true,
        },
      },
      
      -- Code generation
      codeGeneration = {
        enabled = true,
        insertFinalNewline = true,
        trimTrailingWhitespace = true,
      },
      
      -- Linting and analysis
      linting = {
        debounceTime = 250,
      },
      
      -- Indexing
      indexing = {
        enabled = true,
      },
      
      -- External sources (for multiplatform)
      externalSources = {
        useKlsScheme = true,
        autoConvertToKotlin = true,
      },
      
      -- Multiplatform support
      multiplatform = {
        enabled = true,
        platforms = {
          "common",
          "jvm", 
          "android",
          "js",
          "native",
          "ios",
          "macos",
          "linux",
          "mingw",
        },
      },
      
      -- Debugging
      debugAdapter = {
        enabled = true,
        path = "",
      },
      
      -- Formatting
      formatting = {
        enabled = true,
      },
      
      -- Hover documentation
      hover = {
        enabled = true,
      },
    },
  },

  -- Custom on_attach for Kotlin-specific functionality
  on_attach = function(client, bufnr)
    -- Call the default on_attach
    defaults.on_attach(client, bufnr)

    -- Kotlin-specific keymaps
    local function buf_map(mode, lhs, rhs, opts)
      opts = opts or {}
      opts.buffer = bufnr
      opts.desc = "Kotlin: " .. (opts.desc or "")
      vim.keymap.set(mode, lhs, rhs, opts)
    end

    -- Helper function to get project root
    local function get_root_dir()
      return client.config.root_dir or vim.fn.getcwd()
    end

    -- Helper function to detect build system
    local function get_build_system()
      local root = get_root_dir()
      if vim.fn.filereadable(root .. "/build.gradle.kts") == 1 or vim.fn.filereadable(root .. "/build.gradle") == 1 then
        return "gradle"
      elseif vim.fn.filereadable(root .. "/pom.xml") == 1 then
        return "maven"
      else
        return "gradle" -- Default fallback
      end
    end

    -- Build and run operations
    buf_map("n", "<leader>kb", function()
      -- Build project
      local build_system = get_build_system()
      vim.cmd("split")
      
      if build_system == "gradle" then
        vim.fn.termopen({"./gradlew", "build"}, {
          cwd = get_root_dir(),
        })
      elseif build_system == "maven" then
        vim.fn.termopen({"mvn", "compile"}, {
          cwd = get_root_dir(),
        })
      end
    end, { desc = "Build Project" })

    buf_map("n", "<leader>kr", function()
      -- Run project
      local build_system = get_build_system()
      vim.cmd("split")
      
      if build_system == "gradle" then
        vim.fn.termopen({"./gradlew", "run"}, {
          cwd = get_root_dir(),
        })
      elseif build_system == "maven" then
        vim.fn.termopen({"mvn", "exec:java"}, {
          cwd = get_root_dir(),
        })
      end
    end, { desc = "Run Project" })

    -- Testing
    buf_map("n", "<leader>kt", function()
      -- Run tests
      local build_system = get_build_system()
      vim.cmd("split")
      
      if build_system == "gradle" then
        vim.fn.termopen({"./gradlew", "test"}, {
          cwd = get_root_dir(),
        })
      elseif build_system == "maven" then
        vim.fn.termopen({"mvn", "test"}, {
          cwd = get_root_dir(),
        })
      end
    end, { desc = "Run Tests" })

    buf_map("n", "<leader>kT", function()
      -- Run single test class
      local class_name = vim.fn.expand("%:t:r")
      local build_system = get_build_system()
      vim.cmd("split")
      
      if build_system == "gradle" then
        vim.fn.termopen({"./gradlew", "test", "--tests", class_name}, {
          cwd = get_root_dir(),
        })
      elseif build_system == "maven" then
        vim.fn.termopen({"mvn", "test", "-Dtest=" .. class_name}, {
          cwd = get_root_dir(),
        })
      end
    end, { desc = "Run Current Test Class" })

    -- Multiplatform operations
    buf_map("n", "<leader>kj", function()
      -- Build JVM target
      vim.cmd("split")
      vim.fn.termopen({"./gradlew", "jvmMain:build"}, {
        cwd = get_root_dir(),
      })
    end, { desc = "Build JVM Target" })

    buf_map("n", "<leader>kn", function()
      -- Build Native target
      vim.cmd("split")
      vim.fn.termopen({"./gradlew", "linkDebugExecutableLinuxX64"}, {
        cwd = get_root_dir(),
      })
    end, { desc = "Build Native Target" })

    buf_map("n", "<leader>ks", function()
      -- Build JS target
      vim.cmd("split")
      vim.fn.termopen({"./gradlew", "jsBrowserDevelopmentWebpack"}, {
        cwd = get_root_dir(),
      })
    end, { desc = "Build JS Target" })

    buf_map("n", "<leader>ka", function()
      -- Build Android target
      vim.cmd("split")
      vim.fn.termopen({"./gradlew", "assembleDebug"}, {
        cwd = get_root_dir(),
      })
    end, { desc = "Build Android Target" })

    -- Code generation
    buf_map("n", "<leader>kg", function()
      -- Generate data class
      vim.lsp.buf.code_action({
        context = {
          only = { "source.generate.dataClass" },
          diagnostics = {},
        },
      })
    end, { desc = "Generate Data Class" })

    buf_map("n", "<leader>kc", function()
      -- Generate constructor
      vim.lsp.buf.code_action({
        context = {
          only = { "source.generate.constructor" },
          diagnostics = {},
        },
      })
    end, { desc = "Generate Constructor" })

    buf_map("n", "<leader>ke", function()
      -- Generate equals and hashCode
      vim.lsp.buf.code_action({
        context = {
          only = { "source.generate.equalsAndHashCode" },
          diagnostics = {},
        },
      })
    end, { desc = "Generate Equals/HashCode" })

    buf_map("n", "<leader>kt", function()
      -- Generate toString
      vim.lsp.buf.code_action({
        context = {
          only = { "source.generate.toString" },
          diagnostics = {},
        },
      })
    end, { desc = "Generate ToString" })

    -- Refactoring
    buf_map("n", "<leader>ki", function()
      -- Organize imports
      vim.lsp.buf.code_action({
        context = {
          only = { "source.organizeImports" },
          diagnostics = {},
        },
      })
    end, { desc = "Organize Imports" })

    buf_map("n", "<leader>kf", function()
      -- Extract function
      vim.lsp.buf.code_action({
        context = {
          only = { "refactor.extract.function" },
          diagnostics = {},
        },
      })
    end, { desc = "Extract Function" })

    buf_map("n", "<leader>kv", function()
      -- Extract variable
      vim.lsp.buf.code_action({
        context = {
          only = { "refactor.extract.variable" },
          diagnostics = {},
        },
      })
    end, { desc = "Extract Variable" })

    -- Documentation
    buf_map("n", "<leader>kd", function()
      -- Generate KDoc
      vim.lsp.buf.code_action({
        context = {
          only = { "source.generate.kdoc" },
          diagnostics = {},
        },
      })
    end, { desc = "Generate KDoc" })
  end,

  -- File types for Kotlin files
  filetypes = { "kotlin", "kt" },

  -- Root directory patterns for Kotlin projects
  root_dir = function(fname)
    local lspconfig = require("lspconfig")
    return lspconfig.util.root_pattern(
      "settings.gradle.kts", -- Kotlin DSL Gradle
      "settings.gradle",     -- Groovy Gradle
      "build.gradle.kts",    -- Kotlin DSL build file
      "build.gradle",        -- Groovy build file
      "pom.xml",            -- Maven
      ".git"
    )(fname)
  end,

  -- Commands specific to Kotlin
  commands = {
    KotlinBuild = {
      function()
        local lspconfig = require("lspconfig")
        local root_dir = lspconfig.util.root_pattern("build.gradle.kts", "build.gradle", "pom.xml", ".git")(vim.fn.expand("%:p")) or vim.fn.getcwd()
        vim.cmd("split")
        
        -- Detect build system and build
        if vim.fn.filereadable(root_dir .. "/build.gradle.kts") == 1 or vim.fn.filereadable(root_dir .. "/build.gradle") == 1 then
          vim.fn.termopen({"./gradlew", "build"}, { cwd = root_dir })
        elseif vim.fn.filereadable(root_dir .. "/pom.xml") == 1 then
          vim.fn.termopen({"mvn", "compile"}, { cwd = root_dir })
        end
      end,
      description = "Build Kotlin project",
    },
    KotlinRun = {
      function()
        local lspconfig = require("lspconfig")
        local root_dir = lspconfig.util.root_pattern("build.gradle.kts", "build.gradle", "pom.xml", ".git")(vim.fn.expand("%:p")) or vim.fn.getcwd()
        vim.cmd("split")
        
        -- Detect build system and run
        if vim.fn.filereadable(root_dir .. "/build.gradle.kts") == 1 or vim.fn.filereadable(root_dir .. "/build.gradle") == 1 then
          vim.fn.termopen({"./gradlew", "run"}, { cwd = root_dir })
        elseif vim.fn.filereadable(root_dir .. "/pom.xml") == 1 then
          vim.fn.termopen({"mvn", "exec:java"}, { cwd = root_dir })
        end
      end,
      description = "Run Kotlin project",
    },
    KotlinTest = {
      function()
        local lspconfig = require("lspconfig")
        local root_dir = lspconfig.util.root_pattern("build.gradle.kts", "build.gradle", "pom.xml", ".git")(vim.fn.expand("%:p")) or vim.fn.getcwd()
        vim.cmd("split")
        
        -- Detect build system and test
        if vim.fn.filereadable(root_dir .. "/build.gradle.kts") == 1 or vim.fn.filereadable(root_dir .. "/build.gradle") == 1 then
          vim.fn.termopen({"./gradlew", "test"}, { cwd = root_dir })
        elseif vim.fn.filereadable(root_dir .. "/pom.xml") == 1 then
          vim.fn.termopen({"mvn", "test"}, { cwd = root_dir })
        end
      end,
      description = "Run Kotlin tests",
    },
    KotlinFormat = {
      function()
        vim.lsp.buf.format({ timeout_ms = 5000 })
      end,
      description = "Format Kotlin code",
    },
  },

  -- Single file support
  single_file_support = true,
  
  -- Initialize options for multiplatform support
  init_options = {
    storagePath = vim.fn.stdpath("data") .. "/kotlin-language-server",
  },
}

-- Return the enhanced configuration
return defaults.get_enhanced_config(config)

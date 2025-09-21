-- ================================================================================================
-- TITLE : TypeScript/JavaScript LSP Configuration  
-- ABOUT : Configuration for TypeScript Language Server (ts_ls)
-- ================================================================================================

local defaults = require("lsp.utils.defaults")

-- TypeScript/JavaScript specific configuration
local config = {
  init_options = {
    preferences = {
      disableSuggestions = false,
      quotePreference = "auto",
      includeCompletionsForModuleExports = true,
      includeCompletionsForImportStatements = true,
      includeCompletionsWithSnippetText = true,
      includeAutomaticOptionalChainCompletions = true,
    },
  },
  
  settings = {
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = "all", -- 'none' | 'literals' | 'all'
        includeInlayParameterNameHintsWhenArgumentMatchesName = true,
        includeInlayVariableTypeHints = true,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHintsWhenTypeMatchesName = false,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
      preferences = {
        importModuleSpecifier = "relative",
        includePackageJsonAutoImports = "on",
        quotePreference = "auto",
      },
      suggest = {
        includeCompletionsForModuleExports = true,
      },
      surveys = {
        enabled = false,
      },
      format = {
        enable = true,
        indentSize = 2,
        convertTabsToSpaces = true,
        tabSize = 2,
        insertSpaceAfterFunctionKeywordForAnonymousFunctions = true,
        insertSpaceAfterKeywordsInControlFlowStatements = true,
        insertSpaceAfterOpeningAndBeforeClosingNonemptyBrackets = false,
        insertSpaceAfterSemicolonInForStatements = true,
        insertSpaceBeforeAndAfterBinaryOperators = true,
        insertSpaceAfterConstructor = false,
        insertSpaceAfterKeywordsInControlFlowStatements = true,
        insertSpaceAfterFunctionKeywordForAnonymousFunctions = true,
        insertSpaceAfterOpeningAndBeforeClosingTemplateStringBraces = false,
        insertSpaceAfterOpeningAndBeforeClosingJsxExpressionBraces = false,
        insertSpaceAfterTypeAssertion = false,
        insertSpaceBeforeFunctionParenthesis = false,
        placeOpenBraceOnNewLineForControlBlocks = false,
        placeOpenBraceOnNewLineForFunctions = false,
        insertSpaceBeforeTypeAnnotation = false,
        semicolons = "insert", -- "ignore" | "insert" | "remove"
      },
    },
    javascript = {
      inlayHints = {
        includeInlayParameterNameHints = "all",
        includeInlayParameterNameHintsWhenArgumentMatchesName = true,
        includeInlayVariableTypeHints = true,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHintsWhenTypeMatchesName = false,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
      preferences = {
        importModuleSpecifier = "relative",
        includePackageJsonAutoImports = "on",
        quotePreference = "auto",
      },
      suggest = {
        includeCompletionsForModuleExports = true,
      },
      format = {
        enable = true,
        indentSize = 2,
        convertTabsToSpaces = true,
        tabSize = 2,
        insertSpaceAfterFunctionKeywordForAnonymousFunctions = true,
        insertSpaceAfterKeywordsInControlFlowStatements = true,
        insertSpaceAfterOpeningAndBeforeClosingNonemptyBrackets = false,
        insertSpaceAfterSemicolonInForStatements = true,
        insertSpaceBeforeAndAfterBinaryOperators = true,
        insertSpaceAfterConstructor = false,
        insertSpaceAfterKeywordsInControlFlowStatements = true,
        insertSpaceAfterFunctionKeywordForAnonymousFunctions = true,
        insertSpaceAfterOpeningAndBeforeClosingTemplateStringBraces = false,
        insertSpaceAfterOpeningAndBeforeClosingJsxExpressionBraces = false,
        insertSpaceAfterTypeAssertion = false,
        insertSpaceBeforeFunctionParenthesis = false,
        placeOpenBraceOnNewLineForControlBlocks = false,
        placeOpenBraceOnNewLineForFunctions = false,
        insertSpaceBeforeTypeAnnotation = false,
        semicolons = "insert",
      },
    },
    completions = {
      completeFunctionCalls = true,
    },
  },

  -- Custom on_attach for TypeScript-specific functionality
  on_attach = function(client, bufnr)
    -- Call the default on_attach
    defaults.on_attach(client, bufnr)

    -- TypeScript-specific keymaps
    local function buf_map(mode, lhs, rhs, opts)
      opts = opts or {}
      opts.buffer = bufnr
      vim.keymap.set(mode, lhs, rhs, opts)
    end

    -- Organize imports
    buf_map("n", "<leader>to", function()
      vim.lsp.buf.code_action({
        apply = true,
        context = {
          only = { "source.organizeImports.ts" },
          diagnostics = {},
        },
      })
    end, { desc = "Organize Imports" })

    -- Remove unused imports
    buf_map("n", "<leader>tu", function()
      vim.lsp.buf.code_action({
        apply = true,
        context = {
          only = { "source.removeUnused.ts" },
          diagnostics = {},
        },
      })
    end, { desc = "Remove Unused Imports" })

    -- Add missing imports
    buf_map("n", "<leader>ta", function()
      vim.lsp.buf.code_action({
        apply = true,
        context = {
          only = { "source.addMissingImports.ts" },
          diagnostics = {},
        },
      })
    end, { desc = "Add Missing Imports" })

    -- Fix all fixable issues
    buf_map("n", "<leader>tf", function()
      vim.lsp.buf.code_action({
        apply = true,
        context = {
          only = { "source.fixAll.ts" },
          diagnostics = {},
        },
      })
    end, { desc = "Fix All Issues" })

    -- Go to source definition (useful for .d.ts files)
    buf_map("n", "gS", function()
      local params = vim.lsp.util.make_position_params()
      vim.lsp.buf.execute_command({
        command = "_typescript.goToSourceDefinition",
        arguments = {
          vim.uri_from_bufnr(0),
          params.position,
        },
      })
    end, { desc = "Go to Source Definition" })

    -- Restart TypeScript server
    buf_map("n", "<leader>tr", "<cmd>TypescriptReloadProjects<cr>", { desc = "Restart TS Server" })
  end,

  -- File types to attach to
  filetypes = {
    "javascript",
    "javascriptreact", 
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
  },

  -- Root directory patterns
  root_dir = function(fname)
    local lspconfig = require("lspconfig")
    return lspconfig.util.root_pattern(
      "tsconfig.json",
      "package.json",
      "jsconfig.json",
      ".git"
    )(fname)
  end,

  -- Single file support
  single_file_support = true,

  -- Commands
  commands = {
    TypescriptReloadProjects = {
      function()
        vim.lsp.buf.execute_command({
          command = "_typescript.reloadProjects",
          arguments = {},
        })
      end,
      description = "Reload TypeScript projects",
    },
  },
}

-- Return the enhanced configuration
return defaults.get_enhanced_config(config)

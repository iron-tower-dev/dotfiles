-- ================================================================================================
-- TITLE : LSP Autocommands
-- ABOUT : Autocommands for LSP functionality and diagnostics configuration
-- ================================================================================================

-- Configure LSP diagnostics
vim.diagnostic.config({
  virtual_text = {
    spacing = 4,
    source = "if_many",
    prefix = "●",
  },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "✘",
      [vim.diagnostic.severity.WARN] = "▲",
      [vim.diagnostic.severity.HINT] = "⚑",
      [vim.diagnostic.severity.INFO] = "»",
    },
  },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    focusable = false,
    style = "minimal",
    border = "rounded",
    source = "always",
    header = "",
    prefix = "",
  },
})

-- Configure LSP UI
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = "rounded",
  title = "Hover",
})

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
  border = "rounded",
  title = "Signature Help",
})

-- Auto-format on save for specific filetypes
local format_on_save_group = vim.api.nvim_create_augroup("LspFormatOnSave", { clear = true })

-- Function to check if any client supports formatting
local function has_formatter(bufnr)
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  for _, client in ipairs(clients) do
    if client.supports_method("textDocument/formatting") then
      return true
    end
  end
  return false
end

-- Filetypes that should auto-format on save
local format_filetypes = {
  "lua",
  "go", 
  "rust",
  "typescript",
  "javascript",
  "typescriptreact",
  "javascriptreact",
  "elixir",
  "cs",
  "clojure",
}

vim.api.nvim_create_autocmd("BufWritePre", {
  group = format_on_save_group,
  pattern = "*",
  callback = function(args)
    local bufnr = args.buf
    local filetype = vim.bo[bufnr].filetype
    
    -- Only format if filetype is in our list and we have a formatter
    if vim.tbl_contains(format_filetypes, filetype) and has_formatter(bufnr) then
      -- Save cursor position
      local cursor_pos = vim.api.nvim_win_get_cursor(0)
      local view = vim.fn.winsaveview()
      
      -- Format the buffer
      vim.lsp.buf.format({
        timeout_ms = 3000,
        async = false,
      })
      
      -- Restore cursor position
      pcall(vim.fn.winrestview, view)
      pcall(vim.api.nvim_win_set_cursor, 0, cursor_pos)
    end
  end,
})

-- Show diagnostics in a floating window when cursor is over an error
local diagnostic_float_group = vim.api.nvim_create_augroup("DiagnosticFloat", { clear = true })

vim.api.nvim_create_autocmd({ "CursorHold" }, {
  group = diagnostic_float_group,
  pattern = "*",
  callback = function()
    -- Only show if there are diagnostics on the current line
    local line_diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
    if #line_diagnostics > 0 then
      vim.diagnostic.open_float(nil, {
        focusable = false,
        close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
        source = "always",
        prefix = " ",
        scope = "cursor",
      })
    end
  end,
})

-- Update diagnostics in insert mode
vim.api.nvim_create_autocmd({ "InsertLeave" }, {
  group = vim.api.nvim_create_augroup("DiagnosticInsertLeave", { clear = true }),
  pattern = "*",
  callback = function()
    -- Refresh diagnostics when leaving insert mode
    vim.diagnostic.show()
  end,
})

-- Note: fidget.nvim handles LSP progress automatically when loaded
-- No manual progress handling needed

-- Auto-install language servers when opening supported files
local auto_install_group = vim.api.nvim_create_augroup("LspAutoInstall", { clear = true })

-- Map filetypes to their corresponding LSP servers (lspconfig names)
local filetype_to_server = {
  lua = "lua_ls",
  typescript = "ts_ls",
  javascript = "ts_ls",
  typescriptreact = "ts_ls",
  javascriptreact = "ts_ls",
  elixir = "elixirls",
  go = "gopls",
  cs = "omnisharp",
  clojure = "clojure_lsp",
  clojurescript = "clojure_lsp",
  clojurec = "clojure_lsp",
}

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = auto_install_group,
  pattern = "*",
  callback = function(args)
    local filetype = vim.bo[args.buf].filetype
    local lspconfig_server_name = filetype_to_server[filetype]
    
    if lspconfig_server_name then
      -- Get mason-lspconfig mappings to convert lspconfig names to Mason package names
      local mason_lspconfig_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
      if not mason_lspconfig_ok then
        return
      end
      
      local mappings = mason_lspconfig.get_mappings()
      local package_name = mappings.lspconfig_to_package[lspconfig_server_name]
      
      if not package_name then
        -- Skip if no mapping exists (server might not be available via Mason)
        return
      end
      
      -- Check if server package is installed
      local mason_registry_ok, mason_registry = pcall(require, "mason-registry")
      if not mason_registry_ok then
        return
      end
      
      local package_ok, package = pcall(mason_registry.get_package, package_name)
      if not package_ok then
        return
      end
      
      if package:is_installed() then
        return
      end
      
      -- Show notification that server will be installed
      vim.notify(
        string.format("Installing LSP server '%s' (%s) for %s files...", package_name, lspconfig_server_name, filetype),
        vim.log.levels.INFO,
        { title = "LSP Auto-install" }
      )
      
      -- Install the server
      package:install():once("closed", function()
        vim.schedule(function()
          vim.notify(
            string.format("LSP server '%s' installed successfully!", package_name),
            vim.log.levels.INFO,
            { title = "LSP Auto-install" }
          )
          
          -- Restart LSP for this buffer
          vim.cmd("LspRestart")
        end)
      end)
    end
  end,
})

-- Highlight LSP references
local highlight_group = vim.api.nvim_create_augroup("LspReferenceHighlight", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
  group = highlight_group,
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if not client or not client.supports_method("textDocument/documentHighlight") then
      return
    end
    
    local bufnr = event.buf
    local group_name = "LspReferenceHighlight_" .. bufnr
    
    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      group = vim.api.nvim_create_augroup(group_name, { clear = true }),
      buffer = bufnr,
      callback = vim.lsp.buf.document_highlight,
    })
    
    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
      group = group_name,
      buffer = bufnr,
      callback = vim.lsp.buf.clear_references,
    })
    
    vim.api.nvim_create_autocmd("LspDetach", {
      group = group_name,
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.clear_references()
        pcall(vim.api.nvim_del_augroup_by_name, group_name)
      end,
    })
  end,
})

-- Show LSP server status in the command line
vim.api.nvim_create_autocmd({ "LspAttach", "LspDetach" }, {
  group = vim.api.nvim_create_augroup("LspStatus", { clear = true }),
  callback = function(event)
    local clients = vim.lsp.get_clients({ bufnr = event.buf })
    local client_names = {}
    
    for _, client in ipairs(clients) do
      table.insert(client_names, client.name)
    end
    
    if #client_names > 0 then
      vim.notify(
        string.format("LSP: %s", table.concat(client_names, ", ")),
        vim.log.levels.INFO,
        { title = "Language Server" }
      )
    end
  end,
})

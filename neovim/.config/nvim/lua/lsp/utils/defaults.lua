-- ================================================================================================
-- TITLE : Default LSP Configuration
-- ABOUT : Default settings and capabilities for all LSP servers
-- ================================================================================================

local M = {}

--- Get completion capabilities from blink.cmp
---@return table
function M.get_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  
  -- Enable blink.cmp capabilities if available
  local ok, blink = pcall(require, "blink.cmp")
  if ok then
    capabilities = blink.get_lsp_capabilities(capabilities)
  end

  -- Additional capabilities
  capabilities.textDocument.completion.completionItem = {
    documentationFormat = { "markdown", "plaintext" },
    snippetSupport = true,
    preselectSupport = true,
    insertReplaceSupport = true,
    labelDetailsSupport = true,
    deprecatedSupport = true,
    commitCharactersSupport = true,
    tagSupport = { valueSet = { 1 } },
    resolveSupport = {
      properties = {
        "documentation",
        "detail",
        "additionalTextEdits",
      },
    },
  }

  -- File watching capabilities
  capabilities.workspace = capabilities.workspace or {}
  capabilities.workspace.didChangeWatchedFiles = {
    dynamicRegistration = true,
  }

  return capabilities
end

--- Get default LSP server configuration
---@return table
function M.get_default_config()
  return {
    capabilities = M.get_capabilities(),
    flags = {
      debounce_text_changes = 150,
    },
    settings = {},
  }
end

--- Common on_attach function for LSP servers
---@param client vim.lsp.Client
---@param bufnr integer
function M.on_attach(client, bufnr)
  -- Enable inlay hints if supported
  if client.supports_method("textDocument/inlayHint") then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  end

  -- Enable document highlighting if supported
  if client.supports_method("textDocument/documentHighlight") then
    local group = vim.api.nvim_create_augroup("LSPDocumentHighlight_" .. bufnr, { clear = true })
    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      group = group,
      buffer = bufnr,
      callback = vim.lsp.buf.document_highlight,
    })
    vim.api.nvim_create_autocmd("CursorMoved", {
      group = group,
      buffer = bufnr,
      callback = vim.lsp.buf.clear_references,
    })
  end

  -- Set buffer options
  vim.api.nvim_set_option_value("omnifunc", "v:lua.vim.lsp.omnifunc", { buf = bufnr })
  
  -- Format on save for specific file types
  local format_on_save_ft = {
    "lua", "go", "rust", "typescript", "javascript", "elixir"
  }
  
  if client.supports_method("textDocument/formatting") and 
     vim.tbl_contains(format_on_save_ft, vim.bo[bufnr].filetype) then
    local group = vim.api.nvim_create_augroup("LSPFormatOnSave_" .. bufnr, { clear = true })
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = group,
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({
          timeout_ms = 2000,
          filter = function(c)
            return c.id == client.id
          end,
        })
      end,
    })
  end
end

--- Get enhanced configuration with common defaults
---@param config table? Additional configuration to merge
---@return table
function M.get_enhanced_config(config)
  config = config or {}
  
  local default = M.get_default_config()
  default.on_attach = M.on_attach
  
  return vim.tbl_deep_extend("force", default, config)
end

return M

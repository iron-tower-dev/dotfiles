-- ================================================================================================
-- TITLE : LSP Keymaps
-- ABOUT : Key bindings for LSP functionality using modern Neovim features
-- ================================================================================================

-- Set up LSP-related keymaps when an LSP server attaches to a buffer
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
  callback = function(event)
    local bufnr = event.buf
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    
    if not client then return end

    -- Helper function to create buffer-local keymaps
    local function map(keys, func, desc)
      vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
    end

    -- Navigation
    map("gd", vim.lsp.buf.definition, "Go to Definition")
    map("gr", vim.lsp.buf.references, "Go to References") 
    map("gI", vim.lsp.buf.implementation, "Go to Implementation")
    map("gy", vim.lsp.buf.type_definition, "Go to Type Definition")
    map("gD", vim.lsp.buf.declaration, "Go to Declaration")

    -- Documentation
    map("K", vim.lsp.buf.hover, "Hover Documentation")
    map("gK", vim.lsp.buf.signature_help, "Signature Help")

    -- Code actions
    map("<leader>ca", vim.lsp.buf.code_action, "Code Action")
    map("<leader>rn", vim.lsp.buf.rename, "Rename")

    -- Formatting
    if client.supports_method("textDocument/formatting") then
      map("<leader>f", function()
        vim.lsp.buf.format({ timeout_ms = 2000 })
      end, "Format Document")
    end

    -- Range formatting in visual mode
    if client.supports_method("textDocument/rangeFormatting") then
      vim.keymap.set("v", "<leader>f", function()
        vim.lsp.buf.format({ timeout_ms = 2000 })
      end, { buffer = bufnr, desc = "LSP: Format Selection" })
    end

    -- Diagnostics
    map("<leader>d", vim.diagnostic.open_float, "Show Diagnostic")
    map("[d", vim.diagnostic.goto_prev, "Previous Diagnostic")
    map("]d", vim.diagnostic.goto_next, "Next Diagnostic")
    map("<leader>dl", vim.diagnostic.setloclist, "Diagnostic Location List")

    -- Workspace management
    map("<leader>wa", vim.lsp.buf.add_workspace_folder, "Add Workspace Folder")
    map("<leader>wr", vim.lsp.buf.remove_workspace_folder, "Remove Workspace Folder")
    map("<leader>wl", function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, "List Workspace Folders")

    -- Inlay hints toggle (if supported)
    if client.supports_method("textDocument/inlayHint") then
      map("<leader>th", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
      end, "Toggle Inlay Hints")
    end

    -- Symbol highlighting
    if client.supports_method("textDocument/documentHighlight") then
      map("<leader>thl", function()
        -- Toggle document highlight
        local group_name = "LSPDocumentHighlight_" .. bufnr
        local existing = vim.api.nvim_get_autocmds({ group = group_name })
        
        if #existing > 0 then
          vim.api.nvim_del_augroup_by_name(group_name)
          vim.lsp.buf.clear_references()
        else
          local group = vim.api.nvim_create_augroup(group_name, { clear = true })
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
      end, "Toggle Document Highlight")
    end

    -- Advanced features using fzf-lua if available
    local fzf_ok, fzf = pcall(require, "fzf-lua")
    if fzf_ok then
      map("<leader>lr", fzf.lsp_references, "Find References (FZF)")
      map("<leader>ld", fzf.lsp_definitions, "Find Definitions (FZF)")
      map("<leader>li", fzf.lsp_implementations, "Find Implementations (FZF)")
      map("<leader>lt", fzf.lsp_typedefs, "Find Type Definitions (FZF)")
      map("<leader>ls", fzf.lsp_document_symbols, "Document Symbols (FZF)")
      map("<leader>lS", fzf.lsp_workspace_symbols, "Workspace Symbols (FZF)")
      map("<leader>lc", fzf.lsp_code_actions, "Code Actions (FZF)")
      map("<leader>lD", fzf.lsp_workspace_diagnostics, "Workspace Diagnostics (FZF)")
    end

    -- Create a command for LSP info
    vim.api.nvim_buf_create_user_command(bufnr, "LspInfo", function()
      vim.cmd("LspInfo")
    end, { desc = "Show LSP information" })

    -- Create a command for LSP restart
    vim.api.nvim_buf_create_user_command(bufnr, "LspRestart", function()
      vim.cmd("LspRestart")
    end, { desc = "Restart LSP servers" })
  end,
})

-- Global diagnostic keymaps (not buffer-specific)
vim.keymap.set("n", "<leader>dw", vim.diagnostic.setqflist, { desc = "Diagnostic Workspace" })
vim.keymap.set("n", "<leader>dd", function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "Toggle Diagnostics" })

-- Global LSP commands
vim.api.nvim_create_user_command("LspCapabilities", function()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    print("No LSP clients attached to current buffer")
    return
  end
  
  for _, client in ipairs(clients) do
    print("Client: " .. client.name)
    print(vim.inspect(client.server_capabilities))
  end
end, { desc = "Show LSP server capabilities" })

vim.api.nvim_create_user_command("LspLog", function()
  vim.cmd("edit " .. vim.lsp.get_log_path())
end, { desc = "Open LSP log file" })

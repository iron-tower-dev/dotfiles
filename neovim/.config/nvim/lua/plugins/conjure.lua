return {
  -- Conjure - Interactive Clojure/Lisp REPL for Neovim
  {
    "Olical/conjure",
    ft = { "clojure", "clojurescript", "clojurec", "fennel", "janet", "hy", "racket", "scheme" },
    lazy = true,
    init = function()
      -- Set configuration before plugin loads
      -- Disable default mappings to avoid conflicts
      vim.g["conjure#mapping#doc_word"] = false
      vim.g["conjure#mapping#def_word"] = false
      
      -- Configure Conjure for better integration
      vim.g["conjure#log#hud#width"] = 1.0
      vim.g["conjure#log#hud#height"] = 0.42
      vim.g["conjure#log#hud#anchor"] = "SE"
      vim.g["conjure#log#hud#border"] = "rounded"
      
      -- Better log management
      vim.g["conjure#log#strip_ansi_escape_sequences_line_limit"] = 1000
      vim.g["conjure#log#wrap"] = true
      
      -- Client settings
      vim.g["conjure#client#clojure#nrepl#connection#auto_repl#enabled"] = false
      vim.g["conjure#client#clojure#nrepl#connection#auto_repl#hidden"] = true
      vim.g["conjure#client#clojure#nrepl#connection#auto_repl#cmd"] = nil
      vim.g["conjure#client#clojure#nrepl#test#current_form_names"] = {
        "deftest", "defspec", "defflow"
      }
    end,
    config = function()
      -- Set up which-key integration
      local wk_ok, which_key = pcall(require, "which-key")
      if wk_ok then
        which_key.add({
          { "<localleader>", group = "Conjure", buffer = true },
          { "<localleader>c", group = "Connect", buffer = true },
          { "<localleader>e", group = "Evaluate", buffer = true },
          { "<localleader>g", group = "Go to", buffer = true },
          { "<localleader>l", group = "Log", buffer = true },
          { "<localleader>r", group = "Reset/Refresh", buffer = true },
          { "<localleader>s", group = "Session", buffer = true },
          { "<localleader>t", group = "Test", buffer = true },
          { "<localleader>v", group = "View", buffer = true },
        })
      end

      -- Custom keymaps for better Clojure REPL experience
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "clojure", "clojurescript", "clojurec" },
        callback = function(event)
          local bufnr = event.buf
          local opts = { buffer = bufnr, silent = true }
          
          -- Helper function to create mappings with descriptions
          local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, vim.tbl_extend("force", opts, { desc = "Conjure: " .. desc }))
          end
          
          -- REPL Connection (j for "jack-in")
          map("n", "<leader>jj", "<cmd>ConjureConnect<cr>", "Jack-in to REPL")
          map("n", "<leader>jJ", "<cmd>ConjureShadowSelect<cr>", "Select REPL (Shadow CLJS)")
          map("n", "<leader>jc", "<localleader>cc", "Connect to port")
          map("n", "<leader>jp", "<localleader>cp", "Connect to host/port")
          map("n", "<leader>jd", "<localleader>cd", "Disconnect")
          
          -- Evaluation
          map("n", "<leader>ee", "<localleader>ee", "Evaluate current form")
          map("v", "<leader>ee", "<localleader>E", "Evaluate selection")
          map("n", "<leader>er", "<localleader>er", "Evaluate root form")
          map("n", "<leader>ew", "<localleader>ew", "Evaluate word under cursor")
          map("n", "<leader>eb", "<localleader>eb", "Evaluate buffer")
          map("n", "<leader>ef", "<localleader>ef", "Evaluate file from disk")
          map("n", "<leader>em", "<localleader>em", "Evaluate form at mark")
          map("n", "<leader>e!", "<localleader>e!", "Evaluate and replace form")
          
          -- Documentation
          map("n", "<leader>cd", "<localleader>K", "Show documentation")
          map("n", "K", "<localleader>K", "Show documentation")
          
          -- Go to definition
          map("n", "<leader>gd", "<localleader>gd", "Go to definition")
          map("n", "gd", "<localleader>gd", "Go to definition")
          
          -- Testing
          map("n", "<leader>tt", "<localleader>tn", "Run test under cursor")
          map("n", "<leader>tT", "<localleader>tN", "Run all tests in namespace")
          map("n", "<leader>ta", "<localleader>ta", "Run all loaded tests")
          map("n", "<leader>tr", "<localleader>tr", "Rerun last test")
          
          -- Session management
          map("n", "<leader>jq", "<localleader>sq", "Close session")
          map("n", "<leader>jQ", "<localleader>sQ", "Close all sessions")
          map("n", "<leader>jl", "<localleader>sl", "List sessions")
          map("n", "<leader>js", "<localleader>ss", "Assume session")
          map("n", "<leader>jS", "<localleader>sS", "Assume session (prompt)")
          
          -- Log management
          map("n", "<leader>lg", "<localleader>lg", "Go to log buffer")
          map("n", "<leader>ls", "<localleader>ls", "Show/hide log")
          map("n", "<leader>lr", "<localleader>lr", "Reset log (clear)")
          map("n", "<leader>lv", "<localleader>lv", "Toggle log")
          map("n", "<leader>lt", "<localleader>lt", "Toggle log HUD")
          
          -- View source
          map("n", "<leader>vs", "<localleader>vs", "View source")
          
          -- Reset namespace
          map("n", "<leader>jR", "<localleader>RR", "Refresh all changed namespaces")
          map("n", "<leader>jr", "<localleader>rr", "Refresh current namespace")
          
          -- Which-key registration for this buffer
          if wk_ok then
            which_key.add({
              { "<leader>j", group = "Jack-in/REPL", buffer = bufnr },
              { "<leader>e", group = "Evaluate", buffer = bufnr },
              { "<leader>c", group = "Clojure", buffer = bufnr },
              { "<leader>t", group = "Test", buffer = bufnr },
              { "<leader>l", group = "Log", buffer = bufnr },
              { "<leader>g", group = "Go to", buffer = bufnr },
              { "<leader>v", group = "View", buffer = bufnr },
            })
          end
        end,
      })
    end,
  },
  
  -- Paredit for structured editing
  {
    "gpanders/nvim-parinfer",
    ft = { "clojure", "clojurescript", "clojurec", "fennel", "janet", "hy", "racket", "scheme", "lisp" },
    config = function()
      vim.g.parinfer_mode = "smart"
      vim.g.parinfer_force_balance = true
    end,
  },
}

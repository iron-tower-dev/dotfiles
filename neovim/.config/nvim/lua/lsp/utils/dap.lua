-- ================================================================================================
-- TITLE : DAP Configuration
-- ABOUT : Debug Adapter Protocol setup for debugging support
-- ================================================================================================

local dap = require("dap")
local dapui = require("dapui")

-- Configure DAP UI
dapui.setup({
  icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
  mappings = {
    -- Use a table to apply multiple mappings
    expand = { "<CR>", "<2-LeftMouse>" },
    open = "o",
    remove = "d",
    edit = "e",
    repl = "r",
    toggle = "t",
  },
  layouts = {
    {
      elements = {
        -- Elements can be strings or table with id and size keys.
        { id = "scopes", size = 0.25 },
        "breakpoints",
        "stacks",
        "watches",
      },
      size = 40, -- 40 columns
      position = "left",
    },
    {
      elements = {
        "repl",
        "console",
      },
      size = 0.25, -- 25% of total lines
      position = "bottom",
    },
  },
  controls = {
    -- Requires Neovim nightly (or 0.8 when released)
    enabled = true,
    -- Display controls in this element
    element = "repl",
    icons = {
      pause = "",
      play = "",
      step_into = "",
      step_over = "",
      step_out = "",
      step_back = "",
      run_last = "↻",
      terminate = "□",
    },
  },
  floating = {
    max_height = nil, -- These can be integers or a float between 0 and 1.
    max_width = nil, -- Floats will be treated as percentage of your screen.
    border = "rounded", -- Border style. Can be "single", "double" or "rounded"
    mappings = {
      close = { "q", "<Esc>" },
    },
  },
  windows = { indent = 1 },
  render = {
    max_type_length = nil, -- Can be integer or nil.
    max_value_lines = 100, -- Can be integer or nil.
  }
})

-- Configure virtual text
require("nvim-dap-virtual-text").setup({
  enabled = true,
  enabled_commands = true,
  highlight_changed_variables = true,
  highlight_new_as_changed = false,
  show_stop_reason = true,
  commented = false,
  only_first_definition = true,
  all_references = false,
  clear_on_continue = false,
  display_callback = function(variable, buf, stackframe, node, options)
    if options.virt_text_pos == "inline" then
      return " = " .. variable.value
    else
      return variable.name .. " = " .. variable.value
    end
  end,
  virt_text_pos = vim.fn.has("nvim-0.10") == 1 and "inline" or "eol",
  all_frames = false,
  virt_lines = false,
  virt_text_win_col = nil
})

-- Automatically open/close DAP UI
dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open()
end

dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close()
end

dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close()
end

-- Configure DAP signs
vim.fn.sign_define("DapBreakpoint", {
  text = "🔴",
  texthl = "DiagnosticError",
  linehl = "",
  numhl = "DiagnosticError",
})

vim.fn.sign_define("DapBreakpointCondition", {
  text = "🔶",
  texthl = "DiagnosticWarn",
  linehl = "",
  numhl = "DiagnosticWarn",
})

vim.fn.sign_define("DapBreakpointRejected", {
  text = "🚫",
  texthl = "DiagnosticError",
  linehl = "",
  numhl = "DiagnosticError",
})

vim.fn.sign_define("DapStopped", {
  text = "▶️",
  texthl = "DiagnosticInfo",
  linehl = "DiagnosticUnderlineInfo",
  numhl = "DiagnosticInfo",
})

vim.fn.sign_define("DapLogPoint", {
  text = "📝",
  texthl = "DiagnosticInfo",
  linehl = "",
  numhl = "DiagnosticInfo",
})

-- Go debugging setup
local dap_go_ok, dap_go = pcall(require, "dap-go")
if dap_go_ok then
  dap_go.setup({
    dap_configurations = {
      {
        type = "go",
        name = "Attach remote",
        mode = "remote",
        request = "attach",
      },
    },
    delve = {
      path = "dlv",
      initialize_timeout_sec = 20,
      port = "${port}",
      args = {},
      build_flags = "",
    },
  })
end

-- JavaScript/TypeScript debugging setup
local dap_vscode_ok, dap_vscode = pcall(require, "dap-vscode-js")
if dap_vscode_ok then
  dap_vscode.setup({
    adapters = { 'pwa-node', 'pwa-chrome', 'pwa-msedge', 'node-terminal', 'pwa-extensionHost' },
  })

  local js_languages = { "typescript", "javascript", "typescriptreact", "javascriptreact" }
  
  for _, language in ipairs(js_languages) do
    dap.configurations[language] = {
      {
        type = "pwa-node",
        request = "launch",
        name = "Launch file",
        program = "${file}",
        cwd = "${workspaceFolder}",
        sourceMaps = true,
      },
      {
        type = "pwa-node",
        request = "attach",
        name = "Attach",
        processId = require('dap.utils').pick_process,
        cwd = "${workspaceFolder}",
        sourceMaps = true,
      },
      {
        type = "pwa-chrome",
        request = "launch",
        name = "Start Chrome with \"localhost\"",
        url = "http://localhost:3000",
        webRoot = "${workspaceFolder}",
        sourceMaps = true,
      },
      {
        type = "pwa-node",
        request = "launch",
        name = "Debug Jest Tests",
        runtimeExecutable = "node",
        runtimeArgs = {
          "./node_modules/jest/bin/jest.js",
          "--runInBand",
        },
        rootPath = "${workspaceFolder}",
        cwd = "${workspaceFolder}",
        console = "integratedTerminal",
        internalConsoleOptions = "neverOpen",
        sourceMaps = true,
      },
    }
  end
end

-- C# debugging setup (requires netcoredbg)
dap.adapters.coreclr = {
  type = 'executable',
  command = 'netcoredbg',
  args = {'--interpreter=vscode'}
}

dap.configurations.cs = {
  {
    type = "coreclr",
    name = "launch - netcoredbg",
    request = "launch",
    program = function()
      return vim.fn.input('Path to dll: ', vim.fn.getcwd() .. '/bin/Debug/', 'file')
    end,
  },
  {
    type = "coreclr",
    name = "attach - netcoredbg",
    request = "attach",
    processId = require('dap.utils').pick_process,
  },
}

-- Elixir debugging setup (requires elixir-debug-adapter)
dap.adapters.mix_task = {
  type = 'executable',
  command = 'elixir-debug-adapter',
  args = {}
}

dap.configurations.elixir = {
  {
    type = "mix_task",
    name = "mix test",
    request = "launch",
    task = 'test',
    taskArgs = {"--trace"},
    startApps = true,
    projectDir = "${workspaceFolder}",
    requireFiles = {
      "test/**/test_helper.exs",
      "test/**/*_test.exs"
    }
  },
  {
    type = "mix_task",
    name = "phx.server",
    request = "launch",
    task = 'phx.server',
    projectDir = "${workspaceFolder}"
  },
}

-- Helper functions for debugging
local M = {}

--- Start debugging session
function M.start_debugging()
  dap.continue()
end

--- Toggle breakpoint on current line
function M.toggle_breakpoint()
  dap.toggle_breakpoint()
end

--- Set conditional breakpoint
function M.conditional_breakpoint()
  dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
end

--- Set log point
function M.log_point()
  dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
end

--- Clear all breakpoints
function M.clear_breakpoints()
  dap.clear_breakpoints()
end

--- List all breakpoints
function M.list_breakpoints()
  local breakpoints = dap.list_breakpoints()
  if #breakpoints == 0 then
    print("No breakpoints set")
    return
  end
  
  for _, bp in ipairs(breakpoints) do
    print(string.format("%s:%d - %s", bp.filename, bp.line, bp.condition or ""))
  end
end

--- Step over
function M.step_over()
  dap.step_over()
end

--- Step into
function M.step_into()
  dap.step_into()
end

--- Step out
function M.step_out()
  dap.step_out()
end

--- Continue execution
function M.continue()
  dap.continue()
end

--- Terminate debugging session
function M.terminate()
  dap.terminate()
end

--- Run to cursor
function M.run_to_cursor()
  dap.run_to_cursor()
end

--- Toggle DAP UI
function M.toggle_ui()
  dapui.toggle()
end

--- Evaluate expression under cursor
function M.eval_under_cursor()
  dapui.eval()
end

return M

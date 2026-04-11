local M = {}

-- utils
local function hex_to_rgb(hex)
  hex = hex:gsub("#", "")
  return tonumber(hex:sub(1, 2), 16), tonumber(hex:sub(3, 4), 16), tonumber(hex:sub(5, 6), 16)
end

local function rgb_to_hex(r, g, b)
  r = math.min(255, math.max(0, math.floor(r + 0.5)))
  g = math.min(255, math.max(0, math.floor(g + 0.5)))
  b = math.min(255, math.max(0, math.floor(b + 0.5)))
  return string.format("#%02x%02x%02x", r, g, b)
end

local function blend(fg, bg, a)
  local r1, g1, b1 = hex_to_rgb(fg)
  local r2, g2, b2 = hex_to_rgb(bg)
  return rgb_to_hex((1 - a) * r2 + a * r1,
    (1 - a) * g2 + a * g1, (1 - a) * b2 + a * b1)
end

local function set_hl(g, s) vim.api.nvim_set_hl(0, g, s) end
local function link(f, t) vim.api.nvim_set_hl(0, f, { link = t, default = false }) end

-- options
local settings = type(vim.g.game_changer) == "table" and vim.g.game_changer or {}

local function get_opt(name, legacy, default)
  local value = settings[name]
  if value ~= nil then return value end
  value = vim.g[legacy]
  if value ~= nil then return value end
  return default
end

local o = {
  theme           = get_opt("theme", "game_changer_theme", "default"),
  transparent     = get_opt("transparent", "game_changer_transparent", true),
  dim_inactive    = get_opt("dim_inactive", "game_changer_dim_inactive", true),
  italic_comments = get_opt("italic_comments", "game_changer_italic_comments", true),
  italic_keywords = get_opt("italic_keywords", "game_changer_italic_keywords", true),
  bold            = get_opt("bold", "game_changer_bold", true),
  high_contrast   = get_opt("high_contrast", "game_changer_high_contrast", false),
}
local function maybe(bg) return o.transparent and "NONE" or bg end

-- Base colors using YOUR specified palette
local colors = {
  black = "#1B110F",                              -- Very dark gray/near black (background)
  bg_dim = blend("#1B110F", "#2B211F", 0.3),
  bg0 = blend("#1B110F", "#2B211F", 0.5),         -- Primary background
  bg1 = blend("#1B110F", "#3B312F", 0.5),         -- Secondary background
  bg2 = blend("#1B110F", "#4B413F", 0.5),         -- Tertiary background
  bg3 = blend("#1B110F", "#5B514F", 0.5),         -- Quaternary background
  fg0 = "#F8F4F0",                                -- Off-white (primary text)
  fg1 = "#E8E0D8",                                -- Light gray (secondary text)
  fg2 = "#C8C0B8",                                -- Medium gray (tertiary text)
  fg3 = "#A8A098",                                -- Dark gray (quaternary text)
  -- Your exact specified colors
  accent_red = "#AD204A",                         -- Deep red (your specified color)
  accent_orange = "#FF9B45",                      -- Vibrant orange (your specified color)
  accent_cyan = "#00A0B8",                        -- Bright cyan (your specified color)
  error_red = "#DD2330",                          -- Strong red (your specified color)
  accent_yellow = "#FED348",                      -- Bright yellow (your specified color)
  -- Complementary green for strings (inspired by original theme)
  accent_green = "#8f9e6f",                       -- Muted olive green that complements the palette
  -- Updated keyword color for game_changer: deeper coral that stands out on transparent background
  accent_pink = blend("#FF9B45", "#AD204A", 0.6), -- #D96B4A - Rich coral (unique to game_changer)
  accent_blue = "#85efd0",                        -- Pale sky blue for functions
  -- Terminal colors based on YOUR palette
  terminal = {
    [0] = blend("#1B110F", "#2B211F", 0.5),
    [1] = "#DD2330",  -- Your strong red
    [2] = "#8f9e6f",  -- Green
    [3] = "#FF9B45",  -- Your vibrant orange
    [4] = "#00A0B8",  -- Your bright cyan
    [5] = "#AD204A",  -- Your deep red
    [6] = "#00A0B8",  -- Your bright cyan
    [7] = "#F8F4F0",  -- Off-white
    [8] = "#A8A098",  -- Dark gray
    [9] = "#DD2330",  -- Your strong red
    [10] = "#8f9e6f", -- Green
    [11] = "#FED348", -- Your bright yellow
    [12] = "#00A0B8", -- Your bright cyan
    [13] = "#AD204A", -- Your deep red
    [14] = "#00A0B8", -- Your bright cyan
    [15] = "#F8F4F0", -- Off-white
  },
}

local function build_theme(name)
  local t = vim.tbl_extend("force", {}, colors)
  t.string = t.accent_green -- Use green for strings as in original theme
  t.special = t.accent_orange
  t.luster = t.accent_yellow
  t.lack = t.accent_cyan
  t.yellow = t.accent_yellow
  t.green = t.accent_green
  t.red = t.error_red
  t.orange = t.accent_orange
  t.cyan = t.accent_cyan
  t.pink = t.accent_pink -- Dedicated color for keywords
  t.blue = t.accent_blue -- Dedicated color for functions
  t.sel = blend(t.lack, t.bg0, 0.18)
  t.cursorln = blend(t.lack, t.bg0, 0.07)
  t.pmenu = t.bg2
  t.pmenu_sel = blend(t.lack, t.bg2, 0.22)
  t.border = blend(t.lack, t.bg2, 0.45)
  t.floatbg = t.bg2
  if o.high_contrast then t.border = blend(t.lack, t.bg2, 0.65) end
  return t
end

-- build theme
local t = build_theme(o.theme)
local black = t.black
local bg0, bg1, bg2, bg3, bg_dim = t.bg0, t.bg1, t.bg2, t.bg3, t.bg_dim
local fg0, fg1, fg2, fg3 = t.fg0, t.fg1, t.fg2, t.fg3
local luster = t.luster
local lack = t.lack
local yellow, green, red, orange, cyan, pink, blue = t.yellow, t.green, t.red, t.orange, t.cyan, t.pink, t.blue
local string_accent, special = t.string, t.special

-- derived
local sel = t.sel
local cursorln = t.cursorln
local pmenu = t.pmenu
local pmenu_sel = t.pmenu_sel
local border = t.border
local floatbg = t.floatbg

-- apply
local function apply()
  vim.o.termguicolors = true
  vim.g.colors_name = "game_changer"
  vim.cmd("hi clear")
  if vim.fn.exists("syntax_on") == 1 then vim.cmd("syntax reset") end
  vim.o.background = "dark"

  -- terminal ANSI
  for i = 0, 15 do
    vim.g["terminal_color_" .. i] = t.terminal[i]
  end

  -- Core UI
  set_hl("Normal", { fg = fg0, bg = maybe(bg0) })
  set_hl("NormalNC", { fg = o.dim_inactive and fg2 or fg0, bg = maybe(o.dim_inactive and bg_dim or bg0) })
  set_hl("NormalFloat", { fg = fg0, bg = maybe(floatbg) })
  set_hl("FloatBorder", { fg = border, bg = maybe(floatbg) })
  set_hl("FloatTitle", { fg = lack, bg = maybe(floatbg), bold = o.bold })
  set_hl("WinSeparator", { fg = border, bg = maybe(bg0) })
  set_hl("EndOfBuffer", { fg = maybe(bg0), bg = maybe(bg0) })

  set_hl("LineNr", { fg = fg3, bg = "NONE" })
  set_hl("CursorLineNr", { fg = yellow, bg = "NONE", bold = o.bold })
  set_hl("SignColumn", { fg = fg2, bg = "NONE" })
  set_hl("CursorLine", { bg = maybe(cursorln) })
  set_hl("ColorColumn", { bg = maybe(bg1) })
  set_hl("CursorColumn", { bg = maybe(bg1) })

  set_hl("Pmenu", { fg = fg0, bg = maybe(pmenu) })
  set_hl("PmenuSel", { fg = fg0, bg = maybe(pmenu_sel) })
  set_hl("PmenuSbar", { bg = maybe(blend(bg0, pmenu, 0.25)) })
  set_hl("PmenuThumb", { bg = maybe(blend(lack, pmenu, 0.30)) })

  set_hl("Search", { fg = black, bg = yellow, bold = o.bold })
  set_hl("IncSearch", { fg = black, bg = lack, bold = o.bold })
  set_hl("CurSearch", { fg = black, bg = red, bold = o.bold })
  set_hl("MatchParen", { fg = lack, bg = maybe(blend(lack, bg0, 0.16)), bold = o.bold })

  -- Visual mode highlight now preserves background even in transparent mode
  set_hl("Visual", { bg = blend("#00A0B8", bg0, 0.25) })    -- Your bright cyan with transparency
  set_hl("VisualNOS", { bg = blend("#00A0B8", bg0, 0.25) }) -- No selection variant

  set_hl("StatusLine", { fg = fg0, bg = maybe(bg3) })
  set_hl("StatusLineNC", { fg = fg2, bg = maybe(bg1) })
  set_hl("TabLine", { fg = fg2, bg = maybe(bg1) })
  set_hl("TabLineSel", { fg = fg0, bg = maybe(bg3), bold = o.bold })
  set_hl("TabLineFill", { fg = fg2, bg = maybe(bg1) })

  set_hl("Folded", { fg = lack, bg = maybe(blend(lack, bg0, 0.10)), italic = true })
  set_hl("FoldColumn", { fg = fg3, bg = "NONE" })

  set_hl("Title", { fg = yellow, bold = o.bold })
  set_hl("Directory", { fg = lack })
  set_hl("SpecialKey", { fg = fg2 })
  set_hl("NonText", { fg = fg3 })
  set_hl("Whitespace", { fg = fg3 })
  set_hl("Conceal", { fg = fg2 })

  set_hl("ErrorMsg", { fg = red, bold = o.bold })
  set_hl("WarningMsg", { fg = yellow, bold = o.bold })
  set_hl("MoreMsg", { fg = lack, bold = o.bold })
  set_hl("Question", { fg = lack, bold = o.bold })
  set_hl("ModeMsg", { fg = fg0, bold = o.bold })

  set_hl("DiffAdd", { fg = "NONE", bg = maybe(blend(green, bg0, 0.16)) })
  set_hl("DiffChange", { fg = "NONE", bg = maybe(blend(lack, bg0, 0.12)) })
  set_hl("DiffDelete", { fg = "NONE", bg = maybe(blend(red, bg0, 0.15)) })
  set_hl("DiffText", { fg = "NONE", bg = maybe(blend(yellow, bg0, 0.30)) })

  set_hl("SpellBad", { sp = red, undercurl = true })
  set_hl("SpellCap", { sp = lack, undercurl = true })
  set_hl("SpellLocal", { sp = green, undercurl = true })
  set_hl("SpellRare", { sp = yellow, undercurl = true })

  -- Syntax with dedicated colors for different elements like catppuccin
  set_hl("Comment", { fg = fg2, italic = o.italic_comments })
  set_hl("Identifier", { fg = fg0 })
  set_hl("Function", { fg = blue, bold = o.bold })                                -- Functions in pale sky blue
  set_hl("Statement", { fg = orange })                                            -- Statements in vibrant orange
  -- Updated keyword color for game_changer: rich coral that stands out on transparent background
  set_hl("Keyword", { fg = pink, italic = o.italic_keywords, bold = o.bold })     -- Keywords in rich coral with italic and bold
  set_hl("Conditional", { fg = pink, italic = o.italic_keywords, bold = o.bold }) -- Conditionals in rich coral
  set_hl("Repeat", { fg = pink, italic = o.italic_keywords, bold = o.bold })      -- Loops in rich coral
  set_hl("Operator", { fg = fg1 })
  set_hl("Constant", { fg = yellow })
  set_hl("String", { fg = string_accent })
  set_hl("Character", { fg = string_accent })
  set_hl("Number", { fg = orange })
  set_hl("Boolean", { fg = orange })
  set_hl("Float", { fg = orange })
  set_hl("Type", { fg = cyan }) -- Types in bright cyan
  set_hl("StorageClass", { fg = cyan })
  set_hl("Structure", { fg = cyan })
  set_hl("Typedef", { fg = cyan })
  set_hl("PreProc", { fg = fg1 })
  set_hl("Special", { fg = special })
  set_hl("Todo", { fg = black, bg = maybe(yellow), bold = o.bold })
  link("luaNumber", "Number")
  link("luaString", "String")

  -- Treesitter Standard Captures
  link("@comment", "Comment")
  link("@string", "String")
  link("@string.regex", "String")
  link("@string.escape", "Special")
  link("@character", "Character")
  link("@character.special", "Special")
  link("@number", "Number")
  link("@boolean", "Boolean")
  link("@float", "Float")
  link("@function", "Function")
  link("@function.builtin", "Special")
  link("@function.call", "Function")
  link("@function.macro", "Macro")
  link("@method", "Function")
  link("@method.call", "Function")
  link("@constructor", "Constructor")
  link("@parameter", "Identifier")
  link("@keyword", "Keyword")
  link("@keyword.function", "Keyword")
  link("@keyword.operator", "Operator")
  link("@keyword.return", "Keyword")
  link("@conditional", "Conditional")
  link("@repeat", "Repeat")
  link("@debug", "Debug")
  link("@label", "Label")
  link("@include", "Include")
  link("@exception", "Exception")
  link("@type", "Type")
  link("@type.builtin", "Type")
  link("@type.definition", "Typedef")
  link("@type.qualifier", "Type")
  link("@storageclass", "StorageClass")
  link("@attribute", "PreProc")
  link("@field", "Identifier")
  link("@property", "Identifier")
  link("@variable", "Identifier")
  link("@variable.builtin", "Special")
  link("@constant", "Constant")
  link("@constant.builtin", "Special")
  link("@constant.macro", "Define")
  link("@namespace", "Include")
  link("@symbol", "Identifier")
  link("@text", "Normal")
  link("@text.strong", "Bold")
  link("@text.emphasis", "Italic")
  link("@text.underline", "Underlined")
  link("@text.strike", "Strikethrough")
  link("@text.title", "Title")
  link("@text.literal", "String")
  link("@text.uri", "Underlined")
  link("@tag", "Tag")
  link("@tag.attribute", "Identifier")
  link("@tag.delimiter", "Delimiter")

  -- LSP/diagnostics
  set_hl("LspReferenceText", { bg = maybe(blend(lack, bg0, 0.10)) })
  link("LspReferenceRead", "LspReferenceText")
  link("LspReferenceWrite", "LspReferenceText")
  set_hl("LspSignatureActiveParameter", { fg = yellow, bold = o.bold })
  set_hl("LspInlayHint", { fg = fg3, bg = maybe(blend(fg3, bg0, 0.12)), italic = true })

  set_hl("DiagnosticError", { fg = red })
  set_hl("DiagnosticWarn", { fg = yellow })
  set_hl("DiagnosticInfo", { fg = lack })
  set_hl("DiagnosticHint", { fg = lack })
  set_hl("DiagnosticOk", { fg = green })
  set_hl("DiagnosticUnderlineError", { undercurl = true, sp = red })
  set_hl("DiagnosticUnderlineWarn", { undercurl = true, sp = yellow })
  set_hl("DiagnosticUnderlineInfo", { undercurl = true, sp = lack })
  set_hl("DiagnosticUnderlineHint", { undercurl = true, sp = lack })
  set_hl("DiagnosticVirtualTextError", { fg = red, bg = maybe(blend("#a0454e", bg0, 0.22)) })
  set_hl("DiagnosticVirtualTextWarn", { fg = yellow, bg = maybe(blend("#a1834c", bg0, 0.20)) })
  set_hl("DiagnosticVirtualTextInfo", { fg = lack, bg = maybe(blend(lack, bg0, 0.18)) })
  set_hl("DiagnosticVirtualTextHint", { fg = lack, bg = maybe(blend(lack, bg0, 0.18)) })

  -- Telescope
  set_hl("TelescopeNormal", { fg = fg0, bg = maybe(floatbg) })
  set_hl("TelescopeBorder", { fg = border, bg = maybe(floatbg) })
  set_hl("TelescopeTitle", { fg = lack, bold = o.bold })
  set_hl("TelescopeSelection", { fg = fg0, bg = maybe(pmenu_sel) })
  set_hl("TelescopeMatching", { fg = yellow, bold = o.bold })

  -- nvim-cmp
  set_hl("CmpItemAbbr", { fg = fg0 })
  set_hl("CmpItemAbbrDeprecated", { fg = fg2, strikethrough = true })
  set_hl("CmpItemAbbrMatch", { fg = lack, bold = o.bold })
  set_hl("CmpItemAbbrMatchFuzzy", { fg = lack, italic = true })
  set_hl("CmpItemMenu", { fg = fg2 })
  set_hl("CmpBorder", { fg = border, bg = maybe(floatbg) })
  set_hl("CmpDocBorder", { fg = border, bg = maybe(floatbg) })
  local kind = {
    Text = fg0,
    Method = blue,
    Function = blue,
    Constructor = blue,
    Field = fg0,
    Variable = fg0,
    Class = cyan,
    Interface = cyan,
    Module = fg1,
    Property = fg0,
    Unit = lack,
    Value = yellow,
    Enum = yellow,
    Keyword = pink,
    Snippet = yellow,
    Color = lack,
    File = fg0,
    Reference = fg0,
    Folder = lack,
    EnumMember = yellow,
    Constant = yellow,
    Struct = cyan,
    Event = yellow,
    Operator = fg1,
    TypeParameter = cyan,
  }
  for k, c in pairs(kind) do set_hl("CmpItemKind" .. k, { fg = c }) end

  -- Git / explorers / misc
  set_hl("GitSignsAdd", { fg = green })
  set_hl("GitSignsChange", { fg = lack }); set_hl("GitSignsDelete", { fg = red })
  set_hl("NvimTreeNormal", { fg = fg0, bg = maybe(bg0) })
  set_hl("NvimTreeWinSeparator", { fg = border, bg = maybe(bg0) })
  set_hl("NvimTreeRootFolder", { fg = yellow, bold = o.bold })
  set_hl("NvimTreeFolderName", { fg = lack })
  set_hl("NeoTreeNormal", { fg = fg0, bg = maybe(bg0) })
  set_hl("NeoTreeDirectoryName", { fg = lack })
  set_hl("NeoTreeRootName", { fg = yellow, bold = o.bold })

  set_hl("IndentBlanklineChar", { fg = fg3 })
  set_hl("IndentBlanklineContextChar", { fg = blend(lack, bg0, 0.45) })
  set_hl("IblIndent", { fg = fg3 })
  set_hl("IblScope", { fg = blend(lack, bg0, 0.45) })

  set_hl("NotifyBackground", { bg = maybe(floatbg) })
  for _, t in ipairs({ "INFO", "WARN", "ERROR", "DEBUG", "TRACE" }) do
    set_hl("Notify" .. t .. "Border", { fg = border, bg = maybe(floatbg) })
  end
  set_hl("NotifyINFOTitle", { fg = lack, bold = o.bold })
  set_hl("NotifyWARNTitle", { fg = yellow, bold = o.bold })
  set_hl("NotifyERRORTitle", { fg = red, bold = o.bold })
  set_hl("NotifyTRACETitle", { fg = lack, bold = o.bold })

  set_hl("MasonNormal", { fg = fg0, bg = maybe(floatbg) })
  set_hl("MasonHeader",
    { fg = black, bg = yellow, bold = o.bold })
  set_hl("LazyNormal", { fg = fg0, bg = maybe(floatbg) })
  set_hl("LazyH1", { fg = black, bg = lack, bold = o.bold })
  set_hl("NoicePopup", { fg = fg0, bg = maybe(floatbg) })
  set_hl("NoiceCmdlineIcon", { fg = lack })
  set_hl("NoiceCmdlinePopupBorder", { fg = border })

  set_hl("DapBreakpoint", { fg = red })
  set_hl("DapBreakpointCondition", { fg = yellow })
  set_hl("DapStopped", { fg = yellow, bg = maybe(blend(yellow, bg0, 0.10)) })
  set_hl("TroubleNormal", { fg = fg0, bg = maybe(floatbg) })
  set_hl("TroubleText", { fg = fg0 })
  set_hl("TroubleCount", { fg = lack, bg = maybe(blend(lack, bg0, 0.14)) })
  set_hl("DashboardHeader", { fg = lack })
  set_hl("DashboardFooter", { fg = fg2, italic = true })
  set_hl("DashboardCenter", { fg = fg0 })
  set_hl("HopNextKey", { fg = lack, bold = o.bold })
  set_hl("HopNextKey1", { fg = yellow, bold = o.bold })
  set_hl("HopNextKey2", { fg = red })

  -- Transparent mode fix: Only set bg to NONE for specific groups, preserving Visual highlight
  if o.transparent then
    for _, g in ipairs({ "NormalFloat", "SignColumn", "StatusLine", "StatusLineNC", "TabLine", "TabLineFill", "TabLineSel", "CursorLine", "WinBar", "WinBarNC", "TelescopeNormal", "TelescopeBorder", "WhichKeyFloat", "TroubleNormal", "MasonNormal", "LazyNormal" }) do
      local hl = vim.api.nvim_get_hl(0, { name = g, link = false })
      if hl and hl.bg then
        hl.bg = "NONE"
      end
      set_hl(g, hl)
    end
    -- Skip setting Visual to NONE to preserve its highlight
  end
end

apply()

return M

# Nushell Configuration
# Modern structured shell with Catppuccin Macchiato theming

# Load custom theme
source ~/.config/nushell/themes/catppuccin_macchiato.nu

# Load custom commands and aliases  
source ~/.config/nushell/scripts/aliases.nu
source ~/.config/nushell/scripts/git_utils.nu
source ~/.config/nushell/scripts/system_utils.nu

# Environment variables
$env.EDITOR = 'nvim'
$env.VISUAL = 'nvim'

# XDG Base Directory Specification
$env.XDG_CONFIG_HOME = $"($env.HOME)/.config"
$env.XDG_DATA_HOME = $"($env.HOME)/.local/share"
$env.XDG_CACHE_HOME = $"($env.HOME)/.cache"
$env.XDG_STATE_HOME = $"($env.HOME)/.local/state"

# Wayland/Hyprland environment variables
$env.XDG_CURRENT_DESKTOP = "Hyprland"
$env.XDG_SESSION_TYPE = "wayland"
$env.XDG_SESSION_DESKTOP = "Hyprland"
$env.GDK_BACKEND = "wayland,x11"
$env.QT_QPA_PLATFORM = "wayland;xcb"
$env.SDL_VIDEODRIVER = "wayland"
$env.CLUTTER_BACKEND = "wayland"
$env.QT_WAYLAND_DISABLE_WINDOWDECORATION = "1"

# Theme environment variables
$env.QT_QPA_PLATFORMTHEME = "qt5ct"
$env.QT_QPA_PLATFORMTHEME_QT6 = "qt6ct"
$env.QT_STYLE_OVERRIDE = "kvantum"
$env.GTK_THEME = "catppuccin-macchiato-mauve-standard+default"
$env.XCURSOR_THEME = "catppuccin-macchiato-mauve-cursors"
$env.XCURSOR_SIZE = "24"

# Development environment
$env.RUSTUP_HOME = $"($env.HOME)/.rustup"
$env.CARGO_HOME = $"($env.HOME)/.cargo"

# Path management
$env.PATH = ($env.PATH | split row (char esep) | append [
    $"($env.HOME)/.local/bin"
    $"($env.HOME)/.cargo/bin"
    $"($env.HOME)/bin"
] | uniq)

# Nushell configuration
$env.config = {
  show_banner: false
  
  # Table configuration
  table: {
    mode: rounded
    index_mode: always
    show_empty: true
    trim: {
      methodology: wrapping
      wrapping_try_keep_words: true
      truncating_suffix: "..."
    }
  }

  # Error handling
  error_style: "fancy"

  # Date formatting  
  datetime_format: {
    normal: '%Y-%m-%d %H:%M:%S'
    table: '%Y-%m-%d %H:%M:%S'
  }

  # Explore command configuration
  explore: {
    help_banner: true
    exit_esc: true
    command_bar_text: '#C4C9C6'
    status_bar_background: {fg: '#1D1F21', bg: '#C4C9C6'}
    highlight: {fg: 'black', bg: 'yellow'}
    status: {
      error: {fg: 'white', bg: 'red'}
      warn: {}
      info: {}
    }
    try: {
      border_color: 'red'
      highlighted_color: 'blue'
      reactive: false
    }
    table: {
      split_line: '#404040'
      cursor: true
      line_index: true
      line_shift: true
      line_head_top: true
      line_head_bottom: true
      show_head: true
      show_index: true
    }
    config: {
      cursor_color: {bg: 'yellow', fg: 'black' }
    }
  }

  # History configuration
  history: {
    max_size: 100_000
    sync_on_enter: true
    file_format: "plaintext"
    isolation: false
  }

  # Completions configuration
  completions: {
    case_sensitive: false
    quick: true
    partial: true
    algorithm: "prefix"
    external: {
      enable: true
      max_results: 100
      completer: {|spans|
        # Use fish completions if available
        if (which fish | is-not-empty) {
          fish --command $'complete --do-complete ($spans | str join " ")'
          | $"value(char tab)description(char newline)" + $in
          | from tsv --flexible --no-infer
          | default "" description
          | where value != ""
        }
      }
    }
  }

  # File completions (filesize options moved to other config sections)

  # Cursor configuration
  cursor_shape: {
    emacs: line
    vi_insert: block
    vi_normal: underscore
  }

# Color configuration
  color_config: (catppuccin_macchiato)
  footer_mode: 25
  float_precision: 2
  
  # Buffer editor
  buffer_editor: "nvim"
  
  # Use ansi coloring
  use_ansi_coloring: true
  
  # Bracketed paste
  bracketed_paste: true
  
  # Edit mode (emacs/vi)
  edit_mode: emacs
  
  # Shell integration
  shell_integration: {
    osc2: true
    osc7: true
    osc8: true
    osc9_9: false
    osc133: true
    osc633: true
    reset_application_mode: true
  }
  
  # Render right prompt on last line
  render_right_prompt_on_last_line: false

  # Hooks
  hooks: {
    pre_prompt: [{ null }]
    pre_execution: [{ null }]
    env_change: {
      PWD: [{|before, after| null }]
    }
    display_output: "if (term size).columns >= 100 { table -e } else { table }"
    command_not_found: { null }
  }

  # Menus
  menus: [
    {
      name: completion_menu
      only_buffer_difference: false
      marker: "| "
      type: {
        layout: columnar
        columns: 4
        col_width: 20
        col_padding: 2
      }
      style: {
        text: green
        selected_text: green_reverse
        description_text: yellow
      }
    }
    {
      name: history_menu
      only_buffer_difference: true
      marker: "? "
      type: {
        layout: list
        page_size: 10
      }
      style: {
        text: green
        selected_text: green_reverse
        description_text: yellow
      }
    }
    {
      name: help_menu
      only_buffer_difference: true
      marker: "? "
      type: {
        layout: description
        columns: 4
        col_width: 20
        col_padding: 2
        selection_rows: 4
        description_rows: 10
      }
      style: {
        text: green
        selected_text: green_reverse
        description_text: yellow
      }
    }
  ]

  # Keybindings
  keybindings: [
    {
      name: completion_menu
      modifier: none
      keycode: tab
      mode: [emacs vi_normal vi_insert]
      event: {
        until: [
          { send: menu name: completion_menu }
          { send: menunext }
          { edit: complete }
        ]
      }
    }
    {
      name: history_menu
      modifier: control
      keycode: char_r
      mode: [emacs, vi_insert, vi_normal]
      event: { send: menu name: history_menu }
    }
    {
      name: help_menu
      modifier: none
      keycode: f1
      mode: [emacs, vi_insert, vi_normal]
      event: { send: menu name: help_menu }
    }
    {
      name: completion_previous_menu
      modifier: shift
      keycode: backtab
      mode: [emacs, vi_normal, vi_insert]
      event: { send: menuprevious }
    }
    {
      name: next_page_menu
      modifier: control
      keycode: char_x
      mode: emacs
      event: { send: menupagenext }
    }
    {
      name: undo_or_previous_page_menu
      modifier: control
      keycode: char_z
      mode: emacs
      event: {
        until: [
          { send: menupageprevious }
          { edit: undo }
        ]
      }
    }
    {
      name: escape
      modifier: none
      keycode: escape
      mode: [emacs, vi_normal, vi_insert]
      event: { send: esc }
    }
    {
      name: cancel_command
      modifier: control
      keycode: char_c
      mode: [emacs, vi_normal, vi_insert]
      event: { send: ctrlc }
    }
    {
      name: quit_shell
      modifier: control
      keycode: char_d
      mode: [emacs, vi_normal, vi_insert]
      event: { send: ctrld }
    }
    {
      name: clear_screen
      modifier: control
      keycode: char_l
      mode: [emacs, vi_normal, vi_insert]
      event: { send: clearscreen }
    }
    {
      name: search_history
      modifier: control
      keycode: char_q
      mode: [emacs, vi_normal, vi_insert]
      event: { send: searchhistory }
    }
    {
      name: open_command_editor
      modifier: control
      keycode: char_o
      mode: [emacs, vi_normal, vi_insert]
      event: { send: openeditor }
    }
    {
      name: move_up
      modifier: none
      keycode: up
      mode: [emacs, vi_normal, vi_insert]
      event: {
        until: [
          { send: menuup }
          { send: up }
        ]
      }
    }
    {
      name: move_down
      modifier: none
      keycode: down
      mode: [emacs, vi_normal, vi_insert]
      event: {
        until: [
          { send: menudown }
          { send: down }
        ]
      }
    }
    {
      name: move_left
      modifier: none
      keycode: left
      mode: [emacs, vi_normal, vi_insert]
      event: {
        until: [
          { send: menuleft }
          { send: left }
        ]
      }
    }
    {
      name: move_right_or_take_history_hint
      modifier: none
      keycode: right
      mode: [emacs, vi_normal, vi_insert]
      event: {
        until: [
          { send: historyhintcomplete }
          { send: menuright }
          { send: right }
        ]
      }
    }
    {
      name: move_one_word_left
      modifier: control
      keycode: left
      mode: [emacs, vi_normal, vi_insert]
      event: { edit: movewordleft }
    }
    {
      name: move_one_word_right_or_take_history_hint
      modifier: control
      keycode: right
      mode: [emacs, vi_normal, vi_insert]
      event: {
        until: [
          { send: historyhintwordcomplete }
          { edit: movewordright }
        ]
      }
    }
    {
      name: move_to_line_start
      modifier: none
      keycode: home
      mode: [emacs, vi_normal, vi_insert]
      event: { edit: movetolinestart }
    }
    {
      name: move_to_line_start_alt
      modifier: control
      keycode: char_a
      mode: [emacs, vi_normal, vi_insert]
      event: { edit: movetolinestart }
    }
    {
      name: move_to_line_end_or_take_history_hint
      modifier: none
      keycode: end
      mode: [emacs, vi_normal, vi_insert]
      event: {
        until: [
          { send: historyhintcomplete }
          { edit: movetolineend }
        ]
      }
    }
    {
      name: move_to_line_end_alt
      modifier: control
      keycode: char_e
      mode: [emacs, vi_normal, vi_insert]
      event: {
        until: [
          { send: historyhintcomplete }
          { edit: movetolineend }
        ]
      }
    }
    {
      name: move_up_line
      modifier: control
      keycode: char_p
      mode: [emacs, vi_normal, vi_insert]
      event: {
        until: [
          { send: menuup }
          { send: up }
        ]
      }
    }
    {
      name: move_down_line
      modifier: control
      keycode: char_t
      mode: [emacs, vi_normal, vi_insert]
      event: {
        until: [
          { send: menudown }
          { send: down }
        ]
      }
    }
    {
      name: delete_one_character_backward
      modifier: none
      keycode: backspace
      mode: [emacs, vi_insert]
      event: { edit: backspace }
    }
    {
      name: delete_one_word_backward
      modifier: control
      keycode: backspace
      mode: [emacs, vi_insert]
      event: { edit: backspaceword }
    }
    {
      name: delete_one_character_forward
      modifier: none
      keycode: delete
      mode: [emacs, vi_insert]
      event: { edit: delete }
    }
    {
      name: delete_one_word_forward
      modifier: control
      keycode: delete
      mode: [emacs, vi_insert]
      event: { edit: deleteword }
    }
    {
      name: delete_one_word_backward_alt
      modifier: alt
      keycode: backspace
      mode: [emacs, vi_insert]
      event: { edit: backspaceword }
    }
    {
      name: delete_one_word_forward_alt
      modifier: alt
      keycode: delete
      mode: [emacs, vi_insert]
      event: { edit: deleteword }
    }
    {
      name: delete_from_cursor_to_line_end
      modifier: control
      keycode: char_k
      mode: [emacs, vi_insert]
      event: { edit: cuttolineend }
    }
    {
      name: delete_from_line_start_to_cursor
      modifier: control
      keycode: char_u
      mode: [emacs, vi_insert]
      event: { edit: cutfromlinestart }
    }
    {
      name: swap_graphemes
      modifier: control
      keycode: char_t
      mode: emacs
      event: { edit: swapgraphemes }
    }
    {
      name: move_one_word_left_alt
      modifier: alt
      keycode: left
      mode: [emacs, vi_normal, vi_insert]
      event: { edit: movewordleft }
    }
    {
      name: move_one_word_right_alt
      modifier: alt
      keycode: right
      mode: [emacs, vi_normal, vi_insert]
      event: { edit: movewordright }
    }
    {
      name: move_one_word_left_alt2
      modifier: control
      keycode: char_b
      mode: [emacs, vi_normal, vi_insert]
      event: { edit: movewordleft }
    }
    {
      name: move_one_word_right_alt2
      modifier: control
      keycode: char_f
      mode: [emacs, vi_normal, vi_insert]
      event: { edit: movewordright }
    }
    {
      name: cut_word_left
      modifier: control
      keycode: char_w
      mode: [emacs, vi_insert]
      event: { edit: cutwordleft }
    }
    {
      name: cut_line_to_end
      modifier: control
      keycode: char_k
      mode: [emacs, vi_insert]
      event: { edit: cuttolineend }
    }
    {
      name: cut_line_from_start
      modifier: control
      keycode: char_u
      mode: [emacs, vi_insert]
      event: { edit: cutfromlinestart }
    }
    {
      name: yank
      modifier: control
      keycode: char_y
      mode: [emacs, vi_insert]
      event: { edit: paste }
    }
    # transpose_words keybinding removed - not available in this Nushell version
    {
      name: uppercase_word
      modifier: alt
      keycode: char_u
      mode: [emacs, vi_insert]
      event: { edit: uppercaseword }
    }
    {
      name: lowercase_word
      modifier: alt
      keycode: char_l
      mode: [emacs, vi_insert]
      event: { edit: lowercaseword }
    }
    {
      name: capitalize_char
      modifier: alt
      keycode: char_c
      mode: [emacs, vi_insert]
      event: { edit: capitalizechar }
    }
  ]
}

# Initialize Oh My Posh prompt if available
if (which oh-my-posh | is-not-empty) {
  # Set Oh My Posh configuration
  $env.POSH_CONFIG = $"($env.HOME)/.config/catppuccin-macchiato.omp.toml"
  
  # Initialize Oh My Posh for Nushell
  $env.PROMPT_MULTILINE_INDICATOR = (^oh-my-posh print secondary --config $env.POSH_CONFIG)
  
  # Main prompt command
  $env.PROMPT_COMMAND = { ||
    ^oh-my-posh print primary --config $env.POSH_CONFIG $"--shell-version=(version | get version)" $"--execution-time=($env.CMD_DURATION_MS)" $"--status=($env.LAST_EXIT_CODE)"
  }
  
  # Right prompt command
  $env.PROMPT_COMMAND_RIGHT = { ||
    ^oh-my-posh print right --config $env.POSH_CONFIG $"--shell-version=(version | get version)" $"--execution-time=($env.CMD_DURATION_MS)" $"--status=($env.LAST_EXIT_CODE)"
  }
  
  # Transient prompt configuration - simplified prompt after Enter
  $env.TRANSIENT_PROMPT_COMMAND = { ||
    ^oh-my-posh print transient --config $env.POSH_CONFIG
  }
  $env.TRANSIENT_PROMPT_COMMAND_RIGHT = { || "" }
}

# Initialize zoxide if available  
if (which zoxide | is-not-empty) {
  let zoxide_config = $"($env.HOME)/.config/nushell/zoxide.nu"
  if not ($zoxide_config | path exists) {
    ^zoxide init nushell | save --force $zoxide_config
  }
}

# Initialize direnv if available
if (which direnv | is-not-empty) {
  let direnv_config = $"($env.HOME)/.config/nushell/direnv.nu"
  if not ($direnv_config | path exists) {
    ^direnv hook nushell | save --force $direnv_config
  }
}

# Initialize mise if available
if (which mise | is-not-empty) {
  let mise_config = $"($env.HOME)/.config/nushell/mise.nu"
  if not ($mise_config | path exists) {
    ^mise activate nu | save --force $mise_config
  }
}

# Welcome message
print $"(ansi green)Welcome to (ansi blue)Nushell(ansi reset) with (ansi magenta)Catppuccin Macchiato(ansi reset) theme!"
print $"Type (ansi yellow)'help'(ansi reset) to get started or (ansi cyan)'exit'(ansi reset) to return to your previous shell."

# Check if development tools need initialization
let tools_to_init = (
  []
  | (if (which zoxide | is-not-empty) and not ("~/.config/nushell/zoxide.nu" | path expand | path exists) { $in | append "zoxide" } else { $in })
  | (if (which direnv | is-not-empty) and not ("~/.config/nushell/direnv.nu" | path expand | path exists) { $in | append "direnv" } else { $in })
  | (if (which mise | is-not-empty) and not ("~/.config/nushell/mise.nu" | path expand | path exists) { $in | append "mise" } else { $in })
)

if ($tools_to_init | length) > 0 {
  print ""
  print $"(ansi yellow)Development tools available for setup: ($tools_to_init | str join ', ')(ansi reset)"
  print $"(ansi cyan)Run 'source ~/.config/nushell/init.nu' to initialize them.(ansi reset)"
}

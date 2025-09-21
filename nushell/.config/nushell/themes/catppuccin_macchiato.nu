# Catppuccin Macchiato Theme for Nushell
# Beautiful pastel theme with dark background

export def catppuccin_macchiato [] {
  {
    # Color palette
    separator: "#6e738d"
    leading_trailing_space_bg: { attr: n }
    header: { fg: "#8aadf4" attr: b }
    empty: "#8aadf4"
    bool: {|| if $in { "#a6da95" } else { "light_gray" } }
    int: "#6e738d"
    filesize: {|e|
      if $e == 0b {
        "#6e738d"
      } else if $e < 1mb {
        "#8bd5ca"
      } else {{ fg: "#8aadf4" }}
    }
    duration: "#6e738d"
    date: {|| (date now) - $in |
      if $in < 1hr {
        { fg: "#ed8796" attr: b}
      } else if $in < 6hr {
        "#ed8796"
      } else if $in < 1day {
        "#eed49f"
      } else if $in < 3day {
        "#a6da95"
      } else if $in < 1wk {
        { fg: "#a6da95" attr: b}
      } else if $in < 6wk {
        "#8bd5ca"
      } else if $in < 52wk {
        "#8aadf4"
      } else { "dark_gray" }
    }
    range: "#6e738d"
    float: "#6e738d"
    string: "#cad3f5"
    nothing: "#6e738d"
    binary: "#6e738d"
    cellpath: "#6e738d"
    row_index: { fg: "#a6da95" attr: b}
    record: "#cad3f5"
    list: "#cad3f5"
    block: "#cad3f5"
    hints: "dark_gray"
    search_result: {fg: "#ed8796" bg: "#6e738d"}

    shape_and: { fg: "#c6a0f6" attr: b}
    shape_binary: { fg: "#c6a0f6" attr: b}
    shape_block: { fg: "#8aadf4" attr: b}
    shape_bool: "#a6da95"
    shape_custom: "#a6da95"
    shape_datetime: { fg: "#8bd5ca" attr: b}
    shape_directory: "#8bd5ca"
    shape_external: "#8bd5ca"
    shape_externalarg: { fg: "#a6da95" attr: b}
    shape_filepath: "#8bd5ca"
    shape_flag: { fg: "#8aadf4" attr: b}
    shape_float: { fg: "#c6a0f6" attr: b}
    shape_garbage: { fg: "#FFFFFF" bg: "#FF0000" attr: b}
    shape_globpattern: { fg: "#8bd5ca" attr: b}
    shape_int: { fg: "#c6a0f6" attr: b}
    shape_internalcall: { fg: "#8bd5ca" attr: b}
    shape_list: { fg: "#8bd5ca" attr: b}
    shape_literal: "#8aadf4"
    shape_match_pattern: "#a6da95"
    shape_matching_brackets: { attr: u }
    shape_nothing: "#c6a0f6"
    shape_operator: "#eed49f"
    shape_or: { fg: "#c6a0f6" attr: b}
    shape_pipe: { fg: "#c6a0f6" attr: b}
    shape_range: { fg: "#eed49f" attr: b}
    shape_record: { fg: "#8bd5ca" attr: b}
    shape_redirection: { fg: "#c6a0f6" attr: b}
    shape_signature: { fg: "#a6da95" attr: b}
    shape_string: "#a6da95"
    shape_string_interpolation: { fg: "#8bd5ca" attr: b}
    shape_table: { fg: "#8aadf4" attr: b}
    shape_variable: "#c6a0f6"
    shape_vardecl: "#c6a0f6"
  }
}

# Set up the theme variable for use in config.nu
let catppuccin_macchiato_theme = (catppuccin_macchiato)

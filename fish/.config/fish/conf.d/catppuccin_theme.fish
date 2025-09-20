# Catppuccin Macchiato Theme for Fish Shell
# Colors based on Catppuccin Macchiato palette

# Catppuccin Macchiato Colors
set -l rosewater f4dbd6
set -l flamingo f0c6c6
set -l pink f5bde6
set -l mauve c6a0f6
set -l red ed8796
set -l maroon ee99a0
set -l peach f5a97f
set -l yellow eed49f
set -l green a6da95
set -l teal 8bd5ca
set -l sky 91d7e3
set -l sapphire 7dc4e4
set -l blue 8aadf4
set -l lavender b7bdf8
set -l text cad3f5
set -l subtext1 b8c0e0
set -l subtext0 a5adcb
set -l overlay2 939ab7
set -l overlay1 8087a2
set -l overlay0 6e738d
set -l surface2 5b6078
set -l surface1 494d64
set -l surface0 363a4f
set -l base 24273a
set -l mantle 1e2030
set -l crust 181926

# Fish color configuration
set -U fish_color_normal $text
set -U fish_color_command $blue
set -U fish_color_keyword $mauve
set -U fish_color_quote $green
set -U fish_color_redirection $pink
set -U fish_color_end $peach
set -U fish_color_error $red
set -U fish_color_param $text
set -U fish_color_comment $overlay0
set -U fish_color_selection --background=$surface0
set -U fish_color_search_match --background=$surface0
set -U fish_color_operator $sky
set -U fish_color_escape $pink
set -U fish_color_autosuggestion $overlay0
set -U fish_color_cancel $red
set -U fish_color_cwd $peach
set -U fish_color_user $teal
set -U fish_color_host $blue
set -U fish_color_host_remote $green
set -U fish_color_status $red

# Completion colors
set -U fish_color_valid_path --underline
set -U fish_color_history_current $yellow

# Pager colors (for completions)
set -U fish_pager_color_progress $overlay0
set -U fish_pager_color_background
set -U fish_pager_color_prefix $blue
set -U fish_pager_color_completion $text
set -U fish_pager_color_description $overlay0
set -U fish_pager_color_selected_background --background=$surface0
set -U fish_pager_color_selected_prefix $pink
set -U fish_pager_color_selected_completion $text
set -U fish_pager_color_selected_description $overlay1

# Set LS colors for file listings (if using coreutils ls)
set -gx LS_COLORS "rs=0:di=01;34:ln=01;36:mh=00:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:mi=00:su=37;41:sg=30;43:ca=30;41:tw=30;42:ow=34;42:st=37;44:ex=01;32"

# Set colors for EXA (modern ls replacement)
if command -v exa >/dev/null 2>&1
    set -gx EXA_COLORS "ur=33:uw=31:ux=32:ue=32:gr=33:gw=31:gx=32:tr=33:tw=31:tx=32:su=37:sf=32:xa=37:uu=33:un=31:gu=33:gn=31:da=36:ga=36:gm=36:gd=36:gv=36:gt=36:xx=37:lc=90:ec=90:lp=36:cc=37:bO=1;36:bd=33:cd=33:pi=35:so=35:ex=32:fi=37:di=34:ln=36:or=31"
end

# Function to show Catppuccin color palette
function catppuccin_palette
    echo "Catppuccin Macchiato Color Palette:"
    echo "=================================="
    
    set colors rosewater flamingo pink mauve red maroon peach yellow green teal sky sapphire blue lavender text subtext1 subtext0 overlay2 overlay1 overlay0 surface2 surface1 surface0 base mantle crust
    
    for color in $colors
        set color_var $$color
        set_color -b $color_var
        echo -n "  "
        set_color normal
        echo " $color (#$color_var)"
    end
    
    set_color normal
end

# Function to test Fish colors
function fish_colors_test
    echo "Fish Color Test:"
    echo "==============="
    
    set_color $fish_color_command
    echo "command"
    set_color $fish_color_keyword  
    echo "keyword"
    set_color $fish_color_quote
    echo "quote"
    set_color $fish_color_redirection
    echo "redirection"
    set_color $fish_color_end
    echo "end"
    set_color $fish_color_error
    echo "error"
    set_color $fish_color_param
    echo "param"
    set_color $fish_color_comment
    echo "comment"
    set_color $fish_color_operator
    echo "operator"
    set_color $fish_color_escape
    echo "escape"
    set_color $fish_color_autosuggestion
    echo "autosuggestion"
    set_color $fish_color_cwd
    echo "cwd"
    set_color $fish_color_user
    echo "user"
    set_color $fish_color_host
    echo "host"
    
    set_color normal
    echo "normal"
end

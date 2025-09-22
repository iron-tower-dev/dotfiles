#!/usr/bin/python3
"""
Keybinding Reference Panel
A modern, Catppuccin-themed floating panel showing Hyprland and Zellij keybindings
"""

import gi
gi.require_version('Gtk', '4.0')
gi.require_version('Adw', '1')

import os
import sys
import json
import re
from pathlib import Path
from gi.repository import Gtk, Adw, GLib, Gio, Pango

# Catppuccin Macchiato color palette
CATPPUCCIN_MACCHIATO = {
    'rosewater': '#f4dbd6',
    'flamingo': '#f0c6c6',
    'pink': '#f5bde6',
    'mauve': '#c6a0f6',
    'red': '#ed8796',
    'maroon': '#ee99a0',
    'peach': '#f5a97f',
    'yellow': '#eed49f',
    'green': '#a6da95',
    'teal': '#8bd5ca',
    'sky': '#91d7e3',
    'sapphire': '#7dc4e4',
    'blue': '#8aadf4',
    'lavender': '#b7bdf8',
    'text': '#cad3f5',
    'subtext1': '#b8c0e0',
    'subtext0': '#a5adcb',
    'overlay2': '#939ab7',
    'overlay1': '#8087a2',
    'overlay0': '#6e738d',
    'surface2': '#5b6078',
    'surface1': '#494d64',
    'surface0': '#363a4f',
    'base': '#24273a',
    'mantle': '#1e2030',
    'crust': '#181926'
}

class KeybindingReference:
    def __init__(self):
        self.app = Adw.Application(application_id='org.keybind.reference')
        self.app.connect('activate', self.on_activate)
        
        # Keybinding data
        self.hyprland_keybinds = []
        self.zellij_keybinds = []
        self.neovim_lsp_keybinds = []
        
        # Load keybindings
        self.load_hyprland_keybinds()
        self.load_zellij_keybinds()
        self.load_neovim_lsp_keybinds()
    
    def load_hyprland_keybinds(self):
        """Extract keybindings from Hyprland configuration"""
        try:
            config_path = Path.home() / '.config' / 'hypr' / 'hyprland.conf'
            if config_path.exists():
                with open(config_path, 'r') as f:
                    content = f.read()
                
                # Parse bind statements
                bind_pattern = r'bind\s*=\s*([^,]+),\s*([^,]+),\s*(.+)'
                for match in re.finditer(bind_pattern, content):
                    modifiers, key, action = match.groups()
                    self.hyprland_keybinds.append({
                        'key': f"{modifiers.strip()} + {key.strip()}",
                        'action': action.strip(),
                        'category': self.categorize_hyprland_action(action.strip())
                    })
        except Exception as e:
            print(f"Error loading Hyprland keybinds: {e}")
            # Use your actual keybindings as fallback
            self.hyprland_keybinds = [
                {'key': 'SUPER + Return', 'action': 'Open Terminal (Alacritty)', 'category': 'Applications'},
                {'key': 'SUPER + Space', 'action': 'Open Launcher (Rofi)', 'category': 'Applications'},
                {'key': 'SUPER + E', 'action': 'Open File Manager (Thunar)', 'category': 'Applications'},
                {'key': 'SUPER + W', 'action': 'Change Wallpaper', 'category': 'Applications'},
                {'key': 'SUPER + /', 'action': 'Show Keybinding Reference', 'category': 'Applications'},
                
                {'key': 'SUPER + Q', 'action': 'Close Active Window', 'category': 'Window Management'},
                {'key': 'SUPER + M', 'action': 'Exit Hyprland', 'category': 'Window Management'},
                {'key': 'SUPER + T', 'action': 'Toggle Floating Window', 'category': 'Window Management'},
                {'key': 'SUPER + P', 'action': 'Pseudotile (Dwindle)', 'category': 'Window Management'},
                {'key': 'SUPER + J', 'action': 'Toggle Split (Dwindle)', 'category': 'Window Management'},
                
                {'key': 'SUPER + ↑/↓/←/→', 'action': 'Move Focus Between Windows', 'category': 'Navigation'},
                {'key': 'SUPER + Mouse Drag', 'action': 'Move/Resize Window', 'category': 'Navigation'},
                {'key': 'SUPER + Mouse Wheel', 'action': 'Switch Workspaces', 'category': 'Navigation'},
                
                {'key': 'SUPER + 1-9,0', 'action': 'Switch to Workspace N', 'category': 'Workspaces'},
                {'key': 'SUPER + Shift + 1-9,0', 'action': 'Move Window to Workspace N', 'category': 'Workspaces'},
                {'key': 'SUPER + S', 'action': 'Toggle Special Workspace (Magic)', 'category': 'Workspaces'},
                {'key': 'SUPER + Shift + S', 'action': 'Move to Special Workspace', 'category': 'Workspaces'},
                
                {'key': 'XF86AudioRaiseVolume', 'action': 'Increase Volume (5%)', 'category': 'System'},
                {'key': 'XF86AudioLowerVolume', 'action': 'Decrease Volume (5%)', 'category': 'System'},
                {'key': 'XF86AudioMute', 'action': 'Toggle Audio Mute', 'category': 'System'},
                {'key': 'XF86AudioMicMute', 'action': 'Toggle Microphone Mute', 'category': 'System'},
                {'key': 'XF86MonBrightnessUp/Down', 'action': 'Adjust Screen Brightness', 'category': 'System'},
                {'key': 'XF86AudioNext/Prev', 'action': 'Media Control (Next/Previous)', 'category': 'System'},
                {'key': 'XF86AudioPlay/Pause', 'action': 'Media Control (Play/Pause)', 'category': 'System'},
            ]
    
    def load_zellij_keybinds(self):
        """Extract keybindings from Zellij configuration"""
        try:
            # Common Zellij keybindings based on tmux-style config
            self.zellij_keybinds = [
                {'key': 'Ctrl + A', 'action': 'Enter Command Mode', 'category': 'Mode'},
                {'key': 'Ctrl + A, C', 'action': 'New Tab', 'category': 'Tabs'},
                {'key': 'Ctrl + A, &', 'action': 'Close Tab', 'category': 'Tabs'},
                {'key': 'Ctrl + A, 1-9', 'action': 'Go to Tab N', 'category': 'Tabs'},
                {'key': 'Ctrl + A, %', 'action': 'Split Right', 'category': 'Panes'},
                {'key': 'Ctrl + A, "', 'action': 'Split Down', 'category': 'Panes'},
                {'key': 'Ctrl + A, X', 'action': 'Close Pane', 'category': 'Panes'},
                {'key': 'Ctrl + A, H/J/K/L', 'action': 'Navigate Panes', 'category': 'Panes'},
                {'key': 'Ctrl + A, D', 'action': 'Detach Session', 'category': 'Session'},
                {'key': 'Ctrl + A, [', 'action': 'Scroll Mode', 'category': 'Scrolling'},
            ]
        except Exception as e:
            print(f"Error loading Zellij keybinds: {e}")
    
    def load_neovim_lsp_keybinds(self):
        """Load Neovim LSP keybindings from configuration"""
        try:
            # Note: <leader> is typically mapped to Space in modern Neovim configs
            self.neovim_lsp_keybinds = [
                # Navigation keybinds
                {'key': 'gd', 'action': 'Go to Definition', 'category': 'Navigation'},
                {'key': 'gr', 'action': 'Go to References', 'category': 'Navigation'},
                {'key': 'gI', 'action': 'Go to Implementation', 'category': 'Navigation'},
                {'key': 'gy', 'action': 'Go to Type Definition', 'category': 'Navigation'},
                {'key': 'gD', 'action': 'Go to Declaration', 'category': 'Navigation'},
                
                # Documentation
                {'key': 'K', 'action': 'Hover Documentation', 'category': 'Documentation'},
                {'key': 'gK', 'action': 'Signature Help', 'category': 'Documentation'},
                
                # Code actions
                {'key': '<leader>ca', 'action': 'Code Action', 'category': 'Code Actions'},
                {'key': '<leader>rn', 'action': 'Rename Symbol', 'category': 'Code Actions'},
                {'key': '<leader>f', 'action': 'Format Document', 'category': 'Code Actions'},
                
                # Diagnostics
                {'key': '<leader>d', 'action': 'Show Diagnostic', 'category': 'Diagnostics'},
                {'key': '[d', 'action': 'Previous Diagnostic', 'category': 'Diagnostics'},
                {'key': ']d', 'action': 'Next Diagnostic', 'category': 'Diagnostics'},
                {'key': '<leader>dl', 'action': 'Diagnostic Location List', 'category': 'Diagnostics'},
                {'key': '<leader>dw', 'action': 'Diagnostic Workspace', 'category': 'Diagnostics'},
                {'key': '<leader>dd', 'action': 'Toggle Diagnostics', 'category': 'Diagnostics'},
                
                # Workspace management
                {'key': '<leader>wa', 'action': 'Add Workspace Folder', 'category': 'Workspace'},
                {'key': '<leader>wr', 'action': 'Remove Workspace Folder', 'category': 'Workspace'},
                {'key': '<leader>wl', 'action': 'List Workspace Folders', 'category': 'Workspace'},
                
                # Advanced features (FZF)
                {'key': '<leader>lr', 'action': 'Find References (FZF)', 'category': 'Advanced'},
                {'key': '<leader>ld', 'action': 'Find Definitions (FZF)', 'category': 'Advanced'},
                {'key': '<leader>li', 'action': 'Find Implementations (FZF)', 'category': 'Advanced'},
                {'key': '<leader>lt', 'action': 'Find Type Definitions (FZF)', 'category': 'Advanced'},
                {'key': '<leader>ls', 'action': 'Document Symbols (FZF)', 'category': 'Advanced'},
                {'key': '<leader>lS', 'action': 'Workspace Symbols (FZF)', 'category': 'Advanced'},
                {'key': '<leader>lc', 'action': 'Code Actions (FZF)', 'category': 'Advanced'},
                {'key': '<leader>lD', 'action': 'Workspace Diagnostics (FZF)', 'category': 'Advanced'},
                
                # Toggle features
                {'key': '<leader>th', 'action': 'Toggle Inlay Hints', 'category': 'Toggle'},
                {'key': '<leader>thl', 'action': 'Toggle Document Highlight', 'category': 'Toggle'},
                
                # C#-specific keybinds (OmniSharp)
                {'key': '<leader>cb', 'action': 'Build Project', 'category': 'C# Development'},
                {'key': '<leader>cr', 'action': 'Run Project', 'category': 'C# Development'},
                {'key': '<leader>ct', 'action': 'Test Project', 'category': 'C# Development'},
                {'key': '<leader>cT', 'action': 'Test with Coverage', 'category': 'C# Development'},
                {'key': '<leader>cR', 'action': 'Restore Packages', 'category': 'C# Development'},
                {'key': '<leader>cC', 'action': 'Clean Project', 'category': 'C# Development'},
                {'key': '<leader>cp', 'action': 'Add Package', 'category': 'C# Development'},
                {'key': '<leader>cP', 'action': 'Remove Package', 'category': 'C# Development'},
                {'key': '<leader>cn', 'action': 'Create New Class', 'category': 'C# Development'},
                {'key': '<leader>cf', 'action': 'Format Document', 'category': 'C# Development'},
                {'key': '<leader>cA', 'action': 'Go to Alternate File (Test/Implementation)', 'category': 'C# Development'},
                {'key': '<leader>ci', 'action': 'Show Project Info', 'category': 'C# Development'},
                {'key': '<leader>cD', 'action': 'Decompile', 'category': 'C# Development'},
                {'key': '<leader>cu', 'action': 'Organize Imports', 'category': 'C# Development'},
                
                # TypeScript/JavaScript-specific keybinds (ts_ls)
                {'key': '<leader>to', 'action': 'Organize Imports', 'category': 'TypeScript/JavaScript'},
                {'key': '<leader>tu', 'action': 'Remove Unused Imports', 'category': 'TypeScript/JavaScript'},
                {'key': '<leader>ta', 'action': 'Add Missing Imports', 'category': 'TypeScript/JavaScript'},
                {'key': '<leader>tf', 'action': 'Fix All Issues', 'category': 'TypeScript/JavaScript'},
                {'key': 'gS', 'action': 'Go to Source Definition', 'category': 'TypeScript/JavaScript'},
                {'key': '<leader>tr', 'action': 'Restart TypeScript Server', 'category': 'TypeScript/JavaScript'},
                
                # Angular-specific keybinds (angularls)
                {'key': '<leader>ac', 'action': 'Go to Component', 'category': 'Angular Development'},
                {'key': '<leader>at', 'action': 'Go to Template', 'category': 'Angular Development'},
                {'key': '<leader>as', 'action': 'Go to Style', 'category': 'Angular Development'},
                {'key': '<leader>ae', 'action': 'Extract Component', 'category': 'Angular Development'},
                {'key': '<leader>av', 'action': 'Show Angular Version', 'category': 'Angular Development'},
                {'key': '<leader>ar', 'action': 'Restart Angular Server', 'category': 'Angular Development'},
                
                # Go-specific keybinds (gopls)
                {'key': '<leader>gi', 'action': 'Organize Imports', 'category': 'Go Development'},
                {'key': '<leader>gt', 'action': 'Go Mod Tidy', 'category': 'Go Development'},
                {'key': '<leader>gT', 'action': 'Generate Tests', 'category': 'Go Development'},
                {'key': '<leader>gr', 'action': 'Run Tests', 'category': 'Go Development'},
                {'key': '<leader>gR', 'action': 'Run Test Function', 'category': 'Go Development'},
                {'key': '<leader>gf', 'action': 'Fill Struct', 'category': 'Go Development'},
                {'key': '<leader>ga', 'action': 'Add Struct Tags', 'category': 'Go Development'},
                {'key': '<leader>gA', 'action': 'Go to Alternate File (Test/Implementation)', 'category': 'Go Development'},
                {'key': '<leader>gb', 'action': 'Run Benchmarks', 'category': 'Go Development'},
                {'key': '<leader>gv', 'action': 'Vulnerability Check', 'category': 'Go Development'},
                {'key': '<leader>gc', 'action': 'Regenerate CGO', 'category': 'Go Development'},
                
                # Elixir-specific keybinds (elixirls)
                {'key': '<leader>et', 'action': 'Run Tests', 'category': 'Elixir Development'},
                {'key': '<leader>eT', 'action': 'Run Test Under Cursor', 'category': 'Elixir Development'},
                {'key': '<leader>ep', 'action': 'Convert to Pipe', 'category': 'Elixir Development'},
                {'key': '<leader>eP', 'action': 'Convert from Pipe', 'category': 'Elixir Development'},
                {'key': '<leader>em', 'action': 'Expand Macro', 'category': 'Elixir Development'},
                {'key': '<leader>ef', 'action': 'Format with Mix', 'category': 'Elixir Development'},
                {'key': '<leader>er', 'action': 'Restart ElixirLS', 'category': 'Elixir Development'},
                {'key': '<leader>ed', 'action': 'Show Documentation', 'category': 'Elixir Development'},
                {'key': '<leader>ei', 'action': 'Open IEx', 'category': 'Elixir Development'},
                
                # Kotlin-specific keybinds (kotlin_language_server)
                {'key': '<leader>kb', 'action': 'Build Project', 'category': 'Kotlin Development'},
                {'key': '<leader>kr', 'action': 'Run Project', 'category': 'Kotlin Development'},
                {'key': '<leader>kt', 'action': 'Run Tests', 'category': 'Kotlin Development'},
                {'key': '<leader>kT', 'action': 'Run Current Test Class', 'category': 'Kotlin Development'},
                {'key': '<leader>kj', 'action': 'Build JVM Target', 'category': 'Kotlin Multiplatform'},
                {'key': '<leader>kn', 'action': 'Build Native Target', 'category': 'Kotlin Multiplatform'},
                {'key': '<leader>ks', 'action': 'Build JS Target', 'category': 'Kotlin Multiplatform'},
                {'key': '<leader>ka', 'action': 'Build Android Target', 'category': 'Kotlin Multiplatform'},
                {'key': '<leader>kg', 'action': 'Generate Data Class', 'category': 'Kotlin Development'},
                {'key': '<leader>kc', 'action': 'Generate Constructor', 'category': 'Kotlin Development'},
                {'key': '<leader>ke', 'action': 'Generate Equals/HashCode', 'category': 'Kotlin Development'},
                {'key': '<leader>ki', 'action': 'Organize Imports', 'category': 'Kotlin Development'},
                {'key': '<leader>kf', 'action': 'Extract Function', 'category': 'Kotlin Development'},
                {'key': '<leader>kv', 'action': 'Extract Variable', 'category': 'Kotlin Development'},
                {'key': '<leader>kd', 'action': 'Generate KDoc', 'category': 'Kotlin Development'},
                
                # Clojure-specific keybinds (Conjure REPL - j for "jack-in")
                {'key': '<leader>jj', 'action': 'Jack-in to REPL', 'category': 'Clojure REPL'},
                {'key': '<leader>jJ', 'action': 'Select REPL (Shadow CLJS)', 'category': 'Clojure REPL'},
                {'key': '<leader>jc', 'action': 'Connect to port', 'category': 'Clojure REPL'},
                {'key': '<leader>jp', 'action': 'Connect to host/port', 'category': 'Clojure REPL'},
                {'key': '<leader>jd', 'action': 'Disconnect from REPL', 'category': 'Clojure REPL'},
                {'key': '<leader>jq', 'action': 'Close session', 'category': 'Clojure REPL'},
                {'key': '<leader>jQ', 'action': 'Close all sessions', 'category': 'Clojure REPL'},
                {'key': '<leader>jl', 'action': 'List sessions', 'category': 'Clojure REPL'},
                {'key': '<leader>js', 'action': 'Assume session', 'category': 'Clojure REPL'},
                {'key': '<leader>jS', 'action': 'Assume session (prompt)', 'category': 'Clojure REPL'},
                {'key': '<leader>jR', 'action': 'Refresh all changed namespaces', 'category': 'Clojure REPL'},
                {'key': '<leader>jr', 'action': 'Refresh current namespace', 'category': 'Clojure REPL'},
                
                # Clojure evaluation keybinds
                {'key': '<leader>ee', 'action': 'Evaluate current form', 'category': 'Clojure Evaluation'},
                {'key': '<leader>ee (visual)', 'action': 'Evaluate selection', 'category': 'Clojure Evaluation'},
                {'key': '<leader>er', 'action': 'Evaluate root form', 'category': 'Clojure Evaluation'},
                {'key': '<leader>ew', 'action': 'Evaluate word under cursor', 'category': 'Clojure Evaluation'},
                {'key': '<leader>eb', 'action': 'Evaluate buffer', 'category': 'Clojure Evaluation'},
                {'key': '<leader>ef', 'action': 'Evaluate file from disk', 'category': 'Clojure Evaluation'},
                {'key': '<leader>em', 'action': 'Evaluate form at mark', 'category': 'Clojure Evaluation'},
                {'key': '<leader>e!', 'action': 'Evaluate and replace form', 'category': 'Clojure Evaluation'},
                
                # Clojure development keybinds
                {'key': '<leader>cd', 'action': 'Show documentation', 'category': 'Clojure Development'},
                {'key': 'K', 'action': 'Show documentation (hover)', 'category': 'Clojure Development'},
                {'key': '<leader>gd', 'action': 'Go to definition', 'category': 'Clojure Development'},
                {'key': 'gd', 'action': 'Go to definition (direct)', 'category': 'Clojure Development'},
                {'key': '<leader>vs', 'action': 'View source', 'category': 'Clojure Development'},
                
                # Clojure testing keybinds
                {'key': '<leader>tt', 'action': 'Run test under cursor', 'category': 'Clojure Testing'},
                {'key': '<leader>tT', 'action': 'Run all tests in namespace', 'category': 'Clojure Testing'},
                {'key': '<leader>ta', 'action': 'Run all loaded tests', 'category': 'Clojure Testing'},
                {'key': '<leader>tr', 'action': 'Rerun last test', 'category': 'Clojure Testing'},
                
                # Clojure log management
                {'key': '<leader>lg', 'action': 'Go to log buffer', 'category': 'Clojure Log'},
                {'key': '<leader>ls', 'action': 'Show/hide log', 'category': 'Clojure Log'},
                {'key': '<leader>lr', 'action': 'Reset log (clear)', 'category': 'Clojure Log'},
                {'key': '<leader>lv', 'action': 'Toggle log', 'category': 'Clojure Log'},
                {'key': '<leader>lt', 'action': 'Toggle log HUD', 'category': 'Clojure Log'},
            ]
        except Exception as e:
            print(f"Error loading Neovim LSP keybinds: {e}")
    
    def categorize_hyprland_action(self, action):
        """Categorize Hyprland actions for better organization"""
        action_lower = action.lower()
        if any(app in action_lower for app in ['exec', 'alacritty', 'rofi', 'firefox']):
            return 'Applications'
        elif any(word in action_lower for word in ['kill', 'close', 'fullscreen', 'float']):
            return 'Window Management'
        elif any(word in action_lower for word in ['workspace', 'move']):
            return 'Workspaces'
        elif any(word in action_lower for word in ['volume', 'brightness']):
            return 'System'
        else:
            return 'General'
    
    def create_css_provider(self):
        """Create CSS styling with Catppuccin Macchiato colors"""
        # Build CSS string with proper formatting
        css = """
        .keybind-window {
            background-color: """ + CATPPUCCIN_MACCHIATO['base'] + """;
            border: 2px solid """ + CATPPUCCIN_MACCHIATO['surface1'] + """;
            border-radius: 12px;
        }
        
        .title-label {
            color: """ + CATPPUCCIN_MACCHIATO['text'] + """;
            font-size: 24px;
            font-weight: bold;
            margin: 16px;
        }
        
        .nav-help-label {
            color: """ + CATPPUCCIN_MACCHIATO['subtext1'] + """;
            font-size: 12px;
            font-weight: normal;
            margin: 0 16px 8px 16px;
        }
        
        .category-label {
            color: """ + CATPPUCCIN_MACCHIATO['mauve'] + """;
            font-size: 18px;
            font-weight: bold;
            margin: 12px 0 8px 0;
        }
        
        .keybind-row {
            background-color: """ + CATPPUCCIN_MACCHIATO['surface0'] + """;
            border-radius: 8px;
            margin: 4px;
            padding: 8px 12px;
            border: 1px solid """ + CATPPUCCIN_MACCHIATO['surface1'] + """;
            min-height: 40px;
        }
        
        .keybind-row:hover {
            background-color: """ + CATPPUCCIN_MACCHIATO['surface1'] + """;
            border-color: """ + CATPPUCCIN_MACCHIATO['mauve'] + """;
        }
        
        .key-label {
            color: """ + CATPPUCCIN_MACCHIATO['peach'] + """;
            font-family: 'JetBrains Mono', monospace;
            font-weight: bold;
            font-size: 14px;
        }
        
        .action-label {
            color: """ + CATPPUCCIN_MACCHIATO['text'] + """;
            font-size: 14px;
        }
        
        .notebook {
            background-color: """ + CATPPUCCIN_MACCHIATO['base'] + """;
        }
        
        .notebook tab {
            background-color: """ + CATPPUCCIN_MACCHIATO['surface0'] + """;
            color: """ + CATPPUCCIN_MACCHIATO['subtext1'] + """;
            border-radius: 8px 8px 0 0;
            margin-right: 4px;
            padding: 12px 20px;
        }
        
        .notebook tab:checked {
            background-color: """ + CATPPUCCIN_MACCHIATO['surface1'] + """;
            color: """ + CATPPUCCIN_MACCHIATO['text'] + """;
            border-bottom: 3px solid """ + CATPPUCCIN_MACCHIATO['mauve'] + """;
        }
        
        .scrolled-window {
            background-color: transparent;
            min-width: 600px;
        }
        """
        
        css_provider = Gtk.CssProvider()
        css_provider.load_from_string(css)
        return css_provider
    
    def create_keybind_section(self, keybinds, show_leader_note=False):
        """Create a section showing keybindings grouped by category"""
        # Group keybindings by category
        categories = {}
        for keybind in keybinds:
            category = keybind['category']
            if category not in categories:
                categories[category] = []
            categories[category].append(keybind)
        
        # Create scrolled window
        scrolled = Gtk.ScrolledWindow()
        scrolled.set_css_classes(['scrolled-window'])
        scrolled.set_policy(Gtk.PolicyType.AUTOMATIC, Gtk.PolicyType.AUTOMATIC)
        scrolled.set_vexpand(True)
        scrolled.set_min_content_width(600)
        scrolled.set_min_content_height(400)
        scrolled.set_propagate_natural_width(True)
        
        # Main container
        main_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12)
        main_box.set_margin_top(16)
        main_box.set_margin_bottom(16)
        main_box.set_margin_start(20)
        main_box.set_margin_end(20)
        main_box.set_hexpand(True)
        
        # Add leader key explanation if requested
        if show_leader_note:
            leader_note = Gtk.Label(label="Note: <leader> is mapped to Space in this Neovim configuration")
            leader_note.set_css_classes(['action-label'])
            leader_note.set_xalign(0)
            leader_note.set_wrap(True)
            leader_note.set_wrap_mode(Pango.WrapMode.WORD)
            leader_note.set_margin_bottom(16)
            main_box.append(leader_note)
        
        # Add categories
        for category, category_keybinds in sorted(categories.items()):
            # Category label
            category_label = Gtk.Label(label=category)
            category_label.set_css_classes(['category-label'])
            category_label.set_xalign(0)
            main_box.append(category_label)
            
            # Keybindings for this category
            for keybind in category_keybinds:
                row_box = Gtk.Box(orientation=Gtk.Orientation.HORIZONTAL, spacing=16)
                row_box.set_css_classes(['keybind-row'])
                
                # Key combination - fixed width with wrapping
                key_label = Gtk.Label(label=keybind['key'])
                key_label.set_css_classes(['key-label'])
                key_label.set_size_request(180, -1)  # Slightly smaller to leave more room
                key_label.set_xalign(0)
                key_label.set_valign(Gtk.Align.START)
                key_label.set_wrap(True)
                key_label.set_wrap_mode(Pango.WrapMode.WORD_CHAR)
                key_label.set_max_width_chars(25)
                key_label.set_ellipsize(Pango.EllipsizeMode.END)
                
                # Action description - expandable with wrapping
                action_label = Gtk.Label(label=keybind['action'])
                action_label.set_css_classes(['action-label'])
                action_label.set_xalign(0)
                action_label.set_valign(Gtk.Align.START)
                action_label.set_hexpand(True)
                action_label.set_wrap(True)
                action_label.set_wrap_mode(Pango.WrapMode.WORD)
                action_label.set_max_width_chars(50)
                action_label.set_ellipsize(Pango.EllipsizeMode.END)
                action_label.set_justify(Gtk.Justification.LEFT)
                action_label.set_lines(3)  # Limit to 3 lines maximum
                
                # Add tooltips for full text on hover
                key_label.set_tooltip_text(keybind['key'])
                action_label.set_tooltip_text(keybind['action'])
                
                row_box.append(key_label)
                row_box.append(action_label)
                main_box.append(row_box)
        
        scrolled.set_child(main_box)
        return scrolled
    
    def on_activate(self, app):
        # Apply CSS styling
        css_provider = self.create_css_provider()
        
        # Create main window
        self.window = Adw.ApplicationWindow(application=app)
        self.window.set_title("Keybinding Reference - Hyprland, Zellij & Neovim LSP")
        self.window.set_css_classes(['keybind-window'])
        self.window.set_default_size(800, 750)
        
        # Make window focusable for keyboard navigation
        self.window.set_can_focus(True)
        
        # Set window class for Hyprland window rules
        GLib.set_prgname('keybind-reference')
        if hasattr(self.window, 'set_wmclass'):
            self.window.set_wmclass('keybind-reference', 'keybind-reference')
        
        # Create header bar
        header = Adw.HeaderBar()
        
        # Title with navigation help
        title_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=4)
        title_label = Gtk.Label(label="Keybinding Reference")
        title_label.set_css_classes(['title-label'])
        
        nav_help = Gtk.Label(label="Nav: j/k(scroll) • d/u(half-page) • g/G(top/bottom) • H/L(tabs) • 1-3(direct tab) • q/Esc(quit)")
        nav_help.set_css_classes(['nav-help-label'])
        nav_help.set_wrap(True)
        nav_help.set_wrap_mode(Pango.WrapMode.WORD)
        nav_help.set_max_width_chars(80)
        
        title_box.append(title_label)
        title_box.append(nav_help)
        
        header.set_title_widget(title_box)
        
        # Create notebook for tabs
        self.notebook = Gtk.Notebook()
        self.notebook.set_css_classes(['notebook'])
        
        # Store scrolled windows for each tab for navigation
        self.scrolled_windows = []
        
        # Hyprland tab
        hyprland_page = self.create_keybind_section(self.hyprland_keybinds)
        hyprland_label = Gtk.Label(label="Hyprland")
        self.notebook.append_page(hyprland_page, hyprland_label)
        self.scrolled_windows.append(hyprland_page)
        
        # Zellij tab
        zellij_page = self.create_keybind_section(self.zellij_keybinds)
        zellij_label = Gtk.Label(label="Zellij")
        self.notebook.append_page(zellij_page, zellij_label)
        self.scrolled_windows.append(zellij_page)
        
        # Neovim LSP tab
        neovim_lsp_page = self.create_keybind_section(self.neovim_lsp_keybinds, show_leader_note=True)
        neovim_lsp_label = Gtk.Label(label="Neovim LSP")
        self.notebook.append_page(neovim_lsp_page, neovim_lsp_label)
        self.scrolled_windows.append(neovim_lsp_page)
        
        # Main container
        main_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        main_box.append(header)
        main_box.append(self.notebook)
        
        self.window.set_content(main_box)
        
        # Apply CSS styling after window creation
        display = self.window.get_display()
        Gtk.StyleContext.add_provider_for_display(
            display,
            css_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )
        
        self.window.present()
        
        # Setup keyboard navigation
        self.setup_keyboard_navigation()
    
    def setup_keyboard_navigation(self):
        """Setup vim-style keyboard navigation"""
        controller = Gtk.EventControllerKey()
        controller.connect('key-pressed', self.on_key_pressed)
        self.window.add_controller(controller)
    
    def on_key_pressed(self, controller, keyval, keycode, state):
        """Handle keyboard navigation with vim-style motions"""
        # Get the currently active scrolled window
        current_page = self.notebook.get_current_page()
        if current_page >= 0 and current_page < len(self.scrolled_windows):
            current_scrolled = self.scrolled_windows[current_page]
            vadjustment = current_scrolled.get_vadjustment()
            hadjustment = current_scrolled.get_hadjustment()
        
        # Escape key - close window
        if keyval == 65307:  # Escape key
            self.window.close()
            return True
        
        # Q key - quit (vim-style)
        elif keyval == 113:  # 'q' key
            self.window.close()
            return True
        
        # Tab navigation: H/L for previous/next tab
        elif keyval == 72:  # 'H' key (Shift+h)
            current_page = self.notebook.get_current_page()
            if current_page > 0:
                self.notebook.set_current_page(current_page - 1)
            return True
        
        elif keyval == 76:  # 'L' key (Shift+l)
            current_page = self.notebook.get_current_page()
            total_pages = self.notebook.get_n_pages()
            if current_page < total_pages - 1:
                self.notebook.set_current_page(current_page + 1)
            return True
        
        # Vim-style scrolling navigation
        elif keyval == 106:  # 'j' key - scroll down
            if current_page >= 0 and vadjustment:
                current_value = vadjustment.get_value()
                step = vadjustment.get_step_increment() * 3  # Scroll 3 lines at a time
                new_value = min(current_value + step, vadjustment.get_upper() - vadjustment.get_page_size())
                vadjustment.set_value(new_value)
            return True
        
        elif keyval == 107:  # 'k' key - scroll up
            if current_page >= 0 and vadjustment:
                current_value = vadjustment.get_value()
                step = vadjustment.get_step_increment() * 3  # Scroll 3 lines at a time
                new_value = max(current_value - step, vadjustment.get_lower())
                vadjustment.set_value(new_value)
            return True
        
        # Page-wise navigation
        elif keyval == 100:  # 'd' key - half page down (like Ctrl+D in vim)
            if current_page >= 0 and vadjustment:
                current_value = vadjustment.get_value()
                half_page = vadjustment.get_page_size() / 2
                new_value = min(current_value + half_page, vadjustment.get_upper() - vadjustment.get_page_size())
                vadjustment.set_value(new_value)
            return True
        
        elif keyval == 117:  # 'u' key - half page up (like Ctrl+U in vim)
            if current_page >= 0 and vadjustment:
                current_value = vadjustment.get_value()
                half_page = vadjustment.get_page_size() / 2
                new_value = max(current_value - half_page, vadjustment.get_lower())
                vadjustment.set_value(new_value)
            return True
        
        # Jump to beginning/end
        elif keyval == 103:  # 'g' key - go to top (like gg in vim)
            if current_page >= 0 and vadjustment:
                vadjustment.set_value(vadjustment.get_lower())
            return True
        
        elif keyval == 71:  # 'G' key (Shift+g) - go to bottom
            if current_page >= 0 and vadjustment:
                vadjustment.set_value(vadjustment.get_upper() - vadjustment.get_page_size())
            return True
        
        # Horizontal scrolling (for wide content)
        elif keyval == 104:  # 'h' key - scroll left
            if current_page >= 0 and hadjustment:
                current_value = hadjustment.get_value()
                step = hadjustment.get_step_increment() * 2
                new_value = max(current_value - step, hadjustment.get_lower())
                hadjustment.set_value(new_value)
            return True
        
        elif keyval == 108:  # 'l' key - scroll right
            if current_page >= 0 and hadjustment:
                current_value = hadjustment.get_value()
                step = hadjustment.get_step_increment() * 2
                new_value = min(current_value + step, hadjustment.get_upper() - hadjustment.get_page_size())
                hadjustment.set_value(new_value)
            return True
        
        # Number keys for direct tab navigation
        elif keyval >= 49 and keyval <= 57:  # '1' to '9' keys
            tab_index = keyval - 49  # Convert to 0-based index
            total_pages = self.notebook.get_n_pages()
            if tab_index < total_pages:
                self.notebook.set_current_page(tab_index)
            return True
        
        return False
    
    def run(self):
        return self.app.run(sys.argv)

if __name__ == '__main__':
    app = KeybindingReference()
    app.run()

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
from gi.repository import Gtk, Adw, GLib, Gio

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
        
        # Load keybindings
        self.load_hyprland_keybinds()
        self.load_zellij_keybinds()
    
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
        css = f"""
        .keybind-window {{
            background-color: {CATPPUCCIN_MACCHIATO['base']};
            border: 2px solid {CATPPUCCIN_MACCHIATO['surface1']};
            border-radius: 12px;
        }}
        
        .title-label {{
            color: {CATPPUCCIN_MACCHIATO['text']};
            font-size: 24px;
            font-weight: bold;
            margin: 16px;
        }}
        
        .category-label {{
            color: {CATPPUCCIN_MACCHIATO['mauve']};
            font-size: 18px;
            font-weight: bold;
            margin: 12px 0 8px 0;
        }}
        
        .keybind-row {{
            background-color: {CATPPUCCIN_MACCHIATO['surface0']};
            border-radius: 8px;
            margin: 4px;
            padding: 8px 12px;
            border: 1px solid {CATPPUCCIN_MACCHIATO['surface1']};
        }}
        
        .keybind-row:hover {{
            background-color: {CATPPUCCIN_MACCHIATO['surface1']};
            border-color: {CATPPUCCIN_MACCHIATO['mauve']};
        }}
        
        .key-label {{
            color: {CATPPUCCIN_MACCHIATO['peach']};
            font-family: 'JetBrains Mono', monospace;
            font-weight: bold;
            font-size: 14px;
        }}
        
        .action-label {{
            color: {CATPPUCCIN_MACCHIATO['text']};
            font-size: 14px;
        }}
        
        .notebook {{
            background-color: {CATPPUCCIN_MACCHIATO['base']};
        }}
        
        .notebook tab {{
            background-color: {CATPPUCCIN_MACCHIATO['surface0']};
            color: {CATPPUCCIN_MACCHIATO['subtext1']};
            border-radius: 8px 8px 0 0;
            margin-right: 4px;
            padding: 12px 20px;
        }}
        
        .notebook tab:checked {{
            background-color: {CATPPUCCIN_MACCHIATO['surface1']};
            color: {CATPPUCCIN_MACCHIATO['text']};
            border-bottom: 3px solid {CATPPUCCIN_MACCHIATO['mauve']};
        }}
        
        .scrolled-window {{
            background-color: transparent;
        }}
        """
        
        css_provider = Gtk.CssProvider()
        css_provider.load_from_string(css)
        return css_provider
    
    def create_keybind_section(self, keybinds):
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
        scrolled.set_policy(Gtk.PolicyType.NEVER, Gtk.PolicyType.AUTOMATIC)
        scrolled.set_vexpand(True)
        
        # Main container
        main_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=12)
        main_box.set_margin_top(16)
        main_box.set_margin_bottom(16)
        main_box.set_margin_start(20)
        main_box.set_margin_end(20)
        
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
                
                # Key combination
                key_label = Gtk.Label(label=keybind['key'])
                key_label.set_css_classes(['key-label'])
                key_label.set_size_request(200, -1)
                key_label.set_xalign(0)
                
                # Action description
                action_label = Gtk.Label(label=keybind['action'])
                action_label.set_css_classes(['action-label'])
                action_label.set_xalign(0)
                action_label.set_hexpand(True)
                
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
        self.window.set_title("Keybinding Reference")
        self.window.set_css_classes(['keybind-window'])
        self.window.set_default_size(600, 700)
        
        # Set window class for Hyprland window rules
        GLib.set_prgname('keybind-reference')
        if hasattr(self.window, 'set_wmclass'):
            self.window.set_wmclass('keybind-reference', 'keybind-reference')
        
        # Create header bar
        header = Adw.HeaderBar()
        header.set_title_widget(Gtk.Label(label="Keybinding Reference"))
        header.get_title_widget().set_css_classes(['title-label'])
        
        # Create notebook for tabs
        notebook = Gtk.Notebook()
        notebook.set_css_classes(['notebook'])
        
        # Hyprland tab
        hyprland_page = self.create_keybind_section(self.hyprland_keybinds)
        hyprland_label = Gtk.Label(label="Hyprland")
        notebook.append_page(hyprland_page, hyprland_label)
        
        # Zellij tab
        zellij_page = self.create_keybind_section(self.zellij_keybinds)
        zellij_label = Gtk.Label(label="Zellij")
        notebook.append_page(zellij_page, zellij_label)
        
        # Main container
        main_box = Gtk.Box(orientation=Gtk.Orientation.VERTICAL)
        main_box.append(header)
        main_box.append(notebook)
        
        self.window.set_content(main_box)
        
        # Apply CSS styling after window creation
        display = self.window.get_display()
        Gtk.StyleContext.add_provider_for_display(
            display,
            css_provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
        )
        
        self.window.present()
        
        # Close on Escape key
        controller = Gtk.EventControllerKey()
        controller.connect('key-pressed', self.on_key_pressed)
        self.window.add_controller(controller)
    
    def on_key_pressed(self, controller, keyval, keycode, state):
        if keyval == 65307:  # Escape key
            self.window.close()
            return True
        return False
    
    def run(self):
        return self.app.run(sys.argv)

if __name__ == '__main__':
    app = KeybindingReference()
    app.run()

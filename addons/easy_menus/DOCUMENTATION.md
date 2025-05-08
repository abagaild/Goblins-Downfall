# Easy Menus Plugin Documentation

## Overview

The Easy Menus plugin simplifies the creation of responsive menus for Godot games. It provides a set of tools and components to create menus that look good and function well on all screen sizes.

## Core Components

### MenuManager (Autoload)

The MenuManager is an autoload singleton that centralizes menu control. It keeps track of all registered menus and provides methods to open, close, and toggle them.

#### Methods

- `register_menu(menu_name, menu_instance)`: Register a menu with the manager
- `unregister_menu(menu_name)`: Unregister a menu
- `open_menu(menu_name)`: Open a menu by name
- `close_menu(menu_name)`: Close a menu by name
- `toggle_menu(menu_name)`: Toggle a menu by name
- `get_menu(menu_name)`: Get a registered menu by name
- `is_menu_open(menu_name)`: Check if a menu is currently open
- `push_menu(menu_name)`: Push a menu onto the stack
- `pop_menu()`: Pop the top menu from the stack and close it
- `get_top_menu()`: Get the current top menu on the stack
- `clear_menu_stack()`: Clear the entire menu stack, closing all menus

#### Signals

- `menu_opened(menu_name)`: Emitted when a menu is opened
- `menu_closed(menu_name)`: Emitted when a menu is closed
- `menu_stack_changed`: Emitted when the menu stack changes

### EasyMenu (Base Class)

EasyMenu is a base class for all menus. It provides common functionality like opening, closing, and toggling the menu.

#### Properties

- `menu_name`: The name of the menu (used for registration with MenuManager)
- `register_with_manager`: Whether to automatically register with MenuManager
- `use_theme_manager`: Whether to use ThemeManager for theming
- `auto_center`: Whether to automatically center the menu
- `custom_breakpoints`: Custom breakpoints for this menu

##### Size Constraints
- `use_size_constraints`: Whether to use size constraints
- `min_size`: Minimum size of the menu
- `max_size`: Maximum size of the menu
- `default_size`: Default size of the menu
- `scale_with_screen`: Whether to scale the menu size with the screen size
- `screen_size_percentage`: Percentage of screen size to use (0.0-1.0)
- `floating_responsiveness`: Whether to maintain the menu's relative position and edge distances when resizing

##### Text Scaling
- `responsive_text`: Whether to scale text based on menu size
- `max_font_size`: Maximum font size for scaled text

##### Layout Sizes
- `small_layout_size`: Size for small layout
- `default_layout_size`: Size for default layout
- `large_layout_size`: Size for large layout

#### Methods

- `open()`: Open the menu
- `close()`: Close the menu
- `toggle()`: Toggle the menu
- `is_open()`: Check if the menu is open
- `set_layout_size(layout_name)`: Set the menu to a specific layout size (small, default, large)
- `_apply_size_constraints()`: Apply size constraints based on viewport size
- `_scale_text_elements()`: Scale all text elements based on the current size

#### Signals

- `opened`: Emitted when the menu is opened
- `closed`: Emitted when the menu is closed
- `menu_resized`: Emitted when the menu is resized

### EasyButton (Button Extension)

EasyButton extends the Button class to add built-in actions like changing scenes, opening URLs, and toggling menus.

### EasyLabel (Label Extension)

EasyLabel extends the Label class to add responsive text scaling based on container size.

#### Properties

- `responsive_text`: Whether to scale text based on container size
- `max_font_size`: Maximum font size for scaled text
- `min_font_size`: Minimum font size for scaled text
- `reference_width`: Reference width for scaling calculations
- `reference_font_size`: Reference font size for scaling calculations

#### Methods

- `_scale_font_size()`: Scale the font size based on the current size
- `reset_font_size()`: Reset to the original font size

#### Properties

- `action_type`: The type of action to perform when the button is pressed
- `target`: The target of the action (e.g., scene path, URL, menu name)
- `custom_signal`: The name of a custom signal to emit
- `transition_effect`: Whether to use a transition effect
- `transition_time`: The duration of the transition effect

#### Action Types

- `NONE`: No action
- `CHANGE_SCENE`: Change to a different scene
- `OPEN_URL`: Open a URL in the default browser
- `TOGGLE_MENU`: Toggle a menu
- `OPEN_MENU`: Open a menu
- `CLOSE_MENU`: Close a menu
- `QUIT_GAME`: Quit the game
- `CUSTOM`: Emit a custom signal

#### Signals

- `custom_action_triggered`: Emitted when a custom action is triggered

### LayoutManager

LayoutManager handles responsive layouts by swapping containers based on screen size.

#### Properties

- `breakpoints`: Array of breakpoint definitions
- `current_breakpoint`: The currently active breakpoint
- `auto_update`: Whether to automatically update on window resize

#### Methods

- `update_layout()`: Update the layout based on the current viewport size
- `set_breakpoints(new_breakpoints)`: Set custom breakpoints
- `get_current_breakpoint()`: Get the current breakpoint
- `get_current_container()`: Get the container for the current breakpoint

#### Signals

- `layout_changed(breakpoint_name)`: Emitted when the layout changes

### ThemeManager

ThemeManager handles theme loading and application.

#### Methods

- `load_themes()`: Load all theme resources from the themes directory
- `get_theme(theme_name)`: Get a theme by name
- `get_default_theme()`: Get the default theme
- `set_current_theme(theme_name)`: Set the current theme by name
- `get_current_theme()`: Get the current theme
- `get_current_theme_name()`: Get the current theme name
- `apply_theme_to_control(control)`: Apply the current theme to a control
- `get_theme_names()`: Get a list of all available theme names
- `save_theme(theme_name, theme)`: Save a theme to disk

#### Signals

- `theme_changed(theme_name)`: Emitted when the theme changes

### Responsive (Utility)

Responsive is a utility class that provides helper functions for screen size queries.

### TextScaler (Utility)

TextScaler is a utility class that provides functions for scaling text based on container size.

#### Methods

- `scale_label_font_size(label, reference_size, max_font_size)`: Scale a label's font size to maintain its percentage fill
- `scale_button_font_size(button, reference_size, max_font_size)`: Scale a button's font size to maintain its percentage fill
- `scale_container_text(container, reference_size, max_font_size)`: Scale all text elements in a container recursively
- `get_optimal_font_size(text, font, max_width, min_size, max_size)`: Get the optimal font size for a text to fit within a given width
- `maintain_text_ratio(control, original_size, original_font_size, max_font_size)`: Calculate a font size that maintains the same text-to-container ratio

#### Methods

- `get_viewport_size()`: Get the current viewport size
- `is_width_less_than(width)`: Check if the current viewport width is less than or equal to a given width
- `is_height_less_than(height)`: Check if the current viewport height is less than or equal to a given height
- `is_portrait()`: Check if the current viewport is in portrait orientation
- `is_landscape()`: Check if the current viewport is in landscape orientation
- `get_aspect_ratio()`: Get the current aspect ratio (width / height)
- `get_current_breakpoint(breakpoints)`: Find the appropriate breakpoint for the current viewport width
- `scale_value(base_value, base_width)`: Scale a value based on the current viewport size
- `percent_of_width(percent)`: Get a percentage of the viewport width
- `percent_of_height(percent)`: Get a percentage of the viewport height

## Sample Scenes

The plugin includes several sample scenes that you can use as a starting point for your own menus:

- `MainMenu.tscn`: A basic main menu with start, settings, credits, and quit buttons
- `PauseMenu.tscn`: A pause menu with resume, settings, main menu, and quit buttons
- `SettingsMenu.tscn`: A settings menu with video, audio, and controls tabs

## Themes

The plugin includes two default themes:

- `DefaultTheme.tres`: A light theme
- `DarkTheme.tres`: A dark theme

You can create your own themes by duplicating one of these themes and modifying it, or by creating a new theme from scratch.

## Extending the Plugin

### Custom Menu Types

You can create your own menu types by extending EasyMenu:

```gdscript
extends EasyMenu
class_name MyCustomMenu

func _ready():
    super._ready()
    # Custom initialization

func _on_layout_changed(breakpoint_name):
    # Custom layout handling
```

### Custom Button Actions

You can add new button actions by extending EasyButton:

```gdscript
extends EasyButton
class_name MyCustomButton

enum CustomActionType {
    PLAY_SOUND = 100,
    SHOW_ANIMATION = 101
}

func _ready():
    super._ready()
    # Custom initialization

func _on_button_pressed():
    match action_type:
        CustomActionType.PLAY_SOUND:
            _play_sound()
        CustomActionType.SHOW_ANIMATION:
            _show_animation()
        _:
            super._on_button_pressed()

func _play_sound():
    # Play sound implementation

func _show_animation():
    # Show animation implementation
```

## Troubleshooting

### Menu Not Showing

If a menu is not showing when you try to open it:

1. Check that the menu is registered with MenuManager
2. Check that the menu has a unique menu_name
3. Check that the menu is not already open

### Button Action Not Working

If a button action is not working:

1. Check that the action_type is set correctly
2. Check that the target is set correctly (if required)
3. Check that the button is connected to the pressed signal

### Layout Not Updating

If the layout is not updating when the screen size changes:

1. Check that auto_update is set to true
2. Check that the breakpoints are defined correctly
3. Check that the containers are created correctly

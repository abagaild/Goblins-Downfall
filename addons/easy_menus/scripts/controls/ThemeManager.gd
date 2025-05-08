extends Node

# Path to the themes directory
const THEMES_PATH = "res://addons/easy_menus/themes/"

# Dictionary of loaded themes
var _themes = {}

# The currently active theme
var _current_theme_name = "DefaultTheme"

# Signal emitted when the theme changes
signal theme_changed(theme_name)

func _ready():
	# Load all themes in the themes directory
	load_themes()

# Load all theme resources from the themes directory
func load_themes() -> void:
	_themes.clear()
	
	var dir = DirAccess.open(THEMES_PATH)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".tres"):
				var theme_name = file_name.get_basename()
				var theme_path = THEMES_PATH + file_name
				var theme = load(theme_path)
				
				if theme is Theme:
					_themes[theme_name] = theme
				
			file_name = dir.get_next()
	else:
		push_error("ThemeManager: Failed to open themes directory")
	
	# If no themes were loaded, create a default theme
	if _themes.size() == 0:
		var default_theme = Theme.new()
		_themes["DefaultTheme"] = default_theme

# Get a theme by name
func get_theme(theme_name: String) -> Theme:
	if _themes.has(theme_name):
		return _themes[theme_name]
	
	push_warning("ThemeManager: Theme '%s' not found, using default theme" % theme_name)
	return get_default_theme()

# Get the default theme
func get_default_theme() -> Theme:
	if _themes.has("DefaultTheme"):
		return _themes["DefaultTheme"]
	
	# If no default theme exists, return the first available theme
	if _themes.size() > 0:
		var first_key = _themes.keys()[0]
		return _themes[first_key]
	
	# If no themes exist, create a new one
	var default_theme = Theme.new()
	_themes["DefaultTheme"] = default_theme
	return default_theme

# Set the current theme by name
func set_current_theme(theme_name: String) -> void:
	if _themes.has(theme_name):
		_current_theme_name = theme_name
		emit_signal("theme_changed", theme_name)
	else:
		push_warning("ThemeManager: Attempted to set non-existent theme '%s'" % theme_name)

# Get the current theme
func get_current_theme() -> Theme:
	return get_theme(_current_theme_name)

# Get the current theme name
func get_current_theme_name() -> String:
	return _current_theme_name

# Apply the current theme to a control
func apply_theme_to_control(control: Control) -> void:
	control.theme = get_current_theme()

# Get a list of all available theme names
func get_theme_names() -> Array:
	return _themes.keys()

# Save a theme to disk
func save_theme(theme_name: String, theme: Theme) -> bool:
	if theme == null:
		push_error("ThemeManager: Cannot save null theme")
		return false
	
	var save_path = THEMES_PATH + theme_name + ".tres"
	var result = ResourceSaver.save(theme, save_path)
	
	if result == OK:
		_themes[theme_name] = theme
		return true
	else:
		push_error("ThemeManager: Failed to save theme '%s'" % theme_name)
		return false

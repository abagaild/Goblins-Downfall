@tool
extends EditorPlugin

const AUTOLOAD_NAME = "MenuManager"
const AUTOLOAD_PATH = "res://addons/easy_menus/scripts/autoloads/MenuManager.gd"

# Paths to custom classes
const EASY_MENU_SCRIPT = "res://addons/easy_menus/scripts/controls/EasyMenu.gd"
const EASY_BUTTON_SCRIPT = "res://addons/easy_menus/scripts/controls/EasyButton.gd"
const EASY_LABEL_SCRIPT = "res://addons/easy_menus/scripts/controls/EasyLabel.gd"

func _enter_tree():
	# Register autoload
	add_autoload_singleton(AUTOLOAD_NAME, AUTOLOAD_PATH)

	# Add custom types
	add_custom_type("EasyMenu", "Control", load(EASY_MENU_SCRIPT), null)
	add_custom_type("EasyButton", "Button", load(EASY_BUTTON_SCRIPT), null)
	add_custom_type("EasyLabel", "Label", load(EASY_LABEL_SCRIPT), null)

func _exit_tree():
	# Remove autoload
	remove_autoload_singleton(AUTOLOAD_NAME)

	# Remove custom types
	remove_custom_type("EasyMenu")
	remove_custom_type("EasyButton")
	remove_custom_type("EasyLabel")

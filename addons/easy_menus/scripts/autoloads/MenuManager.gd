extends Node

signal menu_opened(menu_name)
signal menu_closed(menu_name)
signal menu_stack_changed

# Dictionary of registered menus
var _menus = {}

# Stack of currently open menus (for pause menus, overlays, etc.)
var _menu_stack = []

# Register a menu with the manager
func register_menu(menu_name: String, menu_instance) -> void:
	if _menus.has(menu_name):
		push_warning("MenuManager: Menu '%s' is already registered. Overwriting." % menu_name)
	
	_menus[menu_name] = menu_instance
	
	# Connect to menu signals if it has them
	if menu_instance.has_signal("opened"):
		menu_instance.opened.connect(_on_menu_opened.bind(menu_name))
	if menu_instance.has_signal("closed"):
		menu_instance.closed.connect(_on_menu_closed.bind(menu_name))

# Unregister a menu
func unregister_menu(menu_name: String) -> void:
	if _menus.has(menu_name):
		var menu = _menus[menu_name]
		
		# Disconnect signals if connected
		if menu.has_signal("opened") and menu.is_connected("opened", _on_menu_opened):
			menu.opened.disconnect(_on_menu_opened)
		if menu.has_signal("closed") and menu.is_connected("closed", _on_menu_closed):
			menu.closed.disconnect(_on_menu_closed)
		
		_menus.erase(menu_name)
	else:
		push_warning("MenuManager: Attempted to unregister non-existent menu '%s'" % menu_name)

# Open a menu by name
func open_menu(menu_name: String) -> bool:
	if not _menus.has(menu_name):
		push_error("MenuManager: Attempted to open non-existent menu '%s'" % menu_name)
		return false
	
	var menu = _menus[menu_name]
	
	# Call the open method if it exists
	if menu.has_method("open"):
		menu.open()
		return true
	else:
		push_error("MenuManager: Menu '%s' does not have an open() method" % menu_name)
		return false

# Close a menu by name
func close_menu(menu_name: String) -> bool:
	if not _menus.has(menu_name):
		push_error("MenuManager: Attempted to close non-existent menu '%s'" % menu_name)
		return false
	
	var menu = _menus[menu_name]
	
	# Call the close method if it exists
	if menu.has_method("close"):
		menu.close()
		return true
	else:
		push_error("MenuManager: Menu '%s' does not have a close() method" % menu_name)
		return false

# Toggle a menu by name
func toggle_menu(menu_name: String) -> bool:
	if not _menus.has(menu_name):
		push_error("MenuManager: Attempted to toggle non-existent menu '%s'" % menu_name)
		return false
	
	var menu = _menus[menu_name]
	
	# Call the toggle method if it exists
	if menu.has_method("toggle"):
		menu.toggle()
		return true
	else:
		push_error("MenuManager: Menu '%s' does not have a toggle() method" % menu_name)
		return false

# Get a registered menu by name
func get_menu(menu_name: String):
	if _menus.has(menu_name):
		return _menus[menu_name]
	return null

# Check if a menu is currently open
func is_menu_open(menu_name: String) -> bool:
	if not _menus.has(menu_name):
		return false
	
	var menu = _menus[menu_name]
	
	# Check if the menu has a is_open property or method
	if menu.has_method("is_open"):
		return menu.is_open()
	elif "is_open" in menu:
		return menu.is_open
	
	# Fallback: check if it's visible
	if menu is CanvasItem:
		return menu.visible
	
	return false

# Push a menu onto the stack
func push_menu(menu_name: String) -> bool:
	if not _menus.has(menu_name):
		push_error("MenuManager: Attempted to push non-existent menu '%s' onto stack" % menu_name)
		return false
	
	if not is_menu_open(menu_name):
		open_menu(menu_name)
	
	# Add to stack if not already in it
	if not _menu_stack.has(menu_name):
		_menu_stack.append(menu_name)
		emit_signal("menu_stack_changed")
	
	return true

# Pop the top menu from the stack and close it
func pop_menu() -> String:
	if _menu_stack.size() == 0:
		push_warning("MenuManager: Attempted to pop from empty menu stack")
		return ""
	
	var menu_name = _menu_stack.pop_back()
	close_menu(menu_name)
	emit_signal("menu_stack_changed")
	
	return menu_name

# Get the current top menu on the stack
func get_top_menu() -> String:
	if _menu_stack.size() == 0:
		return ""
	
	return _menu_stack[_menu_stack.size() - 1]

# Clear the entire menu stack, closing all menus
func clear_menu_stack() -> void:
	while _menu_stack.size() > 0:
		pop_menu()

# Signal handlers
func _on_menu_opened(menu_name: String) -> void:
	emit_signal("menu_opened", menu_name)

func _on_menu_closed(menu_name: String) -> void:
	# Remove from stack if it's in there
	var stack_index = _menu_stack.find(menu_name)
	if stack_index != -1:
		_menu_stack.remove_at(stack_index)
		emit_signal("menu_stack_changed")
	
	emit_signal("menu_closed", menu_name)

extends EasyMainMenu

func _ready():
    super._ready()
    
    # Set the scene to load when starting a new game
    new_game_scene = "res://scenes/main_game.tscn"
    
    # Set the scene to load when continuing a game
    continue_game_scene = "res://scenes/main_game.tscn"
    
    # Connect button signals if not already connected by parent class
    if new_game_button and not new_game_button.pressed.is_connected(_on_new_game_pressed):
        new_game_button.pressed.connect(_on_new_game_pressed)
    
    if continue_button and not continue_button.pressed.is_connected(_on_continue_pressed):
        continue_button.pressed.connect(_on_continue_pressed)
    
    if options_button and not options_button.action_type == EasyMenuButton.ActionType.OPEN_MENU:
        options_button.action_type = EasyMenuButton.ActionType.OPEN_MENU
        options_button.menu_name = "OptionsMenu"
    
    if quit_button and not quit_button.action_type == EasyMenuButton.ActionType.QUIT_GAME:
        quit_button.action_type = EasyMenuButton.ActionType.QUIT_GAME
        quit_button.show_confirmation = true
extends EasyPauseMenu

func _ready():
    super._ready()
    
    # Set the main menu scene
    main_menu_scene = "res://scenes/main_menu.tscn"
    
    # Connect button signals if not already connected by parent class
    if resume_button and not resume_button.pressed.is_connected(_on_resume_pressed):
        resume_button.pressed.connect(_on_resume_pressed)
    
    if save_button and not save_button.pressed.is_connected(_on_save_pressed):
        save_button.pressed.connect(_on_save_pressed)
    
    if load_button and not load_button.action_type == EasyMenuButton.ActionType.OPEN_MENU:
        load_button.action_type = EasyMenuButton.ActionType.OPEN_MENU
        load_button.menu_name = "LoadMenu"
    
    if options_button and not options_button.action_type == EasyMenuButton.ActionType.OPEN_MENU:
        options_button.action_type = EasyMenuButton.ActionType.OPEN_MENU
        options_button.menu_name = "OptionsMenu"
    
    if main_menu_button and not main_menu_button.pressed.is_connected(_on_main_menu_pressed):
        main_menu_button.pressed.connect(_on_main_menu_pressed)
    
    if quit_button and not quit_button.action_type == EasyMenuButton.ActionType.QUIT_GAME:
        quit_button.action_type = EasyMenuButton.ActionType.QUIT_GAME
        quit_button.show_confirmation = true
    
    # Set up input handling for pause
    set_process_input(true)

func _input(event):
    if event.is_action_pressed("ui_cancel"):
        if visible:
            _on_resume_pressed()
        else:
            if Engine.has_singleton("EasyMenuManager"):
                var menu_manager = Engine.get_singleton("EasyMenuManager")
                menu_manager.open_menu("PauseMenu")
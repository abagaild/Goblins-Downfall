extends Node2D

@onready var game_loop_manager = $GameLoopManager
@onready var stats_display = $UI/StatsDisplay
@onready var phase_transition = $UI/PhaseTransition

# Called when the node enters the scene tree for the first time
func _ready():
    # Connect signals from game loop manager
    game_loop_manager.connect("phase_changed", Callable(self, "_on_game_loop_manager_phase_changed"))
    game_loop_manager.connect("day_changed", Callable(self, "_on_game_loop_manager_day_changed"))
    game_loop_manager.connect("loop_completed", Callable(self, "_on_game_loop_manager_loop_completed"))
    game_loop_manager.connect("game_completed", Callable(self, "_on_game_loop_manager_game_completed"))
    
    # Start the game loop
    game_loop_manager.start_farm_phase()

func _on_game_loop_manager_phase_changed(phase):
    # Show phase transition
    if phase_transition:
        var phase_name = ""
        match phase:
            GameLoopManager.GamePhase.FARM:
                phase_name = "Farm Phase"
            GameLoopManager.GamePhase.DEFENSE:
                phase_name = "Defense Phase"
            GameLoopManager.GamePhase.BOSS:
                phase_name = "Boss Battle"
            GameLoopManager.GamePhase.GAME_END:
                phase_name = "Game Over"
        
        phase_transition.show_transition(phase_name)

func _on_game_loop_manager_day_changed(day_number):
    # Update day display
    print("Day changed to: " + str(day_number))

func _on_game_loop_manager_loop_completed(loop_number):
    # Show loop completion message
    print("Loop " + str(loop_number) + " completed!")

func _on_game_loop_manager_game_completed(victory, stats):
    # Game is over, summary will be shown by the game loop manager
    print("Game completed! Victory: " + str(victory))

func _on_pause_button_pressed():
    # Show pause menu
    var pause_menu = load("res://scenes/ui/pause_menu.tscn").instantiate()
    add_child(pause_menu)
    get_tree().paused = true
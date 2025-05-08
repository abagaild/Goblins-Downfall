extends Node
class_name GameLoopManager

signal day_changed(day_number)
signal phase_changed(phase)
signal loop_completed(loop_number)
signal game_completed(victory, stats)

enum GamePhase {FARM, DEFENSE, BOSS, GAME_END}

var current_loop: int = 1
var max_loops: int = 5
var current_phase: GamePhase = GamePhase.FARM
var current_day: int = 1
var boss_defeated: bool = false
var game_stats = {
    "seeds_planted": 0,
    "resources_gathered": 0,
    "enemies_defeated": 0,
    "bosses_defeated": 0,
    "damage_taken": 0
}

# References
@onready var farm_scene = preload("res://scenes/farm/farm_scene.tscn")
@onready var defense_scene = preload("res://scenes/combat/defense_scene.tscn")
@onready var boss_scene = preload("res://scenes/combat/boss_scene.tscn")
@onready var summary_scene = preload("res://scenes/ui/game_summary.tscn")

func _ready():
    # Start with farming phase
    start_farm_phase()

func start_farm_phase():
    current_phase = GamePhase.FARM
    emit_signal("phase_changed", current_phase)
    
    # Wait a moment for the phase transition to show
    await get_tree().create_timer(2.0).timeout
    
    # Load farm scene if not already loaded
    if get_tree().current_scene.name != "FarmScene":
        get_tree().change_scene_to_packed(farm_scene)
        
    # Wait for the scene to be fully loaded
    await get_tree().process_frame
    
    # Connect to farm manager's day/night cycle
    var farm_managers = get_tree().get_nodes_in_group("farm_manager")
    if farm_managers.size() > 0:
        var farm_manager = farm_managers[0]
        var day_night_cycle = farm_manager.get_parent().get_node_or_null("DayNightCycle")
        if day_night_cycle:
            if !day_night_cycle.is_connected("timeout", Callable(self, "_on_farm_day_completed")):
                day_night_cycle.timeout.connect(_on_farm_day_completed)
        else:
            print("Warning: DayNightCycle node not found in the farm scene")
    else:
        print("Warning: No farm_manager found in the scene")

func _on_farm_day_completed():
    # Move to defense phase
    start_defense_phase()

func start_defense_phase():
    current_phase = GamePhase.DEFENSE
    emit_signal("phase_changed", current_phase)
    
    # Load defense scene
    get_tree().change_scene_to_packed(defense_scene)
    
    # Connect to defense completion signal
    await get_tree().process_frame
    var combat_system = get_tree().get_nodes_in_group("combat_system")[0]
    if combat_system:
        combat_system.connect("game_over", Callable(self, "_on_defense_completed"))

func _on_defense_completed(victory):
    if victory:
        # Move to boss phase
        start_boss_phase()
    else:
        # Game over - defeat
        end_game(false)

func start_boss_phase():
    current_phase = GamePhase.BOSS
    emit_signal("phase_changed", current_phase)
    
    # Load boss scene
    get_tree().change_scene_to_packed(boss_scene)
    
    # Connect to boss completion signal
    await get_tree().process_frame
    var boss_combat = get_tree().get_nodes_in_group("boss_combat")[0]
    if boss_combat:
        boss_combat.connect("boss_battle_completed", Callable(self, "_on_boss_completed"))

func _on_boss_completed(victory):
    if victory:
        boss_defeated = true
        game_stats["bosses_defeated"] += 1
        
        # Check if this was the final loop
        if current_loop >= max_loops:
            # Game completed successfully
            end_game(true)
        else:
            # Move to next loop
            current_loop += 1
            emit_signal("loop_completed", current_loop)
            
            # Back to farm phase
            current_day += 1
            emit_signal("day_changed", current_day)
            start_farm_phase()
    else:
        # Game over - defeat
        end_game(false)

func end_game(victory):
    current_phase = GamePhase.GAME_END
    emit_signal("phase_changed", current_phase)
    emit_signal("game_completed", victory, game_stats)
    
    # Load summary scene
    var summary = summary_scene.instantiate()
    summary.set_stats(victory, game_stats)
    get_tree().root.add_child(summary)

# Track game statistics
func track_seed_planted():
    game_stats["seeds_planted"] += 1

func track_resources_gathered(amount):
    game_stats["resources_gathered"] += amount

func track_enemy_defeated():
    game_stats["enemies_defeated"] += 1

func track_damage_taken(amount):
    game_stats["damage_taken"] += amount



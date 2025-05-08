extends Node
class_name MentalHealthCombatSystem

# Combat phases
enum CombatPhase {PLAYER_CHOICE, PLAYER_ACTION, ENEMY_ATTACK, DODGE_PHASE, RESULTS}

# Combat stats
@export var base_damage: float = 10.0
@export var resilience_cost: float = 5.0  # Mental energy cost

# References
@export var stats_system_path: NodePath
@export var battle_arena_path: NodePath

# Private variables
var stats_system = null
var battle_arena = null
var current_phase = CombatPhase.PLAYER_CHOICE
var active_enemy = null
var available_skills = []

# Signals
signal phase_changed(phase)
signal enemy_attack_started(enemy, attack_type)
signal dodge_phase_started(bullet_pattern)
signal skill_unlocked(skill_name)

func _ready():
    if stats_system_path:
        stats_system = get_node(stats_system_path)
    
    if battle_arena_path:
        battle_arena = get_node(battle_arena_path)
    
    # Initialize available skills (only basic ones at start)
    available_skills = ["Basic Attack"]

func start_combat(enemy):
    active_enemy = enemy
    current_phase = CombatPhase.PLAYER_CHOICE
    emit_signal("phase_changed", current_phase)
    
func use_skill(skill_name):
    # Check if we have enough resilience
    var skill_data = SkillDatabase.get_skill(skill_name)
    if not skill_data:
        return false
        
    if stats_system and not stats_system.use_resilience(skill_data.resilience_cost):
        battle_arena.add_to_battle_log("Not enough mental energy!")
        return false
    
    # Apply skill effects
    match skill_name:
        "Basic Attack":
            var damage = base_damage
            active_enemy.take_damage(damage)
            battle_arena.add_to_battle_log("You attacked for " + str(damage) + " damage!")
        "Grounding":
            stats_system.restore_resilience(15)
            battle_arena.add_to_battle_log("You feel more grounded. +15 Mental Energy")
        "Refocus":
            stats_system.heal(10)
            battle_arena.add_to_battle_log("You refocus your thoughts. +10 Fortitude")
        "Cognitive Reframing":
            active_enemy.take_damage(base_damage * 1.5)
            battle_arena.add_to_battle_log("You reframe the situation! " + str(base_damage * 1.5) + " damage!")
        "Mindfulness":
            stats_system.add_shield(20)
            battle_arena.add_to_battle_log("You practice mindfulness. +20 Shield")
        "Deep Breathing":
            # Add defense buff
            stats_system.add_defense_buff(0.7, 3)
            battle_arena.add_to_battle_log("You take deep breaths. Damage reduced by 30% for 3 turns.")
        "Positive Affirmation":
            # Add attack buff
            stats_system.add_attack_buff(1.3, 3)
            battle_arena.add_to_battle_log("You affirm your strength. Attack increased by 30% for 3 turns.")
        "Emotional Regulation":
            # Balance fortitude and resilience
            var fort = stats_system.current_fortitude
            var resil = stats_system.current_resilience
            var avg = (fort + resil) / 2
            stats_system.set_fortitude(avg)
            stats_system.set_resilience(avg)
            battle_arena.add_to_battle_log("You regulate your emotions. Fortitude and Mental Energy balanced.")
    
    # Move to enemy attack phase
    current_phase = CombatPhase.ENEMY_ATTACK
    emit_signal("phase_changed", current_phase)
    
    # Start enemy attack after a short delay
    await get_tree().create_timer(1.0).timeout
    start_enemy_attack()
    
    return true

func start_enemy_attack():
    var attack_type = active_enemy.choose_attack()
    emit_signal("enemy_attack_started", active_enemy, attack_type)
    
    # Start dodge phase after enemy attack animation
    await get_tree().create_timer(1.5).timeout
    start_dodge_phase(attack_type)

func start_dodge_phase(attack_type):
    current_phase = CombatPhase.DODGE_PHASE
    emit_signal("phase_changed", current_phase)
    
    var bullet_pattern = active_enemy.get_bullet_pattern(attack_type)
    emit_signal("dodge_phase_started", bullet_pattern)
    
    # Dodge phase is handled by BulletHellManager
    # When it completes, it will call dodge_phase_completed

func dodge_phase_completed(damage_taken):
    if damage_taken > 0:
        stats_system.take_damage(damage_taken)
        battle_arena.add_to_battle_log("You took " + str(damage_taken) + " damage!")
    
    current_phase = CombatPhase.PLAYER_CHOICE
    emit_signal("phase_changed", current_phase)
    
    # Check if combat should end
    check_combat_state()

func check_combat_state():
    if stats_system.current_fortitude <= 0:
        battle_arena.end_battle({"victory": false})
    elif active_enemy.current_health <= 0:
        battle_arena.end_battle({"victory": true})

func unlock_skill(skill_name):
    if not skill_name in available_skills:
        available_skills.append(skill_name)
        emit_signal("skill_unlocked", skill_name)
        return true
    return false

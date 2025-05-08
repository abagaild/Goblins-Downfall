extends EnemyBase
class_name FodderEnemy

# Enemy types
enum EnemyType {DOUBT, ANXIETY, FEAR, SHAME, RUMINATION}

@export var enemy_type: EnemyType = EnemyType.DOUBT

func _ready():
	super._ready()
	
	# Set up enemy based on type
	match enemy_type:
		EnemyType.DOUBT:
			enemy_name = "Nagging Doubt"
			max_health = 40.0
			current_health = max_health
			attack_power = 5.0
			defense = 2.0
			attacks = ["basic", "spiral"]
		
		EnemyType.ANXIETY:
			enemy_name = "Anxious Thought"
			max_health = 30.0
			current_health = max_health
			attack_power = 8.0
			defense = 1.0
			attacks = ["rapid", "basic"]
		
		EnemyType.FEAR:
			enemy_name = "Irrational Fear"
			max_health = 50.0
			current_health = max_health
			attack_power = 10.0
			defense = 3.0
			attacks = ["basic", "spiral"]
		
		EnemyType.SHAME:
			enemy_name = "Shame Spiral"
			max_health = 45.0
			current_health = max_health
			attack_power = 7.0
			defense = 4.0
			attacks = ["spiral", "basic"]
		
		EnemyType.RUMINATION:
			enemy_name = "Rumination Loop"
			max_health = 60.0
			current_health = max_health
			attack_power = 6.0
			defense = 5.0
			attacks = ["basic", "rapid"]
	
	# Make sure the sprite is set
	if sprite_node and sprite:
		sprite_node.texture = sprite
	
	emit_signal("health_changed", current_health, max_health)

func get_bullet_pattern(attack_name):
	match attack_name:
		"basic":
			return "basic"
		"rapid":
			return "rapid"
		"spiral":
			return "spiral"
	return "basic"

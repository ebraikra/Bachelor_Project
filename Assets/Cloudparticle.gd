extends GPUParticles2D

#EVENTUELLE CODELEICHE

var current_rate: float = 10.0
var target_rate: float = 10.0
var lerp_speed: float = 1.0  # Die Geschwindigkeit, mit der der Übergang stattfindet
var min_rate: int = 1  # Minimale Rate, wenn CO2 niedrig ist
var max_rate: int = 100  # Maximale Rate, wenn CO2 hoch ist

func update_co2(co2_value: int) -> void:
	target_rate = min_rate + int((max_rate - min_rate) * (co2_value / 100.0))

func _process(delta: float) -> void:
	# Fließender Übergang für die Partikelrate
	current_rate = lerp(current_rate, target_rate, lerp_speed * delta)
	emitting = true
	var screen_height: float = get_viewport_rect().size.y
	position.y = randf_range(0, screen_height)

func _ready() -> void:
	var colonyService: Node = get_tree().get_root().get_node("World").get_node("ColonyManager/ColonyService")
	
	

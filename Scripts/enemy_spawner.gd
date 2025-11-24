extends Node2D

@export var enemy: PackedScene
@export var texture: Texture2D

@onready var spawn_timer = $spawn_timer

var rng = RandomNumberGenerator.new()
var spawner: Dictionary
var screen_size: Vector2
var texture_size: Vector2


# Ajusta el tiempo de spawneo según el nivel
func _ready() -> void:
	spawner = Config.ENEMY_SPAWNER_DATA[Config.current_level]
	spawn_timer.wait_time = spawner["spawn_interval"]
	
	screen_size = get_viewport_rect().size
	texture_size = texture.get_size() / 2

# Calcula una posición aleatoria fuera de pantalla
func rand_position():
	var side = randi_range(0, 3)  # 0: izquierda | 1: derecha | 2: arriba | 3: abajo
	match side:
		0: return Vector2(-texture_size.x, randf_range(0, screen_size.y))
		1: return Vector2(screen_size.x + texture_size.x, randf_range(0, screen_size.y))
		2: return Vector2(randf_range(0, screen_size.x), -texture_size.y)
		3: return Vector2(randf_range(0, screen_size.x), screen_size.y + texture_size.y)

# Spawnea el enemigo en una posición aleatoria fuera de pantalla
func spawn_asteroid():
	Config.active_enemies += 1

	var new_pos = rand_position()
	
	var enemy_inst = enemy.instantiate()
	enemy_inst.global_position = new_pos
	
	call_deferred("add_child", enemy_inst)

# Cuando pasa el tiempo de spawneo se crea un asteroide si no se ha alcanzado el maximo (tamaño aleatorio)	
func _on_spawn_timer_timeout() -> void:
	if Config.active_enemies < spawner["max_enemies"]:
		spawn_asteroid()

extends Node2D

@export var enemy: PackedScene

@onready var spawn_timer = $spawn_timer

var rng = RandomNumberGenerator.new()

var spawner: Dictionary
var available_sizes = [enemyConfig.enemy_size.MEDIUM, enemyConfig.enemy_size.BIG, enemyConfig.enemy_size.HUGE]


func _ready() -> void:
	spawner = enemyConfig.SPAWNER_DATA[Globals.current_level]
	spawn_timer.wait_time = spawner["spawn_interval"]
	
# Tamaño aleatorio con pesos según el nivel
func rand_size():
	var weights = PackedFloat32Array(spawner["size_rand_weights"])
	return available_sizes[rng.rand_weighted(weights)]
	
func rand_texture(size):
	# Asignar una textura aleatoria según el tamaño del nuevo enemye
	var num_textures = enemyConfig.enemy_DATA[size]["num_textures"]
	var suffix = randi_range(1, num_textures)

	var texture_path = "res://Sprites/enemys/" + enemyConfig.enemy_DATA[size]["prefix"] + str(suffix) + ".png"
	
	return load(texture_path)
	
func rand_position(texture):
	var screen_size = get_viewport_rect().size
	var texture_size = texture.get_size() / 2
	
	var side = randi_range(0, 3)  # 0: izquierda, 1: derecha, 2: arriba, 3: abajo
	match side:
		0: return Vector2(-texture_size.x, randi_range(0, screen_size.y))
		1: return Vector2(screen_size.x + texture_size.x, randi_range(0, screen_size.y))
		2: return Vector2(randi_range(0, screen_size.x), -texture_size.y)
		3: return Vector2(randi_range(0, screen_size.x), screen_size.y + texture_size.y)
	
func _on_spawn_timer_timeout() -> void:
	if Globals.active_enemys < spawner["max_enemys"]:
		var enemy_size = rand_size()
		spawn_enemy(enemy_size)

# Spawnea el enemye con el tamaño y la posición recibidos
func spawn_enemy(size, pos: Vector2 = Vector2.ZERO):
	if enemyConfig.enemy_DATA[size]["collision"]:
		Globals.active_enemys += 1
	
	var texture = rand_texture(size)
	
	# Calcular la posición fuera del mapa si no surge de una explosión
	var new_pos: Vector2
	if pos == Vector2.ZERO:
		new_pos = rand_position(texture)
	else:
		new_pos = pos
	
	var enemy_inst = enemy.instantiate()
	enemy_inst.connect("exploded", _on_enemy_exploded)
	enemy_inst.global_position = new_pos
	enemy_inst.size = size
	enemy_inst.set_texture(texture)
	
	call_deferred("add_child", enemy_inst)

# Cuando un enemye explota se divide
func _on_enemy_exploded(pos, original_size):
	Globals.active_enemys -= 1
	
	var split_patterns = enemyConfig.SPLIT_PATTERNS[original_size]
	
	for new_enemy_size in split_patterns:
		var min_range = split_patterns[new_enemy_size][0]
		var max_range = split_patterns[new_enemy_size][1]
		var num_new_enemys = randi_range(min_range, max_range)
		
		for i in range(num_new_enemys):
			spawn_enemy(new_enemy_size, pos)

extends Node2D

@export var asteroid: PackedScene

@onready var spawn_timer = $spawn_timer

var rng = RandomNumberGenerator.new()
var spawner: Dictionary
var available_sizes = [AsteroidConfig.asteroid_size.MEDIUM, AsteroidConfig.asteroid_size.BIG, AsteroidConfig.asteroid_size.HUGE]


# Ajusta el tiempo de spawneo según el nivel
func _ready() -> void:
	spawner = AsteroidConfig.SPAWNER_DATA[Globals.current_level]
	spawn_timer.wait_time = spawner["spawn_interval"]
	
# Tamaño aleatorio con pesos según el nivel
func rand_size():
	var weights = PackedFloat32Array(spawner["size_rand_weights"])
	return available_sizes[rng.rand_weighted(weights)]

# Asignar una textura aleatoria según el tamaño del nuevo asteroide	
func rand_texture(size):
	var num_textures = AsteroidConfig.ASTEROID_DATA[size]["num_textures"]
	var suffix = randi_range(1, num_textures)

	var texture_path = "res://Sprites/asteroids_sprites/" + AsteroidConfig.ASTEROID_DATA[size]["prefix"] + str(suffix) + ".png"
	
	return load(texture_path)

# Calcula una posición aleatoria fuera de pantalla
func rand_position(texture):
	var screen_size = get_viewport_rect().size
	var texture_size = texture.get_size() / 2
	
	var side = randi_range(0, 3)  # 0: izquierda | 1: derecha | 2: arriba | 3: abajo
	match side:
		0: return Vector2(-texture_size.x, randi_range(0, screen_size.y))
		1: return Vector2(screen_size.x + texture_size.x, randi_range(0, screen_size.y))
		2: return Vector2(randi_range(0, screen_size.x), -texture_size.y)
		3: return Vector2(randi_range(0, screen_size.x), screen_size.y + texture_size.y)

# Cuando pasa el tiempo de spawneo se crea un asteroide si no se ha alcanzado el maximo (tamaño aleatorio)	
func _on_spawn_timer_timeout() -> void:
	if Globals.active_asteroids < spawner["max_asteroids"]:
		var asteroid_size = rand_size()
		spawn_asteroid(asteroid_size)

# Spawnea el asteroide con el tamaño y la posición recibidos
func spawn_asteroid(size, pos: Vector2 = Vector2.ZERO):
	if AsteroidConfig.ASTEROID_DATA[size]["collision"]:
		Globals.active_asteroids += 1
	
	var texture = rand_texture(size)
	
	# Calcular la posición fuera del mapa si no surge de una explosión
	var new_pos: Vector2
	if pos == Vector2.ZERO:
		new_pos = rand_position(texture)
	else:
		new_pos = pos
	
	var asteroid_inst = asteroid.instantiate()
	asteroid_inst.connect("exploded", _on_asteroid_exploded)
	asteroid_inst.global_position = new_pos
	asteroid_inst.size = size
	asteroid_inst.set_texture(texture)
	
	call_deferred("add_child", asteroid_inst)

# Cuando un asteroide explota se divide según unos patrones (tamaños)
func _on_asteroid_exploded(pos, original_size):
	Globals.active_asteroids -= 1
	
	var split_patterns = AsteroidConfig.SPLIT_PATTERNS[original_size]
	
	for new_asteroid_size in split_patterns:
		var min_range = split_patterns[new_asteroid_size][0]
		var max_range = split_patterns[new_asteroid_size][1]
		var num_new_asteroids = randi_range(min_range, max_range)
		
		for i in range(num_new_asteroids):
			spawn_asteroid(new_asteroid_size, pos)

extends Node2D

@export var asteroid: PackedScene

@onready var spawn_timer = $spawn_timer

var rng = RandomNumberGenerator.new()

var spawner_data = {
	1: {
		"max_asteroids": 5,
		"spawn_interval": 2.0,
		# Huge, big, medium, small, tiny
		"size_rand_weigths": PackedFloat32Array([2, 1, 0.5])
	},
	2: {
		"max_asteroids": 10,
		"spawn_interval": 1.0,
		"size_rand_weigths": PackedFloat32Array([1, 2, 0.5])
	},
	3: {
		"max_asteroids": 15,
		"spawn_interval": 0.5,
		"size_rand_weigths": PackedFloat32Array([0.5, 1, 2])
	}
}

var spawner: Dictionary
var size_array = [Asteroid.asteroid_size.MEDIUM, Asteroid.asteroid_size.BIG, Asteroid.asteroid_size.HUGE]


func _ready() -> void:
	spawner = spawner_data[Globals.current_level]
	spawn_timer.wait_time = spawner["spawn_interval"]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print(Globals.active_asteroids)
	pass
	
# Tamaño aleatorio con pesos según el nivel
func rand_size():
	return size_array[rng.rand_weighted(spawner["size_rand_weigths"])]
	
	
func rand_position():
	var screen_size = get_viewport_rect().size
	var spawn_pos = Vector2()
	var side = randi_range(0, 3)  # 0: izquierda, 1: derecha, 2: arriba, 3: abajo
	match side:
		0: spawn_pos = Vector2(-50, randi_range(0, screen_size.y))
		1: spawn_pos = Vector2(screen_size.x + 50, randi_range(0, screen_size.y))
		2: spawn_pos = Vector2(randi_range(0, screen_size.x), -50)
		3: spawn_pos = Vector2(randi_range(0, screen_size.x), screen_size.y + 50)
		
	return spawn_pos
	
	#randf_range(-asteroid_inst.size.x / 2, screen_size.x + asteroid_inst.size.x / 2),
	#randf_range(-asteroid_inst.size.y, screen_size.y + asteroid_inst.size.y / 2)
	#)	
	
func _on_spawn_timer_timeout() -> void:
	if Globals.active_asteroids < spawner["max_asteroids"]:
		var asteroid_size = rand_size()
		var asteroid_pos = rand_position()
		spawn_asteroid(asteroid_pos, asteroid_size)

# Spawnea el asteroide con el tamaño y la posición recibidos
func spawn_asteroid(pos, size):
	if size != Asteroid.asteroid_size.SMALL || size != Asteroid.asteroid_size.TINY:
		Globals.active_asteroids += 1
	
	var asteroid_inst = asteroid.instantiate()
	asteroid_inst.connect("exploded", _on_asteroid_exploded)
	asteroid_inst.global_position = pos
	asteroid_inst.size = size
	#get_tree().current_scene.call_deferred("add_child", asteroid_inst)
	self.call_deferred("add_child", asteroid_inst)

# Cuando un asteroide explota se divide
func _on_asteroid_exploded(pos, size):
	Globals.active_asteroids -= 1
	match size:
		Asteroid.asteroid_size.HUGE:
			for i in range(randi_range(2,3)):
				spawn_asteroid(pos, Asteroid.asteroid_size.BIG)
			for i in range(randi_range(0,2)):
				spawn_asteroid(pos, Asteroid.asteroid_size.MEDIUM)
			for i in range(randi_range(0,2)):
				spawn_asteroid(pos, Asteroid.asteroid_size.SMALL)
			for i in range(randi_range(0,1)):
				spawn_asteroid(pos, Asteroid.asteroid_size.TINY)
		Asteroid.asteroid_size.BIG:
			for i in range(randi_range(2,3)):
				spawn_asteroid(pos, Asteroid.asteroid_size.MEDIUM)
			for i in range(randi_range(0,2)):
				spawn_asteroid(pos, Asteroid.asteroid_size.SMALL)
			for i in range(randi_range(0,1)):
				spawn_asteroid(pos, Asteroid.asteroid_size.TINY)
		Asteroid.asteroid_size.MEDIUM:
			for i in range(randi_range(2,3)):
				spawn_asteroid(pos, Asteroid.asteroid_size.SMALL)
			for i in range(randi_range(0,2)):
				spawn_asteroid(pos, Asteroid.asteroid_size.TINY)
		Asteroid.asteroid_size.SMALL:
			pass
		Asteroid.asteroid_size.TINY:
			pass

extends Node2D

@export var asteroid: PackedScene


func _ready() -> void:
	#await get_tree().create_timer(10).timeout
	spawn_asteroid(Vector2(500, 500), Asteroid.asteroid_size.HUGE)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
#func rand_position():
	#var screen_size = get_viewport_rect().size
	#var random_position = Vector2(
	#randf_range(-asteroid_inst.size.x / 2, screen_size.x + asteroid_inst.size.x / 2),
	#randf_range(-asteroid_inst.size.y, screen_size.y + asteroid_inst.size.y / 2)
	#)

# Spawnea el asteroide con el tamaño y la posición recibidos
func spawn_asteroid(pos, size):
	var asteroid_inst = asteroid.instantiate()
	asteroid_inst.connect("exploded", _on_asteroid_exploded)
	asteroid_inst.global_position = pos
	asteroid_inst.size = size
	#get_tree().current_scene.call_deferred("add_child", asteroid_inst)
	self.call_deferred("add_child", asteroid_inst)

# Cuando un asteroide explota se divide
func _on_asteroid_exploded(pos, size):
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

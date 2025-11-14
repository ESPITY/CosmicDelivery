extends Node2D

@export var asteroid: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#await get_tree().create_timer(10).timeout
	spawn_asteroid(Vector2(500, 500), Asteroid.asteroid_size.HUGE)
	#await get_tree().create_timer(10).timeout
	#spawn_asteroid(Vector2(500, 500), Asteroid.asteroid_size.BIG)
	#await get_tree().create_timer(10).timeout
	#spawn_asteroid(Vector2(500, 500), Asteroid.asteroid_size.MEDIUM)
	#await get_tree().create_timer(10).timeout
	#spawn_asteroid(Vector2(500, 500), Asteroid.asteroid_size.SMALL)
	#await get_tree().create_timer(10).timeout
	#spawn_asteroid(Vector2(500, 500), Asteroid.asteroid_size.TINY)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
#func rand_position():
	#var screen_size = get_viewport_rect().size
	#var random_position = Vector2(
	#randf_range(-asteroid_inst.size.x / 2, screen_size.x + asteroid_inst.size.x / 2),
	#randf_range(-asteroid_inst.size.y, screen_size.y + asteroid_inst.size.y / 2)
	#)

func spawn_asteroid(pos, size):
	var asteroid_inst = asteroid.instantiate()
	asteroid_inst.connect("exploded", _on_asteroid_exploded)
	asteroid_inst.global_position = pos
	asteroid_inst.size = size
	#self.add_child(asteroid_inst)
	get_tree().current_scene.call_deferred("add_child", asteroid_inst)
	
func _on_asteroid_exploded(pos, size):
	for i in range(2):
		match size:
			Asteroid.asteroid_size.HUGE:
				spawn_asteroid(pos, Asteroid.asteroid_size.BIG)
			Asteroid.asteroid_size.BIG:
				spawn_asteroid(pos, Asteroid.asteroid_size.MEDIUM)
			Asteroid.asteroid_size.MEDIUM:
				spawn_asteroid(pos, Asteroid.asteroid_size.SMALL)
			Asteroid.asteroid_size.SMALL:
				spawn_asteroid(pos, Asteroid.asteroid_size.TINY)
			Asteroid.asteroid_size.TINY:
				pass

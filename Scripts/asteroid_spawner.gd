extends Node2D

@export var asteroid: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(10).timeout
	spawn_asteroid()
	await get_tree().create_timer(10).timeout
	spawn_asteroid()
	await get_tree().create_timer(10).timeout
	spawn_asteroid()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func spawn_asteroid():
	var screen_size = get_viewport_rect().size

	var asteroid_inst = asteroid.instantiate()
	asteroid_inst.size = Asteroid.asteroid_size.BIG
	
	var random_position = Vector2(randf_range(0, screen_size.x), randf_range(0, screen_size.y))
	
	asteroid_inst.global_position = random_position
	self.add_child(asteroid_inst)

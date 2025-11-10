extends RigidBody2D

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# WHEIGHTED
	var rand_num = rng.randf_range(-2, 2)
	print(rand_num)
	
	self.set_global_scale(Vector2(rand_num, rand_num))
	#$CollisionShape2D.set_global_scale(Vector2(rand_num, rand_num))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Destruir o dividir
#func _on_area_entered(area: Area2D) -> void:
	#queue_free()


func _on_body_entered(body: Node) -> void:
	print("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")
	queue_free()

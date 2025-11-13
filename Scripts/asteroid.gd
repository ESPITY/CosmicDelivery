extends RigidBody2D

var rng = RandomNumberGenerator.new()

@onready var animated_sprite = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# WHEIGHTED
	var rand_num = rng.randf_range(-2, 2)
	print(rand_num)
	
	self.set_global_scale(Vector2(rand_num, rand_num))
	#$CollisionShape2D.set_global_scale(Vector2(rand_num, rand_num))
	linear_velocity = Vector2(randf_range(-100, 100), randf_range(-100, 100))
	angular_velocity = randf_range(-1, 1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func explode():
	queue_free()	

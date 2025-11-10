extends Area2D

@export var speed: float = 1000

@onready var bullet_sprite = $bullet


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Eliminar la isntancia cuando ha salido del mapa
func out_of_bounds():
	var screen_size = get_viewport_rect().size
	var sprite_size = bullet_sprite.texture.get_size() / 2
	
	if (position.x < 0 or position.x > screen_size.x) or (position.y < 0 or position.y > screen_size.y):
		queue_free()		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += Vector2(speed * delta, 0).rotated(rotation)
	out_of_bounds()

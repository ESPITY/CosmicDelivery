extends Area2D

@export var speed: float = 1000

@onready var bullet_sprite = $bullet


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Eliminar la instancia cuando ha salido del mapa
func out_of_bounds():
	var screen_size = get_viewport_rect().size
	
	if (position.x < 0 or position.x > screen_size.x) or (position.y < 0 or position.y > screen_size.y):
		queue_free()		


func _process(delta: float) -> void:
	global_position += Vector2(speed * delta, 0).rotated(rotation)
	out_of_bounds()

func _on_body_entered(body: Node2D) -> void:
	body.explode()
	queue_free()

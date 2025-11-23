extends Area2D

@export var speed: float = 1000
@export var player_bullet_texture: Texture2D
@export var enemy_bullet_texture: Texture2D

@onready var bullet_sprite = $bullet_sprite


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if get_parent().is_in_group("player"):
		bullet_sprite = player_bullet_texture
	elif get_parent().is_in_group("enemies"):
		bullet_sprite = enemy_bullet_texture
	
func _process(delta: float) -> void:
	global_position += Vector2(speed * delta, 0).rotated(rotation)
	out_of_bounds()

# Eliminar la instancia cuando ha salido del mapa
func out_of_bounds():
	var screen_size = get_viewport_rect().size
	
	if (position.x < 0 or position.x > screen_size.x) or (position.y < 0 or position.y > screen_size.y):
		queue_free()		

# Detección de colisiones
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("asteroids"):
		body.explode()
	queue_free()

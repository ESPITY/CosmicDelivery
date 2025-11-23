extends Area2D

@export var speed: float = 1000
@export var player_bullet_texture: Texture2D
@export var enemy_bullet_texture: Texture2D

@onready var bullet_sprite = $bullet_sprite


# Configura textura, colisiones y máscaras según el origen del disparo (jugador/enemigo)
func _ready() -> void:
	if get_parent().is_in_group("player"):
		bullet_sprite.texture = player_bullet_texture
		set_collision_layer_value(1, true)		# player_bullets
		set_collision_mask_value(3, true)		# enemies
		set_collision_mask_value(5, true)		# asteroids
		
	elif get_parent().is_in_group("enemies"):
		bullet_sprite.texture = enemy_bullet_texture
		set_collision_layer_value(4, true)		# enemy_bullets
		set_collision_mask_value(1, true)		# player
		set_collision_mask_value(5, true)		# asteroids
	
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
	if body.is_in_group("player"):
		body.damaged(Config.ENEMY_DATA["attack"])
		body.hit_effect()
	if body.is_in_group("enemies"):
		body.damaged(Config.PLAYER_DATA["attack"])
		body.hit_effect()
	queue_free()

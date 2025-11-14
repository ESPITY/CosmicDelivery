class_name Asteroid extends RigidBody2D

var rng = RandomNumberGenerator.new()

@onready var animated_sprite = $AnimatedSprite2D
@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D

enum asteroid_size {HUGE, BIG, MEDIUM, SMALL, TINY}

@export var size = asteroid_size.HUGE

var asteroid_data = {
	asteroid_size.HUGE: {
		"speed_range": Vector2(-100, 100),
		"prefix": "Asteroid_Huge-"
	},
	asteroid_size.BIG: {
		"speed_range": Vector2(-150, 150),
		"prefix": "Asteroid_Big-"
	},
	asteroid_size.MEDIUM: {
		"speed_range": Vector2(-200, 200),
		"prefix": "Asteroid_Medium-"
	},
	asteroid_size.SMALL: {
		"speed_range": Vector2(-250, 250),
		"prefix": "Asteroid_Small-"
	},
	asteroid_size.TINY: {
		"speed_range": Vector2(-300, 300),
		"prefix": "Asteroid_Tiny-"
	}
}

signal exploded(pos, size)


func _ready() -> void:
	var asteroid = asteroid_data[size]	
	var speed = randf_range(asteroid["speed_range"].x, asteroid["speed_range"].y)
	var suffix: int
	
	if (size == asteroid_size.HUGE) || (size == asteroid_size.BIG):
		suffix = randi_range(1, 4)
		
	elif (size == asteroid_size.MEDIUM) || (size == asteroid_size.SMALL) || (size == asteroid_size.TINY):
		suffix = randi_range(1, 2)

	var texture_path = "res://Sprites/Asteroids/" + asteroid["prefix"] + str(suffix) + ".png"
	var collision_path = "res://Resources/" + asteroid["prefix"].replace("Asteroid_", "Asteroid_CS_") + str(suffix) + ".tres"
  
	sprite.texture = load(texture_path)
	collision.shape = load(collision_path)
	
	rotation = randf_range(0, 2 * PI)
	
	# WHEIGHTED
	linear_velocity = Vector2(speed, speed)
	angular_velocity = randf_range(-1, 1)

func teleport():
	var screen_size = get_viewport_rect().size
	var sprite_size = sprite.texture.get_size() / 2
	
	global_position.x = wrapf(global_position.x, -sprite_size.x, screen_size.x + sprite_size.x)
	global_position.y = wrapf(global_position.y, -sprite_size.y, screen_size.y + sprite_size.y)
	

	
func _physics_process(delta):
	teleport()

func split():
	# Generamos un número aleatorio de asteroides hijos
	var num_children = randi_range(2, 4)  # Puede generar entre 2 y 4 asteroides

	# En función del tamaño actual, generamos asteroides más pequeños
	var new_size: asteroid_size
	match size:
		asteroid_size.HUGE:
			new_size = asteroid_size.BIG
		asteroid_size.BIG:
			new_size = asteroid_size.MEDIUM
		asteroid_size.MEDIUM:
			new_size = asteroid_size.SMALL
		asteroid_size.SMALL:
			new_size = asteroid_size.TINY
		asteroid_size.TINY:
			return  # No se puede dividir más

	# Crear los nuevos asteroides
	#for i in range(num_children):
		#var new_asteroid = self.new()
		#new_asteroid.size = new_size
		#new_asteroid.position = position  # Aparecen en la misma posición del asteroide original
		#new_asteroid.linear_velocity = rng.randf_range(-100, 100) * Vector2(cos(randf_range(0, 2 * PI)), sin(randf_range(0, 2 * PI)))
		#get_parent().add_child(new_asteroid)

func explode():
	emit_signal("exploded", global_position, size)
	queue_free()

class_name Asteroid extends RigidBody2D

var rng = RandomNumberGenerator.new()

@onready var animated_sprite = $AnimatedSprite2D

enum asteroid_size {HUGE, BIG, MEDIUM, SMALL, TINY}

@export var size = asteroid_size.HUGE

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var speed: float
	var texture: int
	match size:
		asteroid_size.HUGE:
			speed = randf_range(-100, 100)
			texture = randi_range(1, 4)
			match texture:
				1:
					sprite.texture = preload("res://Sprites/Asteroids/Asteroid_Huge-1.png")
					collision.shape = preload("res://Resources/Asteroid_CS_Huge-1.tres")
				2:
					sprite.texture = preload("res://Sprites/Asteroids/Asteroid_Huge-2.png")
					collision.shape = preload("res://Resources/Asteroid_CS_Huge-2.tres")
				3:
					sprite.texture = preload("res://Sprites/Asteroids/Asteroid_Huge-3.png")
					collision.shape = preload("res://Resources/Asteroid_CS_Huge-3.tres")
				4:
					sprite.texture = preload("res://Sprites/Asteroids/Asteroid_Huge-4.png")
					collision.shape = preload("res://Resources/Asteroid_CS_Huge-4.tres")
		asteroid_size.BIG:
			speed = randf_range(-150, 150)
			texture = randi_range(1, 4)
			match texture:
				1:
					sprite.texture = preload("res://Sprites/Asteroids/Asteroid_Big-1.png")
					collision.shape = preload("res://Resources/Asteroid_CS_Big-1.tres")
				2:
					sprite.texture = preload("res://Sprites/Asteroids/Asteroid_Big-2.png")
					collision.shape = preload("res://Resources/Asteroid_CS_Big-2.tres")
				3:
					sprite.texture = preload("res://Sprites/Asteroids/Asteroid_Big-3.png")
					collision.shape = preload("res://Resources/Asteroid_CS_Big-3.tres")
				4:
					sprite.texture = preload("res://Sprites/Asteroids/Asteroid_Big-4.png")
					collision.shape = preload("res://Resources/Asteroid_CS_Big-4.tres")
		asteroid_size.MEDIUM:
			speed = randf_range(-200, 200)
			texture = randi_range(1, 2)
			match texture:
				1:
					sprite.texture = preload("res://Sprites/Asteroids/Asteroid_Medium-1.png")
					collision.shape = preload("res://Resources/Asteroid_CS_Medium-1.tres")
				2:
					sprite.texture = preload("res://Sprites/Asteroids/Asteroid_Medium-2.png")
					collision.shape = preload("res://Resources/Asteroid_CS_Medium-2.tres")
		asteroid_size.SMALL:
			speed = randf_range(-250, 250)
			texture = randi_range(1, 2)
			match texture:
				1:
					sprite.texture = preload("res://Sprites/Asteroids/Asteroid_Small-1.png")
					collision.shape = preload("res://Resources/Asteroid_CS_Small-1.tres")
				2:
					sprite.texture = preload("res://Sprites/Asteroids/Asteroid_Small-2.png")
					collision.shape = preload("res://Resources/Asteroid_CS_Small-2.tres")
		asteroid_size.TINY:
			speed = randf_range(-300, 300)
			texture = randi_range(1, 2)
			match texture:
				1:
					sprite.texture = preload("res://Sprites/Asteroids/Asteroid_Tiny-1.png")
					collision.shape = preload("res://Resources/Asteroid_CS_Tiny-1.tres")
				2:
					sprite.texture = preload("res://Sprites/Asteroids/Asteroid_Tiny-2.png")
					collision.shape = preload("res://Resources/Asteroid_CS_Tiny-2.tres")
	
	rotation = randf_range(0, 2 * PI)
	
	# WHEIGHTED
	var rand_num = rng.randf_range(-2, 2)
	print(rand_num)
	
	self.set_global_scale(Vector2(rand_num, rand_num))
	#$CollisionShape2D.set_global_scale(Vector2(rand_num, rand_num))
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
	queue_free()	

class_name Asteroid extends RigidBody2D

var rng = RandomNumberGenerator.new()

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var nav_obstacle = $NavigationObstacle2D

@export var size = AsteroidConfig.asteroid_size.HUGE
@export var max_speed: float = 400

var hits: int = 0
var asteroid: Dictionary
var texture: Texture2D
var screen_size: Vector2
var sprite_size: Vector2

signal exploded(size, pos)


func _ready() -> void:
	asteroid = AsteroidConfig.ASTEROID_DATA[size]	

	sprite.texture = texture
	screen_size = get_viewport_rect().size
	sprite_size = sprite.texture.get_size() / 2

	if asteroid["collision"]:
		var texture_name = sprite.texture.resource_path.get_file().replace(".png", "")
		var collision_path = "res://Resources/Asteroid_CS_%s.tres" % texture_name.replace("Asteroid_", "")
		collision.shape = load(collision_path)
	
	var speed = randf_range(asteroid["speed_range"].x, asteroid["speed_range"].y)
	var direction = randf_range(0, 2 * PI)
	
	linear_velocity = Vector2.from_angle(direction) * speed
	angular_velocity = randf_range(-1, 1)
	rotation = randf_range(0, 2 * PI)
	
	mass = asteroid["mass"]
	physics_material_override.friction = asteroid["friction"]
	physics_material_override.bounce = asteroid["bounce"]
	
	set_nav_obstacle()

# El spawner llama esta función para asignar la textura
func set_texture(new_texture):
	texture = new_texture

	
func set_nav_obstacle():
	if  asteroid["collision"]:
		var radius = max(sprite_size.x, sprite_size.y) * 1.2	# 120% del tamaño del sprite
		nav_obstacle.radius = radius
		nav_obstacle.avoidance_enabled = true
		nav_obstacle.affect_navigation_mesh = true
	else:
		nav_obstacle.avoidance_enabled = false
		nav_obstacle.affect_navigation_mesh = false

func teleport():	
	global_position.x = wrapf(global_position.x, -sprite_size.x, screen_size.x + sprite_size.x)
	global_position.y = wrapf(global_position.y, -sprite_size.y, screen_size.y + sprite_size.y)	
	
# Los asteroides SMALL y TINY encojen hasta desaparecer
func shrink(delta):
	if asteroid["shrinks"]:
		sprite.global_scale -= Vector2(0.2, 0.2) * delta
		if sprite.global_scale.x <= 0.05:
			#Globals.active_asteroids -= 1
			queue_free()	

func explode():
	hits += 1
	if hits == asteroid["hits"]:
		emit_signal("exploded", global_position, size)
		queue_free()

func _physics_process(delta):
	teleport()
	shrink(delta)
	linear_velocity = linear_velocity.limit_length(max_speed)
	angular_velocity = clamp(angular_velocity, -2.0, 2.0)

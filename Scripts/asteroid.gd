class_name Asteroid extends RigidBody2D


@export var size = AsteroidConfig.asteroid_size.HUGE
@export var max_speed: float = 400
@export var expel_force: float = 200

@onready var sprite = $asteroid_sprite
@onready var collision = $asteroid_collision
@onready var nav_obstacle = $NavigationObstacle2D
@onready var timer_max_outside = $timer_max_outside

var rng = RandomNumberGenerator.new()
var hits: int = 0	# Nº de golpes que lleva (romperse/dividirse)
var asteroid: Dictionary
var texture: Texture2D
var screen_size: Vector2
var sprite_size: Vector2

signal exploded(size, pos)	# Cuando explota se lo indica al spawner (dividirse)


func _ready() -> void:
	asteroid = AsteroidConfig.ASTEROID_DATA[size]	

	sprite.texture = texture
	screen_size = get_viewport_rect().size
	sprite_size = sprite.texture.get_size() / 2

	if asteroid["collision"]:
		var texture_name = sprite.texture.resource_path.get_file().replace(".png", "")
		var collision_path = "res://Resources/asteroids_collisions/Asteroid_CS_%s.tres" % texture_name.replace("Asteroid_", "")
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
	
func _physics_process(delta):
	teleport()
	shrink(delta)
	linear_velocity = linear_velocity.limit_length(max_speed)
	angular_velocity = clamp(angular_velocity, -2.0, 2.0)

# El spawner llama a esta función para asignar la textura
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
		
# Wrap around (teletransporte en los bordes y expulsión)
func teleport():	
	global_position.x = wrapf(global_position.x, -sprite_size.x, screen_size.x + sprite_size.x)
	global_position.y = wrapf(global_position.y, -sprite_size.y, screen_size.y + sprite_size.y)	
	
	# Si está fuera de los límites comienza el temporizador de expulsión
	var out_of_bounds = false
	if (global_position.x < 0 or global_position.x > screen_size.x) or (global_position.y < 0 or global_position.y > screen_size.y):
		out_of_bounds = true
			
	if out_of_bounds && timer_max_outside.is_stopped():
		timer_max_outside.start()
	elif !out_of_bounds && !timer_max_outside.is_stopped():
		timer_max_outside.stop()

# Cuando lleva demasiado tiempo fuera del mapa se le expulsa hacia el centro	
func _on_timer_max_outside_timeout() -> void:
	var direction_to_center = (get_viewport_rect().size / 2 - global_position).normalized()
	linear_velocity = direction_to_center * expel_force
	timer_max_outside.stop()
	
# Los asteroides SMALL y TINY encojen hasta desaparecer
func shrink(delta):
	if asteroid["shrinks"]:
		sprite.global_scale -= Vector2(0.2, 0.2) * delta
		if sprite.global_scale.x <= 0.05:
			queue_free()	

# Cuando ha recibido un golpe se divide si ha alcanzado un número de hits
func explode():
	hits += 1
	if hits == asteroid["hits"]:
		emit_signal("exploded", global_position, size)
		queue_free()

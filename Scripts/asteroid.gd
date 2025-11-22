class_name Asteroid extends RigidBody2D

var rng = RandomNumberGenerator.new()

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D

@export var size = AsteroidConfig.asteroid_size.HUGE

var hits: int = 0
var asteroid: Dictionary
var texture: Texture2D

signal exploded(size, pos)


func _ready() -> void:
	asteroid = AsteroidConfig.ASTEROID_DATA[size]	

	sprite.texture = texture

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

# El spawner llama esta función para asignar la textura
func set_texture(new_texture):
	texture = new_texture
	#sprite.texture = new_texture

func teleport():
	var screen_size = get_viewport_rect().size
	var sprite_size = sprite.texture.get_size() / 2
	
	global_position.x = wrapf(global_position.x, -sprite_size.x, screen_size.x + sprite_size.x)
	global_position.y = wrapf(global_position.y, -sprite_size.y, screen_size.y + sprite_size.y)	
	
# Los asteroides SMALL y TINY encojen hasta desaparecer
func shrink(delta):
	if AsteroidConfig.ASTEROID_DATA[size]["shrinks"]:
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

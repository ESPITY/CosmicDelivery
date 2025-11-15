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
		"prefix": "Asteroid_Huge-",
		"hits": 10
	},
	asteroid_size.BIG: {
		"speed_range": Vector2(-150, 150),
		"prefix": "Asteroid_Big-",
		"hits": 8
	},
	asteroid_size.MEDIUM: {
		"speed_range": Vector2(-200, 200),
		"prefix": "Asteroid_Medium-",
		"hits": 6
	},
	asteroid_size.SMALL: {
		"speed_range": Vector2(-250, 250),
		"prefix": "Asteroid_Small-",
		"hits": 4
	},
	asteroid_size.TINY: {
		"speed_range": Vector2(-300, 300),
		"prefix": "Asteroid_Tiny-",
		"hits": 2
	}
}

var hits: int = 0

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
	sprite.texture = load(texture_path)
	
	if (size == asteroid_size.SMALL) || (size == asteroid_size.TINY):
		collision.set_disabled(true)
	else:
		var collision_path = "res://Resources/" + asteroid["prefix"].replace("Asteroid_", "Asteroid_CS_") + str(suffix) + ".tres"
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
	
# Los asteroides SMALL y TINY encojen hasta desaparecer
func shrink(delta):
	if(size == asteroid_size.SMALL) || (size == asteroid_size.TINY):
		if sprite.global_scale.x > 0.05 && sprite.global_scale.y > 0.05:
			sprite.global_scale -= Vector2(0.2, 0.2) * delta
		else:
			queue_free()	
	
func _physics_process(delta):
	teleport()
	shrink(delta)

func explode():
	hits += 1
	var asteroid = asteroid_data[size]
	if hits == asteroid["hits"]:
		emit_signal("exploded", global_position, size)
		queue_free()

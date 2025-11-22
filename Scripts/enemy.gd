extends CharacterBody2D

@export var speed: float = 100
@export var shooting_distance: float = 400
@export var fire_rate: float = 0.5

@onready var bullet = preload("res://Scenes/bullet.tscn")
@onready var gun = $gun
@onready var propeller = $propeller
@onready var sprite = $spaceship
var fired: bool = false
enum State { APPROACHING, SHOOTING }
var current_state: State = State.APPROACHING

var player: Node2D
var screen_size: Vector2
var sprite_size: Vector2

func _ready():
	player = get_tree().get_first_node_in_group("player")
	screen_size = get_viewport_rect().size
	sprite_size = sprite.texture.get_size() / 2

func _physics_process(delta):
	var target_pos = shortest_path(player.global_position)
	var distance = global_position.distance_to(target_pos)
	
	match current_state:
		State.APPROACHING:
			if distance <= shooting_distance:
				current_state = State.SHOOTING
			else:
				move_towards(target_pos, delta)
		
		State.SHOOTING:
			fire()
			if distance > shooting_distance:
				current_state = State.APPROACHING
			else:
				rotate_towards(target_pos, delta)
				velocity = Vector2.ZERO
	
	move_and_slide()

func _process(delta):
	teleport()

func move_towards(target_pos: Vector2, delta: float):
	var direction = (target_pos - global_position).normalized()
	velocity = direction * speed
	rotation = direction.angle()
	
func rotate_towards(target_pos: Vector2, delta: float):
	var direction = (target_pos - global_position).normalized()
	rotation = lerp_angle(rotation, direction.angle(), 8 * delta)

# Disparar cada X tiempo
func fire():
	if !fired:
		fired = true
		var bullet_inst = bullet.instantiate()
		get_parent().add_child(bullet_inst)
		bullet_inst.global_position = gun.global_position
		bullet_inst.rotation = rotation
			
		await get_tree().create_timer(fire_rate).timeout
		fired = false

# Calcula el camino más corto al jugador teniendo en cuenta los bordes
func shortest_path(target_pos: Vector2) -> Vector2:
	var direct_distance = global_position.distance_to(target_pos)
	
	# Buscar camino más corto considerando bordes
	var alternatives = [
		Vector2(target_pos.x - screen_size.x, target_pos.y),
		Vector2(target_pos.x + screen_size.x, target_pos.y),
		Vector2(target_pos.x, target_pos.y - screen_size.y),
		Vector2(target_pos.x, target_pos.y + screen_size.y)
	]
	
	var shortest_pos = target_pos
	var shortest_dist = direct_distance
	
	for alt in alternatives:
		var dist = global_position.distance_to(alt)
		if dist < shortest_dist:
			shortest_dist = dist
			shortest_pos = alt
	
	return shortest_pos
	
# Wrap around (teletransporte en los bordes)
func teleport():
	global_position.x = wrapf(global_position.x, -sprite_size.x, screen_size.x + sprite_size.x)
	global_position.y = wrapf(global_position.y, -sprite_size.y, screen_size.y + sprite_size.y)

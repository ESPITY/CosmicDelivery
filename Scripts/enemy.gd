extends CharacterBody2D

# Navigation
@onready var nav_agent = $NavigationAgent2D

@export var speed: float = 200
@export var shooting_distance: float = 400

var player: Node2D

# State machine
@export var expel_state_time: float = 1.5

enum State { APPROACHING, SHOOTING, EXPELLED }

var current_state: State = State.APPROACHING

# Visibilidad propeller
@onready var propeller = $propeller

# Wrap around
@onready var sprite = $spaceship_sprite
@onready var timer_max_outside = $timer_max_outside

@export var expel_force: float = 200

var screen_size: Vector2
var sprite_size: Vector2

# Disparar
@onready var bullet = preload("res://Scenes/bullet.tscn")
@onready var gun = $gun

@export var fire_rate: float = 0.5

var fired: bool = false


# Obtiene el tamaño de la pantalla y de la mitad del sprite, referencia al jugador y configura el NavAgent2D
func _ready():
	player = get_tree().get_first_node_in_group("player")
	
	screen_size = get_viewport_rect().size
	sprite_size = sprite.texture.get_size() / 2
	
	var radius = max(sprite_size.x, sprite_size.y)
	nav_agent.radius = radius
	nav_agent.max_speed = speed

# Máquina de estados
func _physics_process(delta):
	var distance = global_position.distance_to(player.global_position)
	
	match current_state:
		State.APPROACHING:
			if distance <= shooting_distance:
				current_state = State.SHOOTING
			else:
				update_nav()
		
		State.SHOOTING:
			fire()
			if distance > shooting_distance:
				current_state = State.APPROACHING
			else:
				rotate_towards(player.global_position, delta)
				velocity = Vector2.ZERO
				move_and_slide()
				
		State.EXPELLED:
			move_and_slide()

func _process(delta):
	teleport()
	
# Navegacion y cálculo del path
func update_nav():
	var target_pos = get_closest_target()
	nav_agent.target_position = target_pos
	
	if nav_agent.is_navigation_finished():
		velocity = Vector2.ZERO
	else:
		var next_path_position = nav_agent.get_next_path_position()
		var direction = (next_path_position - global_position).normalized()
		
		nav_agent.set_velocity(speed * direction)
		
# Calcula el camino más corto al jugador teniendo en cuenta el wrap around de los bordes
func get_closest_target() -> Vector2:
	var player_pos = player.global_position
	var direct_distance = global_position.distance_to(player_pos)
	
	var alternatives = [
		Vector2(player_pos.x - screen_size.x, player_pos.y),
		Vector2(player_pos.x + screen_size.x, player_pos.y),
		Vector2(player_pos.x, player_pos.y - screen_size.y),
		Vector2(player_pos.x, player_pos.y + screen_size.y)
	]
	
	var closest_target = player_pos
	var closest_dist = direct_distance
	
	for alt in alternatives:
		var dist = global_position.distance_to(alt)
		if dist < closest_dist:
			closest_dist = dist
			closest_target = alt
	
	return closest_target
		
# El NavigationAgent2D calcula la velocidad teniendo en uenta el avoidance
func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	if current_state == State.APPROACHING:
		velocity = safe_velocity
		if safe_velocity.length() > 0.1:
			rotation = safe_velocity.angle()
		move_and_slide()
	
func rotate_towards(target_pos: Vector2, delta: float):
	var direction = (target_pos - global_position).normalized()
	rotation = lerp_angle(rotation, direction.angle(), 8 * delta)
	
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

# Cuando lleva demsiado tiempo fuera del mapa se le expulsa hacia el centro
func _on_timer_max_outside_timeout() -> void:
	current_state = State.EXPELLED	# Cambia de estado si no se sobreescribiría la velocidad modificada
	
	var direction_to_center = (get_viewport_rect().size / 2 - global_position).normalized()
	velocity = direction_to_center * expel_force
	timer_max_outside.stop()
	
	await get_tree().create_timer(expel_state_time).timeout
	current_state = State.APPROACHING

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

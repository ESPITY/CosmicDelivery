extends CharacterBody2D

# Navigation
@onready var nav_agent = $NavigationAgent2D

@export var max_speed: float = 200
@export var shooting_distance: float = 400

var player: Node2D

# State machine
@export var expel_state_time: float = 1.5
@export var min_shooting_time: float = 0.5

enum State { APPROACHING, SHOOTING, EXPELLED }

var current_state: State = State.APPROACHING

# Visibilidad propeller
@onready var propeller = $propeller

# Wrap around
@onready var sprite = $spaceship_sprite
@onready var timer_max_outside = $timer_max_outside
@onready var hits_collision = $Area2D_hits/hits_collision

@export var expel_force: float = 200

var screen_size: Vector2
var sprite_size: Vector2

# Disparar
@onready var bullet = preload("res://Scenes/bullet.tscn")
@onready var gun = $gun

@export var fire_rate: float = 0.5

var fired: bool = false

# Vida
@onready var healthbar = $healthbar
@onready var explosion_vfx = $explosion_vfx

@export var hit_effect_timer: float = 0.1
@export var explosion_vfx_timer: float = 2

var max_health = Config.ENEMY_DATA["max_health"]
var health: float = max_health

signal update_healthbar(health)


# Obtiene la referencia al jugador, el tamaño de la pantalla y de la mitad del sprite y configura el NavAgent2D
func _ready():
	var nodes = get_tree().get_nodes_in_group("player")
	for node in nodes:
		if node is CharacterBody2D:
			player = node
	
	screen_size = get_viewport_rect().size
	sprite_size = sprite.texture.get_size() / 2
	
	var radius = max(sprite_size.x, sprite_size.y)
	nav_agent.radius = radius
	nav_agent.max_speed = max_speed
	
	# Healthbar
	healthbar.set_healthbar(max_health)
	update_healthbar.connect(healthbar._on_update_healthbar)

# Máquina de estados
func _physics_process(delta):
	if health > 0 && player && player.health > 0:
		var distance = global_position.distance_to(player.global_position)
		
		match current_state:
			State.APPROACHING:
				propeller.visible = true 
				if distance <= shooting_distance:
					current_state = State.SHOOTING
				else:
					update_nav()
			
			State.SHOOTING:
				propeller.visible = false
				if distance > shooting_distance:
					await get_tree().create_timer(min_shooting_time).timeout
					current_state = State.APPROACHING
				else:
					rotate_towards(player.global_position, delta)
					fire()
					velocity = Vector2.ZERO
					move_and_slide()
					
			State.EXPELLED:
				propeller.visible = true 
				move_and_slide()
				
		velocity = velocity.limit_length(max_speed)	# Velocidad máxima

func _process(delta):
	if health > 0 && player && player.health > 0:
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
		
		nav_agent.set_velocity(max_speed * direction)
		
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
	
# Wrap around (teletransporte en los bordes y expulsión) + desactivar colisión fuera de pantalla
func teleport():
	global_position.x = wrapf(global_position.x, -sprite_size.x, screen_size.x + sprite_size.x)
	global_position.y = wrapf(global_position.y, -sprite_size.y, screen_size.y + sprite_size.y)
	
	# Si está fuera de los límites comienza el temporizador de expulsión
	var out_of_bounds = false
	healthbar.visible = true
	hits_collision.disabled = false
	if (global_position.x < 0 or global_position.x > screen_size.x) or (global_position.y < 0 or global_position.y > screen_size.y):
		out_of_bounds = true	
		healthbar.visible = false
		hits_collision.disabled = true
			
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

# Detección de choque
func _on_area_2d_hits_body_entered(body: Node2D) -> void:
	if body.is_in_group("asteroids"):
		var asteroid = Config.ASTEROID_DATA[body.size]
		
		# Retroceso del jugador
		var push_direction = (body.global_position - global_position).normalized()
		var player_knockback = asteroid["knockback_force"]
		velocity += push_direction * -1 * player_knockback
		
		body.explode()
		damaged(asteroid["attack"])
		hit_effect()
	
	#if body.is_in_group("enemies"):
		#damaged(Config.ENEMY_DATA["hit_object"])
		#hit_effect()
	
	if body.is_in_group("player"):
		damaged(Config.PLAYER_DATA["hit_object"])
		hit_effect()

# Efecto visual de daño
func hit_effect():
	sprite.modulate = Color("ff8473ff")
	await get_tree().create_timer(hit_effect_timer).timeout
	sprite.modulate = Color("ffffff")

# Daño
func damaged(damage):
	health -= damage
	if health <= 0:
		death()
	emit_signal("update_healthbar", health)

# Muerte con explosión
func death():
	health = 0
	emit_signal("update_healthbar", health)
	await get_tree().create_timer(0.1).timeout
	
	Config.active_enemies -= 1
	Config.current_score += Config.ENEMY_DATA["points"]
	
	sprite.visible = false
	propeller.visible = false
	healthbar.visible = false
	hits_collision.call_deferred("set", "disabled", true)
	$physics_collision.call_deferred("set", "disabled", true)
	
	explosion_vfx.play_vfx()
	await get_tree().create_timer(explosion_vfx_timer).timeout
	
	queue_free()

extends CharacterBody2D

# Rotación: radianes/s y radianes/s^2
@export var rotation_speed: float = PI
@export var rotational_acceleration: float = TAU * 1

# Movimiento: píxeles/s y píxeles/s^2
@export var max_speed: float = 400
@export var vel_acceleration: float = 600
@export var vel_deceleration: float = 50

var rotation_direction: float = 0
var movement_direction: float = 0
var rotational_velocity:float  = 0

# Visibilidad de los propulsores
@onready var front_left_propeller = $front_left_propeller
@onready var front_right_propeller = $front_right_propeller
@onready var back_left_propeller = $back_left_propeller
@onready var back_right_propeller = $back_right_propeller

var propeller_options = {
	"none": [false, false, false, false],
	"up": [true, true, false, false],
	"down": [false, false, true, true],
	"left": [false, true, false, false],
	"right": [true, false, false, false],
	"down_right": [false, false, true, false],
	"down_left": [false, false, false, true]
}

# Wrap around
@onready var sprite = $spaceship
@onready var timer_max_outside = $timer_max_outside

@export var expel_force: float = 200

# Disparar
@onready var bullet = preload("res://Scenes/bullet.tscn")
@onready var left_gun = $left_gun
@onready var right_gun = $right_gun

@export var fire_timer: float = 0.5

var fired: bool = false

# Vida
@export var max_health: float = 100
var health: float = max_health
signal update_healthbar(health)


# Rotación y movimiento de la nave con aceleración y fricción
func movement(delta):
	# Rotación con deceleración y aceleración
	rotation_direction = Input.get_axis("left", "right")
	#rotation += rotation_direction * rotation_speed * delta
	if rotation_direction == 0:
		rotation_direction = sign(rotational_velocity) * -1
	
	rotational_velocity += rotation_direction * rotational_acceleration * delta
	rotational_velocity = clamp(rotational_velocity, -rotation_speed, rotation_speed)
	
	rotation += rotational_velocity * delta
	
	# Movimiento con fricción y aceleración
	movement_direction = Input.get_axis("down", "up")
	if movement_direction == 0:
		velocity = velocity.move_toward(Vector2.ZERO, (vel_deceleration * delta))
	else:
		velocity += transform.x * movement_direction * (vel_acceleration * delta)
		velocity = velocity.limit_length(max_speed)
	
func _input(event):
	if event is InputEventKey:
		if event.pressed || event.is_released():
			propulsion()	# Solo realizar la comprobación cuando se pulsa o suelta una tecla
	
# Visibilidad de los propulsores según el movimiento
func propulsion():
	var input_action = "none"
	if Input.is_action_pressed("up") && Input.is_action_pressed("right"):
		input_action = "right"
	elif Input.is_action_pressed("up") && Input.is_action_pressed("left"):
		input_action = "left"
	elif Input.is_action_pressed("down") && Input.is_action_pressed("right"):
		input_action = "down_right"	
	elif Input.is_action_pressed("down") && Input.is_action_pressed("left"):
		input_action = "down_left"
	elif Input.is_action_pressed("up"):
		input_action = "up"
	elif Input.is_action_pressed("down"):
		input_action = "down"
	elif Input.is_action_pressed("left"):
		input_action = "left"	
	elif Input.is_action_pressed("right"):
		input_action = "right"
	else:
		input_action = "none"
	
	var propellers = propeller_options[input_action]
	back_left_propeller.visible = propellers[0]
	back_right_propeller.visible = propellers[1]
	front_left_propeller.visible = propellers[2]
	front_right_propeller.visible = propellers[3]
	
# Wrap around (teletransporte en los bordes y expulsión al campear)
func teleport():
	var screen_size = get_viewport_rect().size
	var sprite_size = sprite.texture.get_size() / 2
	
	global_position.x = wrapf(global_position.x, -sprite_size.x, screen_size.x + sprite_size.x)
	global_position.y = wrapf(global_position.y, -sprite_size.y, screen_size.y + sprite_size.y)
	
	# Si la nave está fuera de los límites comienza el temprizador de campear
	var out_of_bounds = false
	if (global_position.x < 0 or global_position.x > screen_size.x) or (global_position.y < 0 or global_position.y > screen_size.y):
		out_of_bounds = true
			
	if out_of_bounds && timer_max_outside.is_stopped():
		timer_max_outside.start()
	elif !out_of_bounds && !timer_max_outside.is_stopped():
		timer_max_outside.stop()

# Cuando el jugador lleva demsiado tiempo fuera del mapa se le expulsa hacia el centro
func _on_timer_max_outside_timeout() -> void:
	var direction_to_center = (get_viewport_rect().size / 2 - position).normalized()
	velocity = direction_to_center * expel_force
	timer_max_outside.stop()

# Disparar cada X tiempo
func fire():
	if Input.is_action_pressed("fire") && !fired:
		fired = true
		var bullet_inst1 = bullet.instantiate()
		get_parent().add_child(bullet_inst1)
		bullet_inst1.global_position = left_gun.global_position
		bullet_inst1.rotation = rotation
		
		var bullet_inst2 = bullet.instantiate()
		get_parent().add_child(bullet_inst2)
		bullet_inst2.global_position = right_gun.global_position
		bullet_inst2.rotation = rotation
		
		await get_tree().create_timer(fire_timer).timeout
		fired = false

func _physics_process(delta):
	movement(delta)
	#var hola = move_and_slide()
	#print(hola)
	move_and_slide()
	teleport()
	fire()

# Detección de choque
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("asteroids"):
		body.explode()
		#var asteroid = body.asteroid_data[body.size]
		#damaged(body.asteroid["attack"])
		var asteroid = body.get_asteroid_data()
		damaged(asteroid["attack"])
		
		sprite.modulate = Color("ff8473ff")
		await get_tree().create_timer(0.1).timeout
		sprite.modulate = Color("ffffff")

# Daño
func damaged(damage):
	health -= damage
	if health <= 0:
		health = 0
	emit_signal("update_healthbar", health)

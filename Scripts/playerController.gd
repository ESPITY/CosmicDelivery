extends CharacterBody2D

# Rotación: radianes/s y radianes/s^2
@export var rotation_speed: float = PI
@export var rotational_acceleration: float = TAU * 1

# Movimiento: píxeles/s y píxeles/s^2
@export var max_speed: float = 400
@export var vel_acceleration: float = 600
@export var vel_deceleration: float = 100

var rotation_direction: float = 0
var movement_direction: float = 0
var rotational_velocity:float  = 0

# Rotación y movimiento de la nave con aceleración y fricción
func movement(delta):
	# Rotación con deceleración y aceleración
	rotation_direction = Input.get_axis("left", "right")
	#rotation += rotation_direction * rotation_speed * delta
	if(rotation_direction == 0):
		rotation_direction = sign(rotational_velocity) * -1
	
	rotational_velocity += rotation_direction * rotational_acceleration * delta
	rotational_velocity = clamp(rotational_velocity, -rotation_speed, rotation_speed)
	
	rotation += rotational_velocity * delta
	
	
	# Movimiento con fricción y aceleración
	movement_direction = Input.get_axis("down", "up")
	if(movement_direction == 0):
		velocity = velocity.move_toward(Vector2.ZERO, (vel_deceleration * delta))
	else:
		velocity += transform.x * movement_direction * (vel_acceleration * delta)
		velocity = velocity.limit_length(max_speed)

func _physics_process(delta):
	movement(delta)
	move_and_slide()

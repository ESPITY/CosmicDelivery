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
	
# Wrap around de los bordes	
func teleport():
	var screen_size = get_viewport_rect().size
	var sprite_size_x = $Sprite2D.texture.get_width() / 2
	var sprite_size_y = $Sprite2D.texture.get_height() / 2
	
	position.x = wrapf(position.x, -sprite_size_x, screen_size.x + sprite_size_x)
	position.y = wrapf(position.y, -sprite_size_y, screen_size.y + sprite_size_y)
		

func _physics_process(delta):
	movement(delta)
	move_and_slide()
	teleport()

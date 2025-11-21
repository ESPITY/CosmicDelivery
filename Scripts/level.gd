extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.active_asteroids = 0
	Globals.current_level = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()

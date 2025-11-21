extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.active_asteroids = 0
	
	match Globals.current_level:
		1: $level1.visible = true
		2: $level2.visible = true
		3: $level3.visible = true
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()

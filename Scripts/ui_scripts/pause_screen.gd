extends CanvasLayer

@onready var fade_anim = $AnimationPlayer

var paused: bool = false


func _ready() -> void:
	hide()
	
	# Precargar la animación
	fade_anim.play("pause")
	fade_anim.seek(0)  # Posicionar al inicio
	fade_anim.stop()   # Detener inmediatamente

# Manejo de inputs
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if paused:	# Reanudar juego
			resume()
		else:	# Pausar juego
			pause()

# Reanudar juego
func resume():
	fade_anim.play_backwards("pause")
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	paused = false
	get_tree().paused = false
	Config.playing = true

# Pausar juego
func pause():
	paused = true
	get_tree().paused = true
	Config.playing = false
	show()
	fade_anim.play("pause")
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# Oculta la pantalla de pausa al acabar la animación
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "pause" and !paused:
		hide()

# Botón de reaundar
func _on_resume_button_pressed() -> void:
	resume()

# Botón de reseteo de nivel
func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

# Botón de regresar al menú principal
func _on_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/ui_scenes/main_menu.tscn")

# Botón de salir del juego
func _on_exit_button_pressed() -> void:
	get_tree().quit()

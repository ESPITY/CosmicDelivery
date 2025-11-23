extends Control


# En el menú principal el nivel actual es 0
func _ready() -> void:
	Globals.current_level = 0

# Botón de jugar que lleva al selector de niveles
func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/ui_scenes/level_selector.tscn")

# Botón de salir que cierra el juego
func _on_exit_button_pressed() -> void:
	get_tree().quit()

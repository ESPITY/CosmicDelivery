extends Control


# Muestra el cursor
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# Botón de reseteo de nivel
func _on_restart_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/game.tscn")

# Botón de regresar al menú principal
func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/ui_scenes/main_menu.tscn")

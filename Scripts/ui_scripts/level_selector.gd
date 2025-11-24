extends Control

@onready var game_scene = preload("res://Scenes/game.tscn")

# Muestra el cursor
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
# Botón nivel 1
func _on_level_1_button_pressed() -> void:
	Config.current_level = 1
	get_tree().change_scene_to_packed(game_scene)

# Botón nivel 2
func _on_level_2_button_pressed() -> void:
	Config.current_level = 2
	get_tree().change_scene_to_packed(game_scene)

# Botón nivel 3
func _on_level_3_button_pressed() -> void:
	Config.current_level = 3
	get_tree().change_scene_to_packed(game_scene)

# Botón volver al menú principal
func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/ui_scenes/main_menu.tscn")

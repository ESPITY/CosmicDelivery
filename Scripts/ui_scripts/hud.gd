extends Control

@onready var healthbar = $MarginContainer/HBoxContainer/healthbar


# Obtiene el jugador y conectarlo a la healthbar signándole la vida máxima
func _ready() -> void:
	var player: CharacterBody2D
	var nodes = get_tree().get_nodes_in_group("player")
	for node in nodes:
		if node is CharacterBody2D:
			player = node
			
	healthbar.set_healthbar(player.max_health)
	player.connect_healthbar(healthbar)

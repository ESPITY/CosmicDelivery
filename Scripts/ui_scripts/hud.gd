extends CanvasLayer

@onready var healthbar = $MarginContainer/HBoxContainer/healthbar
@onready var current_score_label = $MarginContainer/HBoxContainer/HBoxContainer/current_score_label
@onready var level_elapsed_time_label = $MarginContainer/HBoxContainer/HBoxContainer2/level_elapsed_time_label
@onready var target_score_label =$MarginContainer/HBoxContainer/HBoxContainer/target_score_label

# Obtiene el jugador y lo conectar a la healthbar, signándole la vida máxima
func _ready() -> void:
	var player: CharacterBody2D
	var nodes = get_tree().get_nodes_in_group("player")
	for node in nodes:
		if node is CharacterBody2D:
			player = node
			
	healthbar.set_healthbar(player.max_health)
	player.connect_healthbar(healthbar)
	
	target_score_label.text = str(Config.LEVEL_TARGET_SCORE[Config.current_level])

# Imprime en los labels la puntuación y el tiempo de juego
func _process(delta):
	current_score_label.text = str(Config.current_score)
	level_elapsed_time_label.text = format_time(Config.level_elapsed_time)

# Da formato al tiempo de juego 99:99:99 (minutos, segúndos, centésimas)
func format_time(seconds: float) -> String:
	var mins = int(seconds) / 60
	var secs = int(seconds) % 60
	var hunds = int((seconds - int(seconds)) * 100)
	
	mins = min(mins, 99)
	secs = min(secs, 99)
	hunds = min(hunds, 99)
	
	return "%02d:%02d:%02d" % [mins, secs, hunds]

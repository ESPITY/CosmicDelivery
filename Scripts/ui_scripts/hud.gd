extends Control

@onready var healthbar = $MarginContainer/HBoxContainer/healthbar

@export var player: CharacterBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.connect("update_healthbar", _on_update_healthbar)
	pass # Replace with function body.a


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_update_healthbar(health):
	healthbar.value = health
	pass

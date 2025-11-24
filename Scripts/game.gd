extends Node2D

@onready var nav_region = $NavigationRegion2D
@onready var player = $NavigationRegion2D/player_items/player
@onready var pause_screen = $death_screen

@export var death_screen: PackedScene

var screen_size: Vector2
var level_start_time: float = 0.0


func _ready() -> void:
	start_game()
	set_nav_region()
	
func _process(delta: float) -> void:
	if Config.playing:
		Config.level_elapsed_time = (Time.get_ticks_msec() / 1000.0) - level_start_time	
			
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
	#print("NavigationRegion rebaked - Asteroides: ", get_tree().get_nodes_in_group("asteroids").size())
	#print(Config.active_asteroids)

# Configuración inicial del juego
func start_game():
	Config.playing = true
	Config.active_asteroids = 0
	Config.active_enemies = 0
	Config.current_score = 0
	Config.level_elapsed_time = 0
	level_start_time = Time.get_ticks_msec() / 1000.0
	
	match Config.current_level:
		1: $level_planets/level1_planets.visible = true
		2: $level_planets/level2_planets.visible = true
		3: $level_planets/level3_planets.visible = true
		
	screen_size = get_viewport_rect().size
	player.global_position = screen_size / 2
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)

# Crea la región de navegación que ocupa toda la pantalla (+ margen)
func set_nav_region():
	var navigation_polygon = NavigationPolygon.new()
	var outline = PackedVector2Array()
	var margin = 100
	
	outline.append(Vector2(-margin, -margin))
	outline.append(Vector2(screen_size.x + margin, -margin))
	outline.append(Vector2(screen_size.x + margin, screen_size.y + margin))
	outline.append(Vector2(-margin, screen_size.y + margin))
	
	navigation_polygon.add_outline(outline)
	navigation_polygon.make_polygons_from_outlines()
	nav_region.navigation_polygon = navigation_polygon
	
	nav_region.call_deferred("bake_navigation_polygon")

# Cuando se termina de bakear el NavRegion2D se vuelve a bakear
func _on_navigation_region_2d_bake_finished() -> void:
	if Config.playing:
		nav_region.bake_navigation_polygon()

extends Node2D

@onready var nav_region = $NavigationRegion2D
@onready var player = $NavigationRegion2D/player

var screen_size: Vector2

func _ready() -> void:
	Globals.active_asteroids = 0
	
	match Globals.current_level:
		1: $level_planets/level1_planets.visible = true
		2: $level_planets/level2_planets.visible = true
		3: $level_planets/level3_planets.visible = true
		
	screen_size = get_viewport_rect().size
	player.global_position = screen_size / 2
	
	set_nav_region()

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
	
	nav_region.bake_navigation_polygon()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
	#print("NavigationRegion rebaked - Asteroides: ", get_tree().get_nodes_in_group("asteroids").size())
	#print(Globals.active_asteroids)

# Cuando se termina de bakear el NavRegion2D se vuelve a bakear
func _on_navigation_region_2d_bake_finished() -> void:
	nav_region.bake_navigation_polygon()

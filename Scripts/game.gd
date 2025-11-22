extends Node2D

@onready var nav_region = $NavigationRegion2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.active_asteroids = 0
	
	match Globals.current_level:
		1: $level1.visible = true
		2: $level2.visible = true
		3: $level3.visible = true
	
	set_nav_region()

func set_nav_region():
	# Crear NavigationPolygon base que cubra toda el área de juego
	var navigation_polygon = NavigationPolygon.new()
	var outline = PackedVector2Array()
	
	var margin = 100  # Margen fuera de pantalla
	var screen_size = get_viewport_rect().size
	
	outline.append(Vector2(-margin, -margin))
	outline.append(Vector2(screen_size.x + margin, -margin))
	outline.append(Vector2(screen_size.x + margin, screen_size.y + margin))
	outline.append(Vector2(-margin, screen_size.y + margin))
	
	navigation_polygon.add_outline(outline)
	navigation_polygon.make_polygons_from_outlines()
	nav_region.navigation_polygon = navigation_polygon
	
	nav_region.bake_navigation_polygon()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
	#print("NavigationRegion rebaked - Asteroides: ", get_tree().get_nodes_in_group("asteroids").size())
	#print(Globals.active_asteroids)


func _on_navigation_region_2d_bake_finished() -> void:
	nav_region.bake_navigation_polygon()

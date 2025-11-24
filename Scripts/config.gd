# config.gd
extends Node

# ----------------------------- VARIABLES GLOBALES -----------------------------
var current_level: int = 1
var active_asteroids: int = 0
var active_enemies: int = 0
var player_max_health: int = 100
var current_score: int = 0
var level_elapsed_time: float = 0.0
var playing: bool = false

# -------------------------------- PUNTUACIONES --------------------------------
# Objetivos de puntuación por nivel
const LEVEL_TARGET_SCORE = {
	1: 1000,
	2: 3000,
	3: 6000
}

var level_score_records = {
	1: {"best_score": 0, "best_time": 0.0, "completed": false},
	2: {"best_score": 0, "best_time": 0.0, "completed": false},
	3: {"best_score": 0, "best_time": 0.0, "completed": false}
}

# ---------------------------------- JUGADOR ----------------------------------

# Golpes (balas y choque) del JUGADOR
const PLAYER_DATA = {
	"attack": 10,
	"hit_object": 5,
	"max_health": 100
}

# ---------------------------------- ENEMIGOS ----------------------------------

# Golpes (balas y choque) de los ENEMIGOS
const ENEMY_DATA = {
	"attack": 10,
	"hit_object": 5,
	"max_health": 100,
	"points": 150
}

# Datos de configuración del SPAWNER ENEMIGOS según el NIVEL
const ENEMY_SPAWNER_DATA = {
	1: {
		"max_enemies": 2,
		"spawn_interval": 2.0,
	},
	2: {
		"max_enemies": 4,
		"spawn_interval": 1.5,
	},
	3: {
		"max_enemies": 6,
		"spawn_interval": 1.0,
	}
}

# --------------------------------- ASTEROIDES ---------------------------------
enum asteroid_size {HUGE, BIG, MEDIUM, SMALL, TINY}

# Datos de configuración del SPAWNER ASTEROIDES según el NIVEL
const ASTEROID_SPAWNER_DATA = {
	1: {
		"max_asteroids": 5,
		"spawn_interval": 2.0,
		# Huge, big, medium, small, tiny
		"size_rand_weights": [2.0, 1.0, 0.5]
	},
	2: {
		"max_asteroids": 10,
		"spawn_interval": 1.0,
		"size_rand_weights": [1.0, 2.0, 0.5]
	},
	3: {
		"max_asteroids": 15,
		"spawn_interval": 0.5,
		"size_rand_weights": [0.5, 1.0, 2.0]
	}
}

# Datos de configuración del ASTEROIDE según el TAMAÑO
const ASTEROID_DATA = {
	asteroid_size.HUGE: {
		"speed_range": Vector2(50, 100),
		"prefix": "Asteroid_Huge-",
		"hits": 8,
		"attack": 15,
		"num_textures": 4,
		"collision": true,
		"shrinks": false,
		"mass": 10.0,
		"friction": 0.0,
		"bounce": 0.1,
		"push_force": 800.0,
		"knockback_force": 100.0,
		"points": 100
	},
	asteroid_size.BIG: {
		"speed_range": Vector2(75, 150),
		"prefix": "Asteroid_Big-",
		"hits": 6,
		"attack": 10,
		"num_textures": 4,
		"collision": true,
		"shrinks": false,
		"mass": 8.0,
		"friction": 0.0,
		"bounce": 0.2,
		"push_force": 1200.0,
		"knockback_force": 80.0,
		"points": 75
	},
	asteroid_size.MEDIUM: {
		"speed_range": Vector2(100, 200),
		"prefix": "Asteroid_Medium-",
		"hits": 4,
		"attack": 5,
		"num_textures": 2,
		"collision": true,
		"shrinks": false,
		"mass": 6.0,
		"friction": 0.0,
		"bounce": 0.3,
		"push_force": 1600.0,
		"knockback_force": 40.0,
		"points": 50
	},
	asteroid_size.SMALL: {
		"speed_range": Vector2(125, 250),
		"prefix": "Asteroid_Small-",
		"hits": 0,
		"attack": 0,
		"num_textures": 2,
		"collision": false,
		"shrinks": true,
		"mass": 4.0,
		"friction": 0.0,
		"bounce": 0.4,
		"push_force": 2000.0,
		"knockback_force": 20.0,
		"points": 25
	},
	asteroid_size.TINY: {
		"speed_range": Vector2(150, 300),
		"prefix": "Asteroid_Tiny-",
		"hits": 0,
		"attack": 0,
		"num_textures": 2,
		"collision": false,
		"shrinks": true,
		"mass": 2.0,
		"friction": 0.0,
		"bounce": 0.5,
		"push_force": 2400.0,
		"knockback_force": 10.0,
		"points": 10
	}
}

# Patrones de tamaños de DIVISIÓN del ASTEROIDE
const SPLIT_PATTERNS = {
	asteroid_size.HUGE: {
		asteroid_size.BIG: Vector2i (2, 3),
		asteroid_size.MEDIUM: Vector2i(0, 2),
		asteroid_size.SMALL: Vector2i(0, 2),
		asteroid_size.TINY: Vector2i(0, 1)
	},
	asteroid_size.BIG: {
		asteroid_size.MEDIUM: [2, 3],
		asteroid_size.SMALL: [0, 2],
		asteroid_size.TINY: [0, 1]
	},
	asteroid_size.MEDIUM: {
		asteroid_size.SMALL: [2, 3],
		asteroid_size.TINY: [0, 2]
	},
	asteroid_size.SMALL: {},
	asteroid_size.TINY: {}
}

class_name AsteroidConfig extends Node

enum asteroid_size {HUGE, BIG, MEDIUM, SMALL, TINY}

# Datos configuración del asteroide según el tamaño
const ASTEROID_DATA = {
	asteroid_size.HUGE: {
		"speed_range": Vector2(-100, 100),
		"prefix": "Asteroid_Huge-",
		"hits": 8,
		"attack": 15,
		"num_textures": 4,
		"collision": true,
		"shrinks": false
	},
	asteroid_size.BIG: {
		"speed_range": Vector2(-150, 150),
		"prefix": "Asteroid_Big-",
		"hits": 6,
		"attack": 10,
		"num_textures": 4,
		"collision": true,
		"shrinks": false
	},
	asteroid_size.MEDIUM: {
		"speed_range": Vector2(-200, 200),
		"prefix": "Asteroid_Medium-",
		"hits": 4,
		"attack": 5,
		"num_textures": 2,
		"collision": true,
		"shrinks": false
	},
	asteroid_size.SMALL: {
		"speed_range": Vector2(-250, 250),
		"prefix": "Asteroid_Small-",
		"hits": 0,
		"attack": 0,
		"num_textures": 2,
		"collision": false,
		"shrinks": true
	},
	asteroid_size.TINY: {
		"speed_range": Vector2(-300, 300),
		"prefix": "Asteroid_Tiny-",
		"hits": 0,
		"attack": 0,
		"num_textures": 2,
		"collision": false,
		"shrinks": true
	}
}

# Datos configuración del spawner según el nivel
const SPAWNER_DATA = {
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

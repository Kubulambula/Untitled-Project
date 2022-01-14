extends Node2D

func _ready():
	var level_data = LevelManager.parse_level_data(
		LevelManager.read_level_data("level1")
	)

	
	LevelManager.build_tilemaps(self, level_data["map"])
	LevelManager.spawn_entities(self, level_data["entities"])
	
	print(level_data)

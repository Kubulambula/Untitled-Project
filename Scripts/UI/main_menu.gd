extends Node2D

func _ready():
	var level_data = LevelManager.parse_level_data(
		LevelManager.read_level_data("level1")
	)
	LevelManager.build_tilemaps(self, level_data["map"])
	
	var player = load("res://Scenes/Entities/Player.tscn").instance()
	player.set_global_position(LevelManager.get_world_position(level_data["player"]["position"]))
	add_child(player)
	
	print(level_data)

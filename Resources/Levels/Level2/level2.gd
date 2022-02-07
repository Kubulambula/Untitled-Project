extends Node2D

const level = "Level2"

var level_data = null

func _ready():
	GameState.player_can_move = false
	
	# warning-ignore:return_value_discarded
	EventReporter.connect("event_reported", self, "handle_event")
	
	LevelManager.set_map_dimensions(30, 9)
	level_data = LevelManager.parse_level_data(LevelManager.read_level_data(level))
	
	level_data = LevelManager.apply_immovable_mask(level_data, ["#", "D", "$"])
	level_data = LevelManager.apply_max_entity_mask(level_data, {"P": 1, "D": 1})
	
	# Insert level specific masks/checks here
	
	LevelManager.write_level_data(level, LevelManager.serialize_level_data(level_data))
	
	LevelManager.build_tilemaps(self, level_data["map"])
	LevelManager.spawn_entities(self, level_data["entities"])
	
	LevelManager.set_entity_properties(level_data, {
		"$": {
			"coin_type": [2, 2, 1, 2, 2, 2, 2, 1, 1, 1, 1, 1]
		},
		"P": {
			"camera_limits": [Rect2(0, 0, 30 * 80, 9 * 80)]
		}
	})
	
	GameState.player_can_move = true

func handle_event(_source, name):
	if name == "player_reached_door":
		GameState.current_level = "level3"
		# warning-ignore:return_value_discarded
		get_tree().change_scene("res://Resources/Levels/Level3/level3.tscn")
		pass # Submit to API & Next level
	elif name == "player_outside_play_area":
		LevelManager.restart_level(level_data)

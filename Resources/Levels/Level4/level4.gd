extends Node2D

const level = "Level4"

var level_data = null

func _ready():
	GameState.player_can_move = false
	# warning-ignore:return_value_discarded
	EventReporter.connect("event_reported", self, "handle_event")
	
	LevelManager.set_map_dimensions(16, 9)
	level_data = LevelManager.parse_level_data(LevelManager.read_level_data(level))
	
	level_data = LevelManager.apply_immovable_mask(level_data, ["P", "#", "D", "$"])
	level_data = LevelManager.apply_max_entity_mask(level_data, {"P": 1, "D": 1, "C": 3})
	
	# Insert level specific masks/checks here
	
	LevelManager.write_level_data(level, LevelManager.serialize_level_data(level_data))
	
	LevelManager.build_tilemaps(self, level_data["map"])
	LevelManager.spawn_entities(self, level_data["entities"])
	
	LevelManager.set_entity_properties(level_data, {
		"$": {
			"coin_type": [2] # Is it enough?
		},
		"P": {
			"camera_limits":[Rect2(0, 0, 16 * 80, 9 * 80)]
		}
	})

	GameState.player_can_move = true

func handle_event(_source, name):
	if name == "player_reached_door":
		get_tree().change_scene("res://Resources/Levels/Level5/level5.tscn")
		GameState.current_level = "level5"
	elif name == "player_outside_play_area":
		LevelManager.restart_level(level_data)

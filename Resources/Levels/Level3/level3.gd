extends Node2D

const level = "Level3"

var level_data = null

func apply_door_destination_mask(level_data, allowed_levels):
	var settings = level_data["settings"]
	var fallback_level = LevelManager.get_internal_option(level_data["level"], "door_destination")
	if "door_destination" in settings:
		var user_level = settings["door_destination"].to_lower()
		for allowed_level in allowed_levels:
			if not "level" in str(allowed_level):
				allowed_level = "level" + str(allowed_level)
			if user_level == allowed_level:
				return level_data
	settings["door_destination"] = fallback_level.to_lower()
	return level_data

func _ready():
	GameState.player_can_move = false
	# warning-ignore:return_value_discarded
	EventReporter.connect("event_reported", self, "handle_event")
	
	LevelManager.set_map_dimensions(30, 9)
	level_data = LevelManager.parse_level_data(LevelManager.read_level_data(level))
	
	level_data = LevelManager.apply_immovable_mask(level_data, ["P", "#", "D", "$"])
	level_data = LevelManager.apply_max_entity_mask(level_data, {"P": 1, "D": 1})
	
	# Insert level specific masks/checks here
	level_data = apply_door_destination_mask(level_data, [3, 4])
	
	LevelManager.write_level_data(level, LevelManager.serialize_level_data(level_data))
	
	LevelManager.build_tilemaps(self, level_data["map"])
	LevelManager.spawn_entities(self, level_data["entities"])
	
	LevelManager.set_entity_properties(level_data, {
		"$": {
			"coin_type": [2, 2, 1, 2, 2, 2, 1, 2, 2, 1, 1, 2, 2, 1, 1, 1]
		},
		"P": {
			"camera_limits": [Rect2(0, 0, 30 * 80, 9 * 80)]
		}
	})

	GameState.player_can_move = true

func handle_event(source, name):
	if name == "player_reached_door":
		# TODO: Submit to API
		var next_level = level_data["settings"]["door_destination"]
		GameState.current_level = next_level
		get_tree().change_scene(LevelManager.get_level_scene(next_level))
	elif name == "player_outside_play_area":
		LevelManager.restart_level(level_data)

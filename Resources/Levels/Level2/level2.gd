extends Node2D

const level = "Level2"

var level_data = null

func _ready():
	GameState.player_can_move = false
	
	# warning-ignore:return_value_discarded
	EventReporter.connect("event_reported", self, "handle_event")
	
	LevelManager.set_map_dimensions(25, 9)
	level_data = LevelManager.parse_level_data(LevelManager.read_level_data(level))
	
	level_data = LevelManager.apply_immovable_mask(level_data, ["#", "D", "$", "K"])
	level_data = LevelManager.apply_max_entity_mask(level_data, {"P": 1, "D": 1})
	
	# Insert level specific masks/checks here
	
	LevelManager.write_level_data(level, LevelManager.serialize_level_data(level_data))
	
	LevelManager.build_tilemaps(self, level_data["map"])
	LevelManager.spawn_entities(self, level_data["entities"])
	
	LevelManager.set_entity_properties(level_data, {
		"$": {
			"coin_type": [1, 2, 2]
		},
		"P": {
			"camera_limits": [Rect2(0, 0, 25 * 80, 9 * 80)]
		}
	})
	
	GameState.player_can_move = false
	
	yield(DialogueBox, "queue_empty")
	GameState.player_can_move = true

func _submit_callback(_code, _response):
	GameState.current_level = "level3"
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Resources/Levels/Level3/level3.tscn")

func handle_event(_source, name):
	if name == "player_reached_door":
		
		WebAPI.submit(GameCode.generate(
			"level2", # Challenge Id -> GameCode.CHALLENGE_IDS
			GameState.score # Collected coins
			+ 1500 # Level completion bonus
		), funcref(self, "_submit_callback"))
		
	elif name == "player_outside_play_area":
		LevelManager.restart_level(level_data)

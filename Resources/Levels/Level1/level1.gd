extends Node2D

const level = "Level1"

var level_data = null

func _ready():
	GameState.player_can_move = false
	# warning-ignore:return_value_discarded
	EventReporter.connect("event_reported", self, "handle_event")
	
	LevelManager.set_map_dimensions(16, 9)
	level_data = LevelManager.parse_level_data(LevelManager.read_level_data(level))
	
	level_data = LevelManager.apply_immovable_mask(level_data, ["P", "D", "$"])
	level_data = LevelManager.apply_max_entity_mask(level_data, {"P": 1, "D": 1})
	
	# Insert level specific masks/checks here
	
	LevelManager.write_level_data(level, LevelManager.serialize_level_data(level_data))
	
	LevelManager.build_tilemaps(self, level_data["map"])
	LevelManager.spawn_entities(self, level_data["entities"])
	
	if not OS.is_debug_build():
		PopupBox.create_simple("ahoj", "")
		yield(PopupBox, "next_button")
		PopupBox.player_request_next()
		PopupBox.create_labeled("Jak je?", "ahoj", "", 2)
		yield(PopupBox, "hidden")
	GameState.player_can_move = true

func _submit_callback(code, response):
	GameState.current_level = "level2"
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Resources/Levels/Level2/level2.tscn")
	

func handle_event(_source, name):
	if name == "player_reached_door":
		
		WebAPI.submit(GameCode.generate(
			"level1", # Challenge Id -> GameCode.CHALLENGE_IDS
			GameState.score # Collected coins
			+ 1500 # Level completion bonus
		), funcref(self, "_submit_callback"))
		
	elif name == "player_outside_play_area":
		LevelManager.restart_level(level_data)

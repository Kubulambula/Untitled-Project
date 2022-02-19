extends Node2D

const level = "Level2"

var level_data = null

func _load_level():
	GameState.score = 0
	# warning-ignore:return_value_discarded
	EventReporter.connect("event_reported", self, "handle_event")
	
	LevelManager.set_map_dimensions(25, 9)
	level_data = LevelManager.parse_level_data(LevelManager.read_level_data(level))
	
	level_data = LevelManager.apply_immovable_mask(level_data, ["#", "D", "$", "K", "C", "?"])
	level_data = LevelManager.apply_max_entity_mask(level_data, {"P": 1, "D": 1})
	
	# Insert level specific masks/checks here
	
	LevelManager.write_level_data(level, LevelManager.serialize_level_data(level_data))
	
	LevelManager.build_tilemaps($LevelData, level_data["map"])
	LevelManager.spawn_entities($LevelData, level_data["entities"])
	
	LevelManager.set_entity_properties(level_data, {
		"$": {
			"coin_type": [1, 2, 2]
		},
		"P": {
			"camera_limits": [Rect2(0, 0, 25 * 80, 9 * 80)]
		}
	})
	

func _ready():
	GameState.player_can_move = false
	
	# warning-ignore:return_value_discarded
	
	_load_level()
	
#	GameState.player_can_move = false
#	# Dialogue goes here
#	yield(DialogueBox, "queue_empty")
	GameState.player_can_move = true

func _submit_callback(code, response):
	print("Code submit response from server: " + str(code) + " : " + str(response))


func handle_event(_source, name):
	if name == "player_reached_door":
		
		var code = GameCode.generate(
			"level2", # Challenge Id -> GameCode.CHALLENGE_IDS
			GameState.score # Collected coins
			+ 1500 # Level completion bonus
		)
		ResultScreen.show_game_code(code, "res://Resources/Levels/Level3/level3.tscn")
		if not GameState.offline:
			WebAPI.submit(code, funcref(self, "_submit_callback"))
		else:
			printerr("RESULT NOT SENT TO SERVER BECAUSE OF OFFLINE MODE. CODE: " + code)
		
		GameState.current_level = "level3"
		# warning-ignore:return_value_discarded
#		get_tree().change_scene("res://Resources/Levels/Level3/level3.tscn")
		
	elif name == "player_outside_play_area":
		LevelManager.restart_level(level_data)

func _process(_delta):
	if Input.is_action_just_pressed("ui_reload"):
		EventReporter.disconnect("event_reported", self, "handle_event")
		for node in $LevelData.get_children():
			$LevelData.remove_child(node)
			node.queue_free()
		_load_level()
		GameState.player_can_move = true

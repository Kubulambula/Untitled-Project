extends Node2D

const level = "Level4"

var level_data = null


onready var container = $LevelData

func _load_level():
	GameState.score = 0
	# warning-ignore:return_value_discarded
	EventReporter.connect("event_reported", self, "handle_event")
	
	LevelManager.set_map_dimensions(30, 9)
	level_data = LevelManager.parse_level_data(LevelManager.read_level_data(level))
	
	level_data = LevelManager.apply_immovable_mask(level_data, ["P", "#", "D", "$", "K", "C", "?"])
	level_data = LevelManager.apply_max_entity_mask(level_data, {"P": 1, "D": 1})
	
	# Insert level specific masks/checks here
	level_data = apply_door_destination_mask(level_data, [4, 5])
	
	LevelManager.write_level_data(level, LevelManager.serialize_level_data(level_data))
	
	LevelManager.build_tilemaps(container, level_data["map"])
	LevelManager.spawn_entities(container, level_data["entities"])
	
	LevelManager.set_entity_properties(level_data, {
		"$": {
			"coin_type": [2, 2, 1, 2, 2, 2, 1, 2, 2, 1, 1, 2, 2, 1, 1, 1]
		},
		"P": {
			"camera_limits": [Rect2(0, 0, 30 * 80, 9 * 80)]
		}
	})

func apply_door_destination_mask(lvl_data, allowed_levels):
	var settings = lvl_data["settings"]
	var fallback_level = LevelManager.get_internal_option(lvl_data["level"], "door_destination")
	if "door_destination" in settings:
		var user_level = settings["door_destination"].to_lower()
		for allowed_level in allowed_levels:
			if not "level" in str(allowed_level):
				allowed_level = "level" + str(allowed_level)
			if user_level == allowed_level:
				return lvl_data
	settings["door_destination"] = fallback_level.to_lower()
	return lvl_data

func _ready():
	GameState.player_can_move = false
	# warning-ignore:return_value_discarded

	_load_level()
	
	GameState.player_can_move = false
	DialogueBox.create_adam(TranslationServer.translate("$Lev4Dia1"), -1)
	yield(DialogueBox, "queue_empty")
	GameState.player_can_move = true

func _submit_callback(code, response):
	print("Code submit response from server: " + str(code) + " : " + str(response))

func handle_event(_source, name):
	if name == "player_reached_door":
		if level_data["settings"]["door_destination"] == "level5":
			
			var code = GameCode.generate(
				"level4", # Challenge Id -> GameCode.CHALLENGE_IDS
				GameState.score # Collected coins
				+ 1500 # Level completion bonus
			)
			ResultScreen.show_game_code(code, "res://Resources/Levels/Level5/level5.tscn")
			if not GameState.offline:
				WebAPI.submit(code, funcref(self, "_submit_callback"))
			else:
				printerr("RESULT NOT SENT TO SERVER BECAUSE OF OFFLINE MODE. CODE: " + code)
			
			GameState.current_level = "level5"
			# warning-ignore:return_value_discarded
	#		get_tree().change_scene("res://Resources/Levels/Level4/level4.tscn")
		else:
			get_tree().reload_current_scene()
		
	elif name == "player_outside_play_area":
		EventReporter.disconnect("event_reported", self, "handle_event")
		for node in $LevelData.get_children():
			$LevelData.call_deferred("remove_child", node)
			node.queue_free()
		_load_level()
		GameState.player_can_move = true
#		LevelManager.restart_level(level_data)

func _process(_delta):
	if Input.is_action_just_pressed("ui_reload"):
		EventReporter.disconnect("event_reported", self, "handle_event")
		for node in $LevelData.get_children():
			$LevelData.remove_child(node)
			node.queue_free()
		_load_level()
		GameState.player_can_move = true

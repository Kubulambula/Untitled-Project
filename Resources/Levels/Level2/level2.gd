extends Node2D

const level = "Level2"

var level_data = null


var done = false

func _load_level():
	GameState.score = 0
	# warning-ignore:return_value_discarded
	EventReporter.connect("event_reported", self, "handle_event")
	
	LevelManager.set_map_dimensions(16, 9)
	level_data = LevelManager.parse_level_data(LevelManager.read_level_data(level))
	
	level_data = LevelManager.apply_immovable_mask(level_data, ["P", "D", "$", "K", "C", "?"])
	level_data = LevelManager.apply_max_entity_mask(level_data, {"P": 1, "D": 1})
	
	# Insert level specific masks/checks here
	
	LevelManager.write_level_data(level, LevelManager.serialize_level_data(level_data))
	
	LevelManager.build_tilemaps($LevelData, level_data["map"])
	LevelManager.spawn_entities($LevelData, level_data["entities"])


func _ready():
	GameState.player_can_move = false
	
	_load_level()
	
	GameState.player_can_move = false
	DialogueBox.create_adam("Tak a je to - Level2.", -1)
	DialogueBox.create_adam("Hmmm...", -1)
	DialogueBox.create_adam_angry("Co kdyby ALESPOŇ NĚCO FUNGOVALO?", -1)
	DialogueBox.create_jakub_angry("Proč je ta podlaha zase v úplně jiný úrovni, než má být?\nTo není možný... Ta Purkiáda se FAKT nestihne.", -1)
	DialogueBox.create_jakub("Zedituj si prosímtě nějak tu mapu, ať můžeš do dalšího levelu...", -1)
	yield(DialogueBox, "queue_empty")
	GameState.player_can_move = true

func _submit_callback(code, response):
	print("Code submit response from server: " + str(code) + " : " + str(response))
	

func handle_event(_source, name):
	if name == "player_reached_door":
		done = true
		GameState.player_can_move = false
		DialogueBox.create_jakub("Další level prosím! Snad tenhle už bude fungovat.", -1)
		yield(DialogueBox, "queue_empty")
		GameState.player_can_move = true
		
		
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
#		get_tree().change_scene("res://Resources/Levels/Level2/level2.tscn")
		
		
	elif name == "player_outside_play_area" and not done:
		EventReporter.disconnect("event_reported", self, "handle_event")
		for node in $LevelData.get_children():
			$LevelData.call_deferred("remove_child", node)
			node.queue_free()
		_load_level()
		GameState.player_can_move = true


func _process(_delta):
	if Input.is_action_just_pressed("ui_reload"):
		EventReporter.disconnect("event_reported", self, "handle_event")
		for node in $LevelData.get_children():
			$LevelData.remove_child(node)
			node.queue_free()
		_load_level()
		GameState.player_can_move = true

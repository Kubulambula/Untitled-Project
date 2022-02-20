extends Node2D

const level = "Level5"

var level_data = null

var player_exists = true

func _ready():
	_load_level()
	
	GameState.player_can_move = false
	DialogueBox.create_jakub_angry("Ty jsi uvěznil Adama v rekurzivním paradoxu? Jak jsi mohl?", -1)
	DialogueBox.create_jakub_angry("To TY můžeš za všchno to, co nefunguje. to TY nám to tu určitě celou dobu kazíš.", -1)
	DialogueBox.create_jakub_angry("Ale zádná sabotáž, nebo vražda vývojáře nedokáže zničit hru mistrů. Tímto tě vyzívám na 1v1!", -1)
	DialogueBox.create_jakub_angry("Jde o hru tak jednoduchou a dokonalou, že nezná chyb. Nestárnoucí klasika žijící v srdcích mnoha hráčů Je to...", -1)
	DialogueBox.create_jakub("PONG", -1)
	DialogueBox.create_jakub_angry("Počkám na tebe v dalším levelu. Zatím nám nachystám svou starou konzoli...", -1)
	yield(DialogueBox, "queue_empty")
	GameState.player_can_move = true


func _load_level():
	GameState.score = 0
	# warning-ignore:return_value_discarded
	EventReporter.connect("event_reported", self, "handle_event")
	
	LevelManager.set_map_dimensions(16, 9)
	level_data = LevelManager.parse_level_data(LevelManager.read_level_data(level))
	
	level_data = LevelManager.apply_immovable_mask(level_data, ["P", "#", "D", "$", "?", "K"])
	level_data = LevelManager.apply_max_entity_mask(level_data, {"P": 1, "D": 1, "C": 3})
	
	# Insert level specific masks/checks here
	
	LevelManager.write_level_data(level, LevelManager.serialize_level_data(level_data))
	
	LevelManager.build_tilemaps(self, level_data["map"])
	LevelManager.spawn_entities(self, level_data["entities"])
	
#	printerr(level_data["entities"])
	
	LevelManager.set_entity_properties(level_data, {
		"$": {
			"coin_type": [2, 2, 2] # Is it enough?
		},
		"P": {
			"camera_limits":[Rect2(0, 0, 16 * 80, 9 * 80)]
		}
	})
	
	GameState.player_can_move = true


func _submit_callback(code, response):
	print("Code submit response from server: " + str(code) + " : " + str(response))


func handle_event(_source, name):
	if name == "player_reached_door":
		
		var code = GameCode.generate(
			"level5", # Challenge Id -> GameCode.CHALLENGE_IDS
			GameState.score # Collected coins
			+ 1500 # Level completion bonus
		)
		ResultScreen.show_game_code(code, "res://Resources/Levels/Level6/level6.tscn")
		if not GameState.offline:
			WebAPI.submit(code, funcref(self, "_submit_callback"))
		else:
			printerr("RESULT NOT SENT TO SERVER BECAUSE OF OFFLINE MODE. CODE: " + code)
		
		GameState.current_level = "level6"
		# warning-ignore:return_value_discarded
#		get_tree().change_scene("res://Resources/Levels/Level5/level5.tscn")
	elif name == "player_outside_play_area" and player_exists:
		LevelManager.restart_level(level_data)

func _process(_delta):
	if Input.is_action_just_pressed("ui_reload"):
		reload()
		LevelManager.restart_level(level_data)


func reload():
	for entity in level_data["entities"]:
		if entity["node"].name == "Player":
			player_exists = false
		entity["node"].queue_free()
	GameState.score = 0
	level_data = LevelManager.parse_level_data(LevelManager.read_level_data(level))
	level_data = LevelManager.apply_immovable_mask(level_data, ["P", "#", "D", "$", "?", "K"])
	level_data = LevelManager.apply_max_entity_mask(level_data, {"P": 1, "D": 1, "C": 3})
	LevelManager.spawn_entities(self, level_data["entities"])

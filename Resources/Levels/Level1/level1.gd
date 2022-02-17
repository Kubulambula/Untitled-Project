extends Node2D

const level = "Level1"

var level_data = null

var death_counter = 0

func _load_level():
# warning-ignore:return_value_discarded
	EventReporter.connect("event_reported", self, "handle_event")
	
	LevelManager.set_map_dimensions(16, 9)
	level_data = LevelManager.parse_level_data(LevelManager.read_level_data(level))
	
	level_data = LevelManager.apply_immovable_mask(level_data, ["P", "D", "$", "K"])
	level_data = LevelManager.apply_max_entity_mask(level_data, {"P": 1, "D": 1})
	
	# Insert level specific masks/checks here
	
	LevelManager.write_level_data(level, LevelManager.serialize_level_data(level_data))
	
	LevelManager.build_tilemaps($LevelData, level_data["map"])
	LevelManager.spawn_entities($LevelData, level_data["entities"])

func _ready():
	GameState.player_can_move = false
	# warning-ignore:return_value_discarded
	
	_load_level()
	
#	GameState.player_can_move = false
#	DialogueBox.create_adam("C-co...?", -1)
#	DialogueBox.create_jakub("Hráč?", -1)
#	DialogueBox.create_adam("Ale ta hra není dodělaná! Vždyť ani nemá název!", -1)
#	DialogueBox.create_adam("Uvidí jak je zabugovaná a že půlka věcí chybí! [color=red](Zatím opravdu)[/color]", -1)
#	DialogueBox.create_jakub("Dobře klid... To se nějak zvládne. Ono se to nějak udělá", -1)
#	DialogueBox.create_jakub("Alespoň nám pomůže tu hru otestovat ne?", -1)
#	DialogueBox.create_jakub("Pomůžeš nám že?", -1)
#	DialogueBox.create_jakub("...", -1)
#	DialogueBox.create_adam_angry("Do háje fix už zase nefungujou dialogy... Vždyť minule to ještě šlo. Se z toho může jeden-", -1)
#	DialogueBox.create_jakub("Beru to jako ano", -1)
#	DialogueBox.create_jakub("Tvým cílem je dostat se v každém levelu vždy ke dveřím. Budeme tě pozorovat z povzdálí.\n\nHodně štěstí", -1)
#	yield(DialogueBox, "queue_empty")
	GameState.player_can_move = true

func _submit_callback(_code, _response):
	GameState.current_level = "level2"
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Resources/Levels/Level2/level2.tscn")
	

func handle_event(_source, name):
	if name == "player_reached_door":
		GameState.player_can_move = false
		DialogueBox.create_jakub("Výborná práce! Vidím, že rozumíš, že změna v jednom souboru dokáže ovlivnit soubor druhý.", -1)
		DialogueBox.create_adam("Dej nám jen chviličku, než načteme nový level...", -1)
		yield(DialogueBox, "queue_empty")
		GameState.player_can_move = true
	
		WebAPI.submit(GameCode.generate(
			"level1", # Challenge Id -> GameCode.CHALLENGE_IDS
			GameState.score # Collected coins
			+ 1500 # Level completion bonus
		), funcref(self, "_submit_callback"))
		
	elif name == "player_outside_play_area":
		EventReporter.disconnect("event_reported", self, "handle_event")
		for node in $LevelData.get_children():
			$LevelData.call_deferred("remove_child", node)
			node.queue_free()
		_load_level()
		GameState.player_can_move = true
		
		death_counter += 1
		if death_counter == 1:
			GameState.player_can_move = false
			DialogueBox.create_adam("No výborně. Další nepřeskočitelná díra. Co zkusit mapu zeditovat a udělat si třeba most?\nMěla by být někde v '[color=black]" + LevelManager.get_level_dir(level) + "[/color]'", -1)
			yield(DialogueBox, "queue_empty")
			GameState.player_can_move = true
		elif death_counter % 5 == 0:
			GameState.player_can_move = false
			DialogueBox.create_adam("Zkus se podívat do '[color=black]" + LevelManager.get_level_dir(level) + "[/color]' jestli něco nevymyslíš s tou mapou", -1)
			yield(DialogueBox, "queue_empty")
			GameState.player_can_move = true

func _process(_delta):
	if Input.is_action_just_pressed("ui_reload"):
		EventReporter.disconnect("event_reported", self, "handle_event")
		for node in $LevelData.get_children():
			$LevelData.remove_child(node)
			node.queue_free()
		_load_level()
		GameState.player_can_move = true

extends Node

const level_name = "Level7"
var level_dir = LevelManager.get_level_dir(level_name)

const resource_dir = "res://Resources/Levels/Level7/To_copy"
const resource_dir2 = "res://Resources/Levels/Level7/Copy_if"

var missing_tileset = preload("res://Resources/Tiles/missing_tileset.tres")

var overlay_layer = preload("res://Scenes/Singleton_scenes/black_screen.tscn").instance()
var overlay = overlay_layer.get_node("Control")

var config_file = null
var config_file2 = null
var config_file_path = LevelManager.get_level_dir(level_name) + "/GAME_CORE/DO_NOT_OPEN/VERY_IMPORTANT_DATA.txt"
var config_file_path2 = LevelManager.get_level_dir(level_name) + "/GAME_CORE/DO_NOT_OPEN/VERY_IMPORTANT_DATA_ADMIN.txt"

var _chapter1_completed = false
var _chapter2_completed = false

var _dialogue_timer = null
var _dialogue_playing = false

func _ready():
	overlay.hide()
	add_child(overlay_layer)
	_reload()
	config_file = _load_config(config_file_path)

func _timer_timeout():
	if not _chapter2_completed:
		_play_chapter_two()
		_chapter2_completed = true

func _play_chapter_one():
	GameState.player_can_move = false
	$Adam.play("adam_talk_angry")
	DialogueBox.create_adam_angry("Dál už ani krok!", -1)
	DialogueBox.create_adam_angry("Co to má znamenat?! Jak jsi se dostal až sem?", -1)
	DialogueBox.create_adam_angry("Tenhle level ještě není dokončený, tady nemůžeš být. Okamžitě ...", -1)
	DialogueBox.create_adam_angry("I když...", -1)
	yield(DialogueBox, "queue_empty")
	$Adam.play("adam_talk")
	DialogueBox.create_adam("To vlastně není tak špatné, že tu jsi. Aspoň už nebudeš dělat problémy a vrtat se nám v kódu hry.", -1)
	DialogueBox.create_adam("Jsem zvědavý, jak se odtud dostaneš a hru dokončíš ;)", -1)
	DialogueBox.create_adam("Hodně štěstí. :p", -1)
	yield(DialogueBox, "queue_empty")
	$Adam.play("adam_idle")
	GameState.player_can_move = true

func _play_chapter_two():
	GameState.player_can_move = false
	DialogueBox.create_adam_missing("Co to?", -1)
	DialogueBox.create_adam_missing("K... Kam? Kam zmizely textury?", -1)
	DialogueBox.create_adam_missing("Co jsi to udělal?! Okamžitě to vrať zpátky!", -1)
	yield(DialogueBox, "queue_empty")
	_dialogue_playing = false
	GameState.player_can_move = true

func _on_Area2D_body_entered(body):
	if body.name == "Player":
		if GameState.finish_chapter == "chapter1":
			if not _chapter1_completed:
				_play_chapter_one()
				_chapter1_completed = true

func rip_textures():
	$Background.hide()
	$MissingBackground.show()
	$Adam.play("adam_missing")
	$TileMap.tile_set = missing_tileset

func _reload():
	if GameState.finish_chapter == "chapter1":
		_copy_dir(resource_dir, level_dir)
		config_file = _load_config(config_file_path)
		if !config_file.get_value("Textures", "load", true):
			GameState.finish_chapter = "chapter2"
	if GameState.finish_chapter == "chapter2" or GameState.finish_chapter == "chapter3":
		_dialogue_timer = Timer.new()
		add_child(_dialogue_timer)
		_dialogue_timer.set_one_shot(true)
		_dialogue_timer.set_wait_time(1)
		_dialogue_timer.connect("timeout", self, "_timer_timeout")
		rip_textures()
		_copy_dir(resource_dir2, level_dir)
		config_file2 = _load_config(config_file_path2)
		_check_chapter2_values()
	elif GameState.finish_chapter == "chapter4":
		_complete_game()

func _check_chapter2_values():
	var graphics = config_file2.get_value("Game", "graphics_module", true)
	var logic = config_file2.get_value("Game", "logic_module", true)
	var core = config_file2.get_value("Game", "core_module", true)
	var failsafe = config_file2.get_value("Failsafe", "prevent_crash", true)
	if not graphics:
		overlay.show()
	else:
		overlay.hide()
	if not logic:
		$Adam.stop()
		$Player.state = $Player.CUSTOM
		GameState.player_can_move = false
	else:
		$Player.state = $Player.IDLE
		if not _dialogue_playing:
			GameState.player_can_move = true
	if not core:
		if failsafe:
			config_file2.set_value("Game", "core_module", true)
			config_file2.save(config_file_path2)
		else:
			GameState.finish_chapter = "chapter4"
			_complete_game()
	if GameState.finish_chapter == "chapter2":
		_dialogue_playing = true
		_dialogue_timer.start()
		GameState.finish_chapter = "chapter3"

func _input(_event):
	if Input.is_action_just_pressed("ui_reload"):
		_reload()

func _load_config(path):
	var config = ConfigFile.new()
	if config.load(path) == OK:
		return config
	else:
		printerr(level_name + ": loading config failed (" + path + "). ERR: " + str(config.load(path)))
		return null

func _submit_callback(code, response):
	print("Code submit response from server: " + str(code) + " : " + str(response))

func _complete_game():
	var code = GameCode.generate(
		"reserve1", # Challenge Id -> GameCode.CHALLENGE_IDS
		3500 # Level completion bonus
	)
	
	ResultScreen.show_blue_screen(code)
	if not GameState.offline:
		WebAPI.submit(code, funcref(self, "_submit_callback"))
	else:
		printerr("RESULT NOT SENT TO SERVER BECAUSE OF OFFLINE MODE. CODE: " + code)

# Ctrl + C & Ctrl + V from Level 5 :P
func _copy_dir(from, to):
	var dir = Directory.new()
	if dir.open(from) == OK:
		dir.list_dir_begin(true, true)
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				dir.make_dir_recursive(to + "/" + file_name)
				_copy_dir(from + "/" + file_name, to + "/" + file_name)
			else:
				if not dir.file_exists(to + "/" + file_name):
					dir.copy(dir.get_current_dir() + "/" + file_name, to + "/" + file_name)
			file_name = dir.get_next()
	else:
		printerr("An error occurred when trying to access the path.")

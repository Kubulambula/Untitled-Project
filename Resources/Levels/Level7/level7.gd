extends Node

const level_name = "Level7"
var level_dir = LevelManager.get_level_dir(level_name)

var resource_dir = "res://Resources/Levels/Level7/To_copy." + TranslationServer.translate("$lvl_suffix")
var resource_dir2 = "res://Resources/Levels/Level7/Copy_if." + TranslationServer.translate("$lvl_suffix")

var internal_admin_config = resource_dir2 + "/GAME_CORE/DO_NOT_OPEN/VERY_IMPORTANT_DATA_ADMIN.txt"

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
	DialogueBox.create_adam_angry(TranslationServer.translate("$Lev7Dia1"), -1)
	DialogueBox.create_adam_angry(TranslationServer.translate("$Lev7Dia2"), -1)
	DialogueBox.create_adam_angry(TranslationServer.translate("$Lev7Dia3"), -1)
	DialogueBox.create_adam_angry(TranslationServer.translate("$Lev7Dia4"), -1)
	yield(DialogueBox, "queue_empty")
	$Adam.play("adam_talk")
	DialogueBox.create_adam(TranslationServer.translate("$Lev7Dia5"), -1)
	DialogueBox.create_adam(TranslationServer.translate("$Lev7Dia6"), -1)
	DialogueBox.create_adam(TranslationServer.translate("$Lev7Dia7"), -1)
	yield(DialogueBox, "queue_empty")
	$Adam.play("adam_idle")
	GameState.player_can_move = true

func _play_chapter_two():
	GameState.player_can_move = false
	DialogueBox.create_adam_missing(TranslationServer.translate("$Lev7Dia8"), -1)
	DialogueBox.create_adam_missing(TranslationServer.translate("$Lev7Dia9"), -1)
	DialogueBox.create_adam_missing(TranslationServer.translate("$Lev7Dia10"), -1)
	yield(DialogueBox, "queue_empty")
	$Adam.play("adam_missing_idle")
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

func write_config_file(path):
	var section = "Global"
	var internal_data = LevelManager._read_file(internal_admin_config)
	var output = ""
	if config_file2 != null:
		for line in internal_data.split("\n"):
			line = line.strip_edges()
			if line.begins_with("[") and line.ends_with("]"):
				section = line.substr(1, len(line) - 2)
			if "=" in line and not line.begins_with(";"):
				var parts = line.split("=")
				output += parts[0] + "=" + str(config_file2.get_value(section, parts[0], true)).to_lower()
			else:
				output += line
			output += "\n"
	else:
		output = internal_data
	LevelManager._write_file(path, output)

func _check_chapter2_values():
	var graphics = true
	var logic = true
	var core = true
	var failsafe = true
	if config_file2 != null:
		graphics = config_file2.get_value("Game", "graphics_module", true)
		logic = config_file2.get_value("Game", "logic_module", true)
		core = config_file2.get_value("Game", "core_module", true)
		failsafe = config_file2.get_value("Failsafe", "prevent_crash", true)
	else:
		write_config_file(config_file_path2)
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
			write_config_file(config_file_path2)
			#config_file2.save(config_file_path2)
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
#	if not GameState.offline:
#		WebAPI.submit(code, funcref(self, "_submit_callback"))
#	else:
#		printerr("RESULT NOT SENT TO SERVER BECAUSE OF OFFLINE MODE. CODE: " + code)

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

extends Node2D

const level_name = "Level6"

const resource_dir = "res://Resources/Levels/Level6/To_copy"

var config_file_locations = {
	"tv": LevelManager.get_level_dir(level_name) + "/TV/tv.txt",
	"p1": LevelManager.get_level_dir(level_name) + "/TV/Channels/PONG/player1.txt",
	"p2": LevelManager.get_level_dir(level_name) + "/TV/Channels/PONG/player2.txt",
}
var config_files = {}

var _tv_prompt = false
var wall_visited = false


func _ready():
	GameState.score = 0
	GameState.offline = false
	GameState.player_can_move = true
	# warning-ignore:return_value_discarded
	$TV.get_node("Screen/Pong").connect("end", self, "_on_pong_end")
	$Player.set_camera_limits(Vector2(0,0), Vector2(1280, 720))
# warning-ignore:return_value_discarded
	EventReporter.connect("event_reported", self, "handle_event")
	$TV/Prompt.visible = false
	reload()


func reload():
	copy_folder_deep()
	get_configs()
	
	# Initial stuff
	match config_files["tv"].get_value("tv", "channel", "OFF").to_upper():
		"PONG":
			$TV/Screen/Pong/BG/PlayerPONG.speed = config_files["p1"].get_value("config", "speed", 300)
			$TV/Screen/Pong/BG/Jakub.speed = config_files["p2"].get_value("config", "speed", 300)
			$TV.set_channel($TV.PONG)
			
		"DISCO":
			$TV.set_channel($TV.DISCO)
			$TV/YouSpinMe.play(0)
			
		_:
			$TV.set_channel($TV.NOISE)


func _on_Area2D_body_entered(body):
	if body.name == "Player":
		_tv_prompt = true
		$TV/Prompt.visible = true


func _on_Area2D_body_exited(body):
	if body.name == "Player":
		_tv_prompt = false
		$TV/Prompt.visible = false


func _input(_event):
	if _tv_prompt and Input.is_action_just_pressed("ui_interact"):
		_tv_prompt = false
		$TV/Prompt.visible = false
		match config_files["tv"].get_value("tv", "channel", "OFF").to_upper():
			"PONG":
				if not $TV/Screen/Pong.ended:
					GameState.player_can_move = false
					DialogueBox.create_jakub("Okay... Firt one to [color=red]3 points[/color] wins.", -1)
					yield(DialogueBox, "queue_empty")
					$Player.state = $Player.CUSTOM
					$Player.get_node("GFX").flip_h = false
					$Player.get_node("GFX").play("player_turn")
					$TV/Jakub.play("jakub_turn")
					yield($TV/Jakub, "animation_finished")
					$TV/Jakub.play("jakub_play")
					$Player.get_node("GFX").play("player_game")
					$TV.start_pong()
				else:
					GameState.player_can_move = false
					DialogueBox.create_jakub("Better luck next time", -1)
					yield(DialogueBox, "queue_empty")
					GameState.player_can_move = true
			"DISCO":
				GameState.player_can_move = false
				DialogueBox.create_jakub_angry("YOU WERE NOT SUPPOSED TO SEE THAT! WHERE DID YOU FIND THAT?!?!!", -1)
				yield(DialogueBox, "queue_empty")
				GameState.player_can_move = true
			_:
				GameState.player_can_move = false
				DialogueBox.create_jakub("Come on start the [color=red]PONG[/color]!", -1)
				yield(DialogueBox, "queue_empty")
				GameState.player_can_move = true
				
	if Input.is_action_just_pressed("ui_reload"):
		# warning-ignore:return_value_discarded
		get_tree().reload_current_scene()
#		reload()
				
func _on_pong_end(player_win: bool):
	if player_win:
		GameState.player_can_move = false
		DialogueBox.create_jakub_angry("WHAT HAVE YOU DONE??? HOW DID YOU DO THAT?", -1)
		DialogueBox.create_jakub_angry("Go to the next level I guess...", -1)
		yield(DialogueBox, "queue_empty")
		GameState.player_can_move = true
		$InvisibleWall.queue_free()
	else:
		GameState.player_can_move = false
		DialogueBox.create_jakub("Haha!\nLooks like I'm still the champion", -1)
		yield(DialogueBox, "queue_empty")
		GameState.player_can_move = true
	$Player.state = $Player.IDLE # TODO : Jakub animation reset


func get_configs():
	for key in config_file_locations.keys():
		var cfg = ConfigFile.new()
		if cfg.load(config_file_locations[key]) == OK:
			config_files[key] = cfg
		else:
			printerr(level_name + ": loading config failed (" + config_files[key] + "). ERR: " + str(cfg.load(config_files[key])))
			config_files[key] = null


func copy_folder_deep():
	var destination_dir = LevelManager.get_level_dir(level_name)
	_copy_dir(resource_dir, destination_dir)


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


func _on_Wall_body_entered(body):
	if body.name == "Player" and not wall_visited:
		wall_visited = true
		GameState.player_can_move = false
		DialogueBox.create_jakub("Looks like you hit an invisible wall\nCome play with me and maybe I will let you pass", -1)
		yield(DialogueBox, "queue_empty")
		GameState.player_can_move = true


func _submit_callback(code, response):
	print("Code submit response from server: " + str(code) + " : " + str(response))


func handle_event(_source, event):
	if event == "player_reached_door":
		var code = GameCode.generate(
			"level6", # Challenge Id -> GameCode.CHALLENGE_IDS
			GameState.score # Collected coins
			+ 1500 # Level completion bonus
		)
		ResultScreen.show_game_code(code, "res://Resources/Levels/Level6/level6.tscn")
		if not GameState.offline:
			WebAPI.submit(code, funcref(self, "_submit_callback"))
		else:
			printerr("RESULT NOT SENT TO SERVER BECAUSE OF OFFLINE MODE. CODE: " + code)
		
		GameState.current_level = "level7"
#		# warning-ignore:return_value_discarded
#		get_tree().change_scene("res://Resources/Levels/Level5/level5.tscn")

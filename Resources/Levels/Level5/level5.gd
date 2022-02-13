extends Node2D

const level_name = "Level5"

const resource_dir = "res://Resources/Levels/Level5/To_copy"

# Values will be replaced by ConfigFile objects
var config_files = {
	"tv": LevelManager.get_level_dir(level_name) + "/TV/tv.txt",
	"p1": LevelManager.get_level_dir(level_name) + "/TV/Channels/PONG/player1.txt",
	"p2": LevelManager.get_level_dir(level_name) + "/TV/Channels/PONG/player2.txt",
}


func _ready():
	$Player.set_camera_limits(Vector2(0,0), Vector2(2560, 720))
	reload()



func reload():
	copy_folder_deep()
	get_configs()
	match config_files["tv"].get_value("tv", "channel", "OFF").to_upper():
		"OFF":
			print("im off")
		"PONG":
			print("play pong")
		"DISCO":
			print("disco")


func _on_Area2D_body_entered(body):
	if body.name == "Player" and config_files["tv"].get_value("tv", "channel", "OFF") == "PONG":
		GameState.player_can_move = false
		$TV.start_pong()


func get_configs():
	for key in config_files.keys():
		var cfg = ConfigFile.new()
		if cfg.load(config_files[key]) == OK:
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

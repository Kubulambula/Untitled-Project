extends Node2D

func _ready():
	var level_data = LevelManager.parse_level_data(
		LevelManager.read_level_data("level1")
	)
	LevelManager.build_tilemaps(self, level_data["map"])
	
	var player = load("res://Scenes/Entities/Player.tscn").instance()
	# Jestli budeme chtít hráče uprostřed tile, tak stačí přičíst GameState.tile_unit_size/2
	player.set_global_position(LevelManager.get_world_position(level_data["player"]["position"]))
	add_child(player)
	
#	WebAPI.login("hulan", "valecek123")
	
#	print(level_data)


func _input(_event):
	if Input.is_action_just_pressed("ui_page_up"):
		PopupBox.create_simple()
	elif Input.is_action_just_pressed("ui_page_down"):
		PopupBox.create_labeled()
	elif Input.is_action_just_pressed("ui_accept"):
		PopupBox.player_request_next()

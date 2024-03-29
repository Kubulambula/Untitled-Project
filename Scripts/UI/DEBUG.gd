extends Node2D

func _ready():
	var level_data = LevelManager.parse_level_data(
		LevelManager.read_level_data("level1")
	)


	LevelManager.build_tilemaps(self, level_data["map"])
	LevelManager.spawn_entities(self, level_data["entities"])

	print(level_data)
	
	WebAPI.login("Hulan", "valecek123", funcref(self, "on_login"))
	WebAPI.get_user_info(funcref(self, "on_get_user_info"))


func on_login(code, response):
	print("GET(" + str(code) + "): " + str(response))

# warning-ignore:unused_argument
func on_get_user_info(code, response):
	if code == 200:
		print("Logged in as '" + response["name"] + "'.")

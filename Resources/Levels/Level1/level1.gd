extends Node2D

const level = "level1"

var level_data = null

func _ready():
	GameState.player_can_move = false
	# warning-ignore:return_value_discarded
	EventReporter.connect("event_reported", self, "handle_event")
	
	LevelManager.set_map_dimensions(16, 9)
	level_data = LevelManager.parse_level_data(LevelManager.read_level_data(level))
	
	LevelManager.apply_immovable_mask(level_data, ["$", "P"])
	LevelManager.apply_max_entity_mask(level_data, {"P": 1, "D": 1})
	
	# Insert level specific masks/checks here
	
	LevelManager.write_level_data(level, LevelManager.serialize_level_data(level_data))
	
	LevelManager.build_tilemaps(self, level_data["map"])
	LevelManager.spawn_entities(self, level_data["entities"])
	
	# WARNING: You must call this AFTER the entities have been spawned
	LevelManager.set_entity_properties(level_data, {
		"$": {
			"coin_type": [2, 2, 0, 1, 1, 0]
		}
	})
	
	if not OS.is_debug_build():
		PopupBox.create_simple("ahoj", "")
		yield(PopupBox, "next_button")
		PopupBox.player_request_next()
		PopupBox.create_labeled("Jak je?", "ahoj", "", 2)
		yield(PopupBox, "hidden")
	GameState.player_can_move = true


func handle_event(source, name):
	if name == "player_reached_door":
		var result = "0".repeat(15) + str(GameState.score)
		WebAPI.submit(result, funcref(self, "_on_submit_response"))
		WebAPI.get_my_results(funcref(self, "_on_get_my_results_response"))

func _on_submit_response(code, response):
	print(code, response)

func _on_get_my_results_response(code, response):
	print(code, response)

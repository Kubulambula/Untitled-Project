extends Node2D

const level = "level1"

var level_data = null


func _ready():
	GameState.player_can_move = false
	# warning-ignore:return_value_discarded
	EventReporter.connect("event_reported", self, "handle_event")
	level_data = LevelManager.parse_level_data(LevelManager.read_level_data("level1"), false)
	LevelManager.build_tilemaps(self, level_data["map"])
	LevelManager.spawn_entities(self, level_data["entities"])
	
	if not OS.is_debug_build():
		PopupBox.create_simple("ahoj", "")
		yield(PopupBox, "next_button")
		PopupBox.player_request_next()
		PopupBox.create_labeled("Jak je?", "ahoj", "", 2)
		yield(PopupBox, "hidden")
	GameState.player_can_move = true


func handle_event(source, name):
	print("level event: ", source, name)

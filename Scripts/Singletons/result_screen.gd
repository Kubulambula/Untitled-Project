extends Node

var overlay_layer = preload("res://Scenes/Singleton_scenes/result_overlay.tscn").instance()
var overlay = overlay_layer.get_node("Control")

var _to_load = ""


func _ready():
	overlay.hide()
	add_child(overlay_layer)
	overlay.get_node("Button").connect("pressed", self, "_on_continue_pressed")

func _on_continue_pressed():
	EscOverlay.allowed = true
	overlay.hide()
	GameState.player_can_move = true
	# warning-ignore:return_value_discarded
	get_tree().change_scene(_to_load)

func show_game_code(code, to_load):
	EscOverlay.allowed = false
	_to_load = to_load
	GameState.player_can_move = false
	var label = overlay.get_node("Label")
	label.text = code
	overlay.show()

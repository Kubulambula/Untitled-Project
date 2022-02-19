extends Node

var overlay_layer = preload("res://Scenes/Singleton_scenes/result_overlay.tscn").instance()
var overlay = overlay_layer.get_node("Control")

func _ready():
	overlay.hide()
	add_child(overlay_layer)
	overlay.get_node("Button").connect("pressed", self, "_on_continue_pressed")

func _on_continue_pressed():
	overlay.hide()

func show_game_code(code):
	var label = overlay.get_node("Label")
	label.text = code
	overlay.show()

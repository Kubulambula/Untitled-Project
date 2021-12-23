extends Node

var overlay_preload = preload("res://Scenes/Singleton_scenes/window_overlay.tscn")
var overlay
var _player: AnimationPlayer


func _ready():
	overlay = overlay_preload.instance()
	_player = overlay.get_node("AnimationPlayer")
	add_child(overlay)


func dim(instantly:bool = false):
	_player.play("dim")
	if instantly:
		_player.seek(_player.current_animation_length)


func undim(instantly:bool = false):
	_player.play_backwards("dim")
	if instantly:
		_player.seek(0)

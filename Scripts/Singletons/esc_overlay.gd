extends Node

const version_format = "Version: %s"

var allowed: bool = true


func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	add_child(preload("res://Scenes/Singleton_scenes/esc_overlay.tscn").instance())
	$CanvasLayer/Control.visible = false
	$CanvasLayer/Control/VBoxContainer/HBoxContainer/Version.text = version_format % GameState.version


func show():
	if allowed:
		$CanvasLayer/Control.visible = true
		get_tree().paused = true


func hide():
	$CanvasLayer/Control.visible = false
	get_tree().paused = false


func _input(_event):
	if Input.is_action_just_pressed("ui_pause"):
		if $CanvasLayer/Control.visible:
			hide()
		else:
			show()

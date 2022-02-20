extends Node

const version_format = "Version: %s"

var allowed: bool = true


func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS
	add_child(preload("res://Scenes/Singleton_scenes/esc_overlay.tscn").instance())
	$CanvasLayer/Control.visible = false
	$CanvasLayer/Control/Version/HBoxContainer/Version.text = version_format % GameState.version
	# warning-ignore:return_value_discarded
	$CanvasLayer/Control/MenuButton.connect("pressed", self, "_menu_pressed")
	# warning-ignore:return_value_discarded
	$CanvasLayer/Control/ReloadButton.connect("pressed", self, "_reload_pressed")


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
	if Input.is_action_just_pressed("ui_reload") and $CanvasLayer/Control.visible:
		_reload_pressed()


func _menu_pressed():
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Scenes/UI/main_menu.tscn")
	hide()


func _reload_pressed():
	# warning-ignore:return_value_discarded
	get_tree().reload_current_scene()
	hide()

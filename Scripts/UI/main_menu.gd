extends Control

const version_format = "Version: %s"
onready var login_panel = $Login

# TODO : 
# load the level with threads
# add credits


func _ready():
	EscOverlay.allowed = false
	$VBoxContainer/HBoxContainer/Version.text = version_format % GameState.version


func _on_Button_pressed():
	EscOverlay.allowed = true
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Resources/Levels/Level1/level1.tscn")

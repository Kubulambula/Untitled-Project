extends Control

const version_format = "Version: %s"

# TODO : 
# load the level with threads
# add login screen for first time login
# add credits


func _ready():
	$VBoxContainer/HBoxContainer/Version.text = version_format % ProjectSettings.get_setting("untitled_project/config/version")

func _on_Button_pressed():
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Resources/Levels/Level1/level1.tscn")

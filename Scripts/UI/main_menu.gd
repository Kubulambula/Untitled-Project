extends Control

# TODO : 
# load the level with threads
# add login screen for first time login
# add credits


func _on_Button_pressed():
	get_tree().change_scene("res://Resources/Levels/Level1/level1.tscn")

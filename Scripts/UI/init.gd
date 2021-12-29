extends Node2D

const next_scene_path = "res://Scenes/UI/main_menu.tscn"


func _ready():
	ResourceQueue.register_callback(next_scene_path, "is_ready", funcref(self, "_next_scene_ready"))
	ResourceQueue.queue_resource(next_scene_path)
	if OS.is_debug_build():
		$AnimationPlayer.play("intro_middle")
	else:
		$AnimationPlayer.play("intro_slow")


func _next_scene_ready(resource):
	if $AnimationPlayer.playback_active:
		yield($AnimationPlayer, "animation_finished")
	# warning-ignore:return_value_discarded
	get_tree().change_scene_to(ResourceQueue.get_resource(resource))

extends Node2D

const next_scene_path = "res://Scenes/UI/main_menu.tscn"

var intro = "intro_slow"

var can_load_next_scene
var next_scene = null


func _ready():
	EscOverlay.allowed = false
	ResourceQueue.register_callback(next_scene_path, "is_ready", funcref(self, "_next_scene_ready"))
	ResourceQueue.queue_resource(next_scene_path)
	if OS.is_debug_build():
		intro = "intro_middle"
	$AnimationPlayer.play(intro)


func _next_scene_ready(resource):
	if can_load_next_scene:
		_switch_to_next_scene(ResourceQueue.get_resource(resource))
	else:
		next_scene = ResourceQueue.get_resource(resource)


func animation_call():
	if next_scene:
		_switch_to_next_scene(next_scene)
	can_load_next_scene = true


func _switch_to_next_scene(scene):
	if intro == "intro_fast":
		WindowOverlay.dim(.1)
	else:
		WindowOverlay.dim(0)
	yield(get_tree().create_timer(.15), "timeout")
	# warning-ignore:return_value_discarded
	get_tree().change_scene_to(scene)
	WindowOverlay.undim(.3)


func _input(event):
	# Ctrl + Shift+ Arrow Up
	if event is InputEventKey and event.alt and event.shift and event.scancode == KEY_UP:
		if not GameState.dev_mode:
			GameState.dev_mode = true
			print("=== DEV MODE ===")
	

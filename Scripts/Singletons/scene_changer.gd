extends Node

var _is_loading = false
var minimal_loading_time_sec = 2

var earliest_loaded_msec


func change_scene(path):
	if _is_loading: 
		return -1
	_is_loading = true
	earliest_loaded_msec = OS.get_system_time_msecs() + minimal_loading_time_sec*1000
	WindowOverlay.dim()
	
	ResourceQueue.register_callback(path, "is_ready", funcref(self, "on_resource_ready"))
	ResourceQueue.queue_resource(path)


func on_resource_ready(resource):
	_is_loading = false
	call_deferred("_change_scene", resource)


func _change_scene(resource):
	if OS.has_feature("release") and OS.get_system_time_msecs() < earliest_loaded_msec: # Check for minimal loading time. If not over, simulate loading
		yield(get_tree().create_timer(minimal_loading_time_sec), "timeout")
	
	print("\nSceneChanger: " + str(resource))
	# warning-ignore:return_value_discarded
	get_tree().change_scene_to(ResourceQueue.get_resource(resource))
	WindowOverlay.undim()

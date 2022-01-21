extends Node

signal complete

const _overlay_preload = preload("res://Scenes/Singleton_scenes/window_overlay.tscn")

var default_duration: float = 0.5
var dim_color: Color = Color("#242424")
var undim_color: Color = Color("#00000000")

var overlay: CanvasLayer
var _tween: Tween
var _color_rect: ColorRect



func _ready():
	overlay = _overlay_preload.instance()
	_tween = overlay.get_node("Tween")
# warning-ignore:return_value_discarded
	_tween.connect("tween_all_completed", self, "_tween_completed")
	_color_rect = overlay.get_node("ColorRect")
	_color_rect.color = undim_color
	add_child(overlay)


func dim(duration:float=0):
	# warning-ignore:return_value_discarded
	_tween.interpolate_property(_color_rect, "color", undim_color, dim_color, duration)
	# warning-ignore:return_value_discarded
	_tween.start()


func undim(duration:float=0):
	# warning-ignore:return_value_discarded
	_tween.interpolate_property(_color_rect, "color", dim_color, undim_color, duration)
	# warning-ignore:return_value_discarded
	_tween.start()


func _tween_completed():
	emit_signal("complete")

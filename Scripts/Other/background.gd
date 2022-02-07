extends Node2D

onready var _parallax = $ParallaxBackground

func _ready():
#	if name == "Background":
	set_process(false)
	$AnimationPlayer.play("stuff")
	for child in $ParallaxBackground.get_children():
		for sub_child in child.get_children():
			if sub_child is AnimatedSprite:
				sub_child.playing = true


func _on_AnimationPlayer_animation_finished(_anim_name):
	$AnimationPlayer.play("stuff")


func _process(delta):
	_parallax.scroll_offset = lerp(_parallax.scroll_offset, get_local_mouse_position() / 64, 7 * delta)

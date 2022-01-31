extends Node2D


func _ready():
	$AnimationPlayer.play("stuff")
	for child in $ParallaxBackground.get_children():
		for sub_child in child.get_children():
			if sub_child is AnimatedSprite:
				sub_child.playing = true




func _on_AnimationPlayer_animation_finished(_anim_name):
	$AnimationPlayer.play("stuff")

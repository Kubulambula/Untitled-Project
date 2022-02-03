extends Node

var is_opened = false
var is_fade_out_ready = false

# Work in progress
func open_treasure():
	GameState.score += 500

func _on_Area2D_body_entered(body):
	if body.name == "Player":
		if not is_opened:
			$Label.show()

func _on_Area2D_body_exited(body):
	if body.name == "Player":
		$Label.hide()

func _input(event):
	if event.is_action_pressed("use_interact"):
		if not is_opened:
			open_treasure()
			is_opened = true
			$AnimatedSprite.play("open")

func _on_AnimatedSprite_animation_finished():
	$Label.hide()
	is_fade_out_ready = true

func _physics_process(delta):
	if is_opened and is_fade_out_ready:
		$AnimatedSprite.set_modulate(lerp($AnimatedSprite.get_modulate(), Color(1,1,1,0), 0.1))

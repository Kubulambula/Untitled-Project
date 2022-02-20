extends Node

var is_opened = false
var is_fade_out_ready = false

var _can_open = false

# Work in progress
func open_treasure():
	GameState.score += 500

func _on_Area2D_body_entered(body):
	if body.name == "Player":
		_can_open = true
		if not is_opened:
			$ChestTitle.show()

func _on_Area2D_body_exited(body):
	if body.name == "Player":
		_can_open = false
		$ChestTitle.hide()

func _input(event):
	if event.is_action_pressed("ui_interact"):
		if _can_open and not is_opened:
			open_treasure()
			is_opened = true
			$AnimatedSprite.play("open")

func _on_AnimatedSprite_animation_finished():
	if $AnimatedSprite.animation == "open":
		$ChestTitle.hide()
		is_fade_out_ready = true

func _physics_process(delta):
	if is_opened and is_fade_out_ready:
		$AnimatedSprite.set_modulate(lerp($AnimatedSprite.get_modulate(), Color(1,1,1,0), 0.1))

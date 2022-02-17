extends Node2D

signal end(player)

onready var ball = $BG/Ball

var player_score = 0
var jakub_score = 0

var ended = false


func _on_Player_back_body_entered(body):
	if body.name == "Ball":
		jakub_score += 1
		$BG/JakubScore.text = str(jakub_score)
		if jakub_score == 3: # Jakub won
			$BG/Jakub.set_physics_process(false)
			$BG/PlayerPONG.speed = 0
			ball.speed = 0
			emit_signal("end", false)
			ended = true
		else:
			restart()


func _on_Jakub_back_body_entered(body):
	if body.name == "Ball":
		player_score += 1
		$BG/PlayerScore.text = str(player_score)
		if player_score == 3:
			$BG/Jakub.set_physics_process(false)
			$BG/PlayerPONG.speed = 0
			ball.speed = 0
			emit_signal("end", true)
			ended = true
		else:
			restart()


func restart():
	$BG/PlayerScore.text = str(player_score)
	$BG/JakubScore.text = str(jakub_score)
	ball.restart()

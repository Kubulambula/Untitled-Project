extends Area2D


func _on_PlayerDeathCheker_body_exited(body):
	if body is KinematicBody2D and body.name == "Player":
		EventReporter.report_event(self, "player_outside_play_area")

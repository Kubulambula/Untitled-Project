extends Area2D




func _on_PlayerDeathCheker_body_exited(body):
	if body is KinematicBody2D and body.has_method("is_grounded"): # This is so retarded
		EventReporter.report_event(self, "player_outside_play_area")

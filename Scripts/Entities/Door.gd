extends Area2D

# TODO : redo the Door scene

func _on_Area2D_body_entered(body):
	if body is KinematicBody2D and body.has_method("recalculate_movement_settings"): # This is so retarded
		EventReporter.report_event(self, "player_reached_door")

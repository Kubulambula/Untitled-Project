extends Area2D

# TODO : redo the Door scene

func _on_Area2D_body_entered(body):
	if body.name == "Player":
		EventReporter.report_event(self, "player_reached_door")

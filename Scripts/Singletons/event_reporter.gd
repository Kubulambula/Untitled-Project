extends Node

signal event_reported(source, name)


func report_event(source: Object, name: String) -> void:
	emit_signal("event_reported", source, name)

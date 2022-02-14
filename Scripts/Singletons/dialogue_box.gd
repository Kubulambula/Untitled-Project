extends Node

signal _player_request_next
signal next_button
signal hidden

var popup = preload("res://Scenes/Singleton_scenes/popup_box.tscn").instance()
var timer = Timer.new()

const lorem = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam id massa vitae est fermentum accumsan sed ut augue. Aenean a nisi placerat justo volutpat placerat. Aenean mollis pulvinar libero at eleifend. Morbi hendrerit lectus et leo vestibulum placerat. Pellentesque pretium elit a faucibus elementum. Aenean porttitor venenatis enim sit amet fringilla. Nunc eget elit sit amet urna bibendum iaculis a a tellus. In imperdiet ante magna, tempus consectetur erat posuere sed. Fusce in elit vitae ligula fermentum luctus. Proin et finibus metus, in lobortis libero."
const default_popup_duration: float = 3.5

enum {ADAM, JAKUB}

onready var tween = popup.get_node("Tween")
onready var window  = popup.get_node("Window")
onready var adam  = popup.get_node("Window/AdamBox")
onready var jakub = popup.get_node("Window/JakubBox")
onready var portrait = popup.get_node("Window/Portrait")
onready var text_label = popup.get_node("Window/Text")
onready var prompt = popup.get_node("Window/Prompt")

var queue = []
var current_item = null


# USAGE EXAMPLE
#func _ready():
#	print("dialogue start")
#	DialogueBox.create_adam("[wave]" + DialogueBox.lorem + "[/wave]", -1)
#	DialogueBox.wait_for_next_request()
#	yield(DialogueBox, "_player_request_next")
#
#	DialogueBox.create_adam("[color=red][wave]" + DialogueBox.lorem + "[/wave][/color]", -1)
#	DialogueBox.wait_for_next_request()
#	yield(DialogueBox, "_player_request_next")
#
#	DialogueBox.create_adam("[color=red][wave]" + DialogueBox.lorem + "[/wave][/color]", -1)
#	DialogueBox.wait_for_next_request()
#	yield(DialogueBox, "_player_request_next")
#	print("dialogue complete")


func _ready():
	add_child(popup)
	add_child(timer)
	timer.connect("timeout", self, "_timer_timeout")
	popup.get_node("AnimationPlayer").play("blink")


func show_next_popup():
	if len(queue) > 0:
		if window.rect_position.x == 0:
			_hide_popup()
			yield(tween, "tween_completed")
		_show_popup()
	else:
		_hide_popup()


func _timer_timeout():
	timer.stop()
	current_item = null
	queue.pop_front()
	show_next_popup()


func _create_helper(object):
	queue.push_back(object)
	if len(queue) == 1:
		show_next_popup()


func pause_process(hide_current = true):
	if hide_current:
		adam.hide()
		jakub.hide()
	timer.paused = true
	timer.wait_time = current_item.duration if current_item else default_popup_duration


func resume_process():
	timer.paused = false
	if not current_item:
		return
	if current_item.type == ADAM:
		adam.show()
	elif current_item.type == JAKUB:
		jakub.show()


func clear_queue(include_current = true):
	queue = []
	if include_current:
		_timer_timeout()


func create_adam(text: String=lorem, duration: float=-0):
	_create_helper({
		"text": text,
		"image": "adam",
		"duration": duration,
		"type": ADAM
	})


func create_jakub(text: String=lorem, duration: float=-0):
	_create_helper({
		"text": text,
		"image": "jakub",
		"duration": duration,
		"type": JAKUB
	})


func create_adam_angry(text: String=lorem, duration: float=-0):
	_create_helper({
		"text": text,
		"image": "adam_angry",
		"duration": duration,
		"type": ADAM
	})


func create_jakub_angry(text: String=lorem, duration: float=-0):
	_create_helper({
		"text": text,
		"image": "jakub_angry",
		"duration": duration,
		"type": JAKUB
	})


func _show_popup():
	var item = queue.front()
		
	if item.type == ADAM:
		adam.show()
		jakub.hide()
	elif item.type == JAKUB:
		jakub.show()
		adam.hide()
	
	portrait.animation = item.image
	text_label.bbcode_text = item.text
	
	current_item = item
	tween.interpolate_property(window, "rect_position:x", null, 0, 0.3, Tween.TRANS_QUART, Tween.EASE_OUT)
	tween.start()
	
	if item.duration == 0: # No time = use default
		prompt.visible = false
		item.duration = default_popup_duration
		timer.start()
	elif item.duration == -1: # Negative time = wait for player input
		prompt.visible = true
		yield(self, "_player_request_next")
		_timer_timeout()
	else:
		prompt.visible = false
		timer.wait_time = item.duration
		timer.start()


func _hide_popup():
	tween.interpolate_property(window, "rect_position:x", null, -900, 0.3, Tween.TRANS_QUART, Tween.EASE_OUT)
	tween.start()
	emit_signal("hidden")


func player_request_next():
	emit_signal("_player_request_next")


func wait_for_next_request():
	yield(self, "next_button")
	emit_signal("_player_request_next")


func _input(_event):
	if Input.is_action_just_pressed("ui_next_dialogue"):
		emit_signal("next_button")

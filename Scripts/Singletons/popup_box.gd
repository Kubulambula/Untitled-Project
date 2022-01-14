extends Node

signal _player_request_next

var popup = preload("res://Scenes/Singleton_scenes/popup_box.tscn").instance()
var timer = Timer.new()

const lorem = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam id massa vitae est fermentum accumsan sed ut augue. Aenean a nisi placerat justo volutpat placerat. Aenean mollis pulvinar libero at eleifend. Morbi hendrerit lectus et leo vestibulum placerat. Pellentesque pretium elit a faucibus elementum. Aenean porttitor venenatis enim sit amet fringilla. Nunc eget elit sit amet urna bibendum iaculis a a tellus. In imperdiet ante magna, tempus consectetur erat posuere sed. Fusce in elit vitae ligula fermentum luctus. Proin et finibus metus, in lobortis libero."
const default_popup_duration: float = 3.5

enum {SIMPLE, LABELED}

onready var window  = popup.get_node("Window")
onready var simple  = popup.get_node("Window/Simple")
onready var labeled = popup.get_node("Window/Labeled")

var queue = []
var current_item = null

const images = {
#	"question_mark":    preload("res://Resources/UI/Popup/Icons/question_mark.png"),
#	"exclamation_mark": preload("res://Resources/UI/Popup/Icons/exclamation_mark.png"),
#	"hat":              preload("res://Resources/UI/Popup/Icons/hat.png")
}


func _ready():
	add_child(popup)
	add_child(timer)
	timer.connect("timeout", self, "_timer_timeout")


func show_next_popup():
	if len(queue) > 0:
		if window.rect_position.x == 0:
			_hide_popup()
			yield(popup.get_node("AnimationPlayer"), "animation_finished")
		_show_popup()
	else:
		_hide_popup()


func _timer_timeout():
	timer.stop()
	current_item = null
	queue.pop_front()
	show_next_popup()


func _create_helper(object):
	if object.image:
		if object.image in images:
			object.image = images[object.image]
		else:
			push_error("Image '" + object.image + "' does not exist")
			return
	else:
		object.image = null
		
	queue.push_back(object)
	if len(queue) == 1:
		show_next_popup()


func pause_process(hide_current = true):
	if hide_current:
		simple.hide()
		labeled.hide()
	timer.paused = true
	timer.wait_time = current_item.duration if current_item else default_popup_duration


func resume_process():
	timer.paused = false
	if not current_item:
		return
	if current_item.type == SIMPLE:
		simple.show()
	elif current_item.type == LABELED:
		labeled.show()


func clear_queue(include_current = true):
	queue = []
	if include_current:
		_timer_timeout()


func create_simple(text: String=lorem, image: String="", duration: float=-1.0):
	_create_helper({
		"text": text,
		"image": image,
		"duration": duration,
		"type": SIMPLE
	})


func create_labeled(label: String=lorem, text: String=lorem, image: String="", duration: float=-1.0):
	_create_helper({
		"text": text,
		"label": label,
		"image": image,
		"duration": duration,
		"type": LABELED
	})


func _show_popup():
	var item = queue.front()
		
	if item.type == SIMPLE:
#		simple.get_node("Window/Content").text = item.text
#		simple.get_node("Window/Icon").texture = item.image
		simple.show()
		labeled.hide()
	elif item.type == LABELED:
#		labeled.get_node("Window/Label").text = item.label
#		labeled.get_node("Window/Content").text = item.text
#		labeled.get_node("Window/Icon").texture = item.image
		labeled.show()
		simple.hide()
	
	current_item = item
	popup.get_node("AnimationPlayer").play("Slide")
	
	if item.duration == 0: # No time = use default
		item.duration = default_popup_duration
	elif item.duration == -1: # Negative time = wait for player input
		yield(self, "_player_request_next")
		_timer_timeout()


func _hide_popup():
	popup.get_node("AnimationPlayer").play_backwards("Slide")


func player_request_next():
	emit_signal("_player_request_next")

extends Control

const version_format = "Version: %s"
onready var login_panel = $Login

onready var title = $AnimatedSprite
# Ah yes... animations
var title_animations_ptr = 0
const title_animations = [
	"idle",
	"idle",
	"shine",
	"idle",
	"idle",
	"idle",
	"idle",
	"idle",
	"idle",
	"idle",
	"idle",
	"shine",
	"idle",
	"idle",
	"idle",
	"idle",
	"idle",
	"idle",
	"idle",
	"idle",
	"idle",
	"shine",
	"idle",
	"idle",
	"idle",
	"gamebook",
	"idle",
	"shine",
	"idle",
	"idle",
	"idle",
	"idle",
	"idle",
	"idle",
	"shine",
]

# TODO : 
# load the level with threads
# add credits


func _ready():
	EscOverlay.allowed = false
	$VBoxContainer/HBoxContainer/Version.text = version_format % GameState.version
	
	title.animation = title_animations[0]
	title_animations_ptr = (title_animations_ptr + 1) % title_animations.size()
	title.frame = 0
	title.playing = true

func _on_Button_pressed():
	EscOverlay.allowed = true
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Resources/Levels/Level1/level1.tscn")


func _on_AnimatedSprite_animation_finished():
	print(title_animations[title_animations_ptr])
	title.animation = title_animations[title_animations_ptr]
	title_animations_ptr = (title_animations_ptr + 1) % title_animations.size()
	title.frame = 0
	title.playing = true

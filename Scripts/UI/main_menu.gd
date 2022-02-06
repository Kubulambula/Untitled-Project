extends Control

const version_format = "Version: %s"
onready var login_panel = $Login

onready var title = $Title
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
	WindowOverlay.dim(0.5)
	yield(WindowOverlay, "complete")
	EscOverlay.allowed = true
	# warning-ignore:return_value_discarded
	get_tree().change_scene(LevelManager.get_level_scene(GameState.current_level))
	WindowOverlay.undim(0.5)


func _on_AnimatedSprite_animation_finished():
	title.animation = title_animations[title_animations_ptr]
	title_animations_ptr = (title_animations_ptr + 1) % title_animations.size()
	title.frame = 0
	title.playing = true


func _on_Quit_pressed():
	GameState.pls_quit()


func _on_Settings_pressed():
	pass # Replace with function body.

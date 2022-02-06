extends Control

const version_format = "%s: %s"
onready var login_panel = $Login

onready var title = $GUI/Menu/Title
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
	$VBoxContainer/HBoxContainer/Version.text = version_format % [TranslationServer.translate("$version"), GameState.version]
	
	title.animation = title_animations[0]
	title_animations_ptr = (title_animations_ptr + 1) % title_animations.size()
	title.frame = 0
	title.playing = true


func _on_AnimatedSprite_animation_finished():
	title.animation = title_animations[title_animations_ptr]
	title_animations_ptr = (title_animations_ptr + 1) % title_animations.size()
	title.frame = 0
	title.playing = true


func _on_Start_pressed():
	WindowOverlay.dim(0.5)
	yield(WindowOverlay, "complete")
	EscOverlay.allowed = true
	# warning-ignore:return_value_discarded
	get_tree().change_scene("res://Resources/Levels/Level1/level1.tscn")
	WindowOverlay.undim(0.5)


func _on_Quit_pressed():
	GameState.pls_quit()


func _on_Settings_pressed():
	pass # Replace with function body.


func _on_About_pressed():
	pass # Replace with function body.


func _on_GodotLogo_pressed():
	OS.shell_open("https://godotengine.org/")


func _on_QRCodeLicense_meta_clicked(meta):
	OS.shell_open("https://www.nayuki.io/page/qr-code-generator-library")


func _on_QRCode_pressed():
	OS.shell_open("https://www.nayuki.io/page/qr-code-generator-library")

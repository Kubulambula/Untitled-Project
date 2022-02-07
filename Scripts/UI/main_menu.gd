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
	$CanvasLayer/VBoxContainer/HBoxContainer/Version.text = version_format % [TranslationServer.translate("$version"), GameState.version]
	$GUI/Settings/SettingsTab.set_tab_title(0, TranslationServer.translate("$graphics"))
	$GUI/Settings/SettingsTab.set_tab_title(1, TranslationServer.translate("$user"))
	
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
	get_tree().change_scene(LevelManager.get_level_scene(GameState.current_level))
	WindowOverlay.undim(0.5)


func _on_Quit_pressed():
	WindowOverlay.dim(0.2)
	yield(WindowOverlay, "complete")
	yield(get_tree().create_timer(0.2), "timeout")
	GameState.pls_quit()


func _on_Settings_pressed():
	$Tween.interpolate_property($Camera2D, "offset:x", null, -640, 0.75, Tween.TRANS_QUINT, Tween.EASE_OUT)
	$Tween.start()


func _on_About_pressed():
	$Tween.interpolate_property($Camera2D, "offset:x", null, 1920, 0.75, Tween.TRANS_QUINT, Tween.EASE_OUT)
	$Tween.start()


func _on_GodotLogo_pressed():
	# warning-ignore:return_value_discarded
	OS.shell_open("https://godotengine.org/")


func _on_QRCodeLicense_meta_clicked(_meta):
	# warning-ignore:return_value_discarded
	OS.shell_open("https://www.nayuki.io/page/qr-code-generator-library")


func _on_QRCode_pressed():
	# warning-ignore:return_value_discarded
	OS.shell_open("https://www.nayuki.io/page/qr-code-generator-library")


func _input(_event):
	if Input.is_action_just_pressed("ui_pause"):
		$Tween.interpolate_property($Camera2D, "offset:x", null, 640, 0.75, Tween.TRANS_QUINT, Tween.EASE_OUT)
		$Tween.start()

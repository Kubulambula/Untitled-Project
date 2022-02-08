extends Control

const version_format = "%s: %s"
onready var login_panel = $Login

const screens = [640, 1920, 3200]
var screen = 1

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

const languages = ["cs", "en"]

# TODO : 
# load the level with threads


func _ready():
	EscOverlay.allowed = false
	$Version/VBoxContainer/HBoxContainer/Version.text = version_format % [TranslationServer.translate("$version"), GameState.version]
	
	title.animation = title_animations[0]
	title_animations_ptr = (title_animations_ptr + 1) % title_animations.size()
	title.frame = 0
	title.playing = true
	
	translate()
	_set_settings_from_saved_config()


func _on_AnimatedSprite_animation_finished():
	title.animation = title_animations[title_animations_ptr]
	title_animations_ptr = (title_animations_ptr + 1) % title_animations.size()
	title.frame = 0
	title.playing = true


func _move_screen():
	$Tween.interpolate_property($Camera2D, "offset:x", null, screens[screen], 0.75, Tween.TRANS_QUINT, Tween.EASE_OUT)
	$Tween.start()


func _set_settings_from_saved_config():
	$GUI/Settings/SettingsTab/Graphics/VBoxContainer/WindowMode/WindowMode.select(GameState.config.get_value("graphics", "window_mode", 0))
	$GUI/Settings/SettingsTab/Graphics/VBoxContainer/KeepScreenOn/KeepScreenOn.pressed = GameState.config.get_value("graphics", "keep_screen_on", true)
	$GUI/Settings/SettingsTab/Graphics/VBoxContainer/Vsync/Vsync.pressed = GameState.config.get_value("graphics", "vsync", true)
	$GUI/Settings/SettingsTab/Graphics/VBoxContainer/VsyncCompositor/VsyncCompositor.pressed = GameState.config.get_value("graphics", "vsync_via_compositor", true)
	
	$GUI/Settings/SettingsTab/User/VBoxContainer/Locale/Language.select(languages.find(GameState.config.get_value("user", "locale", "cs")))


func translate():
	$GUI/Settings/SettingsTab.set_tab_title(0, TranslationServer.translate("$graphics"))
	$GUI/Settings/SettingsTab.set_tab_title(1, TranslationServer.translate("$user"))

# Button fun stuff

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
	screen = 0
	_move_screen()


func _on_About_pressed():
	screen = 2
	_move_screen()


func _on_GodotLogo_pressed():
	# warning-ignore:return_value_discarded
	OS.shell_open("https://godotengine.org/")


func _on_QRCodeLicense_meta_clicked(_meta):
	# warning-ignore:return_value_discarded
	OS.shell_open("https://www.nayuki.io/page/qr-code-generator-library")


func _on_QRCode_pressed():
	# warning-ignore:return_value_discarded
	OS.shell_open("https://www.nayuki.io/page/qr-code-generator-library")


func _input(event):
	if event is InputEventKey and not $Login/Login.visible:
		if Input.is_action_just_pressed("ui_enter"):
			_on_Start_pressed()
		
		elif Input.is_action_just_pressed("ui_pause"):
			screen = 1
			_move_screen()
		
		elif Input.is_action_just_pressed("move_left"):
			screen = clamp(screen - 1, 0, screens.size()-1)
			_move_screen()
		
		elif Input.is_action_just_pressed("move_right"):
			screen = clamp(screen + 1, 0, screens.size()-1)
			_move_screen()


# Settings

func _on_WindowMode_item_selected(index):
	GameState.config.set_value("graphics", "window_mode", index)
	GameState.config.apply()


func _on_KeepScreenOn_toggled(button_pressed):
	GameState.config.set_value("graphics", "keep_screen_on", button_pressed)
	GameState.config.apply()


func _on_Vsync_toggled(button_pressed):
	GameState.config.set_value("graphics", "vsync", button_pressed)
	GameState.config.apply()


func _on_VsyncCompositor_toggled(button_pressed):
	GameState.config.set_value("graphics", "vsync_via_compositor", button_pressed)
	GameState.config.apply()


func _on_Language_item_selected(index):
	GameState.config.set_value("user", "locale", languages[index])
	GameState.config.apply()

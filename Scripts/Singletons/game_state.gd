extends Node

# TODO : Can skip login and some shit (Maybe)
var dev_mode = false

var config: _Config = _Config.new() setget set_discard

const tile_unit_size: Vector2 = Vector2(80, 80)
const map_tile_size: Vector2 = Vector2(16, 9)

var player_can_move = true

var version = ProjectSettings.get_setting("untitled_project/config/version")

var score = 0

func _init():
	print("[START]")
	# warning-ignore:return_value_discarded
	config.load_data()
	# warning-ignore:return_value_discarded
	config.save_data()
	config.apply()


func set_discard(_value):
	push_error("Do not modify this value directly >:(")


func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		pls_quit()


func pls_quit():
	print("[QUIT REQUEST]")
	# warning-ignore:return_value_discarded
	config.save_data()
	print("[QUITTING]")
	get_tree().quit()


# Wrapper for ConfigFile so it can be used safely from outside
class _Config:
	const config_file_path: String = "user://config.cfg"
	const default_config_file_path: String = "res://Resources/default_config.cfg"
	var _cfgf: ConfigFile
	
	
	func _init() -> void:
		_cfgf = ConfigFile.new()
	
	
	func load_data() -> int:
		var err: int = _cfgf.load(config_file_path)
		if err == OK:
			print("Confing found. Loading...")
			return OK
		elif err == ERR_FILE_NOT_FOUND:
			err = _cfgf.load(default_config_file_path)
			if err == OK:
				print("Config not found. Using default...")
				return OK
			else:
				printerr("Error while reading default config data. Err: " + str(err))
				return err
		else:
			printerr("Error while reading config data. Err: " + str(err))
			return err
	
	
	func save_data() -> int:
		var err: int = _cfgf.save(config_file_path)
		if err:
			printerr("Error while saving config data. Err: " + str(err))
		else:
			print("Saving config data...")
		return err
	
	
	func set_value(section: String, key: String, value) -> void:
		_cfgf.set_value(section, key, value)
	
	
	func get_value(section: String, key: String, default):
		return _cfgf.get_value(section, key, default)
	
	
	func apply(): # This is super trash, but who cares? ¯\_(ツ)_/¯
		# NOTE: Token is handled by login.tscn
		
		# Vsync
		OS.set_use_vsync(self.get_value("graphics", "vsync", true))
		# Window mode
		match self.get_value("graphics", "window_mode", 0):
			0: # Windowed
				OS.set_window_fullscreen(false)
				OS.set_borderless_window(false)
			1: # Fullscreen
				OS.set_window_fullscreen(true)
				OS.set_borderless_window(false)
			2: # Borderless
				OS.set_window_fullscreen(false)
				OS.set_borderless_window(true)
			_: # Someone is an idiot and set a bad value. Windowed
				OS.set_window_fullscreen(false)
				OS.set_borderless_window(false)
		# Locale
		if self.get_value("user", "locale", "cs") in TranslationServer.get_loaded_locales():
			TranslationServer.set_locale(self.get_value("user", "locale", "cs"))

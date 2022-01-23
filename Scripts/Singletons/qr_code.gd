extends Node

const qrc_res = "res://External/qrcode.exe"
const qrc_exe = "user://qrc/qrcode.exe"
const qrc_out = "user://qrc/output.bmp"


var _thread = null
var _thread_queue = []
var _mutex = null


func _ready():
	_mutex = Mutex.new()
	_thread = Thread.new()
	set_physics_process(false)
	
	if initialize():
		print("Succesful QRCode init")
	else:
		printerr("Unsuccesful QRCode init. See errors")


func initialize() -> bool:
	var d = Directory.new()
	if not d.file_exists(qrc_exe):
		var err = d.make_dir(qrc_exe.get_base_dir())
		if err == OK or err == ERR_ALREADY_EXISTS:
			err = d.copy(qrc_res, qrc_exe)
			if not err:
				return true
			else:
				push_error("Cannot copy user://qrc/qrcode.exe file. Err: " + str(err))
		else:
			push_error("Cannot create user://qrc/ dir. Err: " + str(err))
	elif d.file_exists(qrc_exe):
		return true
	else:
		push_error("WTF (qr_code.gd)")
	return false


func _physics_process(_delta):
	if not _thread.is_alive():
		_thread.wait_to_finish()
		set_physics_process(false)


func generate(content: String, handler: FuncRef):
	_thread_queue.push_back({"content": content, "handler":handler})
	if not _thread.is_active():
		_thread.start(self, "_thread_func")
	set_physics_process(true)


func _thread_func(_u):
	while true:
		_mutex.lock()
		var code = _thread_queue.pop_front()
		_mutex.unlock()
		if code:
			_thread_generate_and_get_code(code)
		else:
			break


func _thread_generate_and_get_code(code):
	var err = OS.execute(ProjectSettings.globalize_path(qrc_exe), [ProjectSettings.globalize_path(qrc_out), code.content])
	if err == OK:
		var image = Image.new()
		err = image.load(ProjectSettings.globalize_path(qrc_out))
		if err == OK:
			var image_texture = ImageTexture.new()
			image_texture.create_from_image(image)
			image_texture.set_flags(1)
			_mutex.lock()
			code.handler.call_func(image_texture)
			_mutex.unlock()
		else:
			push_error("Cannot load qrcode image. Error: " + str(err))
	else:
		push_error("Cannot generate qrcode. Exit code: " + str(err) + " Code content: " + str(code.content))

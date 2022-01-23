extends Node

var _exe_dir = OS.get_executable_path().get_base_dir()

func generate(content):
	OS.execute(_exe_dir + "/qrcode.exe", [_exe_dir + "/qrcode.bmp", content])

func read(element):
	var image = Image.new()
	var status = image.load(_exe_dir + "/qrcode.bmp")
	if status == OK:
		var texture_image = ImageTexture.new()
		texture_image.create_from_image(image)
		element.set_texture(texture_image)

func _ready():
	generate("https://www.youtube.com/watch?v=dQw4w9WgXcQ")

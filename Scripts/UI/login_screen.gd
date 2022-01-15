extends Control

func _ready():
	$Submit.connect("button_down", self, "on_submit_press")

func on_submit_press():
	var username = $Username.text
	var password = $Password.text
	if username != "" and password != "":
		WebAPI.login(username, password, funcref(self, "on_login_response"))
	else:
		print("Input credentials...")

func on_login_response(http_status, response):
	if http_status == 200:
		SceneChanger.change_scene("res://Scenes/UI/main_menu.tscn")
	else:
		print(http_status)

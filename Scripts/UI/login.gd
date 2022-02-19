extends Control

var logging_in = true

func _ready():
	$OfflineMode.visible = false
	show()
	$CenterContainer/TextureRect/FocusGroup/Name.grab_focus()
	var saved_token = GameState.config.get_value("user", "token", "")
	if saved_token:
		logging_in = false
		$CenterContainer/TokenLogin.visible = true
		_login_from_token(saved_token)


func _input(event):
	if event is InputEventKey and event.pressed == false and event.scancode == KEY_ENTER and logging_in:
		_on_Login_pressed()


func _on_Login_pressed():
	login($CenterContainer/TextureRect/FocusGroup/Name.text, $CenterContainer/TextureRect/FocusGroup/Password.text)


func _on_Login_focus_entered():
	$CenterContainer/TextureRect/FocusGroup/Name.grab_focus()


func show():
	visible = true


func hide():
	visible = false


func alert(message: String, duration: float = 2.5): # Oh my god...
	$CenterContainer/TextureRect/Alert/AlertLabel.text = message
	$AnimationPlayer.play("alert")
	yield(get_tree().create_timer(duration), "timeout")
	$AnimationPlayer.play_backwards("alert")


func login(login: String, password: String): #DO THIS WITH TOKEN FFS
	$AnimationPlayer2.play("load_indicator")
	WebAPI.login(login, password, funcref(self, "_on_login"))


func _on_login(code, response):
	$AnimationPlayer2.play_backwards("load_indicator")
	if code == 200: # OK
		print("Successful user login")
		logging_in = false
		GameState.config.set_value("user", "token", response["accessToken"])
		yield(get_tree().create_timer(.3), "timeout") # Jen aby to vypadalo profesionálně
		hide()
	elif code == 401: # Bad credentials or something idk
		alert("Unsuccessful login")
	else:
		if code == 0: # No internet
			alert("No internet")
		else: # Some random shit I didn't account for
			alert("GET(" + str(code) + "): " + str(response), 8)
		show_offline_mode()


func _login_from_token(saved_token):
	$AnimationPlayer2.play("load_indicator")
	WebAPI._access_token = saved_token
	WebAPI.get_user_info(funcref(self, "_user_info_response"))


func _user_info_response(code, response):
	$AnimationPlayer2.play_backwards("load_indicator")
	if code == 200:
		print("Logged in from saved token")
		hide()
	else:
		logging_in = true
		$CenterContainer/TokenLogin.visible = false
		GameState.config.set_value("user", "token", "")
		alert("Could not log in from token\nGET(" + str(code) + "): " + str(response), 8)
		show_offline_mode()


func show_offline_mode():
	$OfflineMode.visible = true


func _on_OfflineMode_pressed():
	$CenterContainer/OfflineModeConfirm.popup()


func _on_OfflineModeConfirm_confirmed():
	hide()
	GameState.offline = true
	printerr("===NOW IN OFFLINE MODE===")

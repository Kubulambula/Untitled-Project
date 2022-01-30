extends Control


func alert(message: String, duration: float = 5): # Oh my god...
	$CenterContainer/TextureRect/Alert/AlertLabel.text = message
	$AnimationPlayer.play("alert")
	yield(get_tree().create_timer(duration), "timeout")
	$AnimationPlayer.play_backwards("alert")


func _on_Login_pressed():
	WebAPI.login($CenterContainer/TextureRect/Name.text, $CenterContainer/TextureRect/Password.text, funcref(self, "_on_login"))


func _on_login(code, response):
	alert("GET(" + str(code) + "): " + str(response))

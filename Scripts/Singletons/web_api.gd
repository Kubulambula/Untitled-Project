extends Node

onready var http = {}
var _access_token = ""

func _ready():
	http = HTTPClient.new()
	http.connect("request_completed", self, "_on_response")

func login(name, password):
	http.request(
		"https://www.skulaurun.eu/purkiada-jwt-auth/user/login",
		[ "Content-Type: application/json" ],
		true,
		HTTPClient.METHOD_POST,
		to_json({
			"name": name,
			"password": password
		})
	)

func get_user_info():
	http.request(
		"https://www.skulaurun.eu/purkiada-jwt-auth/user",
		[
			"Access-Token: " + _access_token
		]
	)

func _on_response(result, response_code, headers, body, args):
	#print(body)
	print(args)
	pass

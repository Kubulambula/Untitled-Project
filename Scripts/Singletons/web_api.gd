extends Node

var _http = null
var _access_token = ""

var _callback = null
var _request_queue = []

func _ready():
	_http = HTTPRequest.new()
	_http.connect("request_completed", self, "_on_response")
	add_child(_http)

func generic_request(handler_name, args, method, url, data = ""):
	if _http.get_http_client_status() == HTTPClient.STATUS_DISCONNECTED:
		_callback = {
			"name": handler_name,
			"function": args[-1]
		}
		_http.request(
			url,
			[
				"Content-Type: application/json",
				"Access-Token: " + _access_token
			],
			true, method, data
		)
	else:
		_request_queue.append({
			"name": handler_name,
			"args": args
		})

func login(username, password, callback):
	generic_request(
		"login",
		[ username, password, callback ],
		HTTPClient.METHOD_POST,
		"https://www.skulaurun.eu/purkiada-jwt-auth/user/login",
		to_json({
			"name": username,
			"password": password
		})
	)

func get_user_info(callback):
	generic_request(
		"get_user_info",
		[ callback ],
		HTTPClient.METHOD_GET,
		"https://www.skulaurun.eu/purkiada-jwt-auth/user"
	)

func _on_response(result, code, headers, body):
	var next_request = _request_queue.pop_front()
	var response = (JSON.parse(body.get_string_from_utf8()).result)
	if _callback != null:
		if _callback["name"] == "login":
			_access_token = response["accessToken"]
		_callback["function"].call_func(response)
	if next_request != null:
		callv(next_request["name"], next_request["args"])

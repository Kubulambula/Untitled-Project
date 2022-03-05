extends Node

#var _http = null
#var _access_token = ""
#
#var _callback = null
#var _request_queue = []

#const API_URL = "https://www.skulaurun.eu/untitled-project/api"

#func _init():
#	if is_permitted():
#		initialize()

func initialize():
	pass
#	_http = HTTPRequest.new()
#	_http.connect("request_completed", self, "_on_response")
#	add_child(_http)

func is_permitted():
	return (OS.has_feature("Purkiada") or OS.has_feature("editor"))

func is_available():
	return is_permitted() #and (check if server is available)

func generic_request(_handler_name, _args, _method, _url, _data = ""):
	pass
#	if _http.get_http_client_status() == HTTPClient.STATUS_DISCONNECTED:
#		_callback = {
#			"name": handler_name,
#			"function": args[-1]
#		}
#		_http.request(
#			url,
#			[
#				"Content-Type: application/json",
#				"Access-Token: " + _access_token
#			],
#			true, method, data
#		)
#	else:
#		_request_queue.append({
#			"name": handler_name,
#			"args": args
#		})

func login(_username, _password, _callback):
	pass
#	generic_request(
#		"login",
#		[ username, password, callback ],
#		HTTPClient.METHOD_POST,
#		API_URL + "/auth/login",
#		to_json({
#			"name": username,
#			"password": password
#		})
#	)

func get_user_info(_callback):
	pass
#	generic_request(
#		"get_user_info",
#		[ callback ],
#		HTTPClient.METHOD_GET,
#		API_URL + "/me"
#	)

func submit(_code, _callback):
	pass
#	generic_request(
#		"submit",
#		[ code, callback ],
#		HTTPClient.METHOD_POST,
#		API_URL + "/results/submit",
#		to_json({
#			"code": code
#		})
#	)

func get_my_results(_callback):
	pass
#	generic_request(
#		"get_my_results",
#		[ callback ],
#		HTTPClient.METHOD_GET,
#		API_URL + "me/results"
#	)

# warning-ignore:unused_argument
# warning-ignore:unused_argument
func _on_response(_result, _code, _headers, _body):
	pass
#	var next_request = _request_queue.pop_front()
#	if _callback != null:
#		var response = null
#		if not body.empty():
#			response = (JSON.parse(body.get_string_from_utf8()).result)
#			if code == 200 and _callback["name"] == "login":
#				_access_token = response["accessToken"]
#		_callback["function"].call_func(code, response)
#	if next_request != null:
#		callv(next_request["name"], next_request["args"])

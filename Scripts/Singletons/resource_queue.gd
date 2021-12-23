extends Node
#Usage example at https://github.com/godotengine/godot-demo-projects/blob/3.2-5bd2bbf/loading/multiple_threads_loading/preload.gd
# Improved by Adam Charvát
# - Added callbacks
# - Fixed memory leaks

var thread
var mutex
var sem

var time_max = 100 # Milliseconds.

var queue = []
var pending = {}
var callbacks = {}

var running = true


func _ready():
	mutex = Mutex.new()
	sem = Semaphore.new()
	thread = Thread.new()
	thread.start(self, "thread_func", 0)


func _exit_tree():
	cleanup()


func _lock(_caller):
	mutex.lock()


func _unlock(_caller):
	mutex.unlock()


func _post(_caller):
	sem.post()


func _wait(_caller):
	sem.wait()


func thread_func(_u):
	while running:
		_thread_process()


func cleanup():
	running = false
	sem.post()
	mutex.unlock()
	thread.wait_to_finish()


func register_callback(path, action, ref):
	_lock("register_callback")
	if not path in callbacks:
		callbacks[path] = {}
	if not action in callbacks[path]:
		callbacks[path][action] = []
	callbacks[path][action].push_back(ref)
	_unlock("register_callback")


func _try_callback(path, action):
	_lock("_try_callback")
	if path in callbacks:
		if action in callbacks[path]:
			for ref in callbacks[path][action]:
				ref.call_func(path)
	if action == "is_ready":
		callbacks.erase(path)
	_unlock("_try_callback")


func queue_resource(path, p_in_front = false):
	_lock("queue_resource")
	if path in pending:
		_unlock("queue_resource")
		return
	elif ResourceLoader.has_cached(path):
		var res = ResourceLoader.load(path)
		pending[path] = res
		_unlock("queue_resource")
		return
	else:
		var res = ResourceLoader.load_interactive(path)
		res.set_meta("path", path)
		if p_in_front:
			queue.insert(0, res)
		else:
			queue.push_back(res)
		pending[path] = res
		_post("queue_resource")
		_unlock("queue_resource")
		return


func cancel_resource(path):
	_lock("cancel_resource")
	if path in pending:
		if pending[path] is ResourceInteractiveLoader:
			queue.erase(pending[path])
		pending.erase(path)
	_unlock("cancel_resource")


func get_progress(path):
	_lock("get_progress")
	var ret = -1
	if path in pending:
		if pending[path] is ResourceInteractiveLoader:
			ret = float(pending[path].get_stage()) / float(pending[path].get_stage_count())
		else:
			ret = 1.0
	_unlock("get_progress")
	return ret


func is_ready(path):
	var ret
	_lock("is_ready")
	if path in pending:
		ret = !(pending[path] is ResourceInteractiveLoader)
	else:
		ret = false
	_unlock("is_ready")
	return ret


func _wait_for_resource(res, path):
	_unlock("wait_for_resource")
	while true:
		VisualServer.sync()
		OS.delay_usec(16000) # Wait approximately 1 frame.
		_lock("wait_for_resource")
		if queue.size() == 0 || queue[0] != res:
			return pending[path]
		_unlock("wait_for_resource")


func get_resource(path):
	_lock("get_resource")
	if path in pending:
		if pending[path] is ResourceInteractiveLoader:
			var res = pending[path]
			if res != queue[0]:
				var pos = queue.find(res)
				queue.remove(pos)
				queue.insert(0, res)
			res = _wait_for_resource(res, path)
			pending.erase(path)
			_unlock("return")
			return res
		else:
			var res = pending[path]
			pending.erase(path)
			_unlock("return")
			return res
	else:
		_unlock("return")
		return ResourceLoader.load(path)


func _thread_process():
	_wait("_thread_process")
	if not running: return
	_lock("process")
	if not running: return
	while queue.size() > 0:
		var res = queue[0]
		_unlock("process_poll")
		var ret = res.poll()
		_lock("process_check_queue")

		if ret == ERR_FILE_EOF || ret != OK:
			var path = res.get_meta("path")
			if path in pending: # Else, it was already retrieved.
				pending[res.get_meta("path")] = res.get_resource()
			# Something might have been put at the front of the queue while
			# we polled, so use erase instead of remove.
			_try_callback(path, "is_ready")
			queue.erase(res)
	_unlock("process")

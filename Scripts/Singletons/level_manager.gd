extends Node

var map_width = 16
var map_height = 16

var map_tiles = {
	"#": 0
}

var map_entities = {
	"player": "P"
}

var layers = {
	"walls": ["#"]
}

var default_tileset = null

func _ready():
	default_tileset = load("res://Resources/Tiles/bitmap_test.tres")

func _open_exe_dir():
	var exe_dir = Directory.new()
	exe_dir.open(OS.get_executable_path().get_base_dir())
	return exe_dir

func _read_file(path):
	var file = File.new()
	file.open(path, File.READ)
	var content = file.get_as_text()
	file.close()
	return content

func get_level_dir(level):
	var exe_dir = _open_exe_dir()
	if not exe_dir.dir_exists(level):
		exe_dir.make_dir(level)
	return exe_dir.get_current_dir() + "/" + level

func read_level_data(level):
	var level_file = File.new()
	var file_path = get_level_dir(level) + "/level.txt"
	var internal_file_path = "res://Resources/Levels/" + level + ".tres"
	if level_file.file_exists(file_path):
		return _read_file(file_path)
	else:
		if level_file.file_exists(internal_file_path):
			var content = _read_file(internal_file_path)
			level_file.open(file_path, File.WRITE)
			level_file.store_string(content)
			level_file.close()
			return content

func _create_tilemap():
	var tilemap = TileMap.new()
	tilemap.cell_size = Vector2(64, 64)
	tilemap.tile_set = default_tileset
	return tilemap

func build_tilemaps(root, map):
	for key in layers.keys():
		var mask = layers[key]
		var tilemap = _create_tilemap()
		for y in len(map):
			for x in len(map[y]):
				var character = map[y][x]
				if character in mask:
					tilemap.set_cell(x, y, map_tiles[character])
					tilemap.update_bitmask_area(Vector2(x, y))
		root.add_child(tilemap)

func find_tile(map, tile):
	for y in len(map):
		for x in len(map[y]):
			if map[y][x] == tile:
				return Vector2(x, y)
	return Vector2(-1, -1)

func parse_level_data(content: String):
	var section = "Global"
	var lines = content.split("\n")
	var map = []
	var map_row_index = 0
	for line in lines:
		line = line.strip_edges()
		if line == "": continue
		if line.begins_with(";"): continue
		if line.begins_with("[") and line.ends_with("]"):
			section = line.substr(1, len(line) - 2)
			continue
		if section == "Map" and map_row_index != map_height:
			map.append(line.substr(0, map_width))
			map_row_index += 1
	return {
		"map": map,
		"player": {
			"position": find_tile(map, map_entities["player"])
		}
	}

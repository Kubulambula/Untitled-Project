extends Node

var map_tiles = {
	"#": 0
}

var map_entities = {
	"P": {
		"max": 1,
		"resource": "Player.tscn"
	},
	"D": {
		"max": 1,
		"resource": "Door.tscn"
	}
}

var layers = {
	"walls": ["#"]
}

var _default_tilemap = null

func _ready():
	_default_tilemap = TileMap.new()
	_default_tilemap.cell_size = GameState.tile_unit_size
	_default_tilemap.tile_set = load("res://Resources/Tiles/tileset.tres") # Obviously nahradit proper tilemapou
	add_child(_default_tilemap)

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
	var internal_file_path = "res://Resources/Levels/" + level + "/" + level + ".tres"
	if level_file.file_exists(file_path):
		return _read_file(file_path)
	else:
		if level_file.file_exists(internal_file_path):
			var content = _read_file(internal_file_path)
			level_file.open(file_path, File.WRITE)
			level_file.store_string(content)
			level_file.close()
			return content

func _create_compatible_tilemap():
	var tilemap = TileMap.new()
	tilemap.cell_size = _default_tilemap.cell_size
	tilemap.tile_set = _default_tilemap.tile_set
	return tilemap

func build_tilemaps(root, map):
	for key in layers.keys():
		var mask = layers[key]
		var tilemap = _create_compatible_tilemap()
		for y in len(map):
			for x in len(map[y]):
				var character = map[y][x]
				if character in mask:
					tilemap.set_cell(x, y, map_tiles[character])
					tilemap.update_bitmask_area(Vector2(x, y))
					tilemap.update_dirty_quadrants()
		root.add_child(tilemap)

func spawn_entities(root, entities):
	var scenes = []
	for entity_data in entities:
		var resource_path = entity_data["resource"]
		if not resource_path.begins_with("res://"):
			resource_path = "res://Scenes/Entities/" + resource_path
		var entity = load(resource_path).instance()
		entity.set_global_position(get_world_position(entity_data["position"]))
		scenes.append(entity)
		root.add_child(entity)
	return scenes

func find_tile(map, tile):
	for y in len(map):
		for x in len(map[y]):
			if map[y][x] == tile:
				return Vector2(x, y)
	return Vector2(-1, -1)

# Možná jestli se bude s TileMapou hýbat, tak to bude dělat bordel, ale to se asi nebude (pro jistotu sem píšu ať vím kde hledat)
func get_world_position(map_position):
	return _default_tilemap.map_to_world(map_position)

func parse_level_data(content: String, use_max_entity_count: bool=false):
	var section = "Global"
	var lines = content.split("\n")
	var map = []
	var conf = []
	var map_row_index = 0
	for line in lines:
		line = line.strip_edges()
		if line == "": continue
		if line.begins_with(";"): continue
		if line.begins_with("[") and line.ends_with("]"):
			section = line.substr(1, len(line) - 2)
			continue
		if section == "Map" and map_row_index != GameState.map_tile_size.y:
			map.append(line.substr(0, GameState.map_tile_size.x))
			map_row_index += 1
		elif section == "Conf":
			line = line.split("=", false)
			if line.size() == 2:
				conf.append({line[0]:line[1]})
	var entities = []
	var entity_count = {}
	for y in len(map):
		for x in len(map[y]):
			var character = map[y][x]
			if character in map_entities:
				var entity = map_entities[character]
				if not character in entity_count:
					entity_count[character] = 0
				else:
					if entity_count[character] >= entity["max"] and use_max_entity_count:
						continue
				entities.append({
					"position": Vector2(x, y),
					"resource": entity["resource"],
				})
				entity_count[character] += 1
	return {
		"map": map,
		"entities": entities,
		"conf": conf,
	}

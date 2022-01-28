extends Node

# TODO: Implement action log for serialize and parse functions

var map_width = GameState.map_tile_size.x
var map_height = GameState.map_tile_size.y

var map_tiles = {
	"#": 0
}

var map_entities = {
	"P": "Player.tscn",
	"D": "Door.tscn",
	"$": "Coin.tscn"
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
	
func _write_file(path, content):
	var file = File.new()
	file.open(path, File.WRITE)
	file.store_string(content)
	file.close()

func _create_level_header(level):
	return ";" + level + "\n"

func _get_level_internal_path(level):
	return "res://Resources/Levels/" + level + "/" + level + ".tres"

func _get_level_external_path(level):
	return get_level_dir(level) + "/level.txt"

func _load_internal_level_data(level):
	var header = _create_level_header(level)
	var internal_file_path = _get_level_internal_path(level)
	var internal_level_data = parse_level_data(header + _read_file(internal_file_path))
	return internal_level_data

func get_level_dir(level):
	var exe_dir = _open_exe_dir()
	if not exe_dir.dir_exists(level):
		exe_dir.make_dir(level)
	return exe_dir.get_current_dir() + "/" + level

func read_level_data(level):
	var header = _create_level_header(level)
	var level_file = File.new()
	var file_path = _get_level_external_path(level)
	var internal_file_path = _get_level_internal_path(level)
	if level_file.file_exists(file_path):
		return header + _read_file(file_path)
	else:
		if level_file.file_exists(internal_file_path):
			var content = _read_file(internal_file_path)
			level_file.open(file_path, File.WRITE)
			level_file.store_string(content)
			level_file.close()
			return header + content

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

func apply_immovable_mask(level_data, mask, replace_with=" "):
	var internal_level_data = _load_internal_level_data(level_data["level"])
	var internal_map = internal_level_data["map"]
	var internal_entities = internal_level_data["entities"]
	var map = level_data["map"]
	var entities = level_data["entities"]
	for y in len(map):
		for x in len(map[y]):
			if map[y][x] in mask:
				map[y][x] = replace_with
	for y in len(internal_map):
		for x in len(internal_map[y]):
			if internal_map[y][x] in mask:
				map[y][x] = internal_map[y][x]
	for i in range(len(entities) - 1, -1, -1):
		if entities[i]["character"] in mask:
			entities.remove(i)
	for entity in internal_entities:
		if entity["character"] in mask:
			entities.append(entity)
	return level_data

# TODO: Write this if needed or make one function for tiles and entities
func apply_max_tile_mask(level_data, mask, replace_with=" "):
	return level_data

func apply_max_entity_mask(level_data, mask, replace_with=" "):
	var map = level_data["map"]
	var entities = level_data["entities"]
	var entity_count = level_data["character_count"]
	for character in mask:
		if entity_count[character] > mask[character]:
			var difference = entity_count[character] - mask[character]
			for i in range(len(entities) - 1, -1, -1):
				if difference == 0: break
				var entity = entities[i]
				if entity["character"] == character:
					var p = entity["position"]
					map[p.y][p.x] = replace_with
					entities.remove(i)
					difference -= 1
	return level_data

func parse_level_data(content: String):
	var section = "Global"
	var lines = content.split("\n")
	var map = []
	var conf = []
	var entities = []
	var character_count = {}
	var map_row_index = 0
	var level_name = lines[0].substr(1)
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
		elif section == "Conf":
			line = line.split("=", false)
			if line.size() == 2:
				conf.append({line[0]:line[1]})
	for y in len(map):
		for x in len(map[y]):
			var character = map[y][x]
			if not character in character_count:
				character_count[character] = 0
			character_count[character] += 1
			if character in map_entities:
				entities.append({
					"character": character,
					"position": Vector2(x, y),
					"resource": map_entities[character],
				})
	return {
		"level": level_name,
		"map": map,
		"conf": conf,
		"entities": entities,
		"character_count": character_count
	}
	
func write_level_data(level, serialized_level_data):
	var file_path = _get_level_external_path(level)
	_write_file(file_path, serialized_level_data)

# TODO: Reflect changes in conf too
func serialize_level_data(level_data):
	var section = "Global"
	var internal_level_content = _read_file(_get_level_internal_path(level_data["level"]))
	var lines =  internal_level_content.split("\n")
	var map_row_index = 0
	for i in len(lines):
		var line = lines[i]
		if line.begins_with("[") and line.ends_with("]"):
			section = line.substr(1, len(line) - 2)
			continue
		if section == "Map" and map_row_index != map_height:
			lines[i] = level_data["map"][map_row_index]
			map_row_index += 1
	return lines.join("\n")

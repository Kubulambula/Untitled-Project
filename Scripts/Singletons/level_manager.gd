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

var _internal_level_cache = {}

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

func _get_level_internal_path(level: String):
	return "res://Resources/Levels/" + level + "/" + level + ".lvl"

func _get_level_external_path(level):
	return get_level_dir(level) + "/level.txt"

func get_level_scene(level):
	var level_folder = level[0].to_upper() + level.substr(1)
	return "res://Resources/Levels/" + level_folder + "/" + level + ".tscn"

func _load_internal_level_data(level):
	var header = _create_level_header(level)
	var internal_file_path = _get_level_internal_path(level)
	var internal_level_data = parse_level_data(header + _read_file(internal_file_path))
	return internal_level_data

func set_map_dimensions(x, y):
	map_width = x
	map_height = y

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
		entity.set_global_position(get_world_position_with_center_offset(entity_data["position"]))
		entity_data["node"] = entity
		scenes.append(entity)
		root.add_child(entity)
	return scenes

func find_tile(map, tile):
	for y in len(map):
		for x in len(map[y]):
			if map[y][x] == tile:
				return Vector2(x, y)
	return Vector2(-1, -1)

func find_entity(level_data, character):
	for entity in level_data["entities"]:
		if entity["character"] == character:
			return entity
	return null

func find_entities(level_data, character):
	var selected_entities = []
	for entity in level_data["entities"]:
		if entity["character"] == character:
			selected_entities.append(entity)
	return sort_entities(selected_entities)

func count_tiles(map):
	var counts = {}
	for y in len(map):
		for x in len(map[y]):
			var character = map[y][x]
			if not character in counts:
				counts[character] = 0
			counts[character] += 1
	return counts

# Možná jestli se bude s TileMapou hýbat, tak to bude dělat bordel, ale to se asi nebude (pro jistotu sem píšu ať vím kde hledat)
func get_world_position(map_position):
	return _default_tilemap.map_to_world(map_position)

func get_world_position_with_center_offset(map_position):
	return _default_tilemap.map_to_world(map_position) + GameState.tile_unit_size/2

func apply_immovable_mask(level_data, mask):
	# For simplicity's sake
	var internal_level_data = _load_internal_level_data_from_cache(level_data["level"])
	var internal_map = internal_level_data["map"]
	var internal_entities = internal_level_data["entities"]
	var map = level_data["map"]
	var entities = level_data["entities"]
	# Correct tiles
	for y in len(map):
		for x in len(map[y]):
			if map[y][x] in mask:
				map[y][x] = internal_map[y][x]
	for y in len(internal_map):
		for x in len(internal_map[y]):
			if internal_map[y][x] in mask:
				map[y][x] = internal_map[y][x]
				# Correct entity corresponding to the specific tile
				for entity in entities:
					if entity["position"].x == x and entity["position"].y == y:
						entities.erase(entity)
						break
	# Correct entities
	for i in range(len(entities) - 1, -1, -1):
		if entities[i]["character"] in mask:
			entities.remove(i)
	for entity in internal_entities:
		if entity["character"] in mask:
			entities.append(entity)
	return level_data

# TODO: Write this if needed or make one function for tiles and entities
func apply_max_tile_mask(level_data, _mask):
	return level_data

# Maybe rework this in the future, depends on the usage needed
func apply_max_entity_mask(level_data, mask):
	var internal_level_data = _load_internal_level_data_from_cache(level_data["level"])
	var internal_map = internal_level_data["map"]
	var map = level_data["map"]
	var entities = level_data["entities"]
	var entity_count = count_tiles(map)
	for character in mask:
		if character in entity_count and entity_count[character] > mask[character]:
			var difference = entity_count[character] - mask[character]
			for i in range(len(entities) - 1, -1, -1):
				if difference == 0: break
				var entity = entities[i]
				if entity["character"] == character:
					var p = entity["position"]
					if map[p.y][p.x] != internal_map[p.y][p.x]:
						map[p.y][p.x] = internal_map[p.y][p.x]
						entities.remove(i)
						difference -= 1
	return level_data

func _calc_index_from_position(position):
	return position.y * map_width + position.x

func sort_entities(entities):
	# HRLE taught me this! So f*ck u!
	var did_swap = false
	for j in len(entities):
		for i in len(entities) - 1:
			if _calc_index_from_position(entities[i]["position"]) > _calc_index_from_position(entities[i + 1]["position"]):
				var temp =  entities[i]
				entities[i] = entities[i + 1]
				entities[i + 1] = temp
				did_swap = true
		if not did_swap:
			break
	return entities

# WARNING: You must call this AFTER the entities have been spawned
func set_entity_properties(level_data, entity_properties):
	for e_prop in entity_properties:
		var selected_entities = find_entities(level_data, e_prop)
		for i in len(selected_entities):
			var node = selected_entities[i]["node"]
			var properties = entity_properties[e_prop]
			for prop in properties:
				var value = properties[prop]
				if range(len(value)).has(i):
					node.set(prop, value[i])

func parse_level_data(content: String, fill_missing: String = " "):
	var section = "Global"
	var lines = content.split("\n")
	var map = []
	var settings = {}
	var entities = []
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
			var map_row = line.substr(0, map_width)
			# Fill a line with dummy characters if it is not long enough
			if len(map_row) < map_width:
				map_row += fill_missing.repeat(map_width - len(map_row))
			map.append(map_row)
			map_row_index += 1
		elif section == "Settings":
			var pair = line.split("=", false)
			if pair.size() == 2:
				settings[pair[0]] = pair[1]
	# Fill map vertically if there are missing lines
	if len(map) < map_height:
		for i in (map_height - len(map)):
			map.append(fill_missing.repeat(map_width))
	for y in len(map):
		for x in len(map[y]):
			var character = map[y][x]
			if character in map_entities:
				entities.append({
					"character": character,
					"position": Vector2(x, y),
					"resource": map_entities[character],
				})
	return {
		"level": level_name,
		"map": map,
		"settings": settings,
		"entities": entities
	}
	
func write_level_data(level, serialized_level_data):
	var file_path = _get_level_external_path(level)
	_write_file(file_path, serialized_level_data)

func serialize_level_data(level_data):
	var section = "Global"
	var internal_level_content = _read_file(_get_level_internal_path(level_data["level"]))
	var lines =  internal_level_content.split("\n")
	var map_row_index = 0
	for i in len(lines):
		var line = lines[i]
		line = line.strip_edges()
		if line == "": continue
		if line.begins_with(";"): continue
		if line.begins_with("[") and line.ends_with("]"):
			section = line.substr(1, len(line) - 2)
			continue
		if section == "Map" and map_row_index != map_height:
			lines[i] = level_data["map"][map_row_index]
			map_row_index += 1
		elif section == "Settings":
			var pair = line.split("=", false)
			for option in level_data["settings"]:
				if option == pair[0]:
					pair[1] = level_data["settings"][option]
			lines[i] = pair.join("=")
	return lines.join("\n")

# Mabye move somewhere else?
func restart_level(level_data):
	GameState.score = 0
	var player = LevelManager.find_entity(level_data, "P")
	if player != null:
		var start_position = LevelManager.get_world_position_with_center_offset(player["position"])
		player["node"].set_global_position(start_position)
	var coins = LevelManager.find_entities(level_data, "$")
	for coin in coins:
		coin["node"].set("is_collected", false)
		coin["node"].show()

func get_internal_option(level, option):
	var internal_level_data = _load_internal_level_data_from_cache(level)
	if option in internal_level_data["settings"]:
		return internal_level_data["settings"][option]
	return null

func _load_internal_level_data_from_cache(level):
	if level in _internal_level_cache:
		return _internal_level_cache[level]
	else:
		var internal_level = _load_internal_level_data(level)
		_internal_level_cache[level] = internal_level
		return internal_level

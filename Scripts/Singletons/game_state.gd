extends Node

const tile_unit_size: Vector2 = Vector2(80, 80) # TODO - 80;80 až budou assety
const map_tile_size: Vector2 = Vector2(16, 9)

var player_can_move = true

var version = ProjectSettings.get_setting("untitled_project/config/version")

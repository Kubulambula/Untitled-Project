extends Area2D

enum COIN_TYPE {
	Bronze = 0,
	Silver = 1,
	Gold = 2
}

var coin_type = COIN_TYPE.Gold setget set_coin_type

var is_collected = false setget set_collected

func _get_coin_value():
	match coin_type:
		COIN_TYPE.Bronze: return 1
		COIN_TYPE.Silver: return 10
		COIN_TYPE.Gold: return 100

func set_coin_type(new_type):
	$AnimatedSprite.animation = str((COIN_TYPE.keys())[new_type]).to_lower()

func _ready():
	set_coin_type(coin_type)

func set_collected(value: bool):
	is_collected = value
	if value:
		$AnimationPlayer.play("collect")
	else:
		$AnimationPlayer.play("RESET")


func collect():
	if not is_collected:
		$AnimationPlayer.play("collect")
		GameState.score += _get_coin_value()
		is_collected = true
#		self.hide()

func _on_Area2D_body_entered(body):
#	print("colision")
	if body.name == "Player" or body is KinematicBody2D:
		collect()

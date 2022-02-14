extends Node

# Totally not Borovec reference, R'Amen
const FLYING_SPAGHETTI_MONSTER = "0fff"
const BASE36_CHARACTER_SET = "0123456789abcdefghijklmnopqrstuvwxyz"

# Let's rewrite this (Original JavaScript version)
#function cipher(score, levelId) {
#    const cislo = parseInt(levelId, 36);
#    const resultString = parseInt(score + "0fff", 16) + cislo;
#    return resultString.toString(36);
#}

const CHALLENGE_IDS = {
	"total_score": "jkjh",
	"level1": "jd1g",
	"level2": "7gkw",
	"level3": "oi27",
	"level4": "jlke",
	"level5": "1f5j",
	"bonus1": "mcc1",
	"bonus2": "nbcu",
	"bonus3": "yg5n",
	"reserve1": "wsp1",
	"reserve2": "s4qi"
}

func encode_base36(decimal_string):
	var remainders = ""
	var number = int(decimal_string)
	while number != 0:
		var result = number / 36
		remainders = BASE36_CHARACTER_SET[number % 36] + remainders
		number = result
	return remainders

func decode_base(base, base_string):
	var decimal = 0
	var exponent = 0
	for i in range(len(base_string) - 1, -1, -1):
		var value = BASE36_CHARACTER_SET.find(base_string[i], 0)
		decimal += value * pow(base, exponent)
		exponent += 1
	return decimal

func decode_base16(base16_string):
	return decode_base(16, base16_string)

func decode_base36(base36_string):
	return decode_base(36, base36_string)

func generate(challenge, score):
	var number = decode_base36(CHALLENGE_IDS[challenge])
	var scoreString = str(score) + FLYING_SPAGHETTI_MONSTER
	var resultString = decode_base16(scoreString) + number
	return encode_base36(resultString)

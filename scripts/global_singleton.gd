extends Node
var life = 100
var initial_bullets = 20
var num_medkits = 1
var total_bullets = 40
var num_bullets = 20
var fase_atual = 1

func reset_data():
	Global.life = 100
	Global.initial_bullets = 20
	Global.total_bullets = 40
	Global.num_bullets = 20
	Global.num_medkits = 1

extends Control

@onready var num_bullets: Label = $MarginContainer/HBoxContainer/num_bullets
@onready var total_bullets: Label = $MarginContainer/HBoxContainer/total_bullets
@onready var player: CharacterBody2D = $"../../Player"

func _ready() -> void:
	num_bullets.text = str("%02d" % player.num_bullets)
	total_bullets.text = str("%02d" % player.total_bullets)

func _process(delta: float) -> void:
	num_bullets.text = str("%02d" % player.num_bullets)
	total_bullets.text = str("%02d" % player.total_bullets)

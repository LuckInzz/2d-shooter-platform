extends Control

@onready var player: CharacterBody2D = $"../../Player"
@onready var gun_icon: TextureRect = $MarginContainer/HBoxContainer/gun_icon
@onready var divisor: Label = $MarginContainer/HBoxContainer/divisor
@onready var num_bullets: Label = $MarginContainer/HBoxContainer/num_bullets
@onready var total_bullets: Label = $MarginContainer/HBoxContainer/total_bullets
@onready var num_bullets_plus: Label = $num_bullets_plus
@onready var bullet: TextureRect = $bullet
@onready var plus: Label = $plus
@onready var health_bar: ProgressBar = $health_bar
@onready var medkit_icon: TextureRect = $medkit_icon
@onready var num_medkits: Label = $num_medkits
@onready var medkit_icon_plus: TextureRect = $medkit_icon_plus
@onready var plus_medkit: Label = $plus_medkit
@onready var num_medkits_plus: Label = $num_medkits_plus
@onready var mensagens: Label = $mensagens

var baus = []

func _ready() -> void:
	bullet.visible = false
	num_bullets_plus.visible = false
	plus.visible = false
	
	medkit_icon.visible = false
	num_medkits.visible = false
	medkit_icon_plus.visible = false
	plus_medkit.visible = false
	num_medkits_plus.visible = false
	
	baus = get_tree().get_nodes_in_group("baus")
	health_bar.max_value = player.life
	
func _process(delta: float) -> void:
	num_bullets.text = str("%02d" % player.num_bullets)
	total_bullets.text = str("%02d" % player.total_bullets)
	health_bar.value = player.life
	num_medkits.text = str("%01d" % player.num_medkits)
	
	for bau in baus:
		if bau.is_open:
			if bau.name == "bau_senha":
				mostra_mensagem("Você conseguiu um papel estranho, aperte P para abrir", 2)
			bullet.visible = true
			num_bullets_plus.visible = true
			plus.visible = true
			num_bullets_plus.text = str("%02d" % bau.num_bullets_plus)
			if bau.num_medkits_plus > 0:
				medkit_icon_plus.visible = true
				plus_medkit.visible = true
				num_medkits_plus.text = str("%01d" % bau.num_medkits_plus)
				num_medkits_plus.visible = true
			await get_tree().create_timer(3).timeout
			medkit_icon_plus.visible = false
			plus_medkit.visible = false
			num_medkits_plus.visible = false
			
			bau.is_open = false
			bau.already_open = true
			bullet.visible = false
			num_bullets_plus.visible = false
			plus.visible = false
	
	atualiza_HUD()

func atualiza_HUD():
	if player.is_holding_gun:
		gun_icon.visible = true
		num_bullets.visible = true
		divisor.visible = true
		total_bullets.visible = true
		
		medkit_icon.visible = false
		num_medkits.visible = false
	else:
		medkit_icon.visible = true
		num_medkits.visible = true
		
		gun_icon.visible = false
		num_bullets.visible = false
		divisor.visible = false
		total_bullets.visible = false

func mostra_mensagem(mensagem, time):
	mensagens.visible = true
	mensagens.text = mensagem
	await get_tree().create_timer(time).timeout
	mensagens.visible = false

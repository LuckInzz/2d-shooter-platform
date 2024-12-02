extends CanvasLayer

@onready var num_bullets: Label = $Control/MarginContainer/HBoxContainer/num_bullets
@onready var divisor: Label = $Control/MarginContainer/HBoxContainer/divisor
@onready var total_bullets: Label = $Control/MarginContainer/HBoxContainer/total_bullets
@onready var bullet: TextureRect = $Control/bullet
@onready var num_bullets_plus: Label = $Control/num_bullets_plus
@onready var plus: Label = $Control/plus
@onready var xp_icon: TextureRect = $Control/xp_icon
@onready var xp_bar: ProgressBar = $Control/xp_bar
@onready var health_icon: TextureRect = $Control/health_icon
@onready var health_bar: ProgressBar = $Control/health_bar
@onready var medkit_icon: TextureRect = $Control/medkit_icon
@onready var num_medkits: Label = $Control/num_medkits
@onready var medkit_icon_plus: TextureRect = $Control/medkit_icon_plus
@onready var num_medkits_plus: Label = $Control/num_medkits_plus
@onready var plus_medkit: Label = $Control/plus_medkit
@onready var mensagens: Label = $Control/mensagens
@onready var gun_icon: TextureRect = $Control/MarginContainer/HBoxContainer/gun_icon
@onready var player: CharacterBody2D = $"../Player"
@onready var fundo_preto: ColorRect = $Control/fundo_preto

var baus = []

func _ready() -> void:
	show_new_scene()
	bullet.visible = false
	num_bullets_plus.visible = false
	plus.visible = false
	
	medkit_icon.visible = false
	num_medkits.visible = false
	medkit_icon_plus.visible = false
	plus_medkit.visible = false
	num_medkits_plus.visible = false
	
	baus = get_tree().get_nodes_in_group("baus")
	health_bar.max_value = 100
	
func _process(delta: float) -> void:
	num_bullets.text = str("%02d" % Global.num_bullets)
	total_bullets.text = str("%02d" % Global.total_bullets)
	health_bar.value = Global.life
	num_medkits.text = str("%02d" % Global.num_medkits)

func atualiza_HUD(is_holding_gun):
	if is_holding_gun:
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

func atualiza_HUD_baus(num_bullets_plus_2, num_medkits_plus_2):
	bullet.visible = true
	num_bullets_plus.visible = true
	plus.visible = true
	num_bullets_plus.text = str("%02d" % num_bullets_plus_2)
	if num_medkits_plus_2 > 0:
		medkit_icon_plus.visible = true
		plus_medkit.visible = true
		num_medkits_plus.text = str("%01d" % num_medkits_plus_2)
		num_medkits_plus.visible = true
	await get_tree().create_timer(3).timeout
	medkit_icon_plus.visible = false
	plus_medkit.visible = false
	num_medkits_plus.visible = false
	
	bullet.visible = false
	num_bullets_plus.visible = false
	plus.visible = false
	
func change_scene(path, delay = 1):
	var scene_transition = get_tree().create_tween()
	scene_transition.tween_property(fundo_preto, "threshold", 1.0 , 0.5).set_delay(delay)
	await scene_transition.finished
	get_tree().change_scene_to_file(path)
	health_bar.value = Global.life

func show_new_scene():
	var show_transition = get_tree().create_tween()
	show_transition.tween_property(fundo_preto, "threshold", 0.0 , 0.5).from(1.0)
	health_bar.value = Global.life

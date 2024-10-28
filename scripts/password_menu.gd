extends CanvasLayer

@onready var password_screen: Label = $password_screen
@onready var button_1: Button = $Button_1
@onready var button_sound: AudioStreamPlayer = $button_sound
@onready var correct_password: AudioStreamPlayer = $correct_password
@onready var wrong_password: AudioStreamPlayer = $wrong_password


var password = "8213"
var player_password = "0000"
var putting_password = false
var num = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_ESCAPE):
		_on_exit_button_pressed()

func show_in_screen():
	visible = true
	get_tree().paused = true
	#button_1.grab_focus()
	
func _on_exit_button_pressed() -> void:
	visible = false
	putting_password = false
	get_tree().paused = false
	player_password = "0000"
	password_screen.text = "0000"

func _on_button_1_pressed() -> void:
	add_digit("1")
	num = num + 1

func _on_button_2_pressed() -> void:
	add_digit("2")
	num = num + 1
	
func _on_button_3_pressed() -> void:
	add_digit("3")
	num = num + 1
	
func _on_button_4_pressed() -> void:
	add_digit("4")
	num = num + 1
	
func _on_button_5_pressed() -> void:
	add_digit("5")
	num = num + 1
	
func _on_button_6_pressed() -> void:
	add_digit("6")
	num = num + 1
	
func _on_button_7_pressed() -> void:
	add_digit("7")
	num = num + 1
	
func _on_button_8_pressed() -> void:
	add_digit("8")
	num = num + 1
	
func _on_button_9_pressed() -> void:
	button_sound.play()
	if player_password == password:
		correct_password.play()
		await correct_password.finished
		get_tree().quit()
	else:
		wrong_password.play()
		password_screen.text = "0000"
		player_password = "0000"
		num = 0

func add_digit(digit : String) -> void:
	if num < 4:
		button_sound.play()
		player_password = player_password.substr(0, num) + digit + player_password.substr(num + 1)
		password_screen.text = player_password

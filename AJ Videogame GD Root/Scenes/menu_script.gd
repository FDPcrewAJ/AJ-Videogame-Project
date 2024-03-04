extends Control

@onready var inc_text = $Title/Settings/Label
var inc_bool = false

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_continue_pressed():
	get_tree().change_scene_to_file("res://Scenes/level_1.tscn")


func _on_start_pressed():
	get_tree().change_scene_to_file("res://Scenes/level_1.tscn")


func _on_settings_pressed():
	if inc_bool == false:
		inc_bool = true
	else:
		inc_bool = false
	inc_text.set_visible(inc_bool)


func _on_exit_pressed():
	get_tree().quit()

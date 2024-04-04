extends Control

@onready var inc_text_1 = $Title/Settings/nr_1
@onready var inc_text_2 = $Title/Credits/nr_2
var inc_bool = false

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func change_visibility():
	if inc_bool == false:
		inc_bool = true
	else:
		inc_bool = false
	return(inc_bool)


func _on_continue_pressed():
	get_tree().change_scene_to_file("res://Scenes/dev_room.tscn")


func _on_start_pressed():
	get_tree().change_scene_to_file("res://Scenes/dev_room.tscn")


func _on_settings_pressed():
	change_visibility()
	inc_text_1.set_visible(inc_bool)


func _on_credits_pressed():
	get_tree().change_scene_to_file("res://Scenes/credits_screen.tscn")


func _on_exit_pressed():
	get_tree().quit()

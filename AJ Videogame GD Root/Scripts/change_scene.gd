extends Node3D

func _ready():
	pass


func _process(_delta):
	if Input.is_action_pressed("reset"):
		get_tree().reload_current_scene()
	if Input.is_action_pressed("sc1"):
		get_tree().change_scene_to_file("res://Scenes/dev_room.tscn")
	if Input.is_action_pressed("sc2"):
		get_tree().change_scene_to_file("res://Scenes/level_1.tscn")
	if Input.is_action_pressed("sc3"):
		get_tree().change_scene_to_file("res://Scenes/level_2.tscn")
	if Input.is_action_pressed("sc0"):
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	if Input.is_action_pressed("esc"):
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

extends Node3D

signal weapon_changed
signal update_ammo
signal update_weapon_stack

@onready var animation_player = $animation_player

var current_weapon = null
var weapon_stack = []
var weapon_indicator = 0
var next_weapon: String
var weapon_list = {}

@export var _weapon_resources: Array[weapons_resource]
@export var start_weapons: Array[String]

func _ready():
	initialize(start_weapons)

func _physics_process(_delta):
		if Input.is_action_pressed("shoot"):
			shoot()
	
func _input(event):
	if event.is_action_pressed("next_weapon"):
		weapon_indicator = min(weapon_indicator + 1, weapon_stack.size() - 1)
		exit(weapon_stack[weapon_indicator])
	
	if event.is_action_pressed("prev_weapon"):
		weapon_indicator = max(weapon_indicator - 1, 0)
		exit(weapon_stack[weapon_indicator])
	
	if event.is_action_pressed("reload"):
		reload()


func initialize(_start_weapons: Array):
	#Enter into the state machine
	for weapon in _weapon_resources:
		weapon_list[weapon.weapon_name] = weapon
	
	for i in start_weapons:
		weapon_stack.push_back(i)
	
	current_weapon = weapon_list[weapon_stack[0]]
	
	emit_signal("update_weapon_stack", weapon_stack)
	enter()


func enter():
	#Call when you switch to a weapon
	animation_player.queue(current_weapon.activate_anim)
	
	emit_signal("weapon_changed", current_weapon.weapon_name)
	emit_signal("update_ammo", [current_weapon.current_ammo, current_weapon.magazine])


func change_weapon(weapon_name: String):
	current_weapon = weapon_list[weapon_name]
	next_weapon = ""
	enter()


func exit(_next_weapon: String):
	#In order to change weapons call exit first
	if _next_weapon != current_weapon.weapon_name:
		if animation_player.get_current_animation() != current_weapon.deactivate_anim:
			animation_player.play(current_weapon.deactivate_anim)
			next_weapon = _next_weapon
			


func _on_animation_player_animation_finished(anim_name):
	if anim_name == current_weapon.deactivate_anim:
		change_weapon(next_weapon)


func shoot():
	if current_weapon.current_ammo != 0:
		if !animation_player.is_playing():
			# Inforces fire rate set by the animation
			animation_player.play(current_weapon.shoot_anim)
			current_weapon.current_ammo -= 1
			emit_signal("update_ammo", [current_weapon.current_ammo, current_weapon.magazine])
			if current_weapon.auto_reload == true:
				reload()

func reload():
	if current_weapon.current_ammo == current_weapon.magazine:
		return
	elif !animation_player.is_playing():
		animation_player.play(current_weapon.reload_anim)
		var reload_amount = current_weapon.magazine - current_weapon.current_ammo
		current_weapon.current_ammo = current_weapon.current_ammo + reload_amount
		emit_signal("update_ammo", [current_weapon.current_ammo, current_weapon.magazine])
		print("reloaded")

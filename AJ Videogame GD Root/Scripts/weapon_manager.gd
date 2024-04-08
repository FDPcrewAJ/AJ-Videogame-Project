extends Node3D

var current_weapon = null
var weapon_stack = []
var weapon_indicator = 0
var next_weapon: String
var weapon_list = {}

@export var _weapon_resources: Array[weapons_resource]
@export var start_weapons: Array[String]

func _ready():
	initialize(start_weapons)


func initialize(_start_weapons: Array):
	#Enter into the state machine
	for weapon in _weapon_resources:
		weapon_list[weapon.weapon_name] = weapon
	
	for i in start_weapons:
		weapon_stack.push_back(i)
	
	current_weapon = weapon_list[weapon_stack[0]]
	enter()


func enter():
	#Call when you switch to a weapon
	pass


func change_weapon():
	pass


func exit():
	#In order to change weapons call exit first
	pass

extends Node3D

signal weapon_changed
signal update_ammo
signal update_weapon_stack
signal use_grapple

@onready var animation_player = get_node("%animation_player")
@onready var bullet_point = get_node("%bullet_point")

var bullet_marker = preload("res://Assets/bullet_marker.tscn")

var current_weapon = null
var weapon_stack = []
var weapon_indicator = 0
var next_weapon: String
var weapon_list = {}

@export var _weapon_resources: Array[weapons_resource]
@export var start_weapons: Array[String]

enum {Null, Hitscan, Projectile, Grapple}

var collision_exclusion = []

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
	if current_weapon.current_ammo == 0 and current_weapon.auto_reload == true:
		reload()


func shoot():
	if current_weapon.current_ammo != 0:
		if !animation_player.is_playing():
			# Inforces fire rate set by the animation
			animation_player.play(current_weapon.shoot_anim)
			current_weapon.current_ammo -= 1
			emit_signal("update_ammo", [current_weapon.current_ammo, current_weapon.magazine])
			var camera_collision = get_camera_collision()
			
			if current_weapon.type == Grapple:
				print("If statement worked")
			
			match current_weapon.type:
				Null:
					print("Weapon Type Not Chosen")
				Hitscan:
					hit_scan_collision(camera_collision)
					print("Hitscan")
				Projectile:
					launch_projectile(camera_collision)
					print("Projectile")
				Grapple:
					emit_signal("use_grapple")
					print("got through match statement")


func reload():
	if current_weapon.current_ammo == current_weapon.magazine:
		return
	elif !animation_player.is_playing():
		animation_player.play(current_weapon.reload_anim)
		current_weapon.current_ammo = current_weapon.magazine
		emit_signal("update_ammo", [current_weapon.current_ammo, current_weapon.magazine])


func get_camera_collision() -> Vector3:
	var camera = get_viewport().get_camera_3d()
	var viewport = get_viewport().get_size()
	
	var ray_origin = camera.project_ray_origin(viewport / 2)
	var ray_end = ray_origin + camera.project_ray_normal(viewport / 2) * current_weapon.weapon_range
	
	var new_intersection = PhysicsRayQueryParameters3D.create(ray_origin,ray_end)
	new_intersection.set_exclude(collision_exclusion)
	var intersection = get_world_3d().direct_space_state.intersect_ray(new_intersection)
	
	if not intersection.is_empty():
		var col_point = intersection.position
		return col_point
	else:
		return ray_end


func hit_scan_collision(collision_point):
	var bullet_direction = (collision_point - bullet_point.get_global_transform().origin).normalized()
	var new_intersection = PhysicsRayQueryParameters3D.create(bullet_point.get_global_transform().origin, collision_point + bullet_direction * 2)
	
	var bullet_collision = get_world_3d().direct_space_state.intersect_ray(new_intersection)
	
	if bullet_collision:
		var hit_indicator = bullet_marker.instantiate()
		var world = get_tree().get_root().get_child(0)
		world.add_child(hit_indicator)
		hit_indicator.global_translate(bullet_collision.position)
		
		hit_Scan_damage(bullet_collision.collider, bullet_direction, bullet_collision.position)


func hit_Scan_damage(collider, direction, _position):
	if collider.is_in_group("target") and collider.has_method("hit_successful"):
		collider.hit_successful(current_weapon.damage, direction, _position) 


func launch_projectile(point: Vector3):
	var direction = (point - bullet_point.get_global_transform().origin).normalized()
	var projectile = current_weapon.projectile_to_load.instantiate()
	
	var projectile_rid = projectile.get_rid()
	collision_exclusion.push_front(projectile_rid)
	projectile.tree_exited.connect(remove_exclusion.bind(projectile.get_rid()))
	
	bullet_point.add_child(projectile)
	projectile.damage = current_weapon.damage
	projectile.set_linear_velocity(direction * current_weapon.projectile_veloity)


func remove_exclusion(projectile_rid):
	collision_exclusion.erase(projectile_rid)

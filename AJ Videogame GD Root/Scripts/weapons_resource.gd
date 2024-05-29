extends Resource

class_name weapons_resource

@export var weapon_name: String
@export var activate_anim: String
@export var deactivate_anim: String
@export var shoot_anim: String
@export var reload_anim: String

@export var current_ammo: int
@export var magazine: int
@export var auto_reload: bool

@export_flags("Hitscan", "Projectile", "Grapple") var type
@export var weapon_range: int
@export var damage: int

@export var projectile_to_load: PackedScene
@export var projectile_veloity: int

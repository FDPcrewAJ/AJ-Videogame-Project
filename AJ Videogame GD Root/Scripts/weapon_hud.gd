extends CanvasLayer

@onready var current_ammo_label = $VBoxContainer/ammo_container/current_ammo

func _on_weapon_manager_update_ammo(ammo):
	current_ammo_label.set_text(str(ammo[0]) + "/" + str(ammo[1]))

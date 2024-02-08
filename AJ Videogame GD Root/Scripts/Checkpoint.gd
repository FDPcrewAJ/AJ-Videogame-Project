extends Area3D

func _ready() -> void:
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)


func _on_area_entered(_area:Area3D) -> void:
	print("checkpoint")
	global.check_point_pos = global_position

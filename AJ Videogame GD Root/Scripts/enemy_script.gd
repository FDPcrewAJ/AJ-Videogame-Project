extends RigidBody3D

var health = 5
@onready var timer = get_node("%Death Timer")
@onready var death_crosses = get_node("%eye_cross_container")

func hit_successful(damage, _direction:= Vector3.ZERO, _position:= Vector3.ZERO):
	var hit_position = _position - get_global_transform().origin
	
	health -= damage
	print("Enemy Health = " + str(health))
	if health <= 0:
		timer.start()
		death_crosses.visible = true
	
	if _direction != Vector3.ZERO:
		apply_impulse((_direction * damage), hit_position)


func _on_death_timer_timeout():
	queue_free()

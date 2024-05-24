extends RigidBody3D

var health = 5

func hit_successful(damage):
	health -= damage
	print("Enemy Health = " + str(health))
	if health <= 0:
		queue_free()

extends RigidBody3D

var damage: int = 0
@onready var explode_rad = $Area3D


func _on_body_entered(body):
	if body.is_in_group("target") && body.has_method("hit_successful"):
		body.hit_successful(damage)
	for target in explode_rad.get_overlapping_bodies():
		if target.is_in_group("target"):
			target.apply_central_force((target.global_transform.origin - self.global_transform.origin).normalized() * 1000)
		if target is CharacterBody3D:
			target.velocity = (target.global_transform.origin - self.global_transform.origin.normalized() * 500) * -1
			if target.velocity.y >= 10.0:
				target.velocity.y = 10.0
	queue_free()


func _on_timer_timeout():
	queue_free()

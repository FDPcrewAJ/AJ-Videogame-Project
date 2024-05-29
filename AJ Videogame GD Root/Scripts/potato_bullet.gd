extends RigidBody3D

var damage: int = 0
@onready var explode_rad = $Area3D


func _on_body_entered(body):
	if body.is_in_group("target") && body.has_method("hit_successful"):
		body.hit_successful(damage)
	for target in explode_rad.get_overlapping_bodies():
		if target is RigidBody3D or CharacterBody3D:
			target.apply_central_force((target.global_transform.origin - self.global_transform.origin).normalized() * 100)
	queue_free()


func _on_timer_timeout():
	queue_free()

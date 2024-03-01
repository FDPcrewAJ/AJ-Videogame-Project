extends Node3D



func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	rotate(Vector3(0,1,0), 0.001)

extends CharacterBody3D
class_name Player
# Player Nodes
@onready var neck = $neck
@onready var head = $neck/head
@onready var standing_collision_shape = $standing_collision_shape
@onready var crouching_collision_shape = $crouching_collision_shape
@onready var collision_check = $collision_check
@onready var camera_3d = $neck/head/player_camera
@onready var grapplecast = $neck/head/grapple_cast

# Speed and Movement Variables
var current_speed = 5.0
const walking_speed = 5.0
const sprinting_speed = 8.0
const crouching_speed = 3.0
const jump_velocity = 4.5
var crouch_depth = -0.5
var lerp_speed = 10.0
var free_look_tilt_amount = 5
var air_lerp_speed = 3.0

# States
var walking = false
var sprinting = false
var crouching = false
var free_looking = false
var sliding = false

# Slide Variables
var slide_timer = 0.0
var slide_timer_max = 1.0
var slide_vector = Vector2.ZERO
var slide_speed = 10.0

# Input Variables
const mouse_sens = 0.15
var direction = Vector3.ZERO

# Grappling Variables
var grappling = false
var grapple_position = Vector3.ZERO
var grapple_point_get = false
var grapple_length = Vector2.ZERO
var hooked = false
var rest_length = 1.0
var grapple_speed = .5
var max_grapple_speed = 2.75
var grapple_point: NodePath
@onready var line_holder = get_node("neck/head/weapon_manager/grap_gun_holder/line_container")
@onready var grapple_line = get_node("neck/head/weapon_manager/grap_gun_holder/line_container/grapple_line")

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event):
	# Mouse Looking Logic
	if event is InputEventMouseMotion:
		if free_looking:
			neck.rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
			neck.rotation.y = clamp(neck.rotation.y,deg_to_rad(-100),deg_to_rad(100))
		else:
			rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
			head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
			head.rotation.x = clamp(head.rotation.x,deg_to_rad(-89),deg_to_rad(89))


func grapple():
	"""if Input.is_action_pressed("shoot"):
		if grapplecast.is_colliding():
			if not grappling:
				grappling = true
	else:
		grappling = false
	if grappling:
		if not grapple_point_get:
			grapple_point = grapplecast.get_collision_point()
			grapple_point_get = true
			grapple_length = grapple_point.distance_to(transform.origin)
		if grapple_length > 1:
			velocity.y = 0
			if grapple_point_get:
				transform.origin = lerp(transform.origin, grapple_point, delta * 1.5)
	else:
		grapple_point_get = false"""
	var length = calculate_path()
	draw_hook(length)
	look_for_point()


func check_hook_activation():
	# Activate the hook
	if Input.is_action_just_pressed("shoot") and grapplecast.is_colliding():
		hooked = true
		grapple_position = grapplecast.get_collision_point()
		rest_length = (grapple_position - global_position).length() - 2
		grapple_line.show()
	# Stop grappling
	if Input.is_action_just_released("shoot"):
		print("this worked")
		hooked = false
		rest_length = 2
		grapple_line.hide()


func calculate_path():
	var player_2_hook = grapple_position - position
	var length = player_2_hook.distance_to(position)
	if hooked:
		# Dampen speed when we are close to the line
		if length > 4:
			velocity *= .999
		else:
			velocity *= .9
			
		var force = grapple_speed * (length - rest_length)
		
		if abs(force) > max_grapple_speed:
			force = max_grapple_speed
		
		velocity += player_2_hook.normalized() * force
	return length


func draw_hook(length):
	line_holder.look_at(grapple_position, Vector3.UP)
	grapple_line.height = length
	grapple_line.position.z = length / -2

func look_for_point():
	var grapple_pt = get_node_or_null(grapple_point)
	if grapple_pt and grapplecast.is_colliding():
		grapple_pt.position = grapplecast.get_collision_point()


func _physics_process(delta):
	# Reset Scene when key is pressed, and Change scenes when the key is pressed.
	# Get movement inputs
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	# Handling Movement States
	if Input.is_action_pressed("crouch") || sliding:
		# Crouching
		current_speed = lerp(current_speed, crouching_speed, delta * lerp_speed)
		head.position.y = lerp(head.position.y, crouch_depth, delta * lerp_speed)
		
		standing_collision_shape.disabled = true
		crouching_collision_shape.disabled = false
		
		# Slide Begin Logic
		if sprinting && input_dir != Vector2.ZERO:
			sliding = true
			slide_timer = slide_timer_max
			slide_vector = input_dir
			free_looking = true
		
		walking = false
		sprinting = false
		crouching = true
	elif !collision_check.is_colliding():
		# Standing
		standing_collision_shape.disabled = false
		crouching_collision_shape.disabled = true
		
		head.position.y = lerp(head.position.y, 0.0, delta * lerp_speed)
		if Input.is_action_pressed("sprint"):
			# Sprinting
			current_speed = lerp(current_speed, sprinting_speed, delta * lerp_speed)
			walking = false
			sprinting = true
			crouching = false
		else:
			# Walking
			current_speed = lerp(current_speed, walking_speed, delta * lerp_speed)
			walking = true
			sprinting = false
			crouching = false

	# Handle Free Look
	if Input.is_action_pressed("free_look") || sliding:
		free_looking = true
		camera_3d.rotation.z = -deg_to_rad(neck.rotation.y * free_look_tilt_amount)
	else:
		free_looking = false
		neck.rotation.y = lerp(neck.rotation.y, 0.0, delta * lerp_speed)
		camera_3d.rotation.z = lerp(camera_3d.rotation.z, 0.0, delta * lerp_speed)
	
	# Handle Sliding
	if sliding:
		slide_timer -= delta
		if slide_timer <= 0:
			sliding = false
			free_looking = false

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta


	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
		sliding = false

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if is_on_floor():
		direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * lerp_speed)
	else:
		direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * air_lerp_speed)
		
	if sliding:
		direction = (transform.basis * Vector3(slide_vector.x, 0, slide_vector.y)).normalized()
		current_speed = (slide_timer + 0.1) * slide_speed

	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed

	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	if Input.is_action_pressed("load_checkpoint"):
		global_position = singleton.check_point_pos


	#print(grapple_joint.global_position)
	#print(grapple_point)
	"""if Input.is_action_just_released("shoot"):
		print("We know this works")
		hooked = false
		rest_length = 2
		grapple_line.hide()"""
	check_hook_activation()
	move_and_slide()


func _on_death_detector_area_entered(_area):
	global_position = singleton.check_point_pos


func _on_weapon_manager_use_grapple():
	grapple()

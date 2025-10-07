extends Node3D
var healthbar
@export var move_speed:float = 5
@export var health: int = 3
const MOUSE_SENSITIVITY = 0.2
const ROTATION_SMOOTHNESS = 10.0

@onready var camera = $Camera3D 
@onready var character_model = $RigidBody3D/"Buff man"

var move_inputs: Vector2

func _ready() -> void:
	healthbar = $RigidBody3D/SubViewport/HealthBar
	if is_instance_valid(healthbar):
		healthbar.max_value = health
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta:float) -> void:
	if Input.is_action_just_pressed("damage_player"):
		health -= 1
		if is_instance_valid(healthbar):
			healthbar.update(health)

func _physics_process(delta: float) -> void:
	var input_direction = read_move_inputs()
	var move_vector = Vector3.ZERO
	
	if input_direction != Vector2.ZERO:
		# Mouvement relatif à la caméra (Node3D)
		var forward_vector = -global_transform.basis.z
		var right_vector = global_transform.basis.x
		move_vector = forward_vector * input_direction.y + right_vector * input_direction.x
		global_position += move_vector * move_speed * delta
		
	# Rotation du Sprite/Modèle
	if move_vector.length_squared() > 0:
		if is_instance_valid(character_model):
			var target_look_at = global_position - move_vector 
			
			character_model.look_at(target_look_at, Vector3.UP)
			
			# Stocke la rotation Y calculée par look_at
			var target_rotation_y = character_model.rotation.y
			
			# Reset la rotation immédiatement sur les axes X et Z (inclinaison)
			character_model.rotation.x = 0
			character_model.rotation.z = 0
			
			# Interpolation (pour une rotation douce)
			character_model.rotation.y = lerp_angle(character_model.rotation.y, target_rotation_y, delta * ROTATION_SMOOTHNESS)
			
	return

func read_move_inputs() -> Vector2:
	move_inputs.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	move_inputs.y = Input.get_action_strength("move_forward") - Input.get_action_strength("move_backward")
	move_inputs = move_inputs.normalized()
	print(move_inputs)
	return move_inputs

# ---- INPUT SOURIS
func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENSITIVITY))
		
		if is_instance_valid(camera):
			var new_x_rotation = camera.rotation.x + deg_to_rad(-event.relative.y * MOUSE_SENSITIVITY)
			# Limite l'angle de la caméra
			camera.rotation.x = clamp(new_x_rotation, deg_to_rad(-50), deg_to_rad(-20))

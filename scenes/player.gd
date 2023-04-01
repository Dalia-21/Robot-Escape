extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Player lives
@export var lives: int = 5

signal lost_life

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	var direction = Input.get_axis("move_left", "move_right")
	
	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		$AnimatedSprite2D.play("jump")
	
	# Get the input direction and handle the movement/deceleration.
	if direction:
		if direction == -1:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
		velocity.x = direction * SPEED
		$AnimatedSprite2D.play("run")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if velocity.x == 0 and velocity.y == 0:
		$AnimatedSprite2D.play("idle")

	move_and_slide()

func damage_taken():
	emit_signal("lost_life")

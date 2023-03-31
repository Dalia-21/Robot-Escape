extends Area2D


func _ready():
	$RigidBody2D/Animation.play("idle")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

extends RigidBody2D


var laser_firing = false
var trap_collision_layer = 4
var player_collision_mask = 1

func _on_timer_timeout():
	if not laser_firing:
		$Animation.play("fire")
		self.set_collision_layer_value(trap_collision_layer, true)
		self.set_collision_mask_value(player_collision_mask, true)
		laser_firing = true
	else:
		$Animation.play("idle")
		self.set_collision_layer_value(trap_collision_layer, false)
		self.set_collision_mask_value(player_collision_mask, false)
		laser_firing = false
		

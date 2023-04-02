extends RigidBody2D


var laser_activated = false
var laser_transitioning = false
var trap_collision_layer = 4
var player_collision_mask = 1


func _on_timer_timeout():
	# If the laser is in a transition state, play correct animation
	# and switch collision values
	if not laser_transitioning:
		if laser_activated:  # Trap is turning off
			$Animation.play("deactivate")
			self.set_collision_layer_value(trap_collision_layer, false)
			self.set_collision_mask_value(player_collision_mask, false)
			laser_transitioning = true
			laser_activated = false
		else:  # Turning on
			$Animation.play("activate")
			self.set_collision_layer_value(trap_collision_layer, true)
			self.set_collision_mask_value(player_collision_mask, true)
			laser_transitioning = true
			laser_activated = true
	else:
		if laser_activated:  # On state
			$Animation.play("idle")
			laser_transitioning = false
		else:  # Off state
			$Animation.play("deactivated")
			laser_transitioning = false		

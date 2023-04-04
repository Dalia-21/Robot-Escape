extends ScrollContainer


@export var scroll_increment = 5

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_start_timer_timeout():
	start_credits()
	
func start_credits():
	$ScrollTimer.start()

func _on_scroll_timer_timeout():
	scroll_to_next_line()
	
func scroll_to_next_line():
	scroll_vertical += scroll_increment
	$ScrollTimer.start()


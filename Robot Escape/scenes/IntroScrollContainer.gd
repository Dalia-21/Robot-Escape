extends ScrollContainer


@export var scroll_increment = 5


func _ready():
	start_credits()
	
func start_credits():
	$ScrollTimer.start()

func _on_scroll_timer_timeout():
	scroll_to_next_line()
	
func scroll_to_next_line():
	scroll_vertical += scroll_increment
	$ScrollTimer.start()


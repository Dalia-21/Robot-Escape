extends HBoxContainer


@export var total_lives = []

func init_lives():
	for life in total_lives:
		add_child(life)

func _on_life_lost():
	remove_child(total_lives.pop())

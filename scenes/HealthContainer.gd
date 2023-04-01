extends HBoxContainer


@export var total_lives = 0


func update_lives(num_lives):
	if num_lives > total_lives:
		for life in num_lives - total_lives:
			add_life()

func add_life():
	var new_life = load("res://scenes/life.tscn")
	var life_instance = new_life.instantiate()
	add_child(life_instance)
	total_lives += 1

func _on_life_lost():  # Handle index out of bounds
	remove_child(get_child(get_child_count()-1))
	total_lives -= 1

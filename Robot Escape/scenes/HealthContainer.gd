extends HBoxContainer


@export var total_lives = 0


func update_lives(num_lives):
	if num_lives > total_lives:
		for life in num_lives - total_lives:
			add_life()
	else:
		remove_child(get_child(get_child_count()-1))
		total_lives -= 1


func add_life():
	var new_life = load("res://scenes/life.tscn")
	var life_instance = new_life.instantiate()
	add_child(life_instance)
	total_lives += 1

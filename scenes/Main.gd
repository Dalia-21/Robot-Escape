extends Node

var scene_path = "res://scenes/level0%d.tscn"
var next_scene_no = 1
var next_scene = scene_path % next_scene_no
var transition_item  # Item used to transition between levels
var level_name = "Level 0%d"
var next_scene_ready = false
var last_scene_instance = null

func _ready():
	load_main_menu()
	
func load_main_menu():
	var menu_scene = load("res://scenes/menu.tscn")
	var menu_instance = menu_scene.instantiate()
	add_child(menu_instance)
	if last_scene_instance != null:
		remove_child(last_scene_instance)
	last_scene_instance = menu_instance
	
	var button_container = get_tree().current_scene.get_node(
		"Menu/MarginContainer/MenuContainer/ButtonContainer")
	
	var start_button = button_container.get_node("MarginContainer/StartButton")
	if not start_button.button_up.is_connected(Callable(self, "_on_start_button_up")):
		start_button.button_up.connect(Callable(self, "_on_start_button_up"))

	var credits_button = button_container.get_node("MarginContainer2/CreditsButton")
	if not credits_button.button_up.is_connected(Callable(self, "_on_credits_button_up")):
		credits_button.button_up.connect(Callable(self, "_on_credits_button_up"))

	var exit_button = button_container.get_node("MarginContainer3/ExitButton")
	if not exit_button.button_up.is_connected(Callable(self, "_on_exit_button_up")):
		exit_button.button_up.connect(Callable(self, "_on_exit_button_up"))
	
	
func _process(_delta):
	if next_scene_ready:
		if not get_tree().current_scene.has_node("HUD"):
			load_HUD()
		load_next_scene()
		next_scene_ready = false
		
func _on_start_button_up():
	play_intro()
	
func play_intro():
	var intro_scene = load("res://scenes/intro.tscn")
	var intro_instance = intro_scene.instantiate()
	add_child(intro_instance)
	if last_scene_instance != null:
		remove_child(last_scene_instance)
	last_scene_instance = intro_instance
	
	var skip_button = get_tree().current_scene.get_node(
		"Intro/MarginContainer/ContentsContainer/ButtonContainer/MarginContainer/SkipButton")
		
	if not skip_button.button_up.is_connected(Callable(self, "_on_end_intro")):
		skip_button.button_up.connect(Callable(self, "_on_end_intro"))

func _on_end_intro():
	next_scene_ready = true
	
func load_HUD():
	# Load HUD
	var HUD_scene = load("res://scenes/HUD.tscn")
	var HUD_instance = HUD_scene.instantiate()
	add_child(HUD_instance)
	
	var quit_button = get_tree().current_scene.get_node(
		"HUD/HUDLayer/MenuContainer/ButtonContainer/QuitButton")
	
	if not quit_button.button_up.is_connected(Callable(self, "_back_to_menu")):
		quit_button.button_up.connect(Callable(self, "_back_to_menu"))
	
func _on_credits_button_up():
	play_credits()
	
func play_credits():
	var credits_scene = load("res://scenes/credits.tscn")
	var credits_instance = credits_scene.instantiate()
	add_child(credits_instance)
	remove_child(last_scene_instance)
	last_scene_instance = credits_instance
	
	var main_menu_button = get_tree().current_scene.get_node(
		"Credits/MarginContainer/ContentsContainer/ButtonContainer/MarginContainer/ExitButton")
		
	if not main_menu_button.button_up.is_connected(Callable(self, "_back_to_menu")):
		main_menu_button.button_up.connect(Callable(self, "_back_to_menu"))
	
func _back_to_menu():
	if get_tree().current_scene.has_node("HUD"):
		var HUD_node = get_tree().current_scene.get_node("HUD")
		if HUD_node:
			remove_child(HUD_node)
	next_scene_no = 1  # Reset level count
	load_main_menu()
	
func _on_exit_button_up():
	get_tree().quit()
	
func _on_body_entered(_body):
	next_scene_ready = true
		
func load_next_scene():
	next_scene = scene_path % next_scene_no
	if ResourceLoader.exists(next_scene):
		var scene = load(next_scene)
		var instance = scene.instantiate()
		add_child(instance)
		if last_scene_instance != null:
			remove_child(last_scene_instance)
		last_scene_instance = instance
		connect_to_body_entered()
		connect_to_player_lives()
		next_scene_no += 1
	else:  # No more game scenes exist
		var HUD_node = get_tree().current_scene.get_node("HUD")
		remove_child(HUD_node)
		play_credits()

func connect_to_body_entered():
	var current_level_name = level_name % next_scene_no
	transition_item = get_tree().current_scene.get_node(current_level_name +
	"/Level Transition/ItemArea")
	if not transition_item.is_connected("body_entered",
	Callable(self, "_on_body_entered")):
		transition_item.body_entered.connect(Callable(self, "_on_body_entered"))

func connect_to_player_lives():
	# next_scene_no is incremented after this function
	var player = get_tree().current_scene.get_node(
		level_name % next_scene_no).get_node("Player")
	if not player.lost_life.is_connected(Callable(self, "_on_life_lost")):
		player.lost_life.connect(Callable(self, "_on_life_lost"))
		
	# Set initial life value for HUD
	var HUD_node = self.get_node("HUD/HUDLayer/HealthContainer")
	HUD_node.update_lives(player.lives)

func _on_life_lost():
	# Bug exists where dying more than once in rapid succession
	# crashes game with a nil value for nearest_spawn_point_x
	var current_level_name = level_name % (next_scene_no - 1)
	var HUD_node = self.get_node("HUD/HUDLayer/HealthContainer")
	var player = get_tree().current_scene.get_node(
		current_level_name).get_node("Player")
	
	player.set_collision_mask_value(4, false)
		
	var nearest_spawn_point_x = 0
	player.lives -= 1
	if player.lives <= 0:  # Work out how to restart music
		player.die()
		player.lives = player.max_lives
		HUD_node.update_lives(player.lives)
		
	else:
		HUD_node.update_lives(player.lives)
		nearest_spawn_point_x = find_nearest_spawn_point(player)
		
	player.respawn()
	player.position.x = nearest_spawn_point_x
	player.position.y = 0
	player.set_collision_mask_value(4, true)
	
	
func find_nearest_spawn_point(player):
	var spawn_points = get_tree().get_nodes_in_group("spawn_points")
	var viable_spawn_points = []
	for spawn_point in spawn_points:
		if player.position.x >= spawn_point.position.x:
			viable_spawn_points.append(spawn_point.position.x)
	
	if player.position.x == 0:
		return 0
	
	return viable_spawn_points.max()

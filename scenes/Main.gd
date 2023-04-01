extends Node

var scene_path = "res://scenes/level0%d.tscn"
var next_scene_no = 1
var next_scene = scene_path % next_scene_no
var transition_item
var level_name = "Level 0%d"
var next_scene_ready = false
var last_scene_instance = null

func _ready():
	# Load HUD
	var HUD_scene = load("res://scenes/HUD.tscn")
	var HUD_instance = HUD_scene.instantiate()
	add_child(HUD_instance)
	load_next_scene()
	
func _process(_delta):
	if next_scene_ready:
		load_next_scene()
		next_scene_ready = false
	
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
	var current_level_name = level_name % (next_scene_no - 1)
	var HUD_node = self.get_node("HUD/HUDLayer/HealthContainer")
	var player = get_tree().current_scene.get_node(
		current_level_name).get_node("Player")
		
	var nearest_spawn_point_x = 0
	player.lives -= 1
	if player.lives <= 0:  # Work out how to restart music
		player.die()
		player.lives = player.max_lives
		HUD_node.update_lives(player.lives)
		
	else:
		player.set_collision_mask_value(4, false)
		HUD_node.update_lives(player.lives)
		nearest_spawn_point_x = find_nearest_spawn_point(player)
		
	player.position.x = nearest_spawn_point_x
	player.position.y = 0
	player.set_collision_mask_value(4, true)
	
		
func find_nearest_spawn_point(player, dead=false):
	var spawn_points = get_tree().get_nodes_in_group("spawn_points")
	var viable_spawn_points = []
	for spawn_point in spawn_points:
		if player.position.x > spawn_point.position.x:
			viable_spawn_points.append(spawn_point.position.x)
	
	return viable_spawn_points.max()

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
		print(next_scene + " exists!")
		var scene = load(next_scene)
		var instance = scene.instantiate()
		add_child(instance)
		if last_scene_instance != null:
			remove_child(last_scene_instance)
		last_scene_instance = instance
		connect_to_body_entered()
		connect_HUD_to_player_lives()
		next_scene_no += 1	

func connect_to_body_entered():
	var current_level_name = level_name % next_scene_no
	print(current_level_name)
	transition_item = get_tree().current_scene.get_node(current_level_name +
	"/Level Transition/ItemArea")
	if not transition_item.is_connected("body_entered",
	Callable(self, "_on_body_entered")):
		transition_item.body_entered.connect(Callable(self, "_on_body_entered"))

func connect_HUD_to_player_lives():
	# next_scene_no is incremented after this function
	var player = get_tree().current_scene.get_node(
		level_name % next_scene_no).get_node("Player/Player")
	var HUD_node = self.get_node("HUD/HUDLayer/HealthContainer")
	if not player.lost_life.is_connected(Callable(HUD_node, "_on_lost_life")):
		player.lost_life.connect(Callable(HUD_node, "_on_lost_life"))

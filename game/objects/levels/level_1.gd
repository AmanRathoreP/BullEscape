extends Node2D

var player = load("res://game/player/player.tscn")
var joystick = load("res://game/objects/dynamic/joystick/virtual_joystick.tscn")

var players_colors = [Color("#f76dc5"), Color("#f25265"), Color("#6663ff"), Color("#47ffe0"), Color("#dbfa50"), Color("#fcaa44")]
var joystick_position = [Vector2(1920-250,1080-250), Vector2(50,1080-250), Vector2(50,50), Vector2(1920-250,50), Vector2((1920/2)-125,50), Vector2((1920/2)-125,1080-250)]
var player_position = joystick_position
var number_of_players:int = 6
var joystick_instances = []
var player_instances = []
var current_target :int
var next_target :int
var all_targets = []
var next_target_choosing_time:float

func _ready():
	var player_instance
	var joystick_instance
	for player_number in range(number_of_players):
		player_instance = player.instantiate()
		joystick_instance = joystick.instantiate()
		joystick_instance.global_position = joystick_position[player_number]
		joystick_instance.joystick_color = players_colors[player_number]
		joystick_instance.visible = true
		player_instance.global_position = player_position[player_number]
		player_instance.player_color = players_colors[player_number]
		player_instances.append(player_instance)
		joystick_instances.append(joystick_instance)
		$".".add_child(player_instances[player_number])
		$".".add_child(joystick_instances[player_number])
		player_instances[player_number]._ready()
		joystick_instances[player_number]._ready()
		
	current_target = randi_range(0, number_of_players - 1)
	next_target = randi_range(0, number_of_players - 1)
	while next_target == current_target:
		next_target = randi_range(0, number_of_players - 1)
	all_targets.append([current_target, next_target])
	player_instances[current_target].player_is_target = true
	
	next_target_choosing_time = randfn(9.6, 3.5)
	$"target-change".start(next_target_choosing_time)
	$"target-superposition-state".start(next_target_choosing_time - 2)

func _physics_process(_delta):
	for player_number in range(number_of_players):
		# $player_instances[player_number].player_is_target = player_is_target
		if joystick_instances[player_number] and joystick_instances[player_number].is_pressed:
			player_instances[player_number].velocity = joystick_instances[player_number].output * player_instances[player_number].player_speed * 0.6
		else:
			player_instances[player_number].velocity = Vector2.ZERO
	$"anti-player-bull".to_look_at = player_instances[current_target].get_global_position()

func _on_targetchange_timeout():
	player_instances[current_target].player_is_target = false
	player_instances[next_target].stop_target_superposition()
	current_target = next_target
	next_target = randi_range(0, number_of_players - 1)
	while next_target == current_target:
		next_target = randi_range(0, number_of_players - 1)
	all_targets.append(next_target)
	player_instances[current_target].player_is_target = true
	next_target_choosing_time = randfn(9.6, 3.5)
	$"target-change".start(next_target_choosing_time)
	$"target-superposition-state".start(next_target_choosing_time - 2)

func _on_targetsuperpositionstate_timeout():
	player_instances[next_target].start_target_superposition()

extends Control

func _ready():
	for i in range(2, 7):
		$"number-of-players".add_item(str(i))

func _on_start_pressed():
	var level_scene_instance = preload("res://game/objects/levels/level_1.tscn").instantiate()
	level_scene_instance.number_of_players = int($"number-of-players".selected) + 2
	get_tree().get_root().add_child(level_scene_instance)
	queue_free()

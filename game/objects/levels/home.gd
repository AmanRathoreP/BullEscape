extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(2, 7):
		$"number-of-players".add_item(str(i))


func _on_start_pressed():
	var level_scene_instance = preload("res://game/objects/levels/level_1.tscn").instantiate()
	level_scene_instance.number_of_players = int($"number-of-players".selected) + 2
	get_tree().get_root().add_child(level_scene_instance)
	queue_free()
	

"""
func _on_button_pressed():
	# Load the game scene
	var level_scene_instance = preload("res://game/objects/levels/level_1.tscn").instance()

	# Access the custom_variable in the loaded scene
	level_scene_instance.custom_variable = "your_value"

	# Change the scene
	get_tree().change_scene(level_scene_instance)

"""

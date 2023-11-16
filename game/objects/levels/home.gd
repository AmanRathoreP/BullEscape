extends Control

func _on_start_pressed():
	if $BackgroundImage/Start.text == "Start":
		var level_scene_instance = preload("res://game/objects/levels/level_1.tscn").instantiate()
		level_scene_instance.number_of_players = int($BackgroundImage/NumberOfOfflinePlayersSelector.value)
		get_tree().get_root().add_child(level_scene_instance)
		$".".visible = false
	elif $BackgroundImage/Start.text == "Ready":
		#! check if room is avaliable for these players or not
		$BackgroundImage/Start.text = "Cancel"
		$BackgroundImage/WaitingForHost.visible = true
		$BackgroundImage/NumberOfOfflinePlayersSelector.set_editable(false)
	elif $BackgroundImage/Start.text == "Cancel":
		$BackgroundImage/Start.text = "Ready"
		$BackgroundImage/WaitingForHost.visible = false
		$BackgroundImage/NumberOfOfflinePlayersSelector.set_editable(true)
	
func _on_join_online_game_pressed():
	$BackgroundImage/Start.text = "Ready"
	$BackgroundImage/NumberOfOfflinePlayersSelector.min_value = 1
	$BackgroundImage/NumberOfOfflinePlayersSelector.max_value = 11 #! level_1.roomAvaliable()
	$BackgroundImage/NumberOfOfflinePlayersSelector.value = 1
	$BackgroundImage/HostOnlineGame.disabled = true
	$BackgroundImage/JoinOnlineGame.disabled = true
	$BackgroundImage/EnterLobbyId.set_editable(false)
	$BackgroundImage/ExitLobby.visible = true
	
func _on_exit_lobby_pressed():
		get_tree().get_root().add_child(load("res://game/objects/levels/home.tscn").instantiate())
		queue_free()

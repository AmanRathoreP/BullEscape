extends CharacterBody2D

var to_look_at:Vector2

func _physics_process(_delta):
	look_at(to_look_at)

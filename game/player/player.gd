extends CharacterBody2D

var player_color:Color
@export var player_speed:float = 800
@export var player_is_target:bool = false

func _ready():
	$PlayerImage.modulate = player_color
	
func _physics_process(_delta):
	if velocity != Vector2.ZERO:
		$idle.stop()
		move_and_slide()
		for i in get_slide_collision_count():
			$collide.play("collide")
	else:
		$idle.play("idle")

	$"Red-flag".visible = player_is_target

func start_target_superposition():
	$"superposition-state".play("target-superposition")
	
func stop_target_superposition():
	$"superposition-state".stop()

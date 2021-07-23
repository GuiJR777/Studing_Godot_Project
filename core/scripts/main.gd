extends Node2D
 
onready var player = "none"
onready var player_state = "none"
onready var base_player = load(("res://core/scenes/player.tscn"))


func _ready():
	player = base_player.instance()
	player.walk_speed = 200
	player.run_speed = 500
	player.crouch_speed = 100
	player.controlled = true
	player.facing = Vector2(0,-1) # começa virado para cima "north"
	player.person = "player"
	player.global_position = $start_position_player.global_position
	$YSort.call_deferred("add_child", player)
	

func _process(_delta):
	check_player_target()
	check_player_state()
	
func check_player_target():
	var itens = $YSort.get_children()
	var target = null
	for item in itens:
		#if item.get_class() == "StaticBody2D":
		if item.is_target:
			target = true
			player.target =  item
			break
		else:
			target = false
	
	player.aiming = target
	
func check_player_state():
	player_state = player.state
	#print(player_state)

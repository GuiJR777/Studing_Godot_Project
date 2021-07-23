extends BaseEnemy

onready var mark = $target
onready var emotes = {
	'question':load("res://core/assets/graphics/Style 8/emote_question.png"),
	'1dot':load("res://core/assets/graphics/Style 8/emote_dots1.png"),
	'2dot':load("res://core/assets/graphics/Style 8/emote_dots2.png"),
	'3dot':load("res://core/assets/graphics/Style 8/emote_dots3.png"),
	'exclaim':load("res://core/assets/graphics/Style 8/emote_exclamation.png")
}


func _ready():
	add_to_group("targets")
	
func _process(_delta):
	if self.is_target:
		mark.visible = true
		if mark.frame >= 3:
			mark.frame = 0
		mark.frame+=1
	else:
		mark.frame = 0
		mark.visible = false
		

func _on_target():
	self.is_target= change_condition(is_target)
	add_to_group("targets")
	

func change_condition(condition) -> bool:
	if condition:
		return false
	else:
		var itens = get_tree().get_nodes_in_group("targets")
		for item in itens:
			item.is_target = false
		return true
		
		

func _on_percepcao_area_shape_entered(_area_id, area, _area_shape, _local_shape):
	if target:return
	if area.collision_layer == 1:
		var player = area.get_parent()
		if player.state == "crouchidle" or player.state == "crouchwalk":
			pass
		else:
			yield(get_tree().create_timer(1), "timeout")
			$emote.visible = true
			target = player
		
func _on_percepcao_area_shape_exited(_area_id, area, _area_shape, _local_shape):
	if area.collision_layer == 1:
		atack = false
		$emote.texture = emotes['question']
		$emote.visible = false
		target = null
		aiming = false
		can_shoot = false

func _on_visao_area_shape_entered(_area_id, area, _area_shape, _local_shape):
	if area.collision_layer == 1:
		$emote.visible = true
		for i in range(3):
			yield(get_tree().create_timer(0.5), "timeout")
			var index = "%ddot" % [i+1]
			$emote.texture = emotes[index]
			yield(get_tree().create_timer(0.5), "timeout")
		$emote.texture = emotes["exclaim"]
		aiming = true
		can_shoot = true
		atack = true


func _on_visao_area_shape_exited(_area_id, area, _area_shape, _local_shape):
	if area.collision_layer == 1:
		var player = area.get_parent()
		target = null
		yield(get_tree().create_timer(0.1), "timeout")
		target = player
		


func _on_VisibilityNotifier2D_screen_exited():
	target = null
	aiming = false
	can_shoot = false
	is_target = false
	state = "idle"
	get_tree().get_root().get_node("cena_01/YSort/player").aiming = false
	get_tree().get_root().get_node("cena_01/YSort/player").target = Vector2(0,1)
	

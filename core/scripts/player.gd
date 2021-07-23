extends BasePlayer

func _on_selector_pressed():
	get_tree().set_group("characters", "controlled", false)
	yield(get_tree().create_timer(.1), "timeout")
	self.controlled = true

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.scancode == KEY_K:
			self.die()
		elif event.scancode == KEY_L:
			self.ressurect()


func _on_back_button_pressed():
	get_tree().change_scene("res://core/scenes/scene_selection.tscn")

func _on_hit_pressed():
	last_magic = "hit"

func _on_puxar_pressed():
	last_magic = "puxar"

func _on_empurrar_pressed():
	last_magic = "empurrar"

func _on_levitar_pressed():
	last_magic = "levitar"

extends KinematicBodyBase2D

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

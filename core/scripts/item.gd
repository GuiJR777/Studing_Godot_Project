extends StaticBody2D
	
export(bool) var is_target: bool = false

func _ready():
	add_to_group("itens")
	
func _process(_delta):
	var mark = $target
	if self.is_target:
		mark.visible = true
		if mark.frame >= 3:
			mark.frame = 0
		mark.frame+=1
	else:
		mark.frame = 0
		mark.visible = false

func _on_target():
	#get_tree().set_group("itens","is_target", false)
	self.is_target= change_condition(is_target)
	add_to_group("itens")
	

func change_condition(condition) -> bool:
	if condition:
		return false
	else:
		var itens = get_tree().get_nodes_in_group("itens")
		for item in itens:
			item.is_target = false
		return true

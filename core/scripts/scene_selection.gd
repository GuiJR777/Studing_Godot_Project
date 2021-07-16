extends Control

func _on_TextureButton_pressed():
	get_tree().change_scene("res://core/scenes/Cena1.tscn")


func _on_TextureButton2_pressed():
	get_tree().quit()

extends KinematicBody2D

export var speed = 350
export(bool) var is_target: bool = false
onready var mark = $target
var velocity = Vector2.ZERO
var move = false
var move_type = "none"
var target = Vector2.ZERO
var levitando = false
var mouse_target = null
var altura_inicial = 0
var altura_max = -50


func _ready():
	altura_inicial = get_altura_inicial()
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
		
func _physics_process(delta):
	if move:
		if move_type == 'aproximar':
			aproximar(target)
		elif move_type == 'afastar':
			afastar(target)
		elif move_type == 'levitar':
			levitar(target)

func _on_target():
	self.is_target= change_condition(is_target)
	add_to_group("targets")
	
func _input(event):
	if levitando:
		if event.is_action_released('click'):
			mouse_target = get_global_mouse_position()
	

func change_condition(condition) -> bool:
	if condition:
		return false
	else:
		var itens = get_tree().get_nodes_in_group("targets")
		for item in itens:
			item.is_target = false
		return true
		
func move_to_click():
	if mouse_target:
		is_target = false
		velocity = position.direction_to(mouse_target)*speed
		if position.distance_to(mouse_target) > 10:
			velocity = move_and_slide(velocity)
		else:
			var altura = get_node("corpo").position.y
			if altura != altura_inicial:
				get_node("corpo").position.y += 1
			else:
				get_node("colisao").disabled = false
				mouse_target = null
				levitando = false
				move = false
				target = Vector2.ZERO
				
	else:
		pass
		
func afastar(target_position):
	var direction = (global_position-target_position)
	if position.distance_to(target_position) < 600:
		move_and_slide(direction.normalized()*speed)
	else:
		move = false
		target = Vector2.ZERO
		is_target = false
	
func aproximar(target_position):
	velocity = position.direction_to(target_position)*speed
	if position.distance_to(target_position) > 5:
		velocity = move_and_slide(velocity)
	else:
		move = false
		target = Vector2.ZERO
		is_target = false

func get_altura_inicial():
	altura_inicial = get_node("corpo").position.y
	return altura_inicial
		
func levitar(target_position):
	if levitando:
		move_to_click()
	else:
		var altura = get_node("corpo").position.y
		if altura != (altura_inicial + altura_max):
			get_node("corpo").position.y += -1
		else:
			levitando = true
			get_node("colisao").disabled = true
	

func _on_area_contato_area_shape_entered(_area_id, area, _area_shape, _local_shape):
	if area.collision_layer == 8:
		var bullet_type = area.get_parent().bullet_type
		var position = area.get_parent().origin_position
		if bullet_type == "puxar":
			target = position
			move_type = "aproximar"			
			move = true
		elif bullet_type == "empurrar":
			target = position
			move_type = "afastar"			
			move = true
		elif bullet_type == "levitar":
			target = position
			move_type = "levitar"			
			move = true

extends KinematicBody2D

class_name KinematicBodyBase2D

export(int) var walk_speed: int = 300
export(int) var run_speed: int = 300
export(int) var crouch_speed: int = walk_speed * 0.5
export var person: String = "player"
export var facing: Vector2 = Vector2(0,1)
export(bool) var controlled: bool = false
export(bool) var crounched: bool = false
export(bool) var aiming: bool = false
export var target: Vector2 = Vector2(0,1)

var bullet = preload("res://core/scenes/bullet.tscn")
var auxiliar_count = 0
var speed: int = 0
var died: bool = false
var deflecting: bool = false
var roll: bool = false
export var state: String = "idle"
var dir: Vector2 = Vector2.ZERO
var oldTexture = null
export(Array) var directions: Array = ["right", "downright", "down", "downleft", "left", "upleft", "up", "upright"]
var pathTexture: String = "res://core/assets/characters//[PERSON]/sprites/[STATE]/[FACING].png"
var loaded: Dictionary = {}

func _ready() -> void:
	add_to_group("characters")
	speed = walk_speed
	_preCache()

func _physics_process(delta) -> void:
	if died or deflecting: return
	# regras de movimentação, animação e troca de textura do player
	_move(delta)
	# implementa o movimento no KinematicBody2D
	dir = move_and_slide(dir.normalized() * speed)

func _move(delta) -> void:
	dir = Vector2.ZERO
	if crounched:
		state = "crouchidle"
	elif aiming:
		state = "aimidle"
	else:
		state = "idle"
	
	var LEFT:bool = Input.is_action_pressed("ui_left")
	var RIGHT:bool = Input.is_action_pressed("ui_right")
	var UP:bool = Input.is_action_pressed("ui_up")
	var DOWN:bool = Input.is_action_pressed("ui_down")
	
	if !controlled:
		LEFT = false
		RIGHT = false
		UP = false
		DOWN = false
	
	var vX:int = (int(RIGHT)-int(LEFT))
	var vY:int = (int(DOWN)-int(UP))

	dir.x = vX
	dir.y = vY
	

	if dir != Vector2(0,0):
		if crounched:
			state = "crouchwalk"
			speed = crouch_speed
		elif aiming:
			state = "aimwalk"
			speed = walk_speed
		elif roll:
			state = "roll"
			speed = run_speed*0.7
			var max_count = $anim.get_current_animation_length() / 2
			auxiliar_count += delta
			if auxiliar_count >= max_count:
				roll = false
				auxiliar_count = 0
				$anim.playback_speed = 1.0
		elif Input.is_action_pressed("ui_run"):
			state = "run"
			speed = run_speed
			crounched = false
		else:
			state = "walk"
			speed = walk_speed
			
	if LEFT || RIGHT || UP || DOWN:
		facing = dir
		
	if aiming:
		facing = self.target - self.global_position
		
	var animation = direction2str(facing)
	var newTexture = _getTexture(animation, state)
	
	if $anim.assigned_animation != state:
		$anim.play(state)

	if oldTexture != newTexture:
		oldTexture = newTexture
		var key = str(state, "_", animation)
		$corpo.texture = _imageCache(newTexture, key)
		
func change_condition(condition) -> bool:
	if condition:
		return false
	else:
		return true
		
func randint(x:int,y:int) -> int:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	return rng.randi_range(x, y)

func select_rand_item(list_item):
	var choice = randint(0,len(list_item)-1)
	var select_item = list_item[choice]
	return select_item
		
func _input(event):	
		if event is InputEventKey:
			if Input.is_action_just_pressed("ui_crounch"):
				if crounched:
					pass
				else:
					play_quick("crouching", 3.0, false)
				crounched = change_condition(crounched)
			elif Input.is_action_just_pressed("ui_escape"):
				deflect()
			elif Input.is_action_just_pressed("ui_action"):
				action(facing)
				
func direction2str(direction) -> String:
	var angle = direction.angle()
	if angle < 0:
		angle += 2 * PI
	var index = round(angle / PI * 4)
	if index > 7:
		index = 0
	return directions[index]
	
func _imageCache(_newTexture, _key) -> Texture:
	var tex = null
	# Se não tem no cache, então carrega e coloca
	if not loaded.has(_key):
		tex = load(_newTexture)
		loaded[_key] = tex
	else:
		tex = loaded[_key]
	return tex

func _preCache() -> void:
	for anim_state in $anim.get_animation_list():
		for animation in directions:
			var newTexture = _getTexture(animation, anim_state)
			var key = str(anim_state, "_", animation)
			var _tmp = _imageCache(newTexture, key)

func _getTexture(_animation, _state) -> String:
	var newTexture = pathTexture
	newTexture = newTexture.replace("[FACING]", _animation)
	newTexture = newTexture.replace("[PERSON]", person)
	newTexture = newTexture.replace("[STATE]", _state)
	return newTexture

# Actions
func deflect():
	var atual_state = state
	deflecting = true
	if atual_state == "run":
		state = "roll"
	else:
		$colisao.disabled = true
		state = "deflect"
	var _animation = direction2str(facing)
	var newTexture = _getTexture(_animation, state)
	var key = str(state, "_", _animation)
	if oldTexture != newTexture:
		oldTexture = newTexture
		$corpo.texture = _imageCache(newTexture, key)
	$anim.playback_speed = 2.0
	$anim.play(state)
	if atual_state == "run":
		roll = true
		deflecting = false
		return
	else:
		yield($anim, "animation_finished")
	deflecting = false
	$colisao.disabled = false
	state = atual_state
	_animation = direction2str(facing)
	$anim.playback_speed = 1.0
	$anim.play(state)
	deflecting = false
	
func action(direction):
	var bullet_instance = bullet.instance()
	var spawn = bullet_instance.spawn_position[direction2str(direction)]
	bullet_instance.position = self.global_position + spawn
	bullet_instance.bullet_type = "red"
	bullet_instance.set_type_bullet()
	var speed_atack = 5.0
	if aiming:
		bullet_instance.look_at(target)
		speed_atack = 10.0
	play_quick("atack", speed_atack, false)
	bullet_instance.apply_impulse(facing, Vector2(bullet_instance.bullet_speed, 0).rotated(facing.angle()))
	get_tree().get_root().add_child(bullet_instance)
	
func play_quick(anim_state, anim_speed=1.0, backward=false):
	var atual_state = "idle" if state == "die" else state
	if aiming:
		atual_state = "aimidle"
	deflecting = true
	state = anim_state
	var _animation = direction2str(facing)
	var newTexture = _getTexture(_animation, state)
	var key = str(state, "_", _animation)
	if oldTexture != newTexture:
		oldTexture = newTexture
		$corpo.texture = _imageCache(newTexture, key)
	$anim.play(state,-1.0,anim_speed, backward)
	yield($anim, "animation_finished")
	deflecting = false
	state = atual_state
	_animation = direction2str(facing)
	$anim.playback_speed = 1.0
	$anim.play(state)
	
func die():
	if died: return
	died = true
	state = "die"
	var _animation = direction2str(facing)
	var newTexture = _getTexture(_animation, state)
	var key = str(state, "_", _animation)
	if oldTexture != newTexture:
		oldTexture = newTexture
		$corpo.texture = _imageCache(newTexture, key)
	$anim.play(state)
	
	
func ressurect():
	if died:
		died = false
		state = "idle"
		play_quick("standup", 1.0, false)
		var _animation = direction2str(facing)
		var newTexture = _getTexture(_animation, state)
		var key = str(state, "_", _animation)
		if oldTexture != newTexture:
			oldTexture = newTexture
			$corpo.texture = _imageCache(newTexture, key)
		$anim.play(state)
	else:return

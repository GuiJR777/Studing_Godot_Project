extends RigidBody2D

export(int) var bullet_speed = 2000
export var bullet_type:String = "none"
export var bullet_color:String = "none"
export var origin_position:Vector2
onready var explosion = preload("res://core/scenes/MagicExplossion.tscn")

export var spawn_position:Dictionary = {
	"east_spritesheet" : Vector2( 80, -93),
	"southeast_spritesheet" : Vector2( 53, -70),
	"south_spritesheet" : Vector2( 0, 27),
	"southwest_spritesheet" : Vector2( -62, -73),
	"west_spritesheet" : Vector2( -80, -97),
	"northwest_spritesheet" : Vector2( -52, -122),
	"north_spritesheet" : Vector2( 0, -130),
	"northeast_spritesheet" : Vector2( 60, -120),
}

var bullet_colors = {
	"blue" : {
		"primary" : Color(0, 0, 0.55, 1 ),
		"secondary" : Color(0.68, 0.85, 0.9, 1)
	},
	"cyan" : {
		"primary" : Color(0, 0.55, 0.55, 1),
		"secondary" : Color(0.88, 1, 1, 1 )
	},
	"red" : {
		"primary" : Color(0.55, 0, 0, 1 ),
		"secondary" : Color(0.94, 0.5, 0.5, 1 )
	},
	"yellow": {
		"primary": Color(1, 1, 0, 1 ),
		"secondary": Color(1, 1, 0.88, 1 )
	},
	"orange": {
		"primary": Color(1, 0.55, 0, 1 ),
		"secondary": Color(1, 0.65, 0, 1)
	},
	"green":{
		"primary": Color(0, 0.39, 0, 1),
		"secondary": Color( 0.56, 0.93, 0.56, 1)
	},
	"purple": {
		"primary": Color(0.58, 0, 0.83, 1 ),
		"secondary": Color(0.93, 0.51, 0.93, 1 )
	},
	"white": {
		"primary": Color(0.96, 0.96, 0.96, 1 ),
		"secondary": Color(1, 1, 1, 1)
	},
	"black": {
		"primary": Color(0,0,0,1),
		"secondary": Color(44, 62, 80)
	},
	"evil": {
		"primary": Color(0.63, 0.13, 0.94, 1 ),
		"secondary": Color(0,0,0,1)
	},
	"good": {
		"primary": Color(1, 1, 1, 1),
		"secondary": Color(1, 0.84, 0, 1)
	},
}

func set_type_bullet():
	var color = self.bullet_colors.get(self.bullet_color)
	$corpo.modulate = color.get("primary")
	$corpo.self_modulate = color.get("primary")
	$rastro.default_color = color.get("secondary")
	$luz.color = color.get("secondary")

func _on_visibilidade_screen_exited():
	queue_free()

func _on_areadecontato_area_entered(area):
	if area.collision_layer != 64:
		var explosion_instance = explosion.instance()
		explosion_instance.modulate = $corpo.modulate
		explosion_instance.self_modulate = $corpo.self_modulate
		explosion_instance.position = get_global_position()
		get_tree().get_root().add_child(explosion_instance)
		
		queue_free()

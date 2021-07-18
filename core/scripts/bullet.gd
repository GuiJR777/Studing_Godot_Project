extends RigidBody2D

export(int) var bullet_speed = 2000
export var bullet_type:String = "none"

export var spawn_position:Dictionary = {
	"east_spritesheet" : Vector2( 117, -142),
	"southeast_spritesheet" : Vector2( 79, -105),
	"south_spritesheet" : Vector2( 0, 40),
	"southwest_spritesheet" : Vector2( -90, -109),
	"west_spritesheet" : Vector2( -120, -150),
	"northwest_spritesheet" : Vector2( -80, -182),
	"north_spritesheet" : Vector2( 0, -197),
	"northeast_spritesheet" : Vector2( 90, -180),
}

var bullet_types = {
	"blue" : {
		"principal" : Color(0.52,0.95,0.91, 0.8),
		"secondary" : Color(0.68,0.83,0.94)
	},
	"red" : {
		"principal" : Color(0.90,0.29,0.23, 0.8),
		"secondary" : Color(0.94,0.58,0.54)
	}
}

func set_type_bullet():
	var type = self.bullet_types.get(self.bullet_type)
	$corpo.modulate = type.get("principal")
	$corpo.self_modulate = type.get("secondary")
	$rastro.default_color = type.get("secondary")
	$luz.color = type.get("secondary")

func _ready():
	pass 


func _on_bullet_body_entered(body):
	if !body.is_in_group("player"):
		queue_free()

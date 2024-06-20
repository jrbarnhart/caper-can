extends Node2D

@onready var animated_sprite_2d = $AnimatedSprite2D
const FRAME_COUNT = 8

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var angle_degrees = rotation_degrees
	
	angle_degrees = wrapf(angle_degrees, 0, 360)
	
	var frame_index = int((angle_degrees / 360) * FRAME_COUNT) % FRAME_COUNT
	
	animated_sprite_2d.frame = frame_index

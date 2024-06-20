extends RigidBody2D

signal update_charge_meter(value)

@onready var animated_sprite_2d = $AnimatedSprite2D

const FRAME_COUNT = 8
const OFFSET_DEGREES = 337.5
const MAX_CHARGE_TIME = 1.0  # Max time to charge the shot
const CHARGE_MULTIPLIER = 2.5  # Multiplier for fully charged shots
const SHOT_POWER_X = 250.0
const SHOT_POWER_Y = -500.0
const MAX_VELOCITY_Y = 500.0

var charge_time = 0.0
var is_charging_left = false
var is_charging_right = false
var left_shot_released = false
var right_shot_released = false

func _process(delta):
	if Input.is_action_pressed("left_shot"):
		is_charging_left = true
		charge_time += delta
	elif Input.is_action_just_released("left_shot"):
		is_charging_left = false
		left_shot_released = true

	if Input.is_action_pressed("right_shot"):
		is_charging_right = true
		charge_time += delta
	elif Input.is_action_just_released("right_shot"):
		is_charging_right = false
		right_shot_released = true

		
	#Emit signal for charge meter
	emit_signal("update_charge_meter", (charge_time / MAX_CHARGE_TIME) * 100)

	var angle_degrees = rotation_degrees
	angle_degrees = wrapf(angle_degrees - OFFSET_DEGREES, 0, 360)
	var frame_index = int((angle_degrees / 360) * FRAME_COUNT) % FRAME_COUNT
	animated_sprite_2d.frame = frame_index

func _integrate_forces(state):
	if left_shot_released:
		print("Left")
		apply_charged_shot(state, Vector2(-SHOT_POWER_X, SHOT_POWER_Y), -5000.0)
		left_shot_released = false
	elif right_shot_released:
		print("Right")
		apply_charged_shot(state, Vector2(SHOT_POWER_X, SHOT_POWER_Y), 5000.0)
		right_shot_released = false
		
func apply_stopping_shot(state):
	var final_impulse_y = 0
	if state.linear_velocity.y > MAX_VELOCITY_Y:
		final_impulse_y = 0
	else:
		var velocity_difference = MAX_VELOCITY_Y - state.linear_velocity.y
		final_impulse_y = SHOT_POWER_Y * (velocity_difference / MAX_VELOCITY_Y)
	state.apply_impulse(Vector2(-state.linear_velocity.x, final_impulse_y))
	charge_time = 0.0


func apply_charged_shot(state, impulse_vector, torque_impulse):
	var charge_ratio = min(charge_time / MAX_CHARGE_TIME, 1.0)
	var final_impulse_vector = impulse_vector * (1.0 + charge_ratio * (CHARGE_MULTIPLIER - 1.0))
	var final_torque_impulse = torque_impulse * (1.0 + charge_ratio * (CHARGE_MULTIPLIER - 1.0))

	state.linear_velocity = Vector2.ZERO
	state.apply_impulse(final_impulse_vector)
	state.apply_torque_impulse(final_torque_impulse)

	charge_time = 0.0  # Reset charge time after shot

extends KinematicBody2D
var grv = 100
var max_grv = 250
var jmp = 1500
var min_grv = 10
var min_jmp = 300

var acc = 50
var dec = 200
var frc = 80
var top = 1200
var air = 1.2
var drag = .8089
var y_speed = 0

var floor_normal = Vector2(0,-1)
var gsp = 0
var rot = 0
var rotspd = 13
onready var sprite = get_node("Sprite")

var velocity = Vector2(0,0)
onready var sensor_a = get_node("sensors/sensor_a")
onready var sensor_b = get_node("sensors/sensor_b")
onready var sensors = get_node("sensors")

func get_floor_normal():
	if sensor_a.is_colliding() && sensor_b.is_colliding():
		var thing
		if abs(sensor_a.get_collision_normal().angle()) >= abs(sensor_a.get_collision_normal().angle()):
			return sensor_a.get_collision_normal()
		elif abs(sensor_a.get_collision_normal().angle()) < abs(sensor_a.get_collision_normal().angle()):
			return sensor_b.get_collision_normal()
	elif sensor_a.is_colliding():
		return sensor_a.get_collision_normal()
	elif sensor_b.is_colliding():
		return sensor_b.get_collision_normal()
	else:
		return Vector2(0,-1)

func _process(delta):
	floor_normal = get_floor_normal()
	# rotate character
	rot = -floor_normal.angle_to(Vector2(0,-1))
	#sprite.rotation = lerp(sprite.rotation, rot, rotspd*delta)
	if is_on_floor():
		run(floor_normal.angle())
	else:
		if floor_normal == Vector2(0,-1):
			rot = 0
			sprite.rotation = lerp(sprite.rotation, 0, rotspd*delta)
		airMove()
		if Input.is_action_just_released("jump") && velocity.y < -min_jmp:
			y_speed = -min_jmp

	if is_on_ceiling() && velocity.y < 0:
		y_speed = 0

	# move and slide
	velocity = Vector2(gsp, 0).rotated(rot)
	velocity += Vector2(0, y_speed).rotated(rot)
	move_and_slide(velocity, floor_normal)

func run(floor_angle):
	if Input.is_action_pressed("move_left"):
		if (gsp > 0):
			gsp -= dec
		else:
			gsp -= acc
	elif Input.is_action_pressed("move_right"):
		if (gsp < 0):
			gsp += dec
		else:
			gsp += acc
	else:
		if abs(gsp) < frc:
			gsp = 0
		else:
			gsp -= frc * sign(gsp)
	if abs(gsp) > top:
		gsp = top * sign(gsp)
	y_speed = min_grv
	if Input.is_action_just_pressed("jump"):
		y_speed = -jmp
	velocity = Vector2(gsp, 0).rotated(rot)
	velocity += Vector2(0, y_speed).rotated(rot)
	print(velocity)

func airMove():
	if Input.is_action_pressed("move_left"):
		gsp -= acc * air
	elif Input.is_action_pressed("move_right"):
		gsp += acc * air
	else:
		gsp *= drag
	if abs(gsp) > top:
		gsp = top * sign(gsp)
	y_speed += grv
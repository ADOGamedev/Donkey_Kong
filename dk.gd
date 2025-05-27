extends KinematicBody2D

var VERTICAL_SPEED = 93	
var HORIZONTAL_SPEED = 65
var JUMP = 200
var GRAVITY = 800
var velocity = Vector2.ZERO
var reached_top = false
var jumps = -1
var one_time_exe = true
var one_time_exe_2 = true

func _ready():
	
	get_parent().get_node("opening_music").play()
	get_parent().get_node("princess").visible = false
	
func _physics_process(delta):
	
	if position.y < 100:
		reached_top = true
	
	if position.y < 235:
		if one_time_exe_2:
			one_time_exe_2 = false
			VERTICAL_SPEED = 0
			GRAVITY = 0
			yield(get_tree().create_timer(0.5), "timeout")
			VERTICAL_SPEED = 250
			GRAVITY = 800

		
	if !reached_top:
		$animations.animation = "kong_climbing"
		velocity.y = -VERTICAL_SPEED
	
	else:
		get_parent().get_node("princess").visible = true
		if $animations.animation != "kong_angry":
			$animations.animation = "idle"
		velocity.x = HORIZONTAL_SPEED
		if is_on_floor():
			if jumps == 1:
				if one_time_exe:
					one_time_exe = false
					HORIZONTAL_SPEED = 0
					yield(get_tree().create_timer(0.5), "timeout")
					HORIZONTAL_SPEED = 65
					velocity.y -= JUMP
			else:
				velocity.y -= JUMP
	
	if position.x > 475.241:
		velocity = Vector2.ZERO
		
	velocity.y += GRAVITY * delta
	
	if position.y < 500:
		get_parent().get_node("giant_ladder").position.y -= 1.31
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
	if Input.is_action_just_pressed("easter_egg"):
		Global.easter_egg = true

func _on_Area2D_body_entered(body):
	if body is StaticBody2D:
		jumps += 1
		if jumps == 1:
			get_parent().get_node("floor6/floor6_sprite").texture = load("res://assets/flat_floor.png")
		if jumps == 2:
			get_parent().get_node("floor5_sprite").texture = load("res://assets/floor.png")
		if jumps == 3:
			get_parent().get_node("floor4_sprite").texture = load("res://assets/floor.png")
		if jumps == 4:
			get_parent().get_node("floor3_sprite").texture = load("res://assets/floor.png")
		if jumps == 5:
			get_parent().get_node("floor2_sprite").texture = load("res://assets/floor.png")
		if jumps == 6:
			get_parent().get_node("floor1_sprite").texture = load("res://assets/flat_floor.png")
			yield(get_tree().create_timer(0.5), "timeout")
			$animations.animation = "kong_angry"
			yield(get_tree().create_timer(2.8), "timeout")
			get_tree().change_scene("res://main.tscn")

extends KinematicBody2D
class_name player

var velocity = Vector2()
var speed = 70
var gravity = 650
var jump_force = 235
onready var progress_bar = get_parent().get_node("ui/TextureProgress")
onready var animations = $animations
onready var ray = $RayCast2D
onready var points_ray = $PointsRay
onready var hammer = get_parent().get_node("hammer")
onready var pickable_hammer = get_parent().get_node("level/hammer")
onready var pickable_hammer2 = get_parent().get_node("level/hammer2")
var animation
var ladder #Checks if Mario is in front of a ladder
var points = 0
var points_can_exe = true #To only add points once eachtime
var has_hammer = false
var ladder_down = false
var laddering_down = false
onready var ladder_fixers = [] #The fixer of a problem with the broken_ladders

func _ready():
	
	progress_bar.visible = false
	for i in get_parent().get_node("level/broken_ladder_fixers").get_children():
		ladder_fixers.append(i)
		
func _physics_process(delta):
	
	progress_bar.value = $hammer_timer.time_left * 10
	
	if has_hammer:
		progress_bar.visible = true
		progress_bar.rect_position = position + Vector2(22, -75)
		progress_bar.value -= 1/6
		if !is_on_floor():
			hammer.position = position
			animation = "hammer"
			animations.frame = 1
			animations.playing = false
			
	if animation != "laddering" and animation != "climbing":
		velocity.y += gravity * delta
	
	velocity = move_and_slide(velocity, Vector2.UP)
	
	#Functions
	animate()
	
	if !get_parent().restart:

		get_input()
		get_points()
		
		#Game over if Mario falls
		if position.y > 630:
			velocity = Vector2.ZERO
			get_parent().game_over()
			
	else:
		#So it doesnt die when the plyer reches the princess xd
		if !get_parent().victory:
			$animations.playing = true
			animation = "die"
			if $animations.animation == "die" and $animations.frame == 4:
				$animations.playing = false
		
		else:
			animation = "idle"
		
		#Making the collisions so when mario dies it doesnt collide with other things
		velocity.x = 0
		collision_layer = 0
		collision_layer = 1 << 2
		collision_mask = 0
		collision_mask = 1 << 2
	
	if animation == "hammer" or animation == "idle_hammer":
		hammer.position = position
		if !animations.flip_h:
			hammer.scale.x = -1.75
		else:
			hammer.scale.x = 1.75
	
func get_input():
	
	get_input_running_jumping()
		
	get_input_ladder_climbing_detection()
	
	get_input_laddering()

#Collision with a barrel detection
func _on_body_entered(body):
	
	if body == self:
		if get_parent().restart != true:
			velocity = Vector2.ZERO
			get_parent().game_over()

#Collision with the fire guy detection
func _on_fire_guy_entered(body):
	if body == self:
		if get_parent().restart != true:
			velocity = Vector2.ZERO
			get_parent().game_over()
			
#Collision with the oil detection
func _on_oil_entered(body):
	if body == self:
		if get_parent().restart != true:
			velocity = Vector2.ZERO
			get_parent().game_over()

func _on_pickable_hammer1_entered(body):
	if body == self:
		hammer.visible = true
		has_hammer = true
		hammer.position = position
		get_parent().get_node("sounds/normal_bg_music").stop()
		get_parent().get_node("sounds/hammer_music").play()
		pickable_hammer.queue_free()
		hammer.get_node("CollisionShape2D").disabled = false
		hammer.get_node("CollisionShape2D2").disabled = false
		$hammer_timer.start(10)
		yield($hammer_timer, "timeout")
		progress_bar.visible = false
		$hammer_timer.stop()
		get_parent().get_node("sounds/normal_bg_music").play()
		get_parent().get_node("sounds/hammer_music").stop()
		hammer.position = Vector2.ZERO
		hammer.visible = false
		has_hammer = false

func _on_pickable_hammer2_entered(body):
	if body == self:
		hammer.visible = true
		hammer.get_node("CollisionShape2D").disabled = false
		hammer.get_node("CollisionShape2D2").disabled = false
		hammer.position = position
		has_hammer = true
		get_parent().get_node("sounds/normal_bg_music").stop()
		get_parent().get_node("sounds/hammer_music").play()
		pickable_hammer2.queue_free()
		$hammer_timer.start(10)
		yield($hammer_timer, "timeout")
		progress_bar.visible = false
		$hammer_timer.stop()
		get_parent().get_node("sounds/normal_bg_music").play()
		get_parent().get_node("sounds/hammer_music").stop()
		hammer.position = Vector2.ZERO
		hammer.visible = false
		has_hammer = false
		
#Animating all the animations
func animate():
	if animation == "running":
		if has_hammer:
			animation = "hammer"
		else:
			animations.animation = "running"
			animations.playing = true
			animations.position.y = 0
		
	elif animation == "laddering":
		animations.animation = "laddering"
		for i in ladder_fixers:
			i.get_node("CollisionShape2D").disabled = false
		animations.position.y = 0
		
	elif animation == "jumping":
		animations.animation = "jumping"
		for i in ladder_fixers:
			i.get_node("CollisionShape2D").disabled = true
		animations.position.y = 0
			
	elif animation == "idle":
		if has_hammer == true:
			animations.animation = "idle_hammer"
			animations.position = Vector2(0, -4)
		elif has_hammer == false:
			animations.animation = "idle"
			animations.playing = true
			animations.position.y = 1
		
	elif animation == "climbing":
		animations.animation = "climbing"
		animations.position.y = 5.5 #Moving a bit down the climbing so it fits with the floor
		
	elif animation == "die":
		animations.animation = "die"
		animations.position.y = 0
	
	elif animation == "hammer":
		if is_on_floor():
			animations.playing = true
		animations.animation = "hammer"
		animations.position = Vector2(0, 0)
	
	elif animation == "idle_hammer":
		if is_on_floor():
			animations.playing = true
		animations.animation = "idle_hammer"
		animations.position = Vector2(0, -4)
		
func get_input_running_jumping():
	
	#------------------RUNNING------------------#
	if is_on_floor():
		
		if Input.is_action_pressed("left"):
			if !get_parent().get_node("sounds/footsteps").is_playing():
				get_parent().get_node("sounds/footsteps").play()
			velocity.x = -speed
			animations.flip_h = false
			if animation != "climbing":
				if !has_hammer:
					animation = "running"
				else:
					animation = "hammer"
				
		elif Input.is_action_pressed("right"):
			if !get_parent().get_node("sounds/footsteps").is_playing():
				get_parent().get_node("sounds/footsteps").play()
			velocity.x = speed
			animations.flip_h = true
			if animation != "climbing":
				if !has_hammer:
					animation = "running"
				else:
					animation = "hammer"
		
		#Idle dettection
		else:
			get_parent().get_node("sounds/footsteps").playing = false
			velocity.x = 0
			if animation != "climbing":
				if !has_hammer:
					animation = "idle"
				else:
					animation = "idle_hammer"

					
	#------------------JUMPING------------------#
	if Input.is_action_just_pressed("jump") and is_on_floor() and !has_hammer:
		velocity.y = -jump_force
		get_parent().get_node("sounds/jump").play()
		
	if !is_on_floor() and animation != "laddering":
		if animation != "climbing":
			animation = "jumping"
			
func get_input_ladder_climbing_detection():
	
	#------------------LADDER------------------#
	if ray.is_colliding():
		ladder = true
		
	if $ladder_down.is_colliding() and $ladder_down.get_collider().get_parent().get_parent().name.begins_with("normal_ladder"):
		ladder_down = true
	else:
		ladder_down = false
		
	if !ray.is_colliding():
		ladder = false
		
	#------------------CLIMBING------------------#	
	if !ladder and animation == "laddering":
		if !laddering_down:
			animations.playing = true
			animation = "climbing"
			position.y -= 20
		
	if animations.frame == 2:
		animations.playing = false
		animations.frame = 0
		if !has_hammer:
			animation = "idle"
		else:
			animation = "idle_hammer"
		
	if animation == "climbing":
		velocity = Vector2.ZERO

func get_input_laddering():
	
	#------------------LADDERING------------------#
	if ladder:
		if Input.is_action_pressed("up") and (animation == "idle" or animation == "laddering"):
			velocity.y = -70
			velocity.x = 0
			if animation != "climbing":
				animation = "laddering"
			animations.playing = true
				
		elif Input.is_action_pressed("down") and animation == "laddering":
			velocity.y = 50
			if animation != "climbing":
				animation = "laddering"
			animations.playing = true
			
		elif animation == "laddering":
			velocity.y = 0
			animations.playing = false
	
	if ladder_down:
		if Input.is_action_pressed("down"):
			laddering_down = true
			if !ray.is_colliding():
				$CollisionShape2D.disabled = true
			else:
				$CollisionShape2D.disabled = false
			velocity.y = 50
			velocity.x = 0
			if animation != "climbing":
				animation = "laddering"
			animations.playing = true
		else:
			laddering_down = false
func get_points():
	if points_can_exe == true:
		#If its just above a barrel
		if points_ray.is_colliding():
			if points_ray.get_collider() is RigidBody2D and points_ray.get_collider().name != "OilFire":
				if animation == "jumping":
					get_parent().get_node("sounds/points").play()
					add_points(100)
					points_can_exe = false
					yield(get_tree().create_timer(0.2), "timeout") #Waits a bit so it does add more points
					points_can_exe = true

func add_points(amount):
	points += amount
	$add_of_points.text = str(amount)
	yield(get_tree().create_timer(1), "timeout")
	$add_of_points.text = ""

extends KinematicBody2D

var speed = 70
var jump = 300
var gravity = 1100
var velocity = Vector2()
var vel_left = true #Checks if is moving left
var can_start = false #Checks when the fire guy can start to move
var first_barrel = true #Checks if the first barrel reached the oil
onready var player = get_parent().get_node("player")
var random_generator = RandomNumberGenerator.new()

func _ready():
	
	#Each 1.5 secs he will jump
	while true:
		if is_on_floor():
			jump_to_player()
		yield(get_tree().create_timer(1.5), "timeout")
		
func _physics_process(delta):
	
	#Making him visible when he can start
	if can_start == true:
		get_parent().get_node("fire_guy").visible = true
		get_parent().get_node("fire_guy/CollisionShape2D").disabled = false
		get_parent().get_node("fire_guy/Area2D/CollisionShape2D").disabled = false
		
		if vel_left == true:
			velocity.x = -speed
		
		elif vel_left == false:
			velocity.x = speed
		
		#If he reaches the edge, go to left
		if vel_left == false and position.x > 500:
			vel_left = true
		
		velocity = move_and_slide(velocity, Vector2.UP)
	
		velocity.y += gravity * delta
		
func jump_to_player():
	
	var random_num = random_generator.randi_range(1, 2)
	randomize()
	
	#Jumping left or right 50% chance
	if can_start == true:
		if random_num == 1:
			vel_left = true
			$AnimatedSprite.flip_h = true
		
		if random_num == 2:
				vel_left = false
				$AnimatedSprite.flip_h = false
	
		velocity.y = -jump

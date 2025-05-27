extends RigidBody2D

var collisions_number = 0 #How many times it collided
var speed = 110
var velocity = Vector2.ZERO

func _physics_process(_delta):
	
	rotation_degrees = 0 #So it doesnt rotate while its bouncing
		
	#If its colliding with something
	if get_colliding_bodies().size() == 1:
		collisions_number += 1
		#Timing the ColliisonShape so it passes through the floor
		$CollisionShape2D.disabled = true
		yield(get_tree().create_timer(0.4), "timeout")
		$CollisionShape2D.disabled = false
	
	#Changing the velocity so its goes into the oil
	if collisions_number == 5:
		linear_velocity.x = 10
	
	#Going left or right depending on the num of collisions
	elif collisions_number % 2 != 0:
		linear_velocity.x = -speed
		
	elif collisions_number % 2 == 0:
		linear_velocity.x = speed
	
	#Ereasing the barrel
	if collisions_number == 6:
		get_parent().get_node("fire_guy").can_start = true
		queue_free()


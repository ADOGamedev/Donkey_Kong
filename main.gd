extends Node2D

onready var easter_egg_song = preload("res://sounds/easter_egg_song.wav")
onready var packed_barrel = preload("res://barrel.tscn")
onready var barrel_instance = packed_barrel.instance()
onready var first_barrel = $first_barrel
onready var player = $player
onready var fire_guy = $fire_guy
var restart = false #True if u can restart
var left_right_executable = false #True when dk isnt throing a barrel
var victory = false
onready var barrel_array = [] #All the barrels in the level
var random_generator = RandomNumberGenerator.new()
var one_time_exe = true

func _ready():
	
	$level/princess.animation = "help"
	$sounds/normal_bg_music.play()
	
	#Connecting all the signals
	$fire_guy/Area2D.connect("body_entered", $player, "_on_fire_guy_entered")
	$level/oil/OilFire/Area2D.connect("body_entered", $player, "_on_oil_entered")
	$level/oil/OilFire/Area2D.connect("body_entered", self, "_on_oil_entered")
	$level/princess/Area2D.connect("body_entered", self, "_on_princess_entered")
	$level/hammer/Area2D.connect("body_entered", $player, "_on_pickable_hammer1_entered")
	$level/hammer2/Area2D.connect("body_entered", $player, "_on_pickable_hammer2_entered")
	$hammer.connect("area_entered", self, "_on_hammer_entered")
	
	while true:
		
		if !restart:
			left_right_executable = true
		
			randomize()
			var random_num = random_generator.randf_range(1.1, 2.2) 
			
			#Throwing barrel animation
			$level/dk.frame = 0
			$level/dk.animation = "throwing_barrel"
			$level/dk.speed_scale = 1
			$level/dk.playing = true
			
			#Creating the barrel
			yield(get_tree().create_timer(1.2), "timeout") #Waiting untill the animation finishes
			create_barrel()
			yield(get_tree().create_timer(random_num), "timeout")
		
		#So it doesnt keep throwing barrels after loosing/winning
		else:
			break
		
func _physics_process(delta):
	
	#So the barrels doesnt go too fat
	for barrel in barrel_array:
		if barrel != null:
			if barrel.linear_velocity.x > 140:
				barrel.linear_velocity.x = 140
			if barrel.linear_velocity.x < -140:
				barrel.linear_velocity.x = -140
			if barrel.linear_velocity.x > 0:
				barrel.linear_velocity.x = 140
			if barrel.linear_velocity.x < -0:
				barrel.linear_velocity.x = -140
				
			barrel.rotation_degrees = 0
				
	if restart and Input.is_action_just_pressed("restart"):
		if !victory:
			get_tree().reload_current_scene()
		else:
			get_tree().change_scene("res://opening.tscn")
	
	#Idle after throing the abarrel
	if !restart:	
		if $level/dk.frame == 7:
			$level/dk.frame = 0
			$level/dk.animation = "idle"
			$level/dk.speed_scale = 0.2
		
		#1/4 probability to do left right animation
		if left_right_executable:
			if $level/dk.animation == "idle":
				var random_probability = random_generator.randi_range(1, 3)
				randomize()
				if random_probability == 4:
					$level/dk.frame = 0
					$level/dk.animation = "left_right"
					$level/dk.speed_scale = 0.5
					$level/dk.playing = true
				left_right_executable = false
		
		$ui/points.text = "Points: \n" + str(player.points)
		barrels_trought_ladders()
		
		
	if Global.easter_egg and one_time_exe:
		$sounds/normal_bg_music.stream = easter_egg_song
		$sounds/normal_bg_music.volume_db = -8
		$sounds/normal_bg_music.play()
		one_time_exe = false
		
func game_over():
	
	$sounds/die.play()
	$level/dk.animation = "kong_laughing"
	
	restart = true
	
	yield(get_tree().create_timer(3), "timeout") #Waiting until de animation finishes
	
	#SHowing game over text
	while restart == true:
		yield(get_tree().create_timer(0.3), "timeout")
		get_node("ui").get_node("Label1").text = "GAME \nOVER"
		get_node("ui").get_node("Label2").text = "PRESS ENTER"
		yield(get_tree().create_timer(0.7), "timeout")
		get_node("ui").get_node("Label1").text = ""
		get_node("ui").get_node("Label2").text = ""
		
func create_barrel():
	if !restart:
		var new_barrel = packed_barrel.instance()
		add_child(new_barrel)
		new_barrel.linear_velocity.x = -100
		new_barrel.visible = true
		new_barrel.gravity_scale = 100
		new_barrel.set_collision_mask_bit(7, true)
		new_barrel.set_collision_layer_bit(7, true)
		new_barrel.get_node("Area2D").connect("body_entered", $player, "_on_body_entered")
		barrel_array.append(new_barrel)
		

func barrels_trought_ladders():
	random_generator.randomize()
	
	for barrel in barrel_array:
		if is_instance_valid(barrel):
			#If it isnt above a ladder, continue
			if !barrel.get_node("RayCast2D").is_colliding():
				barrel.get_node("CollisionShape2D").disabled = false
				barrel.probability = random_generator.randi_range(1, 4)
				barrel.gravity_scale = 10
				barrel.get_node("AnimatedSprite").animation = "rolling"
				barrel.scale = Vector2(1, 1)
				barrel.get_node("CollisionShape2D").disabled = false
				if barrel.linear_velocity.x > 0:
					barrel.get_node("AnimatedSprite").flip_h = false
				if barrel.linear_velocity.x < 0:
					barrel.get_node("AnimatedSprite").flip_h = true
			
			#If it is above a ladder, 1/4 chance that goes through it
			elif barrel.get_node("RayCast2D").is_colliding() and barrel.get_node("RayCast2D").get_collider().name != "hammer":
		
				
				if barrel.probability == 1:
					barrel.gravity_scale = 5
					barrel.linear_velocity.x = 0
					barrel.get_node("AnimatedSprite").animation = "laddering"
					barrel.scale = Vector2(1.2, 1.2)
					barrel.get_node("CollisionShape2D").disabled = true
						
				else:
					barrel.get_node("AnimatedSprite").animation = "rolling"
					barrel.scale = Vector2(1, 1)
					barrel.get_node("CollisionShape2D").disabled = false
					if barrel.linear_velocity.x > 0:
						barrel.get_node("AnimatedSprite").flip_h = false
					if barrel.linear_velocity.x < 0:
						barrel.get_node("AnimatedSprite").flip_h = true
						

#Ereaing the barrel if hits the oil
func _on_oil_entered(body):
	if body.name == "first_barrel" or barrel_array.has(body):
		barrel_array.erase(body)
		body.queue_free()
		if body.name == "first_barrel":
			$fire_guy.can_start = true

func _on_princess_entered(body):
	
	if body.name == "player":
		
		#Moving the princess and player so it seems like they are looking eachother
		$sounds/normal_bg_music.stop()
		$sounds/winning_music.play()
		$level/princess.animation = "love"
		$level/princess.flip_h = true
		$level/princess.position.x -= 27
		$player.position.x = $level/princess.position.x - 45
		$player.position.y = 55
		
		$level/dk.animation = "kong_angry"
		$level/dk.speed_scale = 0.2
		
		#Winning text
		victory = true
		restart = true
		while restart == true:
			get_node("ui").get_node("Label1").add_color_override("font_color", Color(0.1, 0.9, 0.1))
			get_node("ui").get_node("Label1").add_color_override("font_outline_modulate", Color(0.6, 1, 0.6))
			yield(get_tree().create_timer(0.3), "timeout")
			get_node("ui").get_node("Label1").text = "YOU \nWON"
			get_node("ui").get_node("Label2").text = "PRESS ENTER"
			yield(get_tree().create_timer(0.7), "timeout")
			get_node("ui").get_node("Label1").text = ""
			get_node("ui").get_node("Label2").text = ""
			
func _on_hammer_entered(area):
	if !restart:
		if barrel_array.has(area.get_parent()):
			$sounds/points.play()
			player.add_points(400)
			barrel_array.erase(area.get_parent())
			area.get_parent().queue_free()
		if area.get_parent().name == "fire_guy":
			$sounds/points.play()
			player.add_points(600)
			area.get_parent().queue_free()

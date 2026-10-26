extends CharacterBody2D


const SPEED = 300.0
var last_direction: Vector2 = Vector2.RIGHT
var is_attacking: bool = false;
var hitbox_offset: Vector2

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var swing_sword: AudioStreamPlayer2D = $"Swing Sword"
@onready var hitbox: Area2D = $Hitbox



func _ready() -> void:
	# Initialize hitbox offset
	hitbox_offset = hitbox.position



func _physics_process(_delta: float) -> void:
	# Disable hitbox until attack is triggered
	hitbox.monitoring = false
	
	if Input.is_action_just_pressed("attack") and not is_attacking:
		attack()
		
	# Skip movement if user attacks
	if is_attacking:
		velocity = Vector2.ZERO
		return
		
	process_movement()
	process_animation()
	move_and_slide()


# ---------------------------------------------------
# MOVEMENT & ANIMATION
# ---------------------------------------------------
func process_movement() -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# If the player is moving
	if direction != Vector2.ZERO:
		velocity = direction * SPEED
		last_direction = direction
		update_hitbox_offset()
	else: 
		# If the player is idle 
		velocity = Vector2.ZERO
	
# Determine whether the player is in an idle or running state
func process_animation() -> void:
	if is_attacking:
		return
	if velocity	!= Vector2.ZERO:
		play_animation("run", last_direction)
	else:
		play_animation("idle", last_direction)

# Play the corresponding animation based on the direction the player moves towards
func play_animation(prefix: String, dir: Vector2) -> void:
	if dir.x != 0:
		animated_sprite.flip_h = dir.x < 0
		animated_sprite.play(prefix + "_left_right")
	elif dir.y < 0:
		animated_sprite.play(prefix + "_up")
	elif dir.y > 0:
		animated_sprite.play(prefix + "_down")

# ---------------------------------------------------
# ATTACKING
# ---------------------------------------------------
	
func attack() -> void:
	is_attacking = true
	hitbox.monitoring = true
	swing_sword.play()
	play_animation("attack", last_direction)

func animation_finished() -> void:
	if is_attacking:
		is_attacking = false
		
# ---------------------------------------------------
# HITBOX
# ---------------------------------------------------

func update_hitbox_offset() -> void:
	var x := hitbox_offset.x
	var y := hitbox_offset.y
	
	match last_direction:
		Vector2.LEFT:
			hitbox.position = Vector2(-x, y)
		Vector2.RIGHT:
			hitbox.position = Vector2(x, y)
		Vector2.UP:
			hitbox.position = Vector2(y, -x)
		Vector2.DOWN:
			hitbox.position = Vector2(-y, x)
	
func _on_hitbox_body_entered(body: Node2D) -> void:
	if is_attacking and body.name.begins_with("Slime"):
		print("Hit")

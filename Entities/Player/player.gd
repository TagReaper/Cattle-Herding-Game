extends CharacterBody2D

# Export Variables
@export var speed: float = 40
@export var acceleration: float = 32
@export var growl_cooldown: float = 10
@export var grown_duration: float = 3
@export var bark_cooldown: float = 20
@export var level_time: float = 30

# Node Variables
@export var GrowlTimer: Timer
@export var GrowlLeftNode: Node2D
@export var GrowlRightNode: Node2D
@export var BarkTimer: Timer
@export var LevelTimer: Timer
@export var RotationPoint: Node2D
@export var TimerDisplay: RichTextLabel

# Internal Variables
const MOVEMENT_MULTIPLIER: float = 16
var current_state: int
var direction: Vector2 = Vector2.ZERO
var friction: float = 1

enum State {
	IDLE,
	RUN,
	GROWL,
	BARK
}

func _ready() -> void:
	LevelTimer.start(level_time)

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	# State Check
	if current_state != State.BARK:
		direction.x = Input.get_axis("MoveLeft", "MoveRight")
		direction.y = Input.get_axis("MoveUp", "MoveDown")
		direction = direction.normalized()
		direction = snapped(direction, Vector2(0.001,0.001))
		
		if current_state == State.GROWL:
			direction /= 2
		
		if direction != Vector2.ZERO:
			velocity.x = move_toward(velocity.x, direction.x * speed * MOVEMENT_MULTIPLIER, acceleration * friction)
			velocity.y = move_toward(velocity.y, direction.y * speed * MOVEMENT_MULTIPLIER, acceleration * friction)
			if current_state != State.GROWL:
				current_state = State.RUN
		else:
			velocity.x = move_toward(velocity.x, 0, acceleration * friction)
			velocity.y = move_toward(velocity.y, 0, acceleration * friction)
			if current_state != State.IDLE:
				current_state = State.RUN
	
	var time_left = LevelTimer.time_left
	TimerDisplay.text = "%02d:%02d" % [int(time_left), int((time_left - int(time_left))*100)]
	
	_animation_check()
	move_and_slide()

# Depends on sprites
#func _flip_check() -> void:
	#pass

# Add when Sprites added
func _animation_check() -> void:
	match direction:
		Vector2(1,0):              # R-Facing
			RotationPoint.rotation_degrees = 90
		#Vector2(0.707,-0.707):     # UR-Facing
			#RotationPoint.rotation_degrees = 45
		Vector2(0,-1):             # U-Facing
			RotationPoint.rotation_degrees = 0
		#Vector2(-0.707,-0.707):    # UL-Facing
			#RotationPoint.rotation_degrees = 315
		Vector2(-1,0):             # L-Facing
			RotationPoint.rotation_degrees = 270
		#Vector2(-0.707,0.707):     # DL-Facing
			#RotationPoint.rotation_degrees = 225
		Vector2(0, 1):             # D-Facing
			RotationPoint.rotation_degrees = 180
		#Vector2(0.707,0.707):      # DR-Facing
			#RotationPoint.rotation_degrees = 135

# Gets the flee direction based on what state the player is in
func _get_flee_direction(_location: Vector2) -> Vector2:
	var returnVector = Vector2.ZERO
	match current_state:
		State.GROWL: # Run Perpendicular to the Growl Line
			return returnVector.normalized()
		State.BARK: # Run to the pen
			return returnVector.normalized()
		_:
			returnVector = _location - global_position
			return returnVector.normalized()

# Makes Cows run away from the line in the center of the growl area
func _growl() -> void:
	if GrowlTimer.is_stopped():
		print("GRRRR")
		await get_tree().create_timer(grown_duration).timeout
		GrowlTimer.start(growl_cooldown)

# Makes the cows in the bark area run to the pen
func _bark() -> void:
	pass

# Reset the level on timeout
func _on_level_timer_timeout() -> void:
	get_tree().reload_current_scene()

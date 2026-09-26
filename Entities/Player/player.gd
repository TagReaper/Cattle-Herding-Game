extends CharacterBody2D

# Export Variables
@export var speed: float = 32
@export var acceleration: float = 16
@export var growl_cooldown: float = 10
@export var grown_duration: float = 3
@export var bark_cooldown: float = 20
@export var level_timer: float = 30

# Node Variables
@export var GrowlTimer: Timer
@export var GrowlLeftNode: Node2D
@export var GrowlRightNode: Node2D
@export var BarkTimer: Timer
@export var LevelTimer: Timer

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
	pass

func _physics_process(delta: float) -> void:
	
	# State Check
	if current_state != State.BARK:
		direction.x = Input.get_axis("MoveLeft", "MoveRight")
		direction.y = Input.get_axis("MoveUp", "MoveDown")
		direction = direction.normalized()
		
		if current_state == State.GROWL:
			direction /= 2
		
		if direction != Vector2.ZERO:
			velocity.x = move_toward(velocity.x, speed * MOVEMENT_MULTIPLIER, acceleration * friction)
			velocity.y = move_toward(velocity.y, speed * MOVEMENT_MULTIPLIER, acceleration * friction)
			if current_state != State.GROWL:
				current_state = State.RUN
		else:
			velocity.x = move_toward(velocity.x, 0, acceleration * friction)
			velocity.y = move_toward(velocity.y, 0, acceleration * friction)
			if current_state != State.IDLE:
				current_state = State.RUN

# Depends on sprites
#func _flip_check() -> void:
	#pass

# Add when Sprites added
#func _animation_check() -> void:
	#pass

# Gets the flee direction based on what state the player is in
func _get_flee_direction() -> Vector2:
	match current_state:
		State.GROWL: # Run Perpendicular to the Growl Line
			return Vector2.ZERO
		State.BARK: # Run to the pen
			return Vector2.ZERO
		_:
			return Vector2.ZERO

# Makes Cows run away from the line in the center of the growl area
func _growl() -> void:
	if GrowlTimer.is_stopped():
		print("GRRRR")
		await get_tree().create_timer(grown_duration).timeout
		GrowlTimer.start(growl_cooldown)

# Makes the cows in the bark area run to the pen
func _bark() -> void:
	pass

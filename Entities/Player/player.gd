extends CharacterBody2D

# Export Variables
@export var speed: float = 32
@export var acceleration: float = 16
@export var growl_cooldown: float = 10
@export var grown_duration: float = 3
@export var bark_cooldown: float = 20
@export var bark_severity: float

# Node Variables
@export var GrowlTimer: Timer
@export var GrowlLeftNode: Node2D
@export var GrowlRightNode: Node2D
@export var BarkTimer: Timer

# Internal Variables
var current_state: int

enum State {
	IDLE,
	WALK,
	RUN,
	GROWL,
	BARK
}

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	pass

# Depends on sprites
#func _flip_check() -> void:
	#pass

func _animation_check() -> void:
	pass

# Makes Cows run away from the line in the center of the growl area
func _growl() -> void:
	pass

# Gets the flee direction based on what state the player is in
func _get_flee_direction() -> void:
	match current_state:
		State.IDLE, State.WALK, State.RUN: # Run away from the player
			pass
		State.GROWL: # Run Perpendicular to the Growl Line
			pass
		State.BARK: # Run to the pen
			pass

# Makes the cows in the bark area run to the pen
func _bark() -> void:
	pass

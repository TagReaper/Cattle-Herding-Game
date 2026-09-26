extends CharacterBody2D

# Export Variables
@export var speed: float = 40
@export var acceleration: float = 32
@export var alert_time: float = 30
@export var movement_time: float = 0.5
@export var fear_distance: float = 150

# Node Variables
@export var AlertTimer: Timer
@export var UpCast: RayCast2D
@export var RightCast: RayCast2D
@export var DownCast: RayCast2D
@export var LeftCast: RayCast2D
@export var AlertIcon: Sprite2D
@export var MovementCooldown: Timer

# Internal Variables
const MOVEMENT_MULTIPLIER: float = 16
var current_state: int
var direction: Vector2 = Vector2.ZERO
var friction: float = 1
var player: CharacterBody2D

enum State {
	IDLE,
	ALERT,
	RUN
}

func _ready() -> void:
	current_state = State.IDLE
	AlertIcon.modulate.a = 0

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	if player == null:
		player = get_parent().get_child(0)
	
	if global_position.distance_to(player.global_position) < fear_distance:
		if current_state == State.IDLE:
			current_state = State.ALERT
			_alert()
		else:
			AlertTimer.start(alert_time)
			direction = player._get_flee_direction(global_position)
	
	if MovementCooldown.is_stopped() and current_state == State.RUN:
		var Up: bool = UpCast.is_colliding()
		var Down: bool = DownCast.is_colliding()
		var Left: bool = LeftCast.is_colliding()
		var Right: bool = RightCast.is_colliding()
		
		if Up and Down:
			direction = Vector2(direction.x, 0)
		elif Up or Down:
			direction = Vector2(direction.x, sign(-direction.y) * 0.5)
		if Right and Left:
			direction = Vector2(0, direction.y)
		elif Right or Left:
			direction = Vector2(sign(-direction.x) * 0.5, direction.y)
		
		if Up or Down or Left or Right:
			var time = AlertTimer.time_left
			AlertTimer.start(time + movement_time/2)
			MovementCooldown.start(0.5)
	elif current_state == State.IDLE:
		direction = Vector2.ZERO
	
	direction = direction.normalized()
	
	velocity.x = move_toward(velocity.x, speed * direction.x * MOVEMENT_MULTIPLIER, acceleration * friction)
	velocity.y = move_toward(velocity.y, speed * direction.y * MOVEMENT_MULTIPLIER, acceleration * friction)
	
	_animation_check()
	move_and_slide()

func _alert():
	current_state = State.ALERT
	var tween = create_tween().set_parallel(true)
	tween.tween_property(AlertIcon, "modulate:a", 1, 0.2)
	tween.tween_property(AlertIcon, "scale", Vector2(0.1,0.1), 0.2)
	await get_tree().create_timer(0.5).timeout
	AlertTimer.start(alert_time)
	current_state = State.RUN

func _animation_check() -> void:
	if current_state == State.RUN:
		var angle_deg = atan2(direction.y, direction.x) * (180/PI)
		
		if angle_deg <= 45 and angle_deg >= -45: # R
			pass
		elif angle_deg < 135 and angle_deg > 45: # U
			pass
		elif angle_deg < -45 and angle_deg > -135: # D
			pass
		else: # L
			pass

func _on_alert_timeout() -> void:
	var tween = create_tween().set_parallel(true)
	tween.tween_property(AlertIcon, "modulate:a", 0, 0.2)
	tween.tween_property(AlertIcon, "scale", Vector2.ZERO, 0.2)
	current_state = State.IDLE

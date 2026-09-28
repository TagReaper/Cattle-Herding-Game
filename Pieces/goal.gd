extends Area2D

@export var player: CharacterBody2D
@export var sheep_total: int
var sheep_saved: int
var sheep_lost: int
var level_complete: bool = false
var stars: int = 0

func  _ready() -> void:
	if player == null:
		player = get_parent().get_child(2).get_child(0)

func _on_body_entered(body: Node2D) -> void:
	if body.name.contains("Sheep"):
		body.calmed = true
		body.set_collision_mask_value(4, true)
		sheep_saved += 1

@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:
	if !level_complete:
		if sheep_lost > 3 or player.LevelTimer.time_left == 0:
			# You Lose
			print("You Lose :(")
			get_tree().paused = true
			level_complete = true
			await get_tree().create_timer(2).timeout
			get_tree().reload_current_scene()
		elif sheep_saved == sheep_total - sheep_lost:
			# You Win
			print("You Win!")
			print(sheep_saved, "/", sheep_total)
			get_tree().paused = true
			level_complete = true
			await get_tree().create_timer(2).timeout
			get_tree().reload_current_scene()

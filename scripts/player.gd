extends CharacterBody2D

@export var speed: float = 80.0
@export var max_health: int = 10

var health: int = max_health
var is_attacking: bool = false
var last_direction: Vector2 = Vector2.DOWN
var ataque = 10


@onready var sprite: Sprite2D = $Sprite2D
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var area_attack: Area2D = $AreaAttack

func _physics_process(_delta: float) -> void:
	if is_attacking:
		velocity = Vector2.ZERO
	else:
		get_input()
	
	move_and_slide()
	animate()

func get_input():
	var x_input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var y_input = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	# Impede que o jogador se mova na diagonal
	if abs(x_input) > 0 and abs(y_input) > 0:
		if Input.is_action_pressed("move_up") or Input.is_action_pressed("move_down"):
			x_input = 0
		else:
			y_input = 0

	var input_vector = Vector2(x_input, y_input).normalized()
	velocity = input_vector * speed

	if input_vector != Vector2.ZERO:
		last_direction = input_vector
	
	if Input.is_action_just_pressed("attack") and not is_attacking:
		start_attack()

func start_attack():
	is_attacking = true
	velocity = Vector2.ZERO

	anim_sprite.visible = false
	sprite.visible = true
	
	match last_direction:
		Vector2.UP:
			anim_player.play("SlashBack")
		Vector2.DOWN:
			anim_player.play("SlashFront")
		Vector2.LEFT:
			anim_player.play("SlashLeft")
		Vector2.RIGHT:
			anim_player.play("SlashRight")
		_:
			anim_player.play("SlashFront")

func _on_animation_finished(anim_name):
	if anim_name.begins_with("Slash"):
		is_attacking = false
		sprite.visible = false
		anim_sprite.visible = true

func animate():
	if is_attacking:
		return

	if velocity == Vector2.ZERO:
		match last_direction:
			Vector2.UP:
				anim_sprite.play("idleBack")
			Vector2.DOWN:
				anim_sprite.play("idleFront")
			Vector2.LEFT:
				anim_sprite.play("idleLeft")
			Vector2.RIGHT:
				anim_sprite.play("idleRight")
	else:
		var dir = velocity.normalized()
		if abs(dir.x) > abs(dir.y):
			anim_sprite.play("walkRight" if dir.x > 0 else "walkLeft")
		else:
			anim_sprite.play("walkFront" if dir.y > 0 else "walkBack")

func take_damage(amount: int):
	if health <= 0:
		return

	health -= amount
	emit_signal("health_changed", health)

	if health <= 0:
		die()

func die():
	anim_sprite.play("Die")
	set_process(false)
	set_physics_process(false)

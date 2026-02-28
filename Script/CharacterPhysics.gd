extends CharacterBody2D

# --- Movement ---
const SPEED = 250
const JUMP_FORCE = -420
const GRAVITY = 900
const COYOTE_TIME = 0.15
const DECELERATION = 1500

# --- State ---
var coyote_timer := 0.0
var attacking := false
var dead := false
var attack_step := 1

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	sprite.play("Idle")


func _physics_process(delta):
	if dead:
		return

	# --- Gravity ---
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		coyote_timer -= delta
	else:
		coyote_timer = COYOTE_TIME

	# --- Horizontal movement ---
	var dir := Input.get_axis("ui_left", "ui_right")
	if dir != 0 and not attacking:
		velocity.x = dir * SPEED
		sprite.flip_h = dir < 0
	else:
		velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)

	# --- Jump ---
	if Input.is_action_just_pressed("ui_accept") and coyote_timer > 0 and not attacking:
		velocity.y = JUMP_FORCE
		coyote_timer = 0

	# --- Attack ---
	if Input.is_action_just_pressed("ui_attack") and not attacking:
		start_attack()

	move_and_slide()

	update_animation()


func update_animation():
	if dead or attacking:
		return

	if not is_on_floor():
		play_anim("Jump")
	elif abs(velocity.x) > 5:
		play_anim("Run")
	else:
		play_anim("Idle")


func play_anim(anim: String):
	if sprite.animation != anim:
		sprite.play(anim)


func start_attack():
	attacking = true
	velocity.x = 0

	# Cycle attacks 1 → 2 → 3
	sprite.play("Attack" + str(attack_step))
	attack_step += 1
	if attack_step > 3:
		attack_step = 1

	# Wait for animation to finish
	await sprite.animation_finished
	attacking = false


func die():
	dead = true
	velocity = Vector2.ZERO
	sprite.play("Death")

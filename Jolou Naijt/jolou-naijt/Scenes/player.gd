extends CharacterBody2D

const SPEED = 500
const JUMP_VELOCITY = -700.0
const GRAVITY = 900.0
const MIN_JUMP_VELOCITY = -350.0
const DASH_SPEED = 1300.0
const DASH_DURATION = 0.2  # Duración del dash en segundos
const ATTACK_COOLDOWN = 0.5  # Enfriamiento del ataque en segundos

var is_moving = false
var jump_state = "idle"  # Estados de salto: "idle", "prejump", "jump", "land"
var dash_state = false  # Estado del dash
var dash_timer = 0.0
var has_air_dashed = false  # Control del dash en el aire
var is_attacking = false  # Indica si el personaje está realizando un ataque
var attack_timer = 0.0  # Control del enfriamiento de ataque

func _ready():
	$AnimatedSprite2D.frame_changed.connect(_on_frame_changed)

func _physics_process(delta: float) -> void:
	# Gestionar el temporizador de enfriamiento de ataque
	if attack_timer > 0:
		attack_timer -= delta

	# Gestionar el dash
	if dash_state:
		dash_timer -= delta
		velocity.y = 0  # Eliminar efecto de gravedad durante el dash
		move_and_slide()
		if dash_timer <= 0:
			dash_state = false
			if not is_on_floor():
				$AnimatedSprite2D.play("recover_dash")
			else:
				jump_state = "idle"
				$AnimatedSprite2D.play("idle")
		return

	# Manejar ataques
	
		  # Animación cuando termina el ataque en el aire

	# Aplicar gravedad si el personaje no está en el suelo
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0
		has_air_dashed = false  # Resetear el dash cuando toca el suelo

	# Manejar el salto
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump_state = "prejump"
		$AnimatedSprite2D.play("prejump")

	if Input.is_action_pressed("ui_down") and not is_on_floor():
		velocity.y += GRAVITY * 8 * delta

	# Controlar salto variable
	if Input.is_action_just_released("ui_up") and velocity.y < 0:
		velocity.y = max(velocity.y, MIN_JUMP_VELOCITY)

	# Manejar el dash
	if Input.is_action_just_pressed("ui_accept") and not dash_state:
		if not is_on_floor() and not has_air_dashed:
			has_air_dashed = true
			iniciar_dash()
		elif is_on_floor():
			iniciar_dash()

	# Controlar el movimiento horizontal
	is_moving = false
	if not dash_state:
		if Input.is_action_pressed("ui_right"):
			velocity.x = SPEED
			$AnimatedSprite2D.flip_h = true
			is_moving = true
			if is_on_floor() and jump_state == "idle":
				$AnimatedSprite2D.play("walk")
		elif Input.is_action_pressed("ui_left"):
			velocity.x = -SPEED
			$AnimatedSprite2D.flip_h = false
			is_moving = true
			if is_on_floor() and jump_state == "idle":
				$AnimatedSprite2D.play("walk")
		else:
			velocity.x = 0

	# Controlar animaciones de quietud
	if is_on_floor() and not is_moving and jump_state == "idle" :
		$AnimatedSprite2D.play("idle")

	# Aplicar movimiento
	move_and_slide()

func iniciar_dash():
	dash_state = true
	jump_state = "dash"
	dash_timer = DASH_DURATION
	$AnimatedSprite2D.play("dash")
	velocity.x = DASH_SPEED if $AnimatedSprite2D.flip_h else -DASH_SPEED

func _on_frame_changed():
	# Detectar el final de las animaciones y pasar a la siguiente
	if $AnimatedSprite2D.animation == "prejump" and $AnimatedSprite2D.frame == $AnimatedSprite2D.sprite_frames.get_frame_count("prejump") - 1:
		jump_state = "jump"
		$AnimatedSprite2D.play("jump")
	elif $AnimatedSprite2D.animation == "jump" and is_on_floor():
		jump_state = "idle"
		$AnimatedSprite2D.play("land")
	elif $AnimatedSprite2D.animation == "land" and $AnimatedSprite2D.frame == $AnimatedSprite2D.sprite_frames.get_frame_count("land") - 1:
		jump_state = "idle"
	elif $AnimatedSprite2D.animation == "recover_dash" and $AnimatedSprite2D.frame == $AnimatedSprite2D.sprite_frames.get_frame_count("recover_dash") - 1:
		if is_on_floor():
			jump_state = "idle"
			$AnimatedSprite2D.play("idle")

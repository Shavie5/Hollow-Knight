extends CharacterBody2D

# Variables de configuración
var player_detection
var collision_area
var target
var progress_bar
var you_won_label
var you_lost_label  # Referencia al Label
const SPEED = 1
var end = false
var can_follow = true 
var title
const DASH_SPEED = 1000
const DASH_DURATION = 0.4  # Duración del dash en segundos
var lose = false
var dash_state = false  # Estado del dash
var dash_timer = 0.0
var is_target_in_area = false  # Controla si el jugador está dentro del área

func _ready():
	# Busca el nodo objetivo (EscenaB) en la escena principal
	target = get_parent().get_node("Player")
	progress_bar = get_node("UI/ProgressBar")
	you_won_label = get_node("UI/YouWon")  # Suponiendo que el Label se llama YouWonLabel
	you_won_label.visible = false # Ocultar el Label al inicio
	you_lost_label = get_node("UI/YouLost")
	you_lost_label.visible = false
	title = get_node("UI/ProgressBar/Label")
	# Obtener la referencia al Area2D de detección
	player_detection = $PlayerDetection  # Suponiendo que el nodo de colisión se llama PlayerDetection
	collision_area = $Area2D
	# Conectar las señales 'body_entered' y 'body_exited' para detectar cuando el Player entra o sale del área
	player_detection.connect("body_entered", Callable(self, "_on_player_detection_body_entered"))
	player_detection.connect("body_exited", Callable(self, "_on_body_exited"))
	collision_area.connect("body_entered", Callable(self, "_on_collision_area_body_entered_damage"))
	# Crear un temporizador para controlar los dashes
	var dash_timer_node = Timer.new()
	dash_timer_node.wait_time = 2.0  # Tiempo de 2 segundos entre dashes
	dash_timer_node.one_shot = false
	add_child(dash_timer_node)
	dash_timer_node.start()
	dash_timer_node.timeout.connect(_on_dash_timer_timeout)
	
	# Crear un temporizador para reducir la barra de progreso
	var progress_timer = Timer.new()
	progress_timer.wait_time = 0.5  # Cada segundo
	progress_timer.one_shot = false
	add_child(progress_timer)
	progress_timer.start()
	progress_timer.timeout.connect(_on_progress_timer_timeout)

func _physics_process(delta: float) -> void:
	# Aplicar la gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()

func _process(delta):
	if target:
		var direction = target.global_position.x - global_position.x
		
		# Si el seguidor puede seguir
		if can_follow and not dash_state:
			$AnimatedSprite2D.play("walk")
			global_position.x = lerp(global_position.x, target.global_position.x, SPEED * delta)
		elif not dash_state:
			$AnimatedSprite2D.play("idle")
		
		# Cambiar la dirección de la animación dependiendo de la posición del Player
		if direction > 0:  # El Player está a la derecha
			$AnimatedSprite2D.flip_h = false  # No voltear el sprite
		elif direction < 0:  # El Player está a la izquierda
			$AnimatedSprite2D.flip_h = true  # Voltear el sprite

# Método que se llama cuando el Player entra en el área de detección
func _on_player_detection_body_entered(body: Node2D) -> void:
	if body.name == "Player":  # Verifica si el cuerpo tocado es el Player
		is_target_in_area = true  # El jugador está en el área
		can_follow = false  # Detener el seguimiento normal

# Método que se llama cuando el Player sale del área de detección
func _on_body_exited(body):
	if body.name == "Player":  # Verifica si el cuerpo que salió es el Player
		is_target_in_area = false  # El jugador salió del área
		can_follow = true  # Vuelve a seguir al Player normalmente

# Función que se ejecuta cada 2 segundos
func _on_dash_timer_timeout():
	if is_target_in_area and not dash_state:
		iniciar_dash()

func iniciar_dash():
	dash_state = true
	dash_timer = DASH_DURATION
	$AnimatedSprite2D.play("attack")

	# Determinar la dirección del dash hacia el jugador
	if target:
		var direction = target.global_position.x - global_position.x
		velocity.x = DASH_SPEED * sign(direction)
	else:
		velocity.x = 0

	# Iniciar un temporizador para terminar el dash
	var dash_end_timer = Timer.new()
	dash_end_timer.wait_time = DASH_DURATION
	dash_end_timer.one_shot = true
	add_child(dash_end_timer)
	dash_end_timer.start()
	dash_end_timer.timeout.connect(_on_dash_end_timer_timeout)

func _on_dash_end_timer_timeout():
	dash_state = false
	velocity.x = 0
	if is_on_floor():
		$AnimatedSprite2D.play("idle")
	else:
		$AnimatedSprite2D.play("jump")

# Función que se ejecuta cada segundo para reducir la barra de progreso
func _on_progress_timer_timeout():
	if progress_bar.value > 0:
		progress_bar.value -= 5  # Reducir un 1%
	else:
		progress_bar.value = 0  # Asegurarse de que no sea menor que 0
		if lose == false and end == false:
			you_won_label.visible = true  # Mostrar el mensaje "You won!"
			target.hide()
			hide()
			end = true
			



func _on_collision_area_body_entered_damage(body: Node):
	if body == target and end == false:  # Verifica si el objeto que entró es el jugador
		lose = true
		you_lost_label.visible = true  # Mostrar el Label
		progress_bar.hide()
		title.hide()
		target.hide()
		hide()
		you_won_label.hide()
		end = true

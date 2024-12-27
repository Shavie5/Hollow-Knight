extends Area2D

func _ready():
	# Asegúrate de que las señales estén conectadas
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	# Verifica si el cuerpo que entra es el objetivo
	if body.name == "Player":
		print("El objetivo ha entrado en el rango.")
		# Busca el seguidor y desactiva su seguimiento
		var seguidor = get_parent().get_node("./Boss")
		if seguidor:
			seguidor.can_follow = false

func _on_body_exited(body):
	# Verifica si el cuerpo que sale es el objetivo
	if body.name == "Player":
		print("El objetivo ha salido del rango.")
		# Busca el seguidor y activa su seguimiento
		var seguidor = get_parent().get_node("./Boss")
		if seguidor:
			seguidor.can_follow = true

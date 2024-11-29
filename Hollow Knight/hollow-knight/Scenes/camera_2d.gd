extends Camera2D

# El nodo del personaje que la cámara seguirá
@export var player: Node2D

# Posición fija en el eje Y para la cámara
@export var fixed_y_position: float = 200  # Ajusta según necesites

func _process(delta: float):
	if player:
		# Actualiza solo la posición horizontal (x)
		global_position.x = player.global_position.x
		# Fija la posición vertical (y)
		global_position.y = fixed_y_position

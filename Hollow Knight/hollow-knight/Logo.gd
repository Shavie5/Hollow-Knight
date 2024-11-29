extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	# Obtén el tamaño de la ventana de la escena actual
	var viewport_size = get_viewport_rect().size
	
	# Ajusta la posición del Sprite al centro en X
	position.x = viewport_size.x / 2

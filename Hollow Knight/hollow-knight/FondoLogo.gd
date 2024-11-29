extends Sprite2D


func _ready():
	# Obtener el tamaño de la ventana
	var viewport_size = get_viewport_rect().size

	# Obtener el tamaño de la textura
	if texture:
		var texture_size = texture.get_size()

		# Ajustar la escala del Sprite
		scale.x = viewport_size.x / texture_size.x
		scale.y = viewport_size.y / texture_size.y

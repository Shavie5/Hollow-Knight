extends Label

var blink_time = 0.5  # Tiempo en segundos para parpadear
var timer = 0.0       # Temporizador acumulado

func _process(delta):
	timer += delta
	if timer >= blink_time:
		# Alterna la visibilidad y reinicia el temporizador
		visible = !visible
		timer = 0.0

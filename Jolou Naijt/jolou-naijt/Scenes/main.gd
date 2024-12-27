extends Node

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	if Input.is_key_pressed(KEY_R):
		restart_game()
func restart_game():
	# Recargar la escena actual (reiniciar la partida)
	get_tree().reload_current_scene()

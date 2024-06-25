extends Node2D

func _ready():
	setTransparentBackground()
	
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

func setTransparentBackground():
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_TRANSPARENT, true)
	get_tree().get_root().set_transparent_background(true)

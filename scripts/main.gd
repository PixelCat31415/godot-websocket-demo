extends Node


func _ready() -> void:
	for i in range(2):
		var ws = WebSocketServer.register_connection()
		var panel = preload("res://scenes/WebSocketPanel.tscn").instantiate()
		panel.link(ws)
		$HBoxContainer/VBoxContainer.add_child(panel)
		%Game.add_socket_player(ws)
	%Game.add_human_player()


func _process(_delta: float) -> void:
	$HBoxContainer/VBoxContainer/Panel/FpsCounter.text = "FPS: %f" % Engine.get_frames_per_second()
	if Input.is_action_pressed("ui_cancel"):
		WebSocketServer.stop()
		get_tree().quit()

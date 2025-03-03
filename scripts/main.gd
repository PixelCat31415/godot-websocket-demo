extends Node


const websocket_panel = preload("res://scenes/WebSocketPanel.tscn")


func _ready() -> void:
    for i in range(2):
        var ws = WebSocketServer.get_instance().register_connection()
        var panel = websocket_panel.instantiate()
        panel.link(ws)
        $HBoxContainer/VBoxContainer.add_child(panel)
        %Game.add_socket_player(ws)
    %Game.add_human_player()


func _process(_delta: float) -> void:
    $HBoxContainer/VBoxContainer/Panel/FpsCounter.text = "FPS: %f" % Engine.get_frames_per_second()
    if Input.is_action_pressed("ui_cancel"):
        WebSocketServer.get_instance().stop()
        get_tree().quit()

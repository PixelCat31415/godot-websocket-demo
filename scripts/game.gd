extends Node2D


const player_scene = preload("res://scenes/Entities/Player.tscn")
const human_player_script = preload("res://scripts/player/human_player.gd")
const socket_player_script = preload("res://scripts/player/socket_player.gd")

func add_human_player() -> Player:
    var player = player_scene.instantiate()
    player.set_script(human_player_script)
    player.position = Vector2(300, 300)
    add_child(player)
    return player

func add_socket_player(ws: WebSocketConnection) -> Player:
    var player = player_scene.instantiate()
    player.set_script(socket_player_script)
    player.link(ws)
    player.position = Vector2(300, 300)
    add_child(player)
    return player

func _ready() -> void:
    pass

func _process(_delta: float) -> void:
    pass

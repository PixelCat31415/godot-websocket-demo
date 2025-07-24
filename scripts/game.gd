extends Node2D


const PLAYER_SCENE = preload("res://scenes/Entities/Player.tscn")
const HUMEN_PLAYER_SCRIPT = preload("res://scripts/player/human_player.gd")
const SOCKET_PLAYER_SCRIPT = preload("res://scripts/player/socket_player.gd")

func add_human_player() -> Player:
    var player = PLAYER_SCENE.instantiate()
    player.set_script(HUMEN_PLAYER_SCRIPT)
    player.position = Vector2(300, 300)
    add_child(player)
    return player

func add_socket_player(ws: WebSocketConnection) -> Player:
    var player = PLAYER_SCENE.instantiate()
    player.set_script(SOCKET_PLAYER_SCRIPT)
    player.link(ws)
    player.position = Vector2(300, 300)
    add_child(player)
    return player

func _ready() -> void:
    pass

func _process(_delta: float) -> void:
    pass

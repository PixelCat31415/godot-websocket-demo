class_name WebSocketConnection
extends Node


signal received_text(msg: String)
signal received_bytes(pkt: PackedByteArray)
signal client_connected()
signal client_disconnected()

const TOKEN_LEN: int = 4

static var connection_id_counter = 101
var id: int
var token: String
var socket: WebSocketPeer


func _init() -> void:
	id = connection_id_counter
	connection_id_counter += 1
	token = _generate_token()
	socket = null
	add_to_group("websocket_connections")

func authenticate(token_: String) -> bool:
	return token_ == token

func connect_to_socket(socket_: WebSocketPeer) -> void:
	socket = socket_
	client_connected.emit()

func disconnect_from_socket() -> void:
	if socket != null:
		var state = socket.get_ready_state()
		if state != WebSocketPeer.STATE_CLOSING \
			and state != WebSocketPeer.STATE_CLOSED:
			socket.close()
		if state == WebSocketPeer.STATE_CLOSED:
			socket = null
			client_disconnected.emit()

func is_client_connected() -> bool:
	return socket != null

func send_text(msg: String) -> Error:
	if socket == null:
		return ERR_UNAVAILABLE
	return socket.send_text(msg)

func send_bytes(pkt: PackedByteArray) -> Error:
	if socket == null:
		return ERR_UNAVAILABLE
	return socket.send(pkt)

func _get_message() -> Variant:
	if !_has_message():
		return null
	var pkt: PackedByteArray = socket.get_packet()
	if socket.was_string_packet():
		return pkt.get_string_from_utf8()
	return pkt

func _has_message() -> bool:
	return socket != null and socket.get_available_packet_count() > 0

func _poll() -> void:
	if socket == null:
		return
	socket.poll()
	if socket.get_ready_state() != WebSocketPeer.STATE_OPEN:
		disconnect_from_socket()
		return
	while _has_message():
		var recv = _get_message()
		if typeof(recv) == TYPE_STRING:
			received_text.emit(recv)
		elif typeof(recv) == TYPE_PACKED_BYTE_ARRAY:
			received_bytes.emit(recv)

func _process(_delta: float) -> void:
	_poll()


func _generate_token() -> String:
	const characters: String = 'abcdefghijklmnopqrstuvwxyz'
	var tok: String = ""
	for i in range(TOKEN_LEN):
		tok += characters[randi_range(0, characters.length() - 1)]
	return tok


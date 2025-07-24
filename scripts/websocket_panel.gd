extends Control

var ws: WebSocketConnection = null

@onready var _name_label: Label = $Panel/VBoxContainer/Name
@onready var _status_label: Label = $Panel/VBoxContainer/Status
@onready var _log_area: RichTextLabel = $Panel/VBoxContainer/Log
@onready var _announcement_edit: TextEdit = $Panel/VBoxContainer/AnnouncementEdit

func link(_ws: WebSocketConnection) -> void:
    ws = _ws
    ws.client_connected.connect(_on_client_connected)
    ws.client_disconnected.connect(_on_client_disconnected)
    ws.received_text.connect(_on_received_message)
    ws.received_bytes.connect(_on_received_message)

func unlink() -> void:
    ws.client_connected.disconnect(_on_client_connected)
    ws.client_disconnected.disconnect(_on_client_disconnected)
    ws.received_text.disconnect(_on_received_message)
    ws.received_bytes.disconnect(_on_received_message)
    ws = null


func _log(fmt: String, values: Variant = null) -> void:
    if values != null:
        fmt = fmt.format(values)
    _log_area.text += "[%s]\n%s\n" % [Time.get_time_string_from_system(), fmt]

func _send_message(msg: Variant) -> void:
    if not ws.is_client_connected():
        _log("Message not sent (client disconnected): {msg}", {"msg": msg})
        return
    if typeof(msg) == TYPE_STRING:
        ws.send_text(msg)
    else:
        ws.send_bytes(var_to_bytes(msg))
    _log("Sent message: {msg}", {"msg": str(msg)})

func _on_received_message(_msg: Variant) -> void:
    pass
    # _log("Recieved message: {msg}", {"msg": str(msg)})
    # if typeof(msg) == TYPE_STRING:
    #     ws.send_text("server: ok string=%d" % msg.length())
    # else:
    #     ws.send_text("server: ok bytes=%d" % msg.size())

func _on_client_connected() -> void:
    _log("Client connected")

func _on_client_disconnected() -> void:
    _log("Client disconnected")

func _on_announce() -> void:
    if _announcement_edit.text.is_empty():
        return
    _send_message(_announcement_edit.text)
    _announcement_edit.text = ""

func _on_clear_output() -> void:
    _log_area.text = ""


func _ready() -> void:
    _log_area.scroll_following = true

func _process(_delta: float) -> void:
    if ws == null:
        _status_label.text = "Status: No Socket"
        _status_label.remove_theme_color_override("font_color")
    elif ws.is_client_connected():
        _status_label.text = "Status: Connected"
        _status_label.add_theme_color_override("font_color", Color(0, 1, 0))
    else:
        _status_label.text = "Status: Disconnected"
        _status_label.add_theme_color_override("font_color", Color(1, 0, 0))

    if ws != null:
        _name_label.text = "WebSocket ID = {id}, token = {token}" \
            .format({"id": ws.id, "token": ws.token})
    else:
        _name_label.text = "WebSocket"

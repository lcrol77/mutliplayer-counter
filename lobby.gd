extends Control

@export var port = 3000

@onready var address: LineEdit = $Address
@onready var host_button: Button = $HostButton
@onready var join_button: Button = $JoinButton
@onready var status_ok: Label = $StatusOk
@onready var status_fail: Label = $StatusFail

var peer: ENetMultiplayerPeer

func _ready() -> void:
	# Connect all the callbacks related to networking
	multiplayer.peer_connected.connect(_player_connected)
	multiplayer.peer_disconnected.connect(_player_disconnected)
	multiplayer.connected_to_server.connect(_connected_ok)
	multiplayer.connection_failed.connect(_connected_fail)
	multiplayer.server_disconnected.connect(_server_disconnected)

#region Network callbacks from SceneTree
func _player_connected(_id: int)-> void: 
	var counter: Control = load("res://counter.tscn").instantiate()
	# Connect deferred so we can safely erase it from the callback.
	counter.game_finished.connect(_end_game, CONNECT_DEFERRED)
	get_tree().get_root().add_child(counter)
	hide()

func _player_disconnected(_id: int)-> void: 
	if multiplayer.is_server():
		_end_game("Client disconnected.")
	else:
		_end_game("Server disconnected.")

func _connected_ok()-> void:
	pass

func _connected_fail()-> void:
	_set_status("Couldn't connect.", false)

	multiplayer.set_multiplayer_peer(null)  # Remove peer.
	host_button.set_disabled(false)
	join_button.set_disabled(false)

func _server_disconnected()-> void:
	_end_game("Server disconnected.")
#endregion

#region Game initialization methods
func _end_game(with_error: String="") -> void:
	if has_node("/root/Counter"):
		# Erase immediately, otherwise network might show
		# errors (this is why we connected deferred above).
		get_node(^"/root/Counter").free()
		show()

	multiplayer.set_multiplayer_peer(null)  # Remove peer.
	host_button.set_disabled(false)
	join_button.set_disabled(false)

	_set_status(with_error, false)
	
func _set_status(text: String, is_ok: bool) -> void:
	if is_ok:
		status_ok.set_text(text)
		status_fail.set_text("")
	else:
		status_ok.set_text("")
		status_fail.set_text(text)
		
func _on_host_pressed() -> void:
	peer = ENetMultiplayerPeer.new()
	var err := peer.create_server(port)
	if err != OK:
		# Is another server running?
		_set_status("Can't host, address in use.",false)
		return
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)

	multiplayer.set_multiplayer_peer(peer)
	host_button.set_disabled(true)
	join_button.set_disabled(true)
	_set_status("Waiting for player...", true)
	get_window().title = ProjectSettings.get_setting("application/config/name") + ": Server"


func _on_join_pressed() -> void:
	var ip := address.get_text()
	if not ip.is_valid_ip_address():
		_set_status("IP address is invalid.", false)
		return

	peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)

	_set_status("Connecting...", true)
	get_window().title = ProjectSettings.get_setting("application/config/name") + ": Client"
#endregion

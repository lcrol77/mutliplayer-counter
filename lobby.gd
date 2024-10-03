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
	pass

func _player_disconnected(_id: int)-> void: 
	pass

func _connected_ok()-> void:
	pass

func _connected_fail()-> void:
	pass
	
func _server_disconnected()-> void:
	pass
#endregion

#region Game initialization methods
func _end_game(with_error: String="") -> void:
	pass
	
func _set_status(text: String, is_ok: bool) -> void:
	if is_ok:
		status_ok.set_text(text)
		status_fail.set_text("")
	else:
		status_ok.set_text("")
		status_fail.set_text(text)
		
func _on_host_pressed() -> void:
	pass
	
func _on_join_pressed() -> void:
	pass
#endregion

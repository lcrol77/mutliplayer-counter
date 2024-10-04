extends Control
class_name Counter

signal game_finished()

var count := 0

@onready var label: Label = $Panel/Label
@onready var increment: Button = $Panel/increment
@onready var decrement: Button = $Panel/decrement

@rpc("any_peer", "call_local")
func update_score(amt: int)-> void:
	count += amt
	label.set_text(str(count))
	
@rpc("authority", "call_local")
func sync(cnt: int) -> void:
	count = cnt
	label.set_text(str(count))

func _on_increment_pressed() -> void:
	update_score.rpc(1)


func _on_decrement_pressed() -> void:
	update_score.rpc(-1)

extends Node

var selected_toy_id: StringName = &"ball"
var tutorial_dismissed := false


func reset_session() -> void:
	selected_toy_id = &"ball"

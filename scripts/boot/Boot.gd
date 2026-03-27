extends Node


func _ready() -> void:
	GameState.reset_session()
	get_tree().change_scene_to_file("res://scenes/menu/MainMenu.tscn")

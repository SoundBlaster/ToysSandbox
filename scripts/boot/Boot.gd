extends Node


func _ready() -> void:
	GameState.reset_session()
	call_deferred("_go_to_main_menu")


func _go_to_main_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/MainMenu.tscn")

extends Node2D

@onready var back_button: Button = $CanvasLayer/MarginContainer/VBoxContainer/BackButton
@onready var status_label: Label = $CanvasLayer/MarginContainer/VBoxContainer/StatusLabel


func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	status_label.text = "Sandbox shell ready for toy spawning."


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/MainMenu.tscn")

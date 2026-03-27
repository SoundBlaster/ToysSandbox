extends Node

const SAVE_PATH := "user://settings.cfg"

var settings := {
	"music_volume": 0.8,
	"sound_volume": 0.9,
}


func load_settings() -> Dictionary:
	return settings.duplicate(true)


func save_settings(next_settings: Dictionary) -> void:
	settings = next_settings.duplicate(true)

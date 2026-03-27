extends Node

var music_volume := 0.8
var sound_volume := 0.9


func apply_settings(next_music_volume: float, next_sound_volume: float) -> void:
	music_volume = next_music_volume
	sound_volume = next_sound_volume

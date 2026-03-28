extends Node

const SAVE_PATH := "user://settings.cfg"
const AUDIO_SECTION := "audio"
const GAMEPLAY_SECTION := "gameplay"
const DEFAULT_STATE := {
	"music_volume": 0.8,
	"sound_volume": 0.9,
	"selected_toy_id": "ball",
	"tutorial_dismissed": false,
	"unlimited_toys_unlocked": false,
}

var _state: Dictionary = DEFAULT_STATE.duplicate(true)


func load_settings() -> Dictionary:
	var state := load_state()
	return {
		"music_volume": state.get("music_volume", DEFAULT_STATE["music_volume"]),
		"sound_volume": state.get("sound_volume", DEFAULT_STATE["sound_volume"]),
	}


func save_settings(next_settings: Dictionary) -> void:
	update_state(next_settings)


func load_state() -> Dictionary:
	var next_state := DEFAULT_STATE.duplicate(true)
	var config := ConfigFile.new()
	var load_result := config.load(SAVE_PATH)

	if load_result == OK:
		next_state["music_volume"] = _sanitize_volume(
			config.get_value(AUDIO_SECTION, "music_volume", DEFAULT_STATE["music_volume"]),
			float(DEFAULT_STATE["music_volume"])
		)
		next_state["sound_volume"] = _sanitize_volume(
			config.get_value(AUDIO_SECTION, "sound_volume", DEFAULT_STATE["sound_volume"]),
			float(DEFAULT_STATE["sound_volume"])
		)
		next_state["selected_toy_id"] = _sanitize_toy_id(
			config.get_value(GAMEPLAY_SECTION, "selected_toy_id", DEFAULT_STATE["selected_toy_id"])
		)
		next_state["tutorial_dismissed"] = bool(
			config.get_value(GAMEPLAY_SECTION, "tutorial_dismissed", DEFAULT_STATE["tutorial_dismissed"])
		)
		next_state["unlimited_toys_unlocked"] = bool(
			config.get_value(GAMEPLAY_SECTION, "unlimited_toys_unlocked", DEFAULT_STATE["unlimited_toys_unlocked"])
		)
	elif load_result != ERR_FILE_NOT_FOUND:
		push_warning("SaveService: failed to load %s (code %d). Restoring defaults." % [SAVE_PATH, load_result])

	_state = next_state
	_write_state(_state)
	return _state.duplicate(true)


func save_state(next_state: Dictionary) -> void:
	_state = _normalized_state(next_state)
	_write_state(_state)


func update_state(patch: Dictionary) -> Dictionary:
	var merged_state := _state.duplicate(true)
	merged_state.merge(patch, true)
	save_state(merged_state)
	return _state.duplicate(true)


func get_state() -> Dictionary:
	return _state.duplicate(true)


func _normalized_state(source: Dictionary) -> Dictionary:
	var normalized := DEFAULT_STATE.duplicate(true)
	normalized["music_volume"] = _sanitize_volume(
		source.get("music_volume", normalized["music_volume"]),
		float(DEFAULT_STATE["music_volume"])
	)
	normalized["sound_volume"] = _sanitize_volume(
		source.get("sound_volume", normalized["sound_volume"]),
		float(DEFAULT_STATE["sound_volume"])
	)
	normalized["selected_toy_id"] = _sanitize_toy_id(source.get("selected_toy_id", normalized["selected_toy_id"]))
	normalized["tutorial_dismissed"] = bool(source.get("tutorial_dismissed", normalized["tutorial_dismissed"]))
	normalized["unlimited_toys_unlocked"] = bool(
		source.get("unlimited_toys_unlocked", normalized["unlimited_toys_unlocked"])
	)
	return normalized


func _write_state(next_state: Dictionary) -> void:
	var config := ConfigFile.new()
	config.set_value(AUDIO_SECTION, "music_volume", float(next_state.get("music_volume", DEFAULT_STATE["music_volume"])))
	config.set_value(AUDIO_SECTION, "sound_volume", float(next_state.get("sound_volume", DEFAULT_STATE["sound_volume"])))
	config.set_value(GAMEPLAY_SECTION, "selected_toy_id", String(next_state.get("selected_toy_id", DEFAULT_STATE["selected_toy_id"])))
	config.set_value(GAMEPLAY_SECTION, "tutorial_dismissed", bool(next_state.get("tutorial_dismissed", DEFAULT_STATE["tutorial_dismissed"])))
	config.set_value(
		GAMEPLAY_SECTION,
		"unlimited_toys_unlocked",
		bool(next_state.get("unlimited_toys_unlocked", DEFAULT_STATE["unlimited_toys_unlocked"]))
	)
	var save_result := config.save(SAVE_PATH)
	if save_result != OK:
		push_warning("SaveService: failed to save %s (code %d)." % [SAVE_PATH, save_result])


func _sanitize_volume(value: Variant, fallback: float) -> float:
	if value is float or value is int:
		return clampf(float(value), 0.0, 1.0)
	return clampf(fallback, 0.0, 1.0)


func _sanitize_toy_id(value: Variant) -> String:
	if value is StringName:
		return String(value)
	if value is String and not String(value).strip_edges().is_empty():
		return String(value)
	return String(DEFAULT_STATE["selected_toy_id"])

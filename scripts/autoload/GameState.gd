extends Node

signal show_stats_overlay_changed(is_visible: bool)

const DEFAULT_SELECTED_TOY_ID := &"ball"
const DEFAULT_SELECTED_SKIN_ID := &"classic"

var selected_toy_id: StringName = DEFAULT_SELECTED_TOY_ID
var selected_skin_id: StringName = DEFAULT_SELECTED_SKIN_ID
var tutorial_dismissed := false
var unlimited_toys_unlocked := false
var show_stats_overlay := false


func reset_session() -> void:
	selected_toy_id = DEFAULT_SELECTED_TOY_ID
	selected_skin_id = DEFAULT_SELECTED_SKIN_ID
	tutorial_dismissed = false
	unlimited_toys_unlocked = false
	show_stats_overlay = false


func apply_persisted_state(state: Dictionary) -> void:
	var persisted_toy_id := StringName(String(state.get("selected_toy_id", String(DEFAULT_SELECTED_TOY_ID))))
	var persisted_skin_id := StringName(String(state.get("selected_skin_id", String(DEFAULT_SELECTED_SKIN_ID))))
	if String(persisted_toy_id).strip_edges().is_empty():
		persisted_toy_id = DEFAULT_SELECTED_TOY_ID
	if String(persisted_skin_id).strip_edges().is_empty():
		persisted_skin_id = DEFAULT_SELECTED_SKIN_ID

	if ToyCatalog.has_toy(persisted_toy_id):
		selected_toy_id = persisted_toy_id
	else:
		selected_toy_id = DEFAULT_SELECTED_TOY_ID

	if ToyCatalog.has_skin(persisted_skin_id):
		selected_skin_id = persisted_skin_id
	else:
		selected_skin_id = DEFAULT_SELECTED_SKIN_ID

	tutorial_dismissed = bool(state.get("tutorial_dismissed", false))
	unlimited_toys_unlocked = bool(state.get("unlimited_toys_unlocked", false))
	show_stats_overlay = bool(state.get("show_stats_overlay", false))


func set_selected_toy_id(toy_id: StringName, persist: bool = true) -> void:
	if String(toy_id).strip_edges().is_empty():
		selected_toy_id = DEFAULT_SELECTED_TOY_ID
	elif ToyCatalog.has_toy(toy_id):
		selected_toy_id = toy_id
	else:
		selected_toy_id = DEFAULT_SELECTED_TOY_ID

	if persist:
		SaveService.update_state({"selected_toy_id": String(selected_toy_id)})


func set_selected_skin_id(skin_id: StringName, persist: bool = true) -> void:
	if ToyCatalog.has_skin(skin_id):
		selected_skin_id = skin_id
	else:
		selected_skin_id = DEFAULT_SELECTED_SKIN_ID

	if persist:
		SaveService.update_state({"selected_skin_id": String(selected_skin_id)})


func set_tutorial_dismissed(is_dismissed: bool, persist: bool = true) -> void:
	tutorial_dismissed = is_dismissed
	if persist:
		SaveService.update_state({"tutorial_dismissed": tutorial_dismissed})


func set_unlimited_toys_unlocked(is_unlocked: bool, persist: bool = true) -> void:
	unlimited_toys_unlocked = is_unlocked
	if persist:
		SaveService.update_state({"unlimited_toys_unlocked": unlimited_toys_unlocked})


func set_show_stats_overlay(is_visible: bool, persist: bool = true) -> void:
	if show_stats_overlay == is_visible:
		if persist:
			SaveService.update_state({"show_stats_overlay": show_stats_overlay})
		return

	show_stats_overlay = is_visible
	emit_signal("show_stats_overlay_changed", show_stats_overlay)
	if persist:
		SaveService.update_state({"show_stats_overlay": show_stats_overlay})

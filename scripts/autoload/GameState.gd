extends Node

const DEFAULT_SELECTED_TOY_ID := &"ball"

var selected_toy_id: StringName = DEFAULT_SELECTED_TOY_ID
var tutorial_dismissed := false
var unlimited_toys_unlocked := false


func reset_session() -> void:
	selected_toy_id = DEFAULT_SELECTED_TOY_ID
	tutorial_dismissed = false
	unlimited_toys_unlocked = false


func apply_persisted_state(state: Dictionary) -> void:
	var persisted_toy_id := StringName(String(state.get("selected_toy_id", String(DEFAULT_SELECTED_TOY_ID))))
	if String(persisted_toy_id).strip_edges().is_empty():
		persisted_toy_id = DEFAULT_SELECTED_TOY_ID

	if ToyCatalog.has_toy(persisted_toy_id):
		selected_toy_id = persisted_toy_id
	else:
		selected_toy_id = DEFAULT_SELECTED_TOY_ID

	tutorial_dismissed = bool(state.get("tutorial_dismissed", false))
	unlimited_toys_unlocked = bool(state.get("unlimited_toys_unlocked", false))


func set_selected_toy_id(toy_id: StringName, persist: bool = true) -> void:
	if String(toy_id).strip_edges().is_empty():
		selected_toy_id = DEFAULT_SELECTED_TOY_ID
	elif ToyCatalog.has_toy(toy_id):
		selected_toy_id = toy_id
	else:
		selected_toy_id = DEFAULT_SELECTED_TOY_ID

	if persist:
		SaveService.update_state({"selected_toy_id": String(selected_toy_id)})


func set_tutorial_dismissed(is_dismissed: bool, persist: bool = true) -> void:
	tutorial_dismissed = is_dismissed
	if persist:
		SaveService.update_state({"tutorial_dismissed": tutorial_dismissed})


func set_unlimited_toys_unlocked(is_unlocked: bool, persist: bool = true) -> void:
	unlimited_toys_unlocked = is_unlocked
	if persist:
		SaveService.update_state({"unlimited_toys_unlocked": unlimited_toys_unlocked})

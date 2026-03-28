extends Node2D

const TOY_INSTANCE_SCENE := preload("res://scenes/game/ToyInstance.tscn")
const PLAY_AREA_RECT := Rect2(Vector2(72.0, 72.0), Vector2(836.0, 560.0))

@onready var back_button: Button = $CanvasLayer/MarginContainer/HBoxContainer/InfoPanel/BackButton
@onready var status_label: Label = $CanvasLayer/MarginContainer/HBoxContainer/InfoPanel/StatusLabel
@onready var selected_label: Label = $CanvasLayer/MarginContainer/HBoxContainer/InfoPanel/SelectedLabel
@onready var toy_list: ItemList = $CanvasLayer/MarginContainer/HBoxContainer/ShelfPanel/ShelfMargin/ShelfVBox/ToyList
@onready var spawn_root: Node2D = $SpawnedToys

var shelf_toy_ids: Array[StringName] = []


func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	toy_list.item_selected.connect(_on_toy_selected)

	_ensure_selected_toy()
	_build_toy_shelf()
	status_label.text = "Tap or click in the play area to spawn the selected toy."
	_refresh_selected_label()


func _unhandled_input(event: InputEvent) -> void:
	var spawn_position: Variant = _get_spawn_position(event)

	if spawn_position == null:
		return

	_spawn_selected_toy(spawn_position)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/MainMenu.tscn")


func _spawn_selected_toy(spawn_position: Vector2) -> void:
	var toy_id := GameState.selected_toy_id
	var definition := ToyCatalog.get_toy_definition(toy_id)

	if definition.is_empty():
		status_label.text = "Selected toy is missing from the catalog."
		return

	var toy_instance: RigidBody2D = TOY_INSTANCE_SCENE.instantiate()
	var half_extents: Vector2 = definition.get("size", Vector2(72.0, 72.0)) * 0.5
	toy_instance.position = _clamp_to_play_area(spawn_position, half_extents)
	spawn_root.add_child(toy_instance)
	toy_instance.call("configure", definition)

	status_label.text = "Spawned %s using shared toy data." % definition.get("display_name", "Toy")


func _build_toy_shelf() -> void:
	toy_list.clear()
	shelf_toy_ids = ToyCatalog.list_ids()

	for toy_id in shelf_toy_ids:
		var definition := ToyCatalog.get_toy_definition(toy_id)
		toy_list.add_item(String(definition.get("display_name", "Toy")))

	var selected_index := shelf_toy_ids.find(GameState.selected_toy_id)
	if selected_index == -1 and not shelf_toy_ids.is_empty():
		selected_index = 0
		GameState.selected_toy_id = shelf_toy_ids[0]

	if selected_index >= 0:
		toy_list.select(selected_index)


func _on_toy_selected(index: int) -> void:
	if index < 0 or index >= shelf_toy_ids.size():
		return

	GameState.selected_toy_id = shelf_toy_ids[index]
	var definition := ToyCatalog.get_toy_definition(GameState.selected_toy_id)
	status_label.text = "Selected %s from the shelf." % definition.get("display_name", "Toy")
	_refresh_selected_label()


func _ensure_selected_toy() -> void:
	if ToyCatalog.has_toy(GameState.selected_toy_id):
		return

	var available_ids := ToyCatalog.list_ids()
	if available_ids.is_empty():
		GameState.selected_toy_id = &""
		return

	GameState.selected_toy_id = available_ids[0]


func _refresh_selected_label() -> void:
	var definition := ToyCatalog.get_toy_definition(GameState.selected_toy_id)
	selected_label.text = "Selected toy: %s" % definition.get("display_name", "None")


func _get_spawn_position(event: InputEvent) -> Variant:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		return _screen_to_world(event.position)

	if event is InputEventScreenTouch and event.pressed:
		return _screen_to_world(event.position)

	return null


func _screen_to_world(screen_position: Vector2) -> Vector2:
	return get_viewport().get_canvas_transform().affine_inverse() * screen_position


func _clamp_to_play_area(point: Vector2, half_extents: Vector2 = Vector2.ZERO) -> Vector2:
	var min_point := PLAY_AREA_RECT.position + half_extents
	var max_point := PLAY_AREA_RECT.end - half_extents

	return Vector2(
		clampf(point.x, min_point.x, max_point.x),
		clampf(point.y, min_point.y, max_point.y)
	)

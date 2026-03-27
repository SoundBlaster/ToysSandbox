extends Node2D

const TOY_INSTANCE_SCENE := preload("res://scenes/game/ToyInstance.tscn")
const PLAY_AREA_RECT := Rect2(Vector2(72.0, 72.0), Vector2(1136.0, 560.0))

@onready var back_button: Button = $CanvasLayer/MarginContainer/VBoxContainer/BackButton
@onready var status_label: Label = $CanvasLayer/MarginContainer/VBoxContainer/StatusLabel
@onready var catalog_label: Label = $CanvasLayer/MarginContainer/VBoxContainer/CatalogLabel
@onready var spawn_root: Node2D = $SpawnedToys


func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	status_label.text = "Tap or click in the sandbox to spawn the selected toy."
	catalog_label.text = _build_catalog_text()


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
	toy_instance.position = _clamp_to_play_area(spawn_position)
	spawn_root.add_child(toy_instance)
	toy_instance.call("configure", definition)

	status_label.text = "Spawned %s using shared toy data." % definition.get("display_name", "Toy")


func _get_spawn_position(event: InputEvent) -> Variant:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		return event.position

	if event is InputEventScreenTouch and event.pressed:
		return event.position

	return null


func _clamp_to_play_area(point: Vector2) -> Vector2:
	return Vector2(
		clampf(point.x, PLAY_AREA_RECT.position.x, PLAY_AREA_RECT.end.x),
		clampf(point.y, PLAY_AREA_RECT.position.y, PLAY_AREA_RECT.end.y)
	)


func _build_catalog_text() -> String:
	var entries: Array[String] = []

	for definition in ToyCatalog.list_toys():
		entries.append("%s (%s/%s)" % [
			definition.get("display_name", "Toy"),
			String(definition.get("archetype", &"unknown")),
			String(definition.get("scale_preset", &"unknown")),
		])

	return "Catalog: %s. Selected: %s." % [
		", ".join(entries),
		String(GameState.selected_toy_id).capitalize(),
	]

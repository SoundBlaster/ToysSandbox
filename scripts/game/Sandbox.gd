extends Node2D

const TOY_INSTANCE_SCENE := preload("res://scenes/game/ToyInstance.tscn")
const PLAY_AREA_RECT := Rect2(Vector2(72.0, 72.0), Vector2(836.0, 560.0))
const POINTER_NONE := -999
const RESIZE_STEP := 0.15
const MIN_THROW_SAMPLE_DT := 0.008
const MAX_THROW_SPEED := 1400.0
const THROW_DAMPING := 0.9

@onready var back_button: Button = $CanvasLayer/MarginContainer/HBoxContainer/InfoPanel/BackButton
@onready var duplicate_button: Button = $CanvasLayer/MarginContainer/HBoxContainer/InfoPanel/ActionsRow/DuplicateButton
@onready var grow_button: Button = $CanvasLayer/MarginContainer/HBoxContainer/InfoPanel/ActionsRow/GrowButton
@onready var shrink_button: Button = $CanvasLayer/MarginContainer/HBoxContainer/InfoPanel/ActionsRow/ShrinkButton
@onready var reset_button: Button = $CanvasLayer/MarginContainer/HBoxContainer/InfoPanel/ActionsRow/ResetButton
@onready var status_label: Label = $CanvasLayer/MarginContainer/HBoxContainer/InfoPanel/StatusLabel
@onready var selected_label: Label = $CanvasLayer/MarginContainer/HBoxContainer/InfoPanel/SelectedLabel
@onready var selected_preview: TextureRect = $CanvasLayer/MarginContainer/HBoxContainer/InfoPanel/SelectedPreview
@onready var toy_list: ItemList = $CanvasLayer/MarginContainer/HBoxContainer/ShelfPanel/ShelfMargin/ShelfVBox/ToyList
@onready var spawn_root: Node2D = $SpawnedToys

var shelf_toy_ids: Array[StringName] = []
var fallback_icons: Dictionary = {}
var active_toy: RigidBody2D = null
var dragging_toy: RigidBody2D = null
var drag_pointer_id := POINTER_NONE
var drag_offset := Vector2.ZERO
var drag_previous_freeze_mode := RigidBody2D.FREEZE_MODE_STATIC
var drag_last_target_position := Vector2.ZERO
var drag_last_sample_usec := 0
var drag_release_velocity := Vector2.ZERO


func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	duplicate_button.pressed.connect(_on_duplicate_pressed)
	grow_button.pressed.connect(_on_grow_pressed)
	shrink_button.pressed.connect(_on_shrink_pressed)
	reset_button.pressed.connect(_on_reset_pressed)
	toy_list.item_selected.connect(_on_toy_selected)

	_ensure_selected_toy()
	_build_toy_shelf()
	status_label.text = "Tap a toy to drag it. Tap empty space to spawn the selected toy."
	_refresh_selected_label()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		_handle_key_shortcut(event)
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_handle_pointer_pressed(-1, event.position)
		else:
			_handle_pointer_released(-1, event.position)
		return

	if event is InputEventMouseMotion and drag_pointer_id == -1:
		_handle_pointer_dragged(-1, event.position)
		return

	if event is InputEventScreenTouch:
		if event.pressed:
			_handle_pointer_pressed(event.index, event.position)
		else:
			_handle_pointer_released(event.index, event.position)
		return

	if event is InputEventScreenDrag:
		_handle_pointer_dragged(event.index, event.position)


func _handle_key_shortcut(event: InputEventKey) -> void:
	match event.keycode:
		KEY_D:
			_duplicate_active_toy()
		KEY_R:
			_clear_spawned_toys()
		KEY_EQUAL, KEY_KP_ADD:
			_resize_active_toy(RESIZE_STEP)
		KEY_MINUS, KEY_KP_SUBTRACT:
			_resize_active_toy(-RESIZE_STEP)
		_:
			pass


func _handle_pointer_pressed(pointer_id: int, screen_position: Vector2) -> void:
	var world_position := _screen_to_world(screen_position)
	var picked_toy := _pick_toy_at(world_position)

	if picked_toy != null:
		_set_active_toy(picked_toy)
		_begin_drag(pointer_id, world_position, picked_toy)
		return

	var spawned := _spawn_selected_toy(world_position)
	_set_active_toy(spawned)


func _handle_pointer_dragged(pointer_id: int, screen_position: Vector2) -> void:
	if dragging_toy == null or pointer_id != drag_pointer_id:
		return

	var world_position := _screen_to_world(screen_position)
	_set_dragging_toy_position(world_position)


func _handle_pointer_released(pointer_id: int, screen_position: Vector2) -> void:
	if dragging_toy == null or pointer_id != drag_pointer_id:
		return

	_set_dragging_toy_position(_screen_to_world(screen_position))
	dragging_toy.angular_velocity = 0.0
	var release_velocity := drag_release_velocity * THROW_DAMPING
	if release_velocity.length() > MAX_THROW_SPEED:
		release_velocity = release_velocity.normalized() * MAX_THROW_SPEED

	var released_toy := dragging_toy
	dragging_toy = null
	drag_pointer_id = POINTER_NONE
	drag_last_sample_usec = 0
	drag_release_velocity = Vector2.ZERO
	released_toy.set_deferred("freeze_mode", drag_previous_freeze_mode)
	released_toy.set_deferred("freeze", false)
	released_toy.set_deferred("linear_velocity", release_velocity)
	released_toy.sleeping = false
	status_label.text = "Released active toy."


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/MainMenu.tscn")


func _on_duplicate_pressed() -> void:
	_duplicate_active_toy()


func _on_grow_pressed() -> void:
	_resize_active_toy(RESIZE_STEP)


func _on_shrink_pressed() -> void:
	_resize_active_toy(-RESIZE_STEP)


func _on_reset_pressed() -> void:
	_clear_spawned_toys()


func _spawn_selected_toy(spawn_position: Vector2) -> RigidBody2D:
	var toy_id := GameState.selected_toy_id
	var definition := ToyCatalog.get_toy_definition(toy_id)

	if definition.is_empty():
		status_label.text = "Selected toy is missing from the catalog."
		return null

	var toy_instance: RigidBody2D = TOY_INSTANCE_SCENE.instantiate()
	var half_extents: Vector2 = definition.get("size", Vector2(72.0, 72.0)) * 0.5
	toy_instance.position = _clamp_to_play_area(spawn_position, half_extents)
	spawn_root.add_child(toy_instance)
	toy_instance.call("configure", definition)

	status_label.text = "Spawned %s. Drag, duplicate, resize, or reset." % definition.get("display_name", "Toy")
	return toy_instance


func _build_toy_shelf() -> void:
	toy_list.clear()
	shelf_toy_ids = ToyCatalog.list_ids()

	for toy_id in shelf_toy_ids:
		var definition := ToyCatalog.get_toy_definition(toy_id)
		var icon := _resolve_toy_icon(toy_id, definition)
		toy_list.add_item(String(definition.get("display_name", "Toy")), icon)

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


func _set_active_toy(next_active_toy: RigidBody2D) -> void:
	if active_toy != null and is_instance_valid(active_toy) and active_toy.has_method("set_selected"):
		active_toy.call("set_selected", false)

	active_toy = next_active_toy

	if active_toy != null and is_instance_valid(active_toy) and active_toy.has_method("set_selected"):
		active_toy.call("set_selected", true)


func _begin_drag(pointer_id: int, world_position: Vector2, toy: RigidBody2D) -> void:
	dragging_toy = toy
	drag_pointer_id = pointer_id
	drag_offset = toy.global_position - world_position
	drag_previous_freeze_mode = dragging_toy.freeze_mode
	drag_last_target_position = toy.global_position
	drag_last_sample_usec = Time.get_ticks_usec()
	drag_release_velocity = Vector2.ZERO
	dragging_toy.freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	dragging_toy.freeze = true
	dragging_toy.linear_velocity = Vector2.ZERO
	dragging_toy.angular_velocity = 0.0
	status_label.text = "Dragging active toy. Release to drop it."


func _set_dragging_toy_position(world_position: Vector2) -> void:
	if dragging_toy == null:
		return

	var target_position := world_position + drag_offset
	var clamped_target_position := _clamp_to_play_area(target_position, _get_toy_half_extents(dragging_toy))
	var now_usec := Time.get_ticks_usec()
	var dt := float(now_usec - drag_last_sample_usec) / 1000000.0
	if drag_last_sample_usec > 0 and dt >= MIN_THROW_SAMPLE_DT:
		drag_release_velocity = (clamped_target_position - drag_last_target_position) / dt

	drag_last_target_position = clamped_target_position
	drag_last_sample_usec = now_usec
	dragging_toy.global_position = clamped_target_position


func _pick_toy_at(world_position: Vector2) -> RigidBody2D:
	var state := get_world_2d().direct_space_state
	var query := PhysicsPointQueryParameters2D.new()
	query.position = world_position
	query.collide_with_areas = false
	query.collide_with_bodies = true

	var intersections := state.intersect_point(query, 16)
	for intersection in intersections:
		var collider: Variant = intersection.get("collider")
		if collider is RigidBody2D and (collider as Node).is_in_group("toy_instances"):
			return collider

	return null


func _duplicate_active_toy() -> void:
	if active_toy == null or not is_instance_valid(active_toy):
		status_label.text = "Pick a toy first, then duplicate it."
		return

	var definition: Dictionary = {}
	if active_toy.has_method("get_definition_copy"):
		definition = active_toy.call("get_definition_copy")

	if definition.is_empty():
		status_label.text = "Active toy definition is unavailable."
		return

	var clone: RigidBody2D = TOY_INSTANCE_SCENE.instantiate()
	spawn_root.add_child(clone)
	clone.call("configure", definition)

	var target_position := active_toy.global_position + Vector2(56.0, -36.0)
	clone.global_position = _clamp_to_play_area(target_position, _get_toy_half_extents(clone))
	_set_active_toy(clone)
	status_label.text = "Duplicated active toy."


func _resize_active_toy(step: float) -> void:
	if active_toy == null or not is_instance_valid(active_toy):
		status_label.text = "Pick a toy first, then resize it."
		return

	if not active_toy.has_method("resize_by_step"):
		status_label.text = "Active toy does not support resizing."
		return

	var resized: bool = active_toy.call("resize_by_step", step)
	if not resized:
		status_label.text = "Size limit reached for active toy."
		return

	active_toy.global_position = _clamp_to_play_area(active_toy.global_position, _get_toy_half_extents(active_toy))
	status_label.text = "Resized active toy."


func _clear_spawned_toys() -> void:
	if dragging_toy != null and is_instance_valid(dragging_toy):
		dragging_toy.freeze_mode = drag_previous_freeze_mode
		dragging_toy.freeze = false

	for child in spawn_root.get_children():
		child.queue_free()

	dragging_toy = null
	drag_pointer_id = POINTER_NONE
	drag_last_sample_usec = 0
	drag_release_velocity = Vector2.ZERO
	_set_active_toy(null)
	status_label.text = "Reset sandbox toys. Shelf selection is unchanged."


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
	selected_preview.texture = _resolve_toy_icon(GameState.selected_toy_id, definition)


func _screen_to_world(screen_position: Vector2) -> Vector2:
	return get_viewport().get_canvas_transform().affine_inverse() * screen_position


func _clamp_to_play_area(point: Vector2, half_extents: Vector2 = Vector2.ZERO) -> Vector2:
	var min_point := PLAY_AREA_RECT.position + half_extents
	var max_point := PLAY_AREA_RECT.end - half_extents

	return Vector2(
		clampf(point.x, min_point.x, max_point.x),
		clampf(point.y, min_point.y, max_point.y)
	)


func _get_toy_half_extents(toy: RigidBody2D) -> Vector2:
	var shape_node: CollisionShape2D = toy.get_node_or_null("CollisionShape2D")
	if shape_node != null and shape_node.shape != null:
		if shape_node.shape is RectangleShape2D:
			return (shape_node.shape as RectangleShape2D).size * 0.5
		if shape_node.shape is CircleShape2D:
			var radius := (shape_node.shape as CircleShape2D).radius
			return Vector2(radius, radius)

	return Vector2(36.0, 36.0)


func _resolve_toy_icon(toy_id: StringName, definition: Dictionary = {}) -> Texture2D:
	var texture := ToyCatalog.get_icon_texture(toy_id)
	if texture != null:
		return texture

	if fallback_icons.has(toy_id):
		return fallback_icons[toy_id]

	var source_definition := definition
	if source_definition.is_empty():
		source_definition = ToyCatalog.get_toy_definition(toy_id)

	var fallback_icon := _build_placeholder_icon(source_definition)
	fallback_icons[toy_id] = fallback_icon
	return fallback_icon


func _build_placeholder_icon(definition: Dictionary) -> Texture2D:
	var image_size := 64
	var image := Image.create(image_size, image_size, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.0, 0.0, 0.0, 0.0))

	var fill_color: Color = definition.get("color", Color.WHITE)
	fill_color.a = 1.0
	var border_color := fill_color.darkened(0.35)

	var shape_name: StringName = definition.get("shape", &"rectangle")
	match shape_name:
		&"circle":
			_draw_circle_icon(image, Vector2i(32, 32), 22, fill_color, border_color)
		&"vase":
			_draw_rect_icon(image, Rect2i(22, 12, 20, 40), fill_color, border_color)
			_draw_rect_icon(image, Rect2i(18, 28, 28, 28), fill_color, border_color)
		&"pillow":
			_draw_rect_icon(image, Rect2i(10, 18, 44, 28), fill_color.lightened(0.08), border_color)
		_:
			_draw_rect_icon(image, Rect2i(10, 14, 44, 36), fill_color, border_color)

	return ImageTexture.create_from_image(image)


func _draw_rect_icon(image: Image, rect: Rect2i, fill_color: Color, border_color: Color) -> void:
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			if x < 0 or x >= image.get_width() or y < 0 or y >= image.get_height():
				continue

			var is_border := x == rect.position.x or x == rect.end.x - 1 or y == rect.position.y or y == rect.end.y - 1
			image.set_pixel(x, y, border_color if is_border else fill_color)


func _draw_circle_icon(image: Image, center: Vector2i, radius: int, fill_color: Color, border_color: Color) -> void:
	var radius_sq: int = radius * radius
	var inner_radius: int = maxi(radius - 2, 1)
	var inner_radius_sq: int = inner_radius * inner_radius

	for y in range(center.y - radius, center.y + radius + 1):
		for x in range(center.x - radius, center.x + radius + 1):
			if x < 0 or x >= image.get_width() or y < 0 or y >= image.get_height():
				continue

			var dx := x - center.x
			var dy := y - center.y
			var distance_sq := dx * dx + dy * dy
			if distance_sq > radius_sq:
				continue

			image.set_pixel(x, y, border_color if distance_sq >= inner_radius_sq else fill_color)

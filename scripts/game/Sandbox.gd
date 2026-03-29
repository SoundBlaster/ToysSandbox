extends Node2D

const TOY_INSTANCE_SCENE := preload("res://scenes/game/ToyInstance.tscn")
const SANDBOX_INTERACTION_CONTROLLER := preload("res://scripts/game/SandboxInteractionController.gd")
const PLAY_AREA_RECT := Rect2(Vector2(0.0, 72.0), Vector2(1280.0, 580.0))
const MAX_ACTIVE_TOYS := 25
const PANEL_BASE_COLOR := Color("1a2742")
const HUD_TEXT_PRIMARY := Color("f4f8ff")
const HUD_TEXT_SECONDARY := Color("d3e2ff")

@onready var back_button: Button = $CanvasLayer/MarginContainer/HBoxContainer/InfoPanel/ActionsRow/BackButton
@onready var duplicate_button: Button = $CanvasLayer/MarginContainer/HBoxContainer/InfoPanel/ActionsRow/DuplicateButton
@onready var grow_button: Button = $CanvasLayer/MarginContainer/HBoxContainer/InfoPanel/ActionsRow/GrowButton
@onready var shrink_button: Button = $CanvasLayer/MarginContainer/HBoxContainer/InfoPanel/ActionsRow/ShrinkButton
@onready var reset_button: Button = $CanvasLayer/MarginContainer/HBoxContainer/InfoPanel/ActionsRow/ResetButton
@onready var fan_button: Button = $CanvasLayer/MarginContainer/HBoxContainer/InfoPanel/ActionsRow/FanButton
@onready var smash_button: Button = $CanvasLayer/MarginContainer/HBoxContainer/InfoPanel/ActionsRow/SmashButton
@onready var status_label: Label = $CanvasLayer/MarginContainer/HBoxContainer/InfoPanel/StatusLabel
@onready var hint_label: Label = $CanvasLayer/MarginContainer/HBoxContainer/InfoPanel/HintLabel
@onready var selected_label: Label = $CanvasLayer/MarginContainer/HBoxContainer/InfoPanel/SelectedLabel
@onready var toy_list: ItemList = $CanvasLayer/MarginContainer/HBoxContainer/ShelfPanel/ShelfMargin/ShelfVBox/ToyList
@onready var shelf_panel: PanelContainer = $CanvasLayer/MarginContainer/HBoxContainer/ShelfPanel
@onready var shelf_title_label: Label = $CanvasLayer/MarginContainer/HBoxContainer/ShelfPanel/ShelfMargin/ShelfVBox/ShelfTitleLabel
@onready var shelf_hint_label: Label = $CanvasLayer/MarginContainer/HBoxContainer/ShelfPanel/ShelfMargin/ShelfVBox/ShelfHintLabel
@onready var spawn_root: Node2D = $SpawnedToys
@onready var onboarding_overlay: PanelContainer = $CanvasLayer/OnboardingOverlay
@onready var onboarding_title_label: Label = $CanvasLayer/OnboardingOverlay/OnboardingMargin/OnboardingVBox/OnboardingTitle
@onready var onboarding_spawn_hint_label: Label = $CanvasLayer/OnboardingOverlay/OnboardingMargin/OnboardingVBox/OnboardingSpawnHint
@onready var onboarding_drag_hint_label: Label = $CanvasLayer/OnboardingOverlay/OnboardingMargin/OnboardingVBox/OnboardingDragHint
@onready var onboarding_reset_hint_label: Label = $CanvasLayer/OnboardingOverlay/OnboardingMargin/OnboardingVBox/OnboardingResetHint
@onready var onboarding_controls_hint_label: Label = $CanvasLayer/OnboardingOverlay/OnboardingMargin/OnboardingVBox/OnboardingControlsHint
@onready var dismiss_onboarding_button: Button = $CanvasLayer/OnboardingOverlay/OnboardingMargin/OnboardingVBox/DismissOnboardingButton
@onready var stats_overlay_label: Label = $CanvasLayer/StatsOverlay

var shelf_toy_ids: Array[StringName] = []
var fallback_icons: Dictionary = {}
var active_toy: RigidBody2D = null
var interaction_controller = null


func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)
	duplicate_button.pressed.connect(_on_duplicate_pressed)
	grow_button.pressed.connect(_on_grow_pressed)
	shrink_button.pressed.connect(_on_shrink_pressed)
	reset_button.pressed.connect(_on_reset_pressed)
	fan_button.pressed.connect(_on_fan_pressed)
	smash_button.pressed.connect(_on_smash_pressed)
	toy_list.item_selected.connect(_on_toy_selected)
	dismiss_onboarding_button.pressed.connect(_on_dismiss_onboarding_pressed)

	_apply_visual_polish()
	_ensure_selected_toy()
	_build_toy_shelf()
	status_label.text = "Tap a toy to drag it. Tap empty space to spawn the selected toy."
	_refresh_selected_label()
	_refresh_onboarding_overlay()
	_refresh_stats_overlay()
	interaction_controller = SANDBOX_INTERACTION_CONTROLLER.new()
	interaction_controller.setup(
		status_label,
		spawn_root,
		TOY_INSTANCE_SCENE,
		MAX_ACTIVE_TOYS,
		Callable(self, "_get_active_toy"),
		Callable(self, "_set_active_toy"),
		Callable(self, "_pick_toy_at"),
		Callable(self, "_spawn_selected_toy"),
		Callable(self, "_screen_to_world"),
		Callable(self, "_clamp_to_play_area"),
		Callable(self, "_get_toy_half_extents")
	)


func _process(_delta: float) -> void:
	if GameState.show_stats_overlay:
		_refresh_stats_overlay()


func _unhandled_input(event: InputEvent) -> void:
	if interaction_controller != null:
		interaction_controller.handle_input(event)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/MainMenu.tscn")


func _on_duplicate_pressed() -> void:
	if interaction_controller != null:
		interaction_controller.on_duplicate_pressed()


func _on_grow_pressed() -> void:
	if interaction_controller != null:
		interaction_controller.on_grow_pressed()


func _on_shrink_pressed() -> void:
	if interaction_controller != null:
		interaction_controller.on_shrink_pressed()


func _on_reset_pressed() -> void:
	if interaction_controller != null:
		interaction_controller.on_reset_pressed()


func _on_fan_pressed() -> void:
	if interaction_controller != null:
		interaction_controller.on_fan_pressed()


func _on_smash_pressed() -> void:
	if interaction_controller != null:
		interaction_controller.on_smash_pressed()


func _on_dismiss_onboarding_pressed() -> void:
	_dismiss_onboarding_overlay("Onboarding hidden. You can reset it from Settings.")


func _spawn_selected_toy(spawn_position: Vector2) -> RigidBody2D:
	if not GameState.unlimited_toys_unlocked and _get_active_toy_count() >= MAX_ACTIVE_TOYS:
		status_label.text = "Toy limit reached (%d/%d). Reset or move toys before adding more." % [MAX_ACTIVE_TOYS, MAX_ACTIVE_TOYS]
		return null

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
	_dismiss_onboarding_overlay("")
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
		GameState.set_selected_toy_id(shelf_toy_ids[0])

	_select_shelf_index(selected_index)


func _on_toy_selected(index: int) -> void:
	if index < 0 or index >= shelf_toy_ids.size():
		return

	GameState.set_selected_toy_id(shelf_toy_ids[index])
	var definition := ToyCatalog.get_toy_definition(GameState.selected_toy_id)
	status_label.text = "Selected %s from the shelf." % definition.get("display_name", "Toy")
	_refresh_selected_label()


func _set_active_toy(next_active_toy: RigidBody2D) -> void:
	if active_toy != null and is_instance_valid(active_toy) and active_toy.has_method("set_selected"):
		active_toy.call("set_selected", false)

	active_toy = next_active_toy

	if active_toy != null and is_instance_valid(active_toy) and active_toy.has_method("set_selected"):
		active_toy.call("set_selected", true)
		_sync_shelf_selection_from_active_toy(active_toy)


func _get_active_toy() -> RigidBody2D:
	return active_toy


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


func _ensure_selected_toy() -> void:
	if ToyCatalog.has_toy(GameState.selected_toy_id):
		return

	var available_ids := ToyCatalog.list_ids()
	if available_ids.is_empty():
		GameState.selected_toy_id = &""
		return

	GameState.set_selected_toy_id(available_ids[0])


func _refresh_onboarding_overlay() -> void:
	onboarding_overlay.visible = not GameState.tutorial_dismissed


func _dismiss_onboarding_overlay(status_message: String) -> void:
	if GameState.tutorial_dismissed:
		return

	GameState.set_tutorial_dismissed(true)
	_refresh_onboarding_overlay()
	if not status_message.is_empty():
		status_label.text = status_message


func _refresh_selected_label() -> void:
	var definition := ToyCatalog.get_toy_definition(GameState.selected_toy_id)
	selected_label.text = "Selected toy: %s" % definition.get("display_name", "None")


func _sync_shelf_selection_from_active_toy(toy: RigidBody2D) -> void:
	if toy == null or not is_instance_valid(toy):
		return

	var toy_id := &""
	if toy.has_method("get_toy_id"):
		toy_id = toy.call("get_toy_id")
	elif toy.has_method("get_definition_copy"):
		var definition: Dictionary = toy.call("get_definition_copy")
		toy_id = definition.get("id", &"")

	if not ToyCatalog.has_toy(toy_id):
		return

	GameState.set_selected_toy_id(toy_id)
	_select_shelf_index(shelf_toy_ids.find(toy_id))
	_refresh_selected_label()


func _select_shelf_index(index: int) -> void:
	if index < 0 or index >= shelf_toy_ids.size():
		return

	var signals_were_blocked := toy_list.is_blocking_signals()
	toy_list.set_block_signals(true)
	toy_list.select(index)
	toy_list.set_block_signals(signals_were_blocked)


func _refresh_stats_overlay() -> void:
	stats_overlay_label.visible = GameState.show_stats_overlay
	if not GameState.show_stats_overlay:
		return

	var toy_limit_label := "inf" if GameState.unlimited_toys_unlocked else str(MAX_ACTIVE_TOYS)
	stats_overlay_label.text = "FPS: %d | Toys: %d/%s" % [
		Engine.get_frames_per_second(),
		_get_active_toy_count(),
		toy_limit_label,
	]


func _get_active_toy_count() -> int:
	var active_count := 0
	for child in spawn_root.get_children():
		if child is RigidBody2D and not child.is_queued_for_deletion():
			active_count += 1
	return active_count


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
			var rectangle_half := (shape_node.shape as RectangleShape2D).size * 0.5
			return rectangle_half + Vector2(absf(shape_node.position.x), absf(shape_node.position.y))
		if shape_node.shape is CircleShape2D:
			var radius := (shape_node.shape as CircleShape2D).radius
			return Vector2(radius, radius) + Vector2(absf(shape_node.position.x), absf(shape_node.position.y))
		if shape_node.shape is ConvexPolygonShape2D:
			var points := (shape_node.shape as ConvexPolygonShape2D).points
			if not points.is_empty():
				var bounds := Rect2(points[0], Vector2.ZERO)
				for point in points:
					bounds = bounds.expand(point)
				var half := bounds.size * 0.5
				return half + Vector2(absf(shape_node.position.x), absf(shape_node.position.y))

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


func _apply_visual_polish() -> void:
	shelf_panel.add_theme_stylebox_override("panel", _build_panel_style(Color("8fc6ff"), 0.94))
	onboarding_overlay.add_theme_stylebox_override("panel", _build_panel_style(Color("ffd18f"), 0.96))

	status_label.add_theme_color_override("font_color", HUD_TEXT_PRIMARY)
	hint_label.add_theme_color_override("font_color", HUD_TEXT_SECONDARY)
	selected_label.add_theme_color_override("font_color", HUD_TEXT_PRIMARY)
	shelf_title_label.add_theme_color_override("font_color", HUD_TEXT_PRIMARY)
	shelf_hint_label.add_theme_color_override("font_color", HUD_TEXT_SECONDARY)
	onboarding_title_label.add_theme_color_override("font_color", HUD_TEXT_PRIMARY)
	onboarding_spawn_hint_label.add_theme_color_override("font_color", HUD_TEXT_SECONDARY)
	onboarding_drag_hint_label.add_theme_color_override("font_color", HUD_TEXT_SECONDARY)
	onboarding_reset_hint_label.add_theme_color_override("font_color", HUD_TEXT_SECONDARY)
	onboarding_controls_hint_label.add_theme_color_override("font_color", HUD_TEXT_SECONDARY)
	stats_overlay_label.add_theme_color_override("font_color", HUD_TEXT_PRIMARY)

	_style_action_button(duplicate_button, Color("6fb1ff"))
	_style_action_button(grow_button, Color("60c89d"))
	_style_action_button(shrink_button, Color("d7985f"))
	_style_action_button(reset_button, Color("cc7f7f"))
	_style_action_button(fan_button, Color("72d6d5"))
	_style_action_button(smash_button, Color("d090ec"))
	_style_action_button(back_button, Color("8f9ed8"))
	_style_action_button(dismiss_onboarding_button, Color("f1a95d"))

func _build_panel_style(accent: Color, alpha: float) -> StyleBoxFlat:
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(PANEL_BASE_COLOR.r, PANEL_BASE_COLOR.g, PANEL_BASE_COLOR.b, alpha)
	panel_style.border_color = accent
	panel_style.border_width_left = 2
	panel_style.border_width_top = 2
	panel_style.border_width_right = 2
	panel_style.border_width_bottom = 2
	panel_style.corner_radius_top_left = 16
	panel_style.corner_radius_top_right = 16
	panel_style.corner_radius_bottom_right = 16
	panel_style.corner_radius_bottom_left = 16
	panel_style.shadow_color = Color(0.0, 0.0, 0.0, 0.28)
	panel_style.shadow_size = 8
	return panel_style


func _style_action_button(button: Button, accent: Color) -> void:
	var normal_style := StyleBoxFlat.new()
	normal_style.bg_color = accent.darkened(0.36)
	normal_style.border_color = accent.lightened(0.2)
	normal_style.border_width_left = 2
	normal_style.border_width_top = 2
	normal_style.border_width_right = 2
	normal_style.border_width_bottom = 2
	normal_style.corner_radius_top_left = 12
	normal_style.corner_radius_top_right = 12
	normal_style.corner_radius_bottom_right = 12
	normal_style.corner_radius_bottom_left = 12
	normal_style.set_content_margin(SIDE_LEFT, 14.0)
	normal_style.set_content_margin(SIDE_RIGHT, 14.0)
	normal_style.set_content_margin(SIDE_TOP, 6.0)
	normal_style.set_content_margin(SIDE_BOTTOM, 6.0)

	var hover_style := normal_style.duplicate() as StyleBoxFlat
	hover_style.bg_color = accent.darkened(0.22)
	hover_style.border_color = accent.lightened(0.32)

	var pressed_style := normal_style.duplicate() as StyleBoxFlat
	pressed_style.bg_color = accent.darkened(0.5)
	pressed_style.border_color = accent

	button.add_theme_stylebox_override("normal", normal_style)
	button.add_theme_stylebox_override("hover", hover_style)
	button.add_theme_stylebox_override("pressed", pressed_style)
	button.add_theme_color_override("font_color", Color("fff6ea"))
	button.add_theme_color_override("font_hover_color", Color("ffffff"))
	button.add_theme_color_override("font_pressed_color", Color("ffe6cd"))

extends RefCounted

const POINTER_NONE := -999
const RESIZE_STEP := 0.15
const DRAG_START_DISTANCE := 10.0
const MIN_THROW_SAMPLE_DT := 0.0001
const MIN_THROW_DURATION := 0.03
const MIN_THROW_DISTANCE := 8.0
const MAX_THROW_SPEED := 1400.0
const THROW_DAMPING := 0.9
const EMULATED_MOUSE_SUPPRESS_MS := 120
const DUPLICATE_SPAWN_PRESS_SUPPRESS_MS := 100
const DUPLICATE_SPAWN_PRESS_SUPPRESS_DISTANCE := 20.0
const DELETE_DOUBLE_TAP_WINDOW_MS := 320
const DELETE_DOUBLE_TAP_MAX_DISTANCE := 28.0

var _status_label: Label = null
var _spawn_root: Node2D = null
var _toy_instance_scene: PackedScene = null
var _max_active_toys := 0

var _get_active_toy_fn: Callable
var _set_active_toy_fn: Callable
var _pick_toy_at_fn: Callable
var _spawn_selected_toy_fn: Callable
var _screen_to_world_fn: Callable
var _clamp_to_play_area_fn: Callable
var _get_toy_half_extents_fn: Callable

var _dragging_toy: RigidBody2D = null
var _drag_pointer_id := POINTER_NONE
var _drag_offset := Vector2.ZERO
var _drag_previous_freeze_mode := RigidBody2D.FREEZE_MODE_STATIC
var _drag_last_target_position := Vector2.ZERO
var _drag_last_sample_usec := 0
var _drag_release_velocity := Vector2.ZERO
var _drag_start_position := Vector2.ZERO
var _drag_start_usec := 0
var _pending_drag_toy: RigidBody2D = null
var _pending_drag_pointer_id := POINTER_NONE
var _pending_drag_start_world := Vector2.ZERO
var _active_touch_ids: Dictionary = {}
var _last_touch_timestamp_msec := -1
var _last_spawn_press_world_position := Vector2.ZERO
var _last_spawn_press_timestamp_msec := -1
var _last_tap_toy_instance_id := -1
var _last_tap_timestamp_msec := -1
var _last_tap_world_position := Vector2.ZERO


func setup(
	status_label: Label,
	spawn_root: Node2D,
	toy_instance_scene: PackedScene,
	max_active_toys: int,
	get_active_toy_fn: Callable,
	set_active_toy_fn: Callable,
	pick_toy_at_fn: Callable,
	spawn_selected_toy_fn: Callable,
	screen_to_world_fn: Callable,
	clamp_to_play_area_fn: Callable,
	get_toy_half_extents_fn: Callable
) -> void:
	_status_label = status_label
	_spawn_root = spawn_root
	_toy_instance_scene = toy_instance_scene
	_max_active_toys = max_active_toys
	_get_active_toy_fn = get_active_toy_fn
	_set_active_toy_fn = set_active_toy_fn
	_pick_toy_at_fn = pick_toy_at_fn
	_spawn_selected_toy_fn = spawn_selected_toy_fn
	_screen_to_world_fn = screen_to_world_fn
	_clamp_to_play_area_fn = clamp_to_play_area_fn
	_get_toy_half_extents_fn = get_toy_half_extents_fn


func handle_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		_handle_key_shortcut(event as InputEventKey)
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if _should_ignore_emulated_mouse(event.position):
			return
		if event.pressed:
			_handle_pointer_pressed(-1, event.position)
		else:
			_handle_pointer_released(-1, event.position)
		return

	if event is InputEventMouseMotion:
		if _should_ignore_emulated_mouse(event.position):
			return
		_handle_pointer_dragged(-1, event.position)
		return

	if event is InputEventScreenTouch:
		if event.pressed:
			_register_touch_press(event.index)
			_handle_pointer_pressed(event.index, event.position)
		else:
			_register_touch_release(event.index)
			_handle_pointer_released(event.index, event.position)
		return

	if event is InputEventScreenDrag:
		_register_touch_press(event.index)
		_handle_pointer_dragged(event.index, event.position)


func _register_touch_press(pointer_id: int) -> void:
	_active_touch_ids[pointer_id] = true
	_last_touch_timestamp_msec = Time.get_ticks_msec()


func _register_touch_release(pointer_id: int) -> void:
	_active_touch_ids.erase(pointer_id)
	_last_touch_timestamp_msec = Time.get_ticks_msec()


func _should_ignore_emulated_mouse(_screen_position: Vector2) -> bool:
	if not _is_mobile_runtime():
		return false
	if not _active_touch_ids.is_empty():
		return true
	if _last_touch_timestamp_msec < 0:
		return false
	return Time.get_ticks_msec() - _last_touch_timestamp_msec <= EMULATED_MOUSE_SUPPRESS_MS


func _is_mobile_runtime() -> bool:
	return OS.has_feature("ios") or OS.has_feature("android") or OS.has_feature("mobile")


func _should_suppress_duplicate_spawn_press(world_position: Vector2) -> bool:
	if not _is_mobile_runtime():
		return false
	if _last_spawn_press_timestamp_msec < 0:
		return false
	if Time.get_ticks_msec() - _last_spawn_press_timestamp_msec > DUPLICATE_SPAWN_PRESS_SUPPRESS_MS:
		return false
	return _last_spawn_press_world_position.distance_to(world_position) <= DUPLICATE_SPAWN_PRESS_SUPPRESS_DISTANCE


func _record_spawn_press(world_position: Vector2) -> void:
	_last_spawn_press_world_position = world_position
	_last_spawn_press_timestamp_msec = Time.get_ticks_msec()


func on_duplicate_pressed() -> void:
	_duplicate_active_toy()


func on_grow_pressed() -> void:
	_resize_active_toy(RESIZE_STEP)


func on_shrink_pressed() -> void:
	_resize_active_toy(-RESIZE_STEP)


func on_reset_pressed() -> void:
	_clear_spawned_toys()


func on_fan_pressed() -> void:
	_apply_fan_to_active_toy()


func on_smash_pressed() -> void:
	_apply_smash_to_active_toy()


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
		KEY_F:
			_apply_fan_to_active_toy()
		KEY_S:
			_apply_smash_to_active_toy()
		_:
			pass


func _handle_pointer_pressed(pointer_id: int, screen_position: Vector2) -> void:
	if _dragging_toy != null:
		# Keep one authoritative drag pointer. Ignore extra touches/clicks until release
		# so we do not leave the previously dragged toy frozen.
		if pointer_id != _drag_pointer_id:
			return

	var world_position := _screen_to_world(screen_position)
	var picked_toy := _pick_toy_at(world_position)

	if picked_toy != null:
		_set_active_toy(picked_toy)
		_pending_drag_toy = picked_toy
		_pending_drag_pointer_id = pointer_id
		_pending_drag_start_world = world_position
		_set_status("Selected active toy. Drag to move it.")
		return

	_clear_pending_drag()
	_clear_last_tap_record()
	if _should_suppress_duplicate_spawn_press(world_position):
		return
	_record_spawn_press(world_position)
	var spawned := _spawn_selected_toy(world_position)
	if spawned != null:
		_set_active_toy(spawned)


func _handle_pointer_dragged(pointer_id: int, screen_position: Vector2) -> void:
	var world_position := _screen_to_world(screen_position)

	if _dragging_toy != null:
		if pointer_id != _drag_pointer_id:
			return
		_set_dragging_toy_position(world_position)
		return

	if _pending_drag_toy == null or pointer_id != _pending_drag_pointer_id:
		return

	if not is_instance_valid(_pending_drag_toy):
		_clear_pending_drag()
		return

	if _pending_drag_start_world.distance_to(world_position) < DRAG_START_DISTANCE:
		return

	var drag_toy := _pending_drag_toy
	_clear_pending_drag()
	_begin_drag(pointer_id, world_position, drag_toy)
	_set_dragging_toy_position(world_position)


func _handle_pointer_released(pointer_id: int, screen_position: Vector2) -> void:
	var world_position := _screen_to_world(screen_position)

	if _dragging_toy == null or pointer_id != _drag_pointer_id:
		if pointer_id == _pending_drag_pointer_id and is_instance_valid(_pending_drag_toy):
			var tapped_toy := _pending_drag_toy
			_clear_pending_drag()
			if _is_double_tap_delete(tapped_toy, world_position):
				_delete_toy_instance(tapped_toy)
				_clear_last_tap_record()
				return
			_record_tap_on_toy(tapped_toy, world_position)
		return

	_clear_last_tap_record()
	_set_dragging_toy_position(world_position)
	_dragging_toy.angular_velocity = 0.0
	var drag_duration := float(Time.get_ticks_usec() - _drag_start_usec) / 1000000.0
	var drag_distance := _drag_start_position.distance_to(_dragging_toy.global_position)
	if drag_duration >= MIN_THROW_SAMPLE_DT and _drag_release_velocity.length() < 1.0:
		_drag_release_velocity = (_dragging_toy.global_position - _drag_start_position) / drag_duration

	var release_velocity := _drag_release_velocity * THROW_DAMPING
	if drag_duration < MIN_THROW_DURATION or drag_distance < MIN_THROW_DISTANCE:
		release_velocity = Vector2.ZERO
	if release_velocity.length() > MAX_THROW_SPEED:
		release_velocity = release_velocity.normalized() * MAX_THROW_SPEED

	var released_toy := _dragging_toy
	_dragging_toy = null
	_drag_pointer_id = POINTER_NONE
	_drag_last_sample_usec = 0
	_drag_release_velocity = Vector2.ZERO
	_drag_start_usec = 0
	released_toy.set_deferred("freeze_mode", _drag_previous_freeze_mode)
	released_toy.set_deferred("freeze", false)
	released_toy.set_deferred("linear_velocity", release_velocity)
	released_toy.sleeping = false
	_set_status("Released active toy.")


func _begin_drag(pointer_id: int, world_position: Vector2, toy: RigidBody2D) -> void:
	_dragging_toy = toy
	_drag_pointer_id = pointer_id
	_drag_offset = toy.global_position - world_position
	_drag_previous_freeze_mode = _dragging_toy.freeze_mode
	_drag_last_target_position = toy.global_position
	_drag_last_sample_usec = Time.get_ticks_usec()
	_drag_start_position = toy.global_position
	_drag_start_usec = _drag_last_sample_usec
	_drag_release_velocity = Vector2.ZERO
	_dragging_toy.freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	_dragging_toy.freeze = true
	_dragging_toy.linear_velocity = Vector2.ZERO
	_dragging_toy.angular_velocity = 0.0
	_set_status("Dragging active toy. Release to drop it.")


func _set_dragging_toy_position(world_position: Vector2) -> void:
	if _dragging_toy == null:
		return

	var target_position := world_position + _drag_offset
	var clamped_target_position := _clamp_to_play_area(target_position, _get_toy_half_extents(_dragging_toy))
	var now_usec := Time.get_ticks_usec()
	var dt := float(now_usec - _drag_last_sample_usec) / 1000000.0
	if _drag_last_sample_usec > 0 and dt >= MIN_THROW_SAMPLE_DT:
		_drag_release_velocity = (clamped_target_position - _drag_last_target_position) / dt

	_drag_last_target_position = clamped_target_position
	_drag_last_sample_usec = now_usec
	_dragging_toy.global_position = clamped_target_position


func _duplicate_active_toy() -> void:
	var active_toy := _get_active_toy()
	if active_toy == null or not is_instance_valid(active_toy):
		_set_status("Pick a toy first, then duplicate it.")
		return

	var definition: Dictionary = {}
	if active_toy.has_method("get_definition_copy"):
		definition = active_toy.call("get_definition_copy")

	if definition.is_empty():
		_set_status("Active toy definition is unavailable.")
		return

	if _spawn_root == null or _toy_instance_scene == null:
		_set_status("Unable to duplicate active toy right now.")
		return
	if not GameState.unlimited_toys_unlocked and _max_active_toys > 0 and _spawn_root.get_child_count() >= _max_active_toys:
		_set_status("Toy limit reached (%d/%d). Reset or move toys before duplicating." % [_max_active_toys, _max_active_toys])
		return

	var clone: RigidBody2D = _toy_instance_scene.instantiate()
	_spawn_root.add_child(clone)
	clone.call("configure", definition)

	var target_position := active_toy.global_position + Vector2(56.0, -36.0)
	clone.global_position = _clamp_to_play_area(target_position, _get_toy_half_extents(clone))
	_set_active_toy(clone)
	_set_status("Duplicated active toy.")


func _resize_active_toy(step: float) -> void:
	var active_toy := _get_active_toy()
	if active_toy == null or not is_instance_valid(active_toy):
		_set_status("Pick a toy first, then resize it.")
		return

	if not active_toy.has_method("resize_by_step"):
		_set_status("Active toy does not support resizing.")
		return

	var resized: bool = active_toy.call("resize_by_step", step)
	if not resized:
		_set_status("Size limit reached for active toy.")
		return

	active_toy.global_position = _clamp_to_play_area(active_toy.global_position, _get_toy_half_extents(active_toy))
	_set_status("Resized active toy.")


func _apply_fan_to_active_toy() -> void:
	var active_toy := _get_active_toy()
	if active_toy == null or not is_instance_valid(active_toy):
		_set_status("Pick a toy first, then use Fan.")
		return

	if not active_toy.has_method("apply_fan_tool"):
		_set_status("Active toy does not support fan reaction.")
		return

	active_toy.call("apply_fan_tool", Vector2.RIGHT)
	_set_status("Fan applied to active toy.")


func _apply_smash_to_active_toy() -> void:
	var active_toy := _get_active_toy()
	if active_toy == null or not is_instance_valid(active_toy):
		_set_status("Pick a toy first, then use Smash.")
		return

	if not active_toy.has_method("apply_smash_tool"):
		_set_status("Active toy does not support smash reaction.")
		return

	active_toy.call("apply_smash_tool", Vector2.DOWN)
	_set_status("Smash applied to active toy.")


func _clear_spawned_toys() -> void:
	_clear_pending_drag()
	_clear_last_tap_record()

	if _dragging_toy != null and is_instance_valid(_dragging_toy):
		_dragging_toy.freeze_mode = _drag_previous_freeze_mode
		_dragging_toy.freeze = false

	if _spawn_root != null:
		for child in _spawn_root.get_children():
			child.queue_free()

	_dragging_toy = null
	_drag_pointer_id = POINTER_NONE
	_drag_last_sample_usec = 0
	_drag_release_velocity = Vector2.ZERO
	_drag_start_usec = 0
	_set_active_toy(null)
	_set_status("Reset sandbox toys. Shelf selection is unchanged.")


func _delete_toy_instance(toy: RigidBody2D) -> void:
	if toy == null or not is_instance_valid(toy):
		return

	if toy == _dragging_toy:
		_dragging_toy = null
		_drag_pointer_id = POINTER_NONE
		_drag_last_sample_usec = 0
		_drag_release_velocity = Vector2.ZERO
		_drag_start_usec = 0

	if toy == _pending_drag_toy:
		_clear_pending_drag()

	var active_toy := _get_active_toy()
	var deleted_toy_name := "Toy"
	if toy.has_method("get_definition_copy"):
		var definition: Dictionary = toy.call("get_definition_copy")
		deleted_toy_name = String(definition.get("display_name", "Toy"))

	toy.queue_free()
	if active_toy == toy:
		_set_active_toy(null)

	_set_status("Deleted %s." % deleted_toy_name)


func _record_tap_on_toy(toy: RigidBody2D, world_position: Vector2) -> void:
	if toy == null or not is_instance_valid(toy):
		return

	_last_tap_toy_instance_id = toy.get_instance_id()
	_last_tap_timestamp_msec = Time.get_ticks_msec()
	_last_tap_world_position = world_position


func _is_double_tap_delete(toy: RigidBody2D, world_position: Vector2) -> bool:
	if toy == null or not is_instance_valid(toy):
		return false
	if _last_tap_toy_instance_id < 0 or _last_tap_timestamp_msec < 0:
		return false
	if Time.get_ticks_msec() - _last_tap_timestamp_msec > DELETE_DOUBLE_TAP_WINDOW_MS:
		return false
	if _last_tap_world_position.distance_to(world_position) > DELETE_DOUBLE_TAP_MAX_DISTANCE:
		return false

	return toy.get_instance_id() == _last_tap_toy_instance_id


func _clear_last_tap_record() -> void:
	_last_tap_toy_instance_id = -1
	_last_tap_timestamp_msec = -1
	_last_tap_world_position = Vector2.ZERO


func _clear_pending_drag() -> void:
	_pending_drag_toy = null
	_pending_drag_pointer_id = POINTER_NONE
	_pending_drag_start_world = Vector2.ZERO


func _get_active_toy() -> RigidBody2D:
	if _get_active_toy_fn.is_null():
		return null
	return _get_active_toy_fn.call() as RigidBody2D


func _set_active_toy(next_active_toy: RigidBody2D) -> void:
	if _set_active_toy_fn.is_null():
		return
	_set_active_toy_fn.call(next_active_toy)


func _pick_toy_at(world_position: Vector2) -> RigidBody2D:
	if _pick_toy_at_fn.is_null():
		return null
	return _pick_toy_at_fn.call(world_position) as RigidBody2D


func _spawn_selected_toy(world_position: Vector2) -> RigidBody2D:
	if _spawn_selected_toy_fn.is_null():
		return null
	return _spawn_selected_toy_fn.call(world_position) as RigidBody2D


func _screen_to_world(screen_position: Vector2) -> Vector2:
	if _screen_to_world_fn.is_null():
		return screen_position
	return _screen_to_world_fn.call(screen_position) as Vector2


func _clamp_to_play_area(point: Vector2, half_extents: Vector2) -> Vector2:
	if _clamp_to_play_area_fn.is_null():
		return point
	return _clamp_to_play_area_fn.call(point, half_extents) as Vector2


func _get_toy_half_extents(toy: RigidBody2D) -> Vector2:
	if _get_toy_half_extents_fn.is_null():
		return Vector2(36.0, 36.0)
	return _get_toy_half_extents_fn.call(toy) as Vector2


func _set_status(message: String) -> void:
	if _status_label != null:
		_status_label.text = message

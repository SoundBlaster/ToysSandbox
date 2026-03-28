extends RigidBody2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var body_polygon: Polygon2D = $BodyPolygon
@onready var world_sprite: Sprite2D = $WorldSprite
@onready var name_label: Label = $NameLabel

var toy_definition: Dictionary = {}
var base_color: Color = Color.WHITE
var is_selected := false
var size_scale := 1.0

const MIN_SIZE_SCALE := 0.6
const MAX_SIZE_SCALE := 1.8
const FAN_FORCE_BY_ARCHETYPE := {
	&"bouncy": 1.0,
	&"soft": 0.75,
	&"heavy": 0.45,
	&"fragile": 0.7,
	&"air": 1.7,
	&"deformable": 0.8,
	&"metal": 0.55,
	&"sticky": 0.35,
}
const SMASH_FORCE_BY_ARCHETYPE := {
	&"bouncy": 0.85,
	&"soft": 0.65,
	&"heavy": 1.2,
	&"fragile": 1.35,
	&"air": 0.5,
	&"deformable": 0.7,
	&"metal": 1.05,
	&"sticky": 0.55,
}
const SMASH_REBOUND_BY_ARCHETYPE := {
	&"bouncy": 780.0,
	&"air": 420.0,
}


func _ready() -> void:
	add_to_group("toy_instances")


func configure(definition: Dictionary) -> void:
	toy_definition = definition.duplicate(true)
	size_scale = 1.0

	if toy_definition.is_empty():
		physics_material_override = null
		return

	if collision_shape == null:
		collision_shape = get_node("CollisionShape2D")
		body_polygon = get_node("BodyPolygon")
		world_sprite = get_node("WorldSprite")
		name_label = get_node("NameLabel")

	name = "Toy_%s" % String(toy_definition.get("id", &"unknown"))
	mass = float(toy_definition.get("mass", 1.0))
	gravity_scale = float(toy_definition.get("gravity_scale", 1.0))
	linear_damp = float(toy_definition.get("linear_damp", 0.2))
	angular_damp = float(toy_definition.get("angular_damp", 0.2))
	_apply_physics_material()

	_apply_shape()
	_apply_visuals()
	set_selected(false)


func _apply_physics_material() -> void:
	var material := PhysicsMaterial.new()
	material.bounce = clampf(float(toy_definition.get("physics_bounce", 0.0)), 0.0, 1.0)
	material.friction = maxf(float(toy_definition.get("physics_friction", 1.0)), 0.0)
	physics_material_override = material


func get_definition_copy() -> Dictionary:
	return toy_definition.duplicate(true)


func set_selected(selected: bool) -> void:
	is_selected = selected
	_apply_selection_visuals()


func resize_by_step(step: float) -> bool:
	if toy_definition.is_empty():
		return false

	var next_scale := clampf(size_scale + step, MIN_SIZE_SCALE, MAX_SIZE_SCALE)
	if is_equal_approx(next_scale, size_scale):
		return false

	size_scale = next_scale
	_apply_shape()
	_apply_visuals()
	_apply_selection_visuals()
	return true


func apply_fan_tool(direction: Vector2, base_force: float = 900.0) -> void:
	if toy_definition.is_empty():
		return

	var wind_direction := direction.normalized()
	if wind_direction == Vector2.ZERO:
		wind_direction = Vector2.RIGHT

	var archetype: StringName = toy_definition.get("archetype", &"bouncy")
	var force_scale: float = float(FAN_FORCE_BY_ARCHETYPE.get(archetype, 1.0))
	var fan_impulse := wind_direction * base_force * force_scale

	apply_central_impulse(fan_impulse)
	sleeping = false
	_apply_tool_feedback(archetype, &"fan")


func apply_smash_tool(direction: Vector2, base_force: float = 1200.0) -> void:
	if toy_definition.is_empty():
		return

	var smash_direction := direction.normalized()
	if smash_direction == Vector2.ZERO:
		smash_direction = Vector2.DOWN

	var archetype: StringName = toy_definition.get("archetype", &"bouncy")
	var force_scale: float = float(SMASH_FORCE_BY_ARCHETYPE.get(archetype, 1.0))
	var smash_impulse := smash_direction * base_force * force_scale

	apply_central_impulse(smash_impulse)
	if archetype == &"fragile":
		angular_velocity += 5.0
	elif archetype == &"soft" or archetype == &"deformable":
		angular_velocity *= 0.5
	else:
		angular_velocity += 1.5

	if _is_grounded():
		var rebound_force: float = float(SMASH_REBOUND_BY_ARCHETYPE.get(archetype, 0.0))
		if rebound_force > 0.0:
			apply_central_impulse(Vector2.UP * rebound_force)
			linear_velocity.y = minf(linear_velocity.y, -280.0)

	sleeping = false
	_apply_tool_feedback(archetype, &"smash")


func _apply_shape() -> void:
	var size: Vector2 = _get_scaled_size()
	var shape_name: StringName = toy_definition.get("shape", &"rectangle")

	match shape_name:
		&"circle":
			var circle_shape := CircleShape2D.new()
			circle_shape.radius = size.x * 0.5
			collision_shape.shape = circle_shape
			body_polygon.polygon = _build_circle_polygon(circle_shape.radius)
		&"pillow":
			var pillow_shape := RectangleShape2D.new()
			pillow_shape.size = size
			collision_shape.shape = pillow_shape
			body_polygon.polygon = PackedVector2Array([
				Vector2(-size.x * 0.45, -size.y * 0.35),
				Vector2(0.0, -size.y * 0.5),
				Vector2(size.x * 0.45, -size.y * 0.35),
				Vector2(size.x * 0.5, 0.0),
				Vector2(size.x * 0.45, size.y * 0.35),
				Vector2(0.0, size.y * 0.5),
				Vector2(-size.x * 0.45, size.y * 0.35),
				Vector2(-size.x * 0.5, 0.0),
			])
		&"vase":
			var vase_shape := RectangleShape2D.new()
			vase_shape.size = Vector2(size.x * 0.6, size.y)
			collision_shape.shape = vase_shape
			body_polygon.polygon = PackedVector2Array([
				Vector2(-size.x * 0.18, -size.y * 0.5),
				Vector2(size.x * 0.18, -size.y * 0.5),
				Vector2(size.x * 0.28, -size.y * 0.2),
				Vector2(size.x * 0.36, size.y * 0.35),
				Vector2(0.0, size.y * 0.5),
				Vector2(-size.x * 0.36, size.y * 0.35),
				Vector2(-size.x * 0.28, -size.y * 0.2),
			])
		_:
			var rectangle_shape := RectangleShape2D.new()
			rectangle_shape.size = size
			collision_shape.shape = rectangle_shape
			body_polygon.polygon = PackedVector2Array([
				Vector2(-size.x * 0.5, -size.y * 0.5),
				Vector2(size.x * 0.5, -size.y * 0.5),
				Vector2(size.x * 0.5, size.y * 0.5),
				Vector2(-size.x * 0.5, size.y * 0.5),
			])


func _apply_visuals() -> void:
	base_color = toy_definition.get("color", Color.WHITE)
	body_polygon.color = base_color
	name_label.text = toy_definition.get("display_name", "Toy")
	var size: Vector2 = _get_scaled_size()
	name_label.position = Vector2(-64.0, -size.y * 0.9)

	var toy_id: StringName = toy_definition.get("id", &"")
	var world_texture := ToyCatalog.get_world_texture(toy_id)
	if world_texture != null:
		world_sprite.texture = world_texture
		world_sprite.visible = true
		body_polygon.visible = false
		_fit_world_texture(size, world_texture)
	else:
		world_sprite.texture = null
		world_sprite.visible = false
		body_polygon.visible = true


func _get_scaled_size() -> Vector2:
	var base_size: Vector2 = toy_definition.get("size", Vector2(72.0, 72.0))
	return base_size * size_scale


func _build_circle_polygon(radius: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	var sides := 24

	for index in range(sides):
		var angle := TAU * float(index) / float(sides)
		points.append(Vector2.RIGHT.rotated(angle) * radius)

	return points


func _fit_world_texture(target_size: Vector2, texture: Texture2D) -> void:
	if texture == null:
		world_sprite.scale = Vector2.ONE
		return

	var source_size := texture.get_size()
	if source_size.x <= 0.0 or source_size.y <= 0.0:
		world_sprite.scale = Vector2.ONE
		return

	var scale_x := target_size.x / source_size.x
	var scale_y := target_size.y / source_size.y
	world_sprite.scale = Vector2(scale_x, scale_y)


func _apply_selection_visuals() -> void:
	if is_selected:
		body_polygon.color = base_color.lightened(0.2)
		name_label.modulate = Color(1.0, 0.95, 0.7)
		world_sprite.modulate = Color(1.1, 1.1, 1.1)
	else:
		body_polygon.color = base_color
		name_label.modulate = Color(1.0, 1.0, 1.0)
		world_sprite.modulate = Color(1.0, 1.0, 1.0)


func _apply_tool_feedback(archetype: StringName, tool: StringName) -> void:
	if tool == &"smash":
		_play_impact_punch()

	match archetype:
		&"bouncy":
			_play_feedback_flash(Color(1.2, 1.15, 0.95), 0.12)
			if tool == &"fan" and world_sprite.visible:
				var canonical_scale := _get_canonical_world_sprite_scale()
				world_sprite.scale = canonical_scale * Vector2(0.9, 1.12)
				var bouncy_tween := create_tween()
				bouncy_tween.tween_property(world_sprite, "scale", canonical_scale, 0.1)
			angular_velocity += 2.2 if tool == &"fan" else 3.4
		&"fragile":
			_play_feedback_flash(Color(0.7, 0.9, 1.2), 0.22)
			if tool == &"smash":
				_play_feedback_flash(Color(1.2, 0.85, 0.85), 0.16)
		&"soft", &"deformable":
			_play_feedback_flash(Color(1.1, 0.95, 1.2), 0.18)
			if world_sprite.visible:
				var canonical_scale := _get_canonical_world_sprite_scale()
				world_sprite.scale = canonical_scale * Vector2(1.12, 0.86)
				var squash_tween := create_tween()
				squash_tween.tween_property(world_sprite, "scale", canonical_scale, 0.14)
		&"heavy":
			_play_feedback_flash(Color(1.15, 1.08, 0.9), 0.14)
			name_label.modulate = Color(1.0, 0.92, 0.72)
			var base_label_modulate := _get_name_label_base_modulate()
			var rigid_tween := create_tween()
			rigid_tween.tween_property(name_label, "modulate", base_label_modulate, 0.14)
		&"metal":
			_play_feedback_flash(Color(1.08, 1.12, 1.18), 0.14)
			name_label.modulate = Color(0.9, 0.98, 1.0)
			if tool == &"smash":
				angular_velocity += 4.2
			else:
				angular_velocity += 1.8
			var base_label_modulate := _get_name_label_base_modulate()
			var metal_tween := create_tween()
			metal_tween.tween_property(name_label, "modulate", base_label_modulate, 0.18)
		&"air":
			_play_feedback_flash(Color(1.2, 0.96, 1.1), 0.2)
			if tool == &"fan":
				linear_velocity += Vector2(0.0, -120.0)
			else:
				linear_velocity += Vector2(0.0, -60.0)
			if world_sprite.visible:
				var canonical_scale := _get_canonical_world_sprite_scale()
				world_sprite.scale = canonical_scale * Vector2(1.06, 0.92)
				var drift_tween := create_tween()
				drift_tween.tween_property(world_sprite, "scale", canonical_scale, 0.2)
		&"sticky":
			_play_feedback_flash(Color(0.9, 1.12, 0.84), 0.22)
			linear_velocity *= 0.72
			angular_velocity *= 0.4
			if world_sprite.visible:
				var canonical_scale := _get_canonical_world_sprite_scale()
				world_sprite.scale = canonical_scale * Vector2(0.92, 1.08)
				var peel_tween := create_tween()
				peel_tween.tween_property(world_sprite, "scale", canonical_scale, 0.24)
		_:
			_play_feedback_flash(Color(1.08, 1.08, 1.08), 0.12)


func _play_impact_punch() -> void:
	var polygon_base_scale := body_polygon.scale
	var sprite_base_scale := _get_canonical_world_sprite_scale()
	var punch_scale := Vector2(1.15, 0.84)

	body_polygon.scale = polygon_base_scale * punch_scale
	if world_sprite.visible:
		world_sprite.scale = sprite_base_scale * punch_scale

	var punch_tween := create_tween()
	punch_tween.tween_property(body_polygon, "scale", polygon_base_scale, 0.12)
	if world_sprite.visible:
		punch_tween.parallel().tween_property(world_sprite, "scale", sprite_base_scale, 0.12)


func _get_name_label_base_modulate() -> Color:
	return Color(1.0, 0.95, 0.7) if is_selected else Color(1.0, 1.0, 1.0)


func _get_canonical_world_sprite_scale() -> Vector2:
	if not world_sprite.visible or world_sprite.texture == null:
		return world_sprite.scale

	var source_size := world_sprite.texture.get_size()
	if source_size.x <= 0.0 or source_size.y <= 0.0:
		return world_sprite.scale

	var target_size := _get_scaled_size()
	return Vector2(target_size.x / source_size.x, target_size.y / source_size.y)


func _play_feedback_flash(boost_modulate: Color, duration: float) -> void:
	var source_body_color := body_polygon.color
	var source_world_modulate := world_sprite.modulate
	body_polygon.color = source_body_color * boost_modulate
	if world_sprite.visible:
		world_sprite.modulate = _flash_world_modulate(boost_modulate)

	var tween := create_tween()
	tween.tween_property(body_polygon, "color", source_body_color, duration)
	if world_sprite.visible:
		tween.parallel().tween_property(world_sprite, "modulate", source_world_modulate, duration)


func _flash_world_modulate(boost_modulate: Color) -> Color:
	# Texture sprites are often already white; multiplying by values >1 can look unchanged.
	# Use a visible tint shift on impact and tween back to the baseline modulate.
	return Color(
		clampf(0.72 + boost_modulate.r * 0.28, 0.0, 1.0),
		clampf(0.72 + boost_modulate.g * 0.28, 0.0, 1.0),
		clampf(0.72 + boost_modulate.b * 0.28, 0.0, 1.0),
		1.0
	)


func _is_grounded() -> bool:
	var colliders: Array[Node2D] = get_colliding_bodies()
	return not colliders.is_empty()

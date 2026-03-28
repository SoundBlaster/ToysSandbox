extends RigidBody2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var body_polygon: Polygon2D = $BodyPolygon
@onready var world_sprite: Sprite2D = $WorldSprite
@onready var name_label: Label = $NameLabel

var toy_definition: Dictionary = {}


func configure(definition: Dictionary) -> void:
	toy_definition = definition.duplicate(true)

	if toy_definition.is_empty():
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

	_apply_shape()
	_apply_visuals()


func _apply_shape() -> void:
	var size: Vector2 = toy_definition.get("size", Vector2(72.0, 72.0))
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
	body_polygon.color = toy_definition.get("color", Color.WHITE)
	name_label.text = toy_definition.get("display_name", "Toy")
	var size: Vector2 = toy_definition.get("size", Vector2(72.0, 72.0))
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

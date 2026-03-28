extends Node

const DEFAULT_SKIN_ID := &"classic"
const SCALE_PRESETS := {
	&"small": {
		"size": Vector2(56.0, 56.0),
	},
	&"medium": {
		"size": Vector2(84.0, 56.0),
	},
	&"large": {
		"size": Vector2(96.0, 96.0),
	},
	&"wide": {
		"size": Vector2(112.0, 64.0),
	},
}

const ARCHETYPE_DEFAULTS := {
	&"bouncy": {
		"gravity_scale": 1.0,
		"linear_damp": 0.15,
		"angular_damp": 0.1,
		"mass": 0.8,
		"physics_bounce": 0.62,
		"physics_friction": 0.2,
		"reaction_hooks": [&"bounce", &"roll"],
	},
	&"soft": {
		"gravity_scale": 0.9,
		"linear_damp": 1.4,
		"angular_damp": 1.0,
		"mass": 1.0,
		"physics_bounce": 0.18,
		"physics_friction": 0.85,
		"reaction_hooks": [&"squish", &"settle"],
	},
	&"heavy": {
		"gravity_scale": 1.2,
		"linear_damp": 0.5,
		"angular_damp": 0.6,
		"mass": 2.4,
		"physics_bounce": 0.08,
		"physics_friction": 1.05,
		"reaction_hooks": [&"thud", &"stack"],
	},
	&"fragile": {
		"gravity_scale": 1.0,
		"linear_damp": 0.35,
		"angular_damp": 0.45,
		"mass": 1.2,
		"physics_bounce": 0.34,
		"physics_friction": 0.45,
		"reaction_hooks": [&"clink", &"shatter"],
	},
	&"air": {
		"gravity_scale": 0.35,
		"linear_damp": 0.08,
		"angular_damp": 0.2,
		"mass": 0.3,
		"physics_bounce": 0.72,
		"physics_friction": 0.08,
		"reaction_hooks": [&"float", &"drift"],
	},
	&"deformable": {
		"gravity_scale": 0.95,
		"linear_damp": 1.1,
		"angular_damp": 0.9,
		"mass": 0.9,
		"physics_bounce": 0.26,
		"physics_friction": 0.6,
		"reaction_hooks": [&"jiggle", &"wobble"],
	},
	&"metal": {
		"gravity_scale": 1.15,
		"linear_damp": 0.25,
		"angular_damp": 0.2,
		"mass": 2.0,
		"physics_bounce": 0.42,
		"physics_friction": 0.18,
		"reaction_hooks": [&"ring", &"spin"],
	},
	&"sticky": {
		"gravity_scale": 1.0,
		"linear_damp": 2.2,
		"angular_damp": 1.6,
		"mass": 1.4,
		"physics_bounce": 0.04,
		"physics_friction": 1.4,
		"reaction_hooks": [&"stick", &"peel"],
	},
}

const TOY_DEFINITIONS := {
	&"ball": {
		"id": &"ball",
		"display_name": "Ball",
		"archetype": &"bouncy",
		"scale_preset": &"small",
		"shape": &"circle",
		"icon_texture": "res://assets/toys/icons/ball_icon.svg",
		"world_texture": "res://assets/toys/world/ball_world.svg",
		"color": Color("ff8a3d"),
	},
	&"pillow": {
		"id": &"pillow",
		"display_name": "Pillow",
		"archetype": &"soft",
		"scale_preset": &"medium",
		"shape": &"pillow",
		"icon_texture": "res://assets/toys/icons/pillow_icon.svg",
		"world_texture": "res://assets/toys/world/pillow_world.svg",
		"color": Color("8dd9c2"),
	},
	&"brick": {
		"id": &"brick",
		"display_name": "Brick",
		"archetype": &"heavy",
		"scale_preset": &"medium",
		"shape": &"rectangle",
		"icon_texture": "res://assets/toys/icons/brick_icon.svg",
		"world_texture": "res://assets/toys/world/brick_world.svg",
		"color": Color("b65a3a"),
	},
	&"vase": {
		"id": &"vase",
		"display_name": "Vase",
		"archetype": &"fragile",
		"scale_preset": &"large",
		"shape": &"vase",
		"icon_texture": "res://assets/toys/icons/vase_icon.svg",
		"world_texture": "res://assets/toys/world/vase_world.svg",
		"color": Color("7ca7ff"),
	},
	&"balloon": {
		"id": &"balloon",
		"display_name": "Balloon",
		"archetype": &"air",
		"scale_preset": &"large",
		"shape": &"circle",
		"gravity_scale": 0.12,
		"mass": 0.14,
		"linear_damp": 1.35,
		"angular_damp": 2.4,
		"physics_bounce": 0.38,
		"center_of_mass_mode": "custom",
		"center_of_mass": Vector2(0.0, 18.0),
		"buoyancy_force": 20.0,
		"upright_strength": 55.0,
		"upright_damping": 9.0,
		"icon_texture": "res://assets/toys/icons/balloon_icon.svg",
		"world_texture": "res://assets/toys/world/balloon_world.svg",
		"color": Color("ff7fb5"),
	},
	&"jelly_cube": {
		"id": &"jelly_cube",
		"display_name": "Jelly Cube",
		"archetype": &"deformable",
		"scale_preset": &"medium",
		"shape": &"rectangle",
		"icon_texture": "res://assets/toys/icons/jelly_cube_icon.svg",
		"world_texture": "res://assets/toys/world/jelly_cube_world.svg",
		"color": Color("9b9bff"),
	},
	&"pot": {
		"id": &"pot",
		"display_name": "Pot",
		"archetype": &"metal",
		"scale_preset": &"medium",
		"shape": &"vase",
		"icon_texture": "res://assets/toys/icons/pot_icon.svg",
		"world_texture": "res://assets/toys/world/pot_world.svg",
		"color": Color("c7935d"),
	},
	&"sticky_block": {
		"id": &"sticky_block",
		"display_name": "Sticky Block",
		"archetype": &"sticky",
		"scale_preset": &"wide",
		"shape": &"rectangle",
		"icon_texture": "res://assets/toys/icons/sticky_block_icon.svg",
		"world_texture": "res://assets/toys/world/sticky_block_world.svg",
		"color": Color("7fd24a"),
	},
}

const TOY_ORDER: Array[StringName] = [
	&"ball",
	&"pillow",
	&"brick",
	&"vase",
	&"balloon",
	&"jelly_cube",
	&"pot",
	&"sticky_block",
]

const SKIN_PRESETS := {
	&"classic": {
		"id": &"classic",
		"display_name": "Classic",
		"use_source_textures": true,
		"hue_shift": 0.0,
		"saturation_scale": 1.0,
		"value_scale": 1.0,
		"border_darken": 0.26,
		"highlight_strength": 0.2,
		"highlight_alpha": 0.34,
	},
	&"sunset_pop": {
		"id": &"sunset_pop",
		"display_name": "Sunset Pop",
		"use_source_textures": false,
		"hue_shift": 0.085,
		"saturation_scale": 1.15,
		"value_scale": 1.08,
		"border_darken": 0.34,
		"highlight_strength": 0.26,
		"highlight_alpha": 0.42,
	},
	&"moonlight": {
		"id": &"moonlight",
		"display_name": "Moonlight",
		"use_source_textures": false,
		"hue_shift": -0.18,
		"saturation_scale": 0.62,
		"value_scale": 0.92,
		"border_darken": 0.18,
		"highlight_strength": 0.1,
		"highlight_alpha": 0.22,
	},
}

const SKIN_ORDER: Array[StringName] = [
	&"classic",
	&"sunset_pop",
	&"moonlight",
]

var _icon_cache: Dictionary = {}
var _world_cache: Dictionary = {}
var _styled_icon_cache: Dictionary = {}
var _styled_world_cache: Dictionary = {}


func list_ids() -> Array[StringName]:
	return TOY_ORDER.duplicate()


func list_toys(skin_id: StringName = StringName("")) -> Array[Dictionary]:
	var toys: Array[Dictionary] = []
	for toy_id in list_ids():
		toys.append(get_toy_definition(toy_id, skin_id))
	return toys


func list_skin_ids() -> Array[StringName]:
	return SKIN_ORDER.duplicate()


func list_skins() -> Array[Dictionary]:
	var skins: Array[Dictionary] = []
	for skin_id in list_skin_ids():
		skins.append(get_skin_definition(skin_id))
	return skins


func has_toy(toy_id: StringName) -> bool:
	return TOY_DEFINITIONS.has(toy_id)


func has_skin(skin_id: StringName) -> bool:
	return SKIN_PRESETS.has(skin_id)


func get_skin_definition(skin_id: StringName) -> Dictionary:
	var resolved_skin_id := _resolve_skin_id(skin_id)
	var base_skin: Dictionary = SKIN_PRESETS.get(resolved_skin_id, SKIN_PRESETS[DEFAULT_SKIN_ID])
	var definition := base_skin.duplicate(true)
	definition["id"] = resolved_skin_id
	return definition


func get_skin_display_name(skin_id: StringName) -> String:
	return String(get_skin_definition(skin_id).get("display_name", "Classic"))


func get_toy_definition(toy_id: StringName, skin_id: StringName = StringName("")) -> Dictionary:
	if not TOY_DEFINITIONS.has(toy_id):
		return {}

	var base_definition: Dictionary = TOY_DEFINITIONS[toy_id]
	var archetype_defaults: Dictionary = ARCHETYPE_DEFAULTS.get(base_definition.get("archetype", &""), {})
	var scale_defaults: Dictionary = SCALE_PRESETS.get(base_definition.get("scale_preset", &""), {})

	var definition := {}
	definition.merge(archetype_defaults, true)
	definition.merge(scale_defaults, true)
	definition.merge(base_definition, true)
	return _apply_skin_to_definition(definition, _resolve_skin_id(skin_id))


func get_icon_texture(toy_id: StringName, skin_id: StringName = StringName("")) -> Texture2D:
	var resolved_skin_id := _resolve_skin_id(skin_id)
	var skin := get_skin_definition(resolved_skin_id)

	if bool(skin.get("use_source_textures", false)):
		if _icon_cache.has(toy_id):
			return _icon_cache[toy_id]

		var definition := get_toy_definition(toy_id, resolved_skin_id)
		var source_texture := _load_texture_from_path(String(definition.get("icon_texture", "")))
		if source_texture != null:
			_icon_cache[toy_id] = source_texture
			return source_texture

	var cache_key := _cache_key(toy_id, resolved_skin_id)
	if _styled_icon_cache.has(cache_key):
		return _styled_icon_cache[cache_key]

	var generated_texture := _build_generated_toy_texture(get_toy_definition(toy_id, resolved_skin_id), Vector2i(96, 96), true)
	_styled_icon_cache[cache_key] = generated_texture
	return generated_texture


func get_world_texture(toy_id: StringName, skin_id: StringName = StringName("")) -> Texture2D:
	var resolved_skin_id := _resolve_skin_id(skin_id)
	var skin := get_skin_definition(resolved_skin_id)

	if bool(skin.get("use_source_textures", false)):
		if _world_cache.has(toy_id):
			return _world_cache[toy_id]

		var definition := get_toy_definition(toy_id, resolved_skin_id)
		var source_texture := _load_texture_from_path(String(definition.get("world_texture", "")))
		if source_texture != null:
			_world_cache[toy_id] = source_texture
			return source_texture

	var cache_key := _cache_key(toy_id, resolved_skin_id)
	if _styled_world_cache.has(cache_key):
		return _styled_world_cache[cache_key]

	var generated_texture := _build_generated_toy_texture(get_toy_definition(toy_id, resolved_skin_id), Vector2i(320, 320), false)
	_styled_world_cache[cache_key] = generated_texture
	return generated_texture


func _resolve_skin_id(skin_id: StringName) -> StringName:
	if not String(skin_id).strip_edges().is_empty() and SKIN_PRESETS.has(skin_id):
		return skin_id
	if SKIN_PRESETS.has(GameState.selected_skin_id):
		return GameState.selected_skin_id
	return DEFAULT_SKIN_ID


func _apply_skin_to_definition(definition: Dictionary, skin_id: StringName) -> Dictionary:
	var skin := get_skin_definition(skin_id)
	var base_color: Color = definition.get("color", Color.WHITE)
	var styled_color := _transform_color(base_color, skin)
	definition["base_color"] = base_color
	definition["color"] = styled_color
	definition["border_color"] = styled_color.darkened(float(skin.get("border_darken", 0.26)))
	definition["highlight_color"] = Color(1.0, 1.0, 1.0, float(skin.get("highlight_alpha", 0.3)))
	definition["skin_id"] = skin_id
	definition["skin_display_name"] = skin.get("display_name", "Classic")
	return definition


func _transform_color(base_color: Color, skin: Dictionary) -> Color:
	var hue := wrapf(base_color.h + float(skin.get("hue_shift", 0.0)), 0.0, 1.0)
	var saturation := clampf(base_color.s * float(skin.get("saturation_scale", 1.0)), 0.14, 1.0)
	var value := clampf(base_color.v * float(skin.get("value_scale", 1.0)), 0.2, 1.0)
	var highlight_strength := float(skin.get("highlight_strength", 0.0))
	return Color.from_hsv(hue, saturation, value, base_color.a).lightened(highlight_strength)


func _build_generated_toy_texture(definition: Dictionary, canvas_size: Vector2i, is_icon: bool) -> Texture2D:
	var image := Image.create(canvas_size.x, canvas_size.y, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.0, 0.0, 0.0, 0.0))

	var fill_color: Color = definition.get("color", Color.WHITE)
	fill_color.a = 1.0
	var border_color: Color = definition.get("border_color", fill_color.darkened(0.28))
	var highlight_color: Color = definition.get("highlight_color", Color(1.0, 1.0, 1.0, 0.26))
	var shape_name: StringName = definition.get("shape", &"rectangle")

	match shape_name:
		&"circle":
			_draw_circle_texture(image, fill_color, border_color, highlight_color)
		&"pillow":
			_draw_pillow_texture(image, fill_color, border_color, highlight_color)
		&"vase":
			_draw_vase_texture(image, fill_color, border_color, highlight_color)
		_:
			_draw_block_texture(image, fill_color, border_color, highlight_color, is_icon)

	return ImageTexture.create_from_image(image)


func _draw_circle_texture(image: Image, fill_color: Color, border_color: Color, highlight_color: Color) -> void:
	var width := image.get_width()
	var height := image.get_height()
	var center := Vector2i(width / 2, height / 2)
	var radius := int(minf(float(width), float(height)) * 0.38)
	var inner_radius := maxi(radius - maxi(width / 28, 3), 1)
	var radius_sq := radius * radius
	var inner_radius_sq := inner_radius * inner_radius

	for y in range(center.y - radius, center.y + radius + 1):
		for x in range(center.x - radius, center.x + radius + 1):
			if x < 0 or x >= width or y < 0 or y >= height:
				continue
			var dx := x - center.x
			var dy := y - center.y
			var distance_sq := dx * dx + dy * dy
			if distance_sq > radius_sq:
				continue
			image.set_pixel(x, y, border_color if distance_sq >= inner_radius_sq else fill_color)

	_draw_ellipse_highlight(
		image,
		Vector2(width * 0.38, height * 0.3),
		Vector2(width * 0.16, height * 0.11),
		highlight_color
	)


func _draw_pillow_texture(image: Image, fill_color: Color, border_color: Color, highlight_color: Color) -> void:
	var width := image.get_width()
	var height := image.get_height()
	var rect := Rect2i(int(width * 0.12), int(height * 0.26), int(width * 0.76), int(height * 0.48))
	_draw_rounded_rect(image, rect, int(height * 0.16), fill_color, border_color)
	_draw_horizontal_band(
		image,
		int(height * 0.5),
		int(height * 0.05),
		Rect2i(rect.position.x + 8, rect.position.y + 8, rect.size.x - 16, rect.size.y - 16),
		highlight_color
	)


func _draw_vase_texture(image: Image, fill_color: Color, border_color: Color, highlight_color: Color) -> void:
	var width := image.get_width()
	var height := image.get_height()
	var neck := Rect2i(int(width * 0.39), int(height * 0.15), int(width * 0.22), int(height * 0.2))
	var body := Rect2i(int(width * 0.25), int(height * 0.32), int(width * 0.5), int(height * 0.48))
	_draw_rounded_rect(image, neck, int(width * 0.04), fill_color, border_color)
	_draw_rounded_rect(image, body, int(width * 0.12), fill_color, border_color)
	_draw_ellipse_highlight(
		image,
		Vector2(width * 0.42, height * 0.44),
		Vector2(width * 0.08, height * 0.18),
		highlight_color
	)


func _draw_block_texture(image: Image, fill_color: Color, border_color: Color, highlight_color: Color, is_icon: bool) -> void:
	var width := image.get_width()
	var height := image.get_height()
	var rect := Rect2i(int(width * 0.14), int(height * 0.22), int(width * 0.72), int(height * 0.54))
	var corner_radius := int(height * (0.08 if is_icon else 0.1))
	_draw_rounded_rect(image, rect, corner_radius, fill_color, border_color)
	_draw_horizontal_band(
		image,
		int(height * 0.36),
		maxi(int(height * 0.04), 3),
		Rect2i(rect.position.x + 6, rect.position.y + 6, rect.size.x - 12, rect.size.y - 12),
		highlight_color
	)


func _draw_rounded_rect(image: Image, rect: Rect2i, radius: int, fill_color: Color, border_color: Color) -> void:
	var inner_radius := maxi(radius - 3, 0)
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			if x < 0 or x >= image.get_width() or y < 0 or y >= image.get_height():
				continue
			if not _point_in_rounded_rect(x, y, rect, radius):
				continue
			var is_border := not _point_in_rounded_rect(x, y, rect.grow(-2), inner_radius)
			image.set_pixel(x, y, border_color if is_border else fill_color)


func _draw_horizontal_band(image: Image, center_y: int, half_height: int, clip_rect: Rect2i, color: Color) -> void:
	for y in range(center_y - half_height, center_y + half_height + 1):
		for x in range(clip_rect.position.x, clip_rect.end.x):
			if x < 0 or x >= image.get_width() or y < 0 or y >= image.get_height():
				continue
			var band_alpha := clampf(1.0 - (absf(float(y - center_y)) / maxf(float(half_height), 1.0)), 0.0, 1.0)
			var existing := image.get_pixel(x, y)
			image.set_pixel(x, y, existing.blend(Color(color.r, color.g, color.b, color.a * band_alpha)))


func _draw_ellipse_highlight(image: Image, center: Vector2, radii: Vector2, color: Color) -> void:
	var min_x := int(center.x - radii.x)
	var max_x := int(center.x + radii.x)
	var min_y := int(center.y - radii.y)
	var max_y := int(center.y + radii.y)
	for y in range(min_y, max_y + 1):
		for x in range(min_x, max_x + 1):
			if x < 0 or x >= image.get_width() or y < 0 or y >= image.get_height():
				continue
			var normalized_x := (float(x) - center.x) / maxf(radii.x, 1.0)
			var normalized_y := (float(y) - center.y) / maxf(radii.y, 1.0)
			var distance := normalized_x * normalized_x + normalized_y * normalized_y
			if distance > 1.0:
				continue
			var alpha := clampf((1.0 - distance) * color.a, 0.0, color.a)
			var existing := image.get_pixel(x, y)
			image.set_pixel(x, y, existing.blend(Color(color.r, color.g, color.b, alpha)))


func _point_in_rounded_rect(x: int, y: int, rect: Rect2i, radius: int) -> bool:
	if radius <= 0:
		return rect.has_point(Vector2i(x, y))

	if x >= rect.position.x + radius and x < rect.end.x - radius:
		return y >= rect.position.y and y < rect.end.y
	if y >= rect.position.y + radius and y < rect.end.y - radius:
		return x >= rect.position.x and x < rect.end.x

	var corner_centers: Array[Vector2] = [
		Vector2(rect.position.x + radius, rect.position.y + radius),
		Vector2(rect.end.x - radius - 1, rect.position.y + radius),
		Vector2(rect.position.x + radius, rect.end.y - radius - 1),
		Vector2(rect.end.x - radius - 1, rect.end.y - radius - 1),
	]
	for center in corner_centers:
		var dx: float = float(x) - center.x
		var dy: float = float(y) - center.y
		if dx * dx + dy * dy <= float(radius * radius):
			return true
	return false


func _cache_key(toy_id: StringName, skin_id: StringName) -> String:
	return "%s::%s" % [String(toy_id), String(skin_id)]


func _load_texture_from_path(path: String) -> Texture2D:
	if path.is_empty():
		return null

	if not ResourceLoader.exists(path):
		return null

	var resource := ResourceLoader.load(path)
	if resource is Texture2D:
		return resource as Texture2D

	return null

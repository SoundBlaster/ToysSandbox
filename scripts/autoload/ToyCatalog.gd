extends Node

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
}

const ARCHETYPE_DEFAULTS := {
	&"bouncy": {
		"gravity_scale": 1.0,
		"linear_damp": 0.15,
		"angular_damp": 0.1,
		"mass": 0.8,
		"reaction_hooks": [&"bounce", &"roll"],
	},
	&"soft": {
		"gravity_scale": 0.9,
		"linear_damp": 1.4,
		"angular_damp": 1.0,
		"mass": 1.0,
		"reaction_hooks": [&"squish", &"settle"],
	},
	&"heavy": {
		"gravity_scale": 1.2,
		"linear_damp": 0.5,
		"angular_damp": 0.6,
		"mass": 2.4,
		"reaction_hooks": [&"thud", &"stack"],
	},
	&"fragile": {
		"gravity_scale": 1.0,
		"linear_damp": 0.35,
		"angular_damp": 0.45,
		"mass": 1.2,
		"reaction_hooks": [&"clink", &"shatter"],
	},
}

const TOY_DEFINITIONS := {
	&"ball": {
		"id": &"ball",
		"display_name": "Ball",
		"archetype": &"bouncy",
		"scale_preset": &"small",
		"shape": &"circle",
		"color": Color("ff8a3d"),
	},
	&"pillow": {
		"id": &"pillow",
		"display_name": "Pillow",
		"archetype": &"soft",
		"scale_preset": &"medium",
		"shape": &"pillow",
		"color": Color("8dd9c2"),
	},
	&"brick": {
		"id": &"brick",
		"display_name": "Brick",
		"archetype": &"heavy",
		"scale_preset": &"medium",
		"shape": &"rectangle",
		"color": Color("b65a3a"),
	},
	&"vase": {
		"id": &"vase",
		"display_name": "Vase",
		"archetype": &"fragile",
		"scale_preset": &"large",
		"shape": &"vase",
		"color": Color("7ca7ff"),
	},
}

const TOY_ORDER: Array[StringName] = [&"ball", &"pillow", &"brick", &"vase"]


func list_ids() -> Array[StringName]:
	return TOY_ORDER.duplicate()


func list_toys() -> Array[Dictionary]:
	var toys: Array[Dictionary] = []
	for toy_id in list_ids():
		toys.append(get_toy_definition(toy_id))
	return toys


func has_toy(toy_id: StringName) -> bool:
	return TOY_DEFINITIONS.has(toy_id)


func get_toy_definition(toy_id: StringName) -> Dictionary:
	if not TOY_DEFINITIONS.has(toy_id):
		return {}

	var base_definition: Dictionary = TOY_DEFINITIONS[toy_id]
	var archetype_defaults: Dictionary = ARCHETYPE_DEFAULTS.get(base_definition.get("archetype", &""), {})
	var scale_defaults: Dictionary = SCALE_PRESETS.get(base_definition.get("scale_preset", &""), {})

	var definition := {}
	definition.merge(archetype_defaults, true)
	definition.merge(scale_defaults, true)
	definition.merge(base_definition, true)
	return definition

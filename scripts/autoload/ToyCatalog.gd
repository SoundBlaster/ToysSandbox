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
	&"air": {
		"gravity_scale": 0.35,
		"linear_damp": 0.08,
		"angular_damp": 0.2,
		"mass": 0.3,
		"reaction_hooks": [&"float", &"drift"],
	},
	&"deformable": {
		"gravity_scale": 0.95,
		"linear_damp": 1.1,
		"angular_damp": 0.9,
		"mass": 0.9,
		"reaction_hooks": [&"jiggle", &"wobble"],
	},
	&"metal": {
		"gravity_scale": 1.15,
		"linear_damp": 0.25,
		"angular_damp": 0.2,
		"mass": 2.0,
		"reaction_hooks": [&"ring", &"spin"],
	},
	&"sticky": {
		"gravity_scale": 1.0,
		"linear_damp": 2.2,
		"angular_damp": 1.6,
		"mass": 1.4,
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
	&"balloon": {
		"id": &"balloon",
		"display_name": "Balloon",
		"archetype": &"air",
		"scale_preset": &"large",
		"shape": &"circle",
		"color": Color("ff7fb5"),
	},
	&"jelly_cube": {
		"id": &"jelly_cube",
		"display_name": "Jelly Cube",
		"archetype": &"deformable",
		"scale_preset": &"medium",
		"shape": &"rectangle",
		"color": Color("9b9bff"),
	},
	&"pot": {
		"id": &"pot",
		"display_name": "Pot",
		"archetype": &"metal",
		"scale_preset": &"medium",
		"shape": &"vase",
		"color": Color("c7935d"),
	},
	&"sticky_block": {
		"id": &"sticky_block",
		"display_name": "Sticky Block",
		"archetype": &"sticky",
		"scale_preset": &"wide",
		"shape": &"rectangle",
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

extends Node

const PLACEHOLDER_TOYS := [
	{
		"id": &"ball",
		"display_name": "Ball",
		"archetype": "bouncy",
	},
	{
		"id": &"pillow",
		"display_name": "Pillow",
		"archetype": "soft",
	},
	{
		"id": &"brick",
		"display_name": "Brick",
		"archetype": "heavy",
	},
	{
		"id": &"vase",
		"display_name": "Vase",
		"archetype": "fragile",
	},
]


func list_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for toy in PLACEHOLDER_TOYS:
		ids.append(toy["id"])
	return ids

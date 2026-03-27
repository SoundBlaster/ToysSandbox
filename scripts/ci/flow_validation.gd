extends Node

const TEST_RESOURCES := [
	"res://scenes/boot/Boot.tscn",
	"res://scenes/menu/MainMenu.tscn",
	"res://scenes/game/Sandbox.tscn",
	"res://scenes/game/ToyInstance.tscn",
	"res://scripts/boot/Boot.gd",
	"res://scripts/game/Sandbox.gd",
	"res://scripts/game/ToyInstance.gd",
	"res://scripts/menu/MainMenu.gd",
	"res://scripts/autoload/AudioService.gd",
	"res://scripts/autoload/GameState.gd",
	"res://scripts/autoload/SaveService.gd",
	"res://scripts/autoload/ToyCatalog.gd",
]

const LINT_ROOTS := [
	"res://scenes",
	"res://scripts",
]

const LINT_EXTENSIONS := [".gd", ".tscn"]

func _ready() -> void:
	var mode := _read_mode()
	var resource_paths: Array = TEST_RESOURCES

	if mode == "lint":
		resource_paths = _collect_resources(LINT_ROOTS, LINT_EXTENSIONS)
	elif mode != "tests":
		_fail_and_quit("Unknown validation mode: %s" % mode)
		return

	if resource_paths.is_empty():
		_fail_and_quit("No resources were scheduled for validation in %s mode." % mode)
		return

	print("Flow validation mode: %s" % mode)
	print("Validating %d resources." % resource_paths.size())

	if _validate_resources(resource_paths):
		print("Flow validation passed for %s." % mode)
		get_tree().quit(0)
	else:
		_fail_and_quit("Flow validation failed for %s." % mode)

func _read_mode() -> String:
	var user_arguments := OS.get_cmdline_user_args()
	if user_arguments.is_empty():
		return "tests"
	return String(user_arguments[0])

func _collect_resources(root_directories: Array, extensions: Array) -> Array:
	var collected_resources: Array = []
	for root_directory in root_directories:
		_collect_directory(root_directory, extensions, collected_resources)
	collected_resources.sort()
	return collected_resources

func _collect_directory(directory_path: String, extensions: Array, collected_resources: Array) -> void:
	var directory := DirAccess.open(directory_path)
	if directory == null:
		_fail_and_quit("Unable to open directory: %s" % directory_path)
		return

	directory.list_dir_begin()
	var entry_name := directory.get_next()
	while entry_name != "":
		if entry_name != "." and entry_name != "..":
			var entry_path := directory_path.path_join(entry_name)
			if directory.current_is_dir():
				_collect_directory(entry_path, extensions, collected_resources)
			elif _has_allowed_extension(entry_name, extensions):
				collected_resources.append(entry_path)
		entry_name = directory.get_next()
	directory.list_dir_end()

func _has_allowed_extension(file_name: String, extensions: Array) -> bool:
	for extension in extensions:
		if file_name.ends_with(String(extension)):
			return true
	return false

func _validate_resources(resource_paths: Array) -> bool:
	var all_resources_valid := true
	for resource_path in resource_paths:
		if not _validate_resource(String(resource_path)):
			all_resources_valid = false
	return all_resources_valid

func _validate_resource(resource_path: String) -> bool:
	var resource := ResourceLoader.load(resource_path)
	if resource == null:
		printerr("Failed to load resource: %s" % resource_path)
		return false

	if resource is Script:
		if not _validate_script(resource as Script, resource_path):
			return false
		print("Validated %s" % resource_path)
		return true

	if resource is PackedScene:
		var scene_instance := (resource as PackedScene).instantiate()
		if scene_instance == null:
			printerr("Failed to instantiate scene: %s" % resource_path)
			return false
		if not _validate_node_scripts(scene_instance, resource_path):
			scene_instance.free()
			return false
		scene_instance.free()

	print("Validated %s" % resource_path)
	return true

func _validate_script(script_resource: Script, resource_path: String) -> bool:
	if not script_resource.can_instantiate():
		printerr("Script cannot be instantiated: %s" % resource_path)
		return false
	return true

func _validate_node_scripts(node: Node, resource_path: String) -> bool:
	var node_script: Script = node.get_script()
	if node_script != null and node_script is Script:
		if not _validate_script(node_script as Script, resource_path):
			return false

	for child_node in node.get_children():
		if child_node is Node:
			if not _validate_node_scripts(child_node as Node, resource_path):
				return false

	return true

func _fail_and_quit(message: String) -> void:
	printerr(message)
	get_tree().quit(1)

## Mana System Plugin (Modular Ability & Networked Attributes)
## Created by Matthew Janes (IndieGameDad) - 2025

## Main plugin class responsible for registering and managing all MANA editor tools.
## Initializes custom inspectors, panels, and registry loaders for the plugin.
@tool class_name ManaSystem extends EditorPlugin


const VARIABLE_PREFIX_TAG: String = "MTag_"

## Registry Paths
const MANA_TAG_REGISTRY_PATH: String = "res://addons/mana_system/data/mana_tag_registry.tres"


func _enter_tree() -> void:
	add_control_to_bottom_panel(Control.new(), "Mana System")
	
	var refs: EditorFileSystem = get_editor_interface().get_resource_filesystem()
	refs.resources_reimported.connect(func(resources: PackedStringArray): _update_dynamic_enums())
	refs.resources_reload.connect(func(resources: PackedStringArray): _update_dynamic_enums())


func _exit_tree() -> void:
	pass


func _update_dynamic_enums() -> void:
	pass


static func get_mana_tag_registry(cache_mode: ResourceLoader.CacheMode = 1) -> ManaTagRegistry: 
	return ResourceLoader.load(MANA_TAG_REGISTRY_PATH, "Resource", cache_mode)

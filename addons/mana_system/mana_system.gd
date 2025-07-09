## Mana System Plugin (Modular Ability & Networked Attributes)
## Created by Matthew Janes (IndieGameDad) - 2025

## Main plugin class responsible for registering and managing all MANA editor tools.
## Initializes custom inspectors, panels, and registry loaders for the plugin.
@tool class_name ManaSystem extends EditorPlugin


const SUFFIX_HANDLE_TAGLIST: String = "mana_taglist"


func _enter_tree() -> void:
	add_control_to_bottom_panel(Control.new(), "Mana System")
	
	var refs: EditorFileSystem = get_editor_interface().get_resource_filesystem()
	refs.resources_reimported.connect(func(resources: PackedStringArray): _update_dynamic_enums())
	refs.resources_reload.connect(func(resources: PackedStringArray): _update_dynamic_enums())


func _exit_tree() -> void:
	pass


func _update_dynamic_enums() -> void:
	pass

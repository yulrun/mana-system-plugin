## @Project:        MANA System (Modular Ability & Networked Attributes)
## @Author:         Matthew Janes (IndieGameDad) - 2025


@tool class_name ManaSystem extends EditorPlugin


func _enter_tree() -> void:
	add_control_to_bottom_panel(Control.new(), "Mana System")


func _exit_tree() -> void:
	pass

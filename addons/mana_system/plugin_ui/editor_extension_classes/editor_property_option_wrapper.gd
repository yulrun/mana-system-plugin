## Mana System Plugin (Modular Ability & Networked Attributes)
## Created by Matthew Janes (IndieGameDad) - 2025

## Editor wrapper for OptionButton controls used in suffix-handled dropdowns.
## Handles value sync between editor property and selected item.
@tool class_name EditorPropertyOptionWrapper extends EditorProperty

var inner_control: OptionButton


## Description: Initializes the editor property with an OptionButton control.
## Usage: Used in suffix handlers to display dropdowns in the inspector.
func _init(control: OptionButton) -> void:
	inner_control = control
	add_child(inner_control)
	inner_control.item_selected.connect(_on_option_selected)


## Description: Called when the user selects an item in the dropdown.
## Usage: Emits the selected string (or "" if [None]) to the property system.
func _on_option_selected(index: int) -> void:
	var value: String = "" if index == 0 else inner_control.get_item_text(index)
	emit_changed(get_edited_property(), value)


## Description: Refreshes the editor UI when the value changes externally.
## Usage: Called automatically by the editor when the value is updated.
func update_property() -> void:
	call_deferred("_refresh_value")


## Description: Synchronizes the dropdown selection with the property value.
## Usage: Internal only — matches selected index to current property state.
func _refresh_value() -> void:
	var current: String = get_edited_object().get(get_edited_property())
	var selected_idx: int = 0

	for i in range(1, inner_control.item_count):
		if inner_control.get_item_text(i) == current:
			selected_idx = i
			break

	inner_control.select(selected_idx)
	inner_control.text = inner_control.get_item_text(selected_idx)

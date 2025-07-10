## MANA System Plugin (Modular Ability & Networked Attributes)
## Created by Matthew Janes (IndieGameDad) - 2025

## Inspector prefix handler for exposing tag dropdowns based on property name prefix.
## Supports single and multi-tag properties using MTag_ prefix for gameplay tags.
@tool class_name ManaVariablePrefixHandler extends EditorInspectorPlugin

var gameplay_tags_resource: ManaTagRegistry = ManaSystem.get_mana_tag_registry()
var prefix_handlers: Dictionary = {}


### Determines if this suffix handler applies to the given object.
## Required for all EditorInspectorPlugin subclasses.
## Called by Godot editor internals.
func _can_handle(object: Object) -> bool:
	return true


## Parses each property and injects custom editor UI if suffix matches.
## Only applies to properties ending in _mana_taglist.
## Routes handling to internal logic for tag dropdowns.
func _parse_property(object: Object, type: Variant.Type, name: String, hint: PropertyHint, hint_text: String, usage: int, wide: bool) -> bool:
	_initialize_prefix_handlers()
	
	var prefix: String = name.split("_")[0] + "_"
	if prefix_handlers.has(prefix):
		return _handle_prefixed_property(object, type, name, prefix, prefix_handlers[prefix])
	return false


## Description: Registers all known prefix handlers and their UI generation logic.
## Usage: Called once per inspector parse to initialize handler dispatch map.
## Adds support for tag, attribute, and future prefix-based systems.
func _initialize_prefix_handlers() -> void:
	if prefix_handlers.size() > 0:
		return # Already Initialized
	
	prefix_handlers[ManaSystem.VARIABLE_PREFIX_TAG] = {
		"get_choices": func() -> Array[String]:
			var tags: Array[String] = []
			for tag in gameplay_tags_resource.get_all_non_cue_tags():
				tags.append(tag.get_flat_name())
			return tags,

		"create_array_editor": func(array_val: Array[String]) -> EditorProperty:
			var editor: MultiTagEditorProperty = MultiTagEditorProperty.new()
			editor.initialize(array_val, gameplay_tags_resource, false)
			editor.set_read_only(false)
			return editor,

		"show_none": true
	}


## Builds tag editor widgets for string or array properties.
## Handles OptionButton or MultiTagEditorProperty creation.
## Applies cue filtering and dynamic label formatting.
func _handle_prefixed_property(object: Object, type: Variant.Type, name: String, prefix: String, handler: Dictionary) -> bool:
	var clean_label: String = name.substr(prefix.length()).capitalize()

	match type:
		TYPE_STRING:
			var choices: Array[String] = handler.get_choices.call()
			var current_value: String = object.get(name)
			var dropdown_data: Dictionary = _create_dropdown(choices, current_value, handler.show_none)
			var editor: EditorProperty = EditorPropertyOptionWrapper.new(dropdown_data.dropdown, dropdown_data.show_none)
			add_property_editor(name, editor, false, clean_label)
			return true

		TYPE_ARRAY:
			var array_val = object.get(name)
			# Ensure all array values are Strings
			if array_val.all(func(x): return typeof(x) == TYPE_STRING):
				var editor: EditorProperty = handler.create_array_editor.call(array_val)
				add_property_editor(name, editor, false, clean_label)
				return true

	return false


## Creates a reusable dropdown selector from an array of strings.
## Supports optional 'None' entry and a callback for selection logic.
func _create_dropdown(choices: Array[String], current_value: String, show_none: bool) -> Dictionary:
	var dropdown: OptionButton = OptionButton.new()
	
	if show_none:
		dropdown.add_item("(None)")
	
	for choice in choices:
		dropdown.add_item(choice)
	
	var offset: int = 1 if show_none else 0
	var found_index: int = 0
	
	for i in range(offset, dropdown.item_count):
		if dropdown.get_item_text(i) == current_value:
			found_index = i
			break
	
	dropdown.select(found_index)
	
	return {
		"dropdown" = dropdown,
		"show_none" = show_none
	}

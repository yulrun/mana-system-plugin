## MANA System Plugin (Modular Ability & Networked Attributes)
## Created by Matthew Janes (IndieGameDad) - 2025

## Inspector suffix handler for exposing tag dropdowns based on property name suffix.
## Supports single and multi-tag properties using _mana_taglist suffix.
@tool class_name ManaSuffixHandler extends EditorInspectorPlugin

var gameplay_tags_resource: ManaTagRegistry = ManaSystem.get_mana_tag_registry()


### Determines if this suffix handler applies to the given object.
## Required for all EditorInspectorPlugin subclasses.
## Called by Godot editor internals.
func _can_handle(object: Object) -> bool:
	return true


## Parses each property and injects custom editor UI if suffix matches.
## Only applies to properties ending in _mana_taglist.
## Routes handling to internal logic for tag dropdowns.
func _parse_property(object: Object, type: Variant.Type, name: String, hint: PropertyHint, hint_text: String, usage: int, wide: bool) -> bool:
	if name.ends_with(ManaSystem.SUFFIX_HANDLE_TAGLIST):
		return _handle_gameplay_tags(object, type, name, hint, hint_text, usage, wide)
	
	return false


## Builds tag editor widgets for string or array properties.
## Handles OptionButton or MultiTagEditorProperty creation.
## Applies cue filtering and dynamic label formatting.
func _handle_gameplay_tags(object: Object, type: Variant.Type, name: String, hint: PropertyHint, hint_text: String, usage: int, wide: bool) -> bool:
	var clean_label: String = name.substr(0, name.length() - ManaSystem.SUFFIX_HANDLE_TAGLIST.length()).capitalize()

	# Single tag string dropdown
	if type == TYPE_STRING:
		var tag_names: Array[String] = []
		for tag in gameplay_tags_resource.get_all_non_cue_tags():
			tag_names.append(tag.get_flat_name())

		var current_value: String = object.get(name)

		var dropdown: OptionButton = _create_dropdown(tag_names, current_value, false, func(index: int, dropdown_ref: OptionButton) -> void:
				var selected_tag: String = "" if index == 0 else dropdown_ref.get_item_text(index)
				object.set(name, selected_tag)
		)

		var editor: EditorProperty = EditorPropertyOptionWrapper.new(dropdown)
		add_property_editor(name, editor, false, clean_label)
		return true

	# Multi-tag array editor
	if type == TYPE_ARRAY:
		var array_val = object.get(name)
		if typeof(array_val) == TYPE_ARRAY and array_val.all(func(x): return typeof(x) == TYPE_STRING):
			var editor: MultiTagEditorProperty = MultiTagEditorProperty.new()
			editor.initialize(array_val, gameplay_tags_resource, false)
			editor.set_read_only(false)
			add_property_editor(name, editor, false, clean_label)
			return true

	return false


## Creates a reusable dropdown selector from an array of strings.
## Supports optional '[None]' entry and a callback for selection logic.
func _create_dropdown(choices: Array[String], current_value: String, show_none: bool, on_select: Callable) -> OptionButton:
	var dropdown: OptionButton = OptionButton.new()
	if show_none:
		dropdown.add_item("[None]")

	for choice in choices:
		dropdown.add_item(choice)

	var offset: int = 1 if show_none else 0
	var found_index: int = 0
	for i in range(offset, dropdown.item_count):
		if dropdown.get_item_text(i) == current_value:
			found_index = i
			break

	dropdown.select(found_index)

	dropdown.item_selected.connect(func(index: int) -> void:
		on_select.call(index, dropdown)
	)

	return dropdown

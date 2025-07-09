## Mana System Plugin (Modular Ability & Networked Attributes)
## Created by Matthew Janes (IndieGameDad) - 2025

## A custom editor property used for selecting multiple ManaTags via dropdowns.
## Supports Cue vs Non-Cue tag filtering and dynamic add/remove functionality.
@tool class_name MultiTagEditorProperty extends EditorProperty

const EXPAND_TEXT: String = "Expand Tag List"
const COLLAPS_TEXT: String = "Collapse Tag List"
const BUTTON_ADD_TAG: String = "Add Tag"

const EXPAND_TEXT_CUE: String = "Expand Cue Tag List"
const COLLAPS_TEXT_CUE: String = "Collapse Cue Tag List"
const BUTTON_ADD_TAG_CUE: String = "Add Cue Tag"

@onready var ICON_EXPAND: Texture2D = get_theme_icon("ExpandTree", "EditorIcons")
@onready var ICON_COLLAPSE: Texture2D = get_theme_icon("CollapseTree", "EditorIcons")
@onready var ICON_ADD: Texture2D = get_theme_icon("Add", "EditorIcons")

var tag_registry: ManaTagRegistry
var all_tags: Array[ManaTag] = []
var tags: Array[ManaTag] = []

var container: VBoxContainer
var add_button: Button
var fold_button: Button
var is_expanded: bool = false
var is_cue_tag: bool = false
var _refreshing: bool = false


## Initializes the editor with given tag list and registry reference.
## Called by suffix handler to pass tag context and cue type.
func initialize(initial_tags: Array[String], registry: ManaTagRegistry, cue_mode: bool = false) -> void:
	is_cue_tag = cue_mode
	tag_registry = registry
	all_tags = tag_registry.get_all_cue_tags() if is_cue_tag else tag_registry.get_all_non_cue_tags()

	tags.clear()
	for flat_tag in initial_tags:
		for tag in all_tags:
			if tag.get_flat_name() == flat_tag:
				tags.append(tag)
				break

	_setup_ui()
	call_deferred("_refresh")


## Builds the main layout and expand/collapse toggle.
func _setup_ui() -> void:
	fold_button = Button.new()
	fold_button.toggle_mode = true
	fold_button.set_pressed_no_signal(is_expanded)
	fold_button.focus_mode = Control.FOCUS_NONE
	fold_button.toggled.connect(_on_fold_button_toggled)

	fold_button.text = COLLAPS_TEXT_CUE if is_expanded and is_cue_tag else COLLAPS_TEXT if is_expanded else EXPAND_TEXT_CUE if is_cue_tag else EXPAND_TEXT
	fold_button.icon = ICON_COLLAPSE if is_expanded else ICON_EXPAND

	container = VBoxContainer.new()
	container.visible = is_expanded

	var main_vbox: VBoxContainer = VBoxContainer.new()
	main_vbox.add_child(fold_button)
	main_vbox.add_child(container)
	add_child(main_vbox)


## Called when expand/collapse toggle is pressed.
func _on_fold_button_toggled(pressed: bool) -> void:
	is_expanded = pressed
	container.visible = pressed
	fold_button.text = COLLAPS_TEXT_CUE if pressed and is_cue_tag else COLLAPS_TEXT if pressed else EXPAND_TEXT_CUE if is_cue_tag else EXPAND_TEXT
	fold_button.icon = ICON_COLLAPSE if pressed else ICON_EXPAND


## Rebuilds all dropdowns and Add button.
func _refresh() -> void:
	if _refreshing:
		return
	_refreshing = true

	all_tags = tag_registry.get_all_cue_tags() if is_cue_tag else tag_registry.get_all_non_cue_tags()

	# Normalize tag references and remove stale ones
	var rebuilt_tags: Array[ManaTag] = []
	for tag in tags:
		for real_tag in all_tags:
			if real_tag.get_flat_name() == tag.get_flat_name():
				rebuilt_tags.append(real_tag)
				break
	tags = rebuilt_tags

	container.queue_free()
	container = VBoxContainer.new()
	container.visible = is_expanded
	get_child(0).add_child(container)

	for i in range(tags.size()):
		_build_dropdown_row(i)

	add_button = Button.new()
	add_button.text = BUTTON_ADD_TAG_CUE if is_cue_tag else BUTTON_ADD_TAG
	add_button.icon = ICON_ADD
	add_button.focus_mode = Control.FOCUS_NONE
	add_button.disabled = _get_unused_tags().is_empty()
	add_button.pressed.connect(_on_add_pressed)

	container.add_child(add_button)
	call_deferred("_update_property")

	_refreshing = false


## Builds a single dropdown + remove row.
func _build_dropdown_row(i: int) -> void:
	var hbox: HBoxContainer = HBoxContainer.new()
	var dropdown: OptionButton = OptionButton.new()
	dropdown.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var used_flat_names: Array[String] = []
	for j in range(tags.size()):
		if j != i:
			used_flat_names.append(tags[j].get_flat_name())

	for tag in all_tags:
		var flat_name: String = tag.get_flat_name()
		var idx: int = dropdown.item_count
		dropdown.add_item(flat_name)
		if flat_name in used_flat_names:
			dropdown.set_item_disabled(idx, true)

	var selected_index: int = all_tags.find(tags[i])
	if selected_index >= 0:
		dropdown.select(selected_index)

	dropdown.item_selected.connect(func(index: int) -> void:
		var selected_tag: ManaTag = all_tags[index]
		if selected_tag in tags and tags[i] != selected_tag:
			var old_index: int = all_tags.find(tags[i])
			if old_index >= 0:
				dropdown.select(old_index)
			return

		tags[i] = selected_tag

		var flat: Array[String] = []
		for t in tags:
			flat.append(t.get_flat_name())
		emit_changed(get_edited_property(), flat)

		call_deferred("_refresh")
	)

	var remove_button: Button = Button.new()
	remove_button.icon = get_theme_icon("Remove", "EditorIcons")
	remove_button.tooltip_text = "Remove Cue Tag" if is_cue_tag else "Remove Tag"
	remove_button.focus_mode = Control.FOCUS_NONE
	remove_button.pressed.connect(func() -> void:
		tags.remove_at(i)

		var flat: Array[String] = []
		for t in tags:
			flat.append(t.get_flat_name())
		emit_changed(get_edited_property(), flat)

		_refresh()
	)

	hbox.add_child(dropdown)
	hbox.add_child(remove_button)
	container.add_child(hbox)


## Returns available ManaTags not already used.
func _get_unused_tags() -> Array[ManaTag]:
	var used_flat: Array[String] = []
	for tag in tags:
		used_flat.append(tag.get_flat_name())

	var result: Array[ManaTag] = []
	for tag in all_tags:
		if not used_flat.has(tag.get_flat_name()):
			result.append(tag)
	return result


## Called when Add Tag button is pressed.
func _on_add_pressed() -> void:
	var unused: Array[ManaTag] = _get_unused_tags()
	if not unused.is_empty():
		tags.append(unused[0])

		var flat: Array[String] = []
		for t in tags:
			flat.append(t.get_flat_name())
		emit_changed(get_edited_property(), flat)

		_refresh()


## Updates UI when external data changes.
func _update_property() -> void:
	var raw = get_edited_object().get(get_edited_property())
	
	if raw == null or not raw is Array:
		return
	
	# Defensive check: all entries must be strings
	var is_valid = true
	for val in raw:
		if typeof(val) != TYPE_STRING:
			is_valid = false
			break
	if not is_valid:
		return
	
	var rebuilt: Array[ManaTag] = []
	for flat in raw:
		for tag in all_tags:
			if tag.get_flat_name() == flat:
				rebuilt.append(tag)
				break
	
	# Only update if different than current
	var current_flat: Array[String] = []
	for tag in tags:
		current_flat.append(tag.get_flat_name())
	
	var new_flat: Array[String] = []
	for tag in rebuilt:
		new_flat.append(tag.get_flat_name())
	
	if current_flat != new_flat:
		tags = rebuilt
		call_deferred("_refresh")

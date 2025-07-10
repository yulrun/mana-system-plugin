## Mana System Plugin (Modular Ability & Networked Attributes)
## Created by Matthew Janes (IndieGameDad) - 2025

## A custom editor property for selecting multiple ManaTags.
## Mimics native Array behavior with clean toggle and compact layout.
@tool class_name MultiTagEditorProperty extends EditorProperty

@onready var ICON_ADD: Texture2D = get_theme_icon("Add", "EditorIcons")
@onready var ICON_REMOVE: Texture2D = get_theme_icon("Remove", "EditorIcons")

var tag_registry: ManaTagRegistry
var all_tags: Array[ManaTag] = []
var tags: Array[ManaTag] = []

var is_cue_tag: bool = false
var is_expanded: bool = true
var _refreshing: bool = false

var fold_button: Button
var container: VBoxContainer
var main_container: VBoxContainer


## Initializes the editor with flat tag names and registry.
func initialize(initial_tags: Array[String], registry: ManaTagRegistry, cue_mode: bool = false) -> void:
	is_cue_tag = cue_mode
	tag_registry = registry
	all_tags = tag_registry.get_all_cue_tags() if is_cue_tag else tag_registry.get_all_non_cue_tags()

	tags.clear()
	for flat in initial_tags:
		for tag in all_tags:
			if tag.get_flat_name() == flat:
				tags.append(tag)
				break

	_setup_ui()
	call_deferred("_refresh")


## Builds the expand button and container.
func _setup_ui() -> void:
	main_container = VBoxContainer.new()
	main_container.custom_minimum_size = Vector2(0, 48)
	add_child(main_container)

	fold_button = Button.new()
	fold_button.toggle_mode = true
	fold_button.focus_mode = Control.FOCUS_NONE
	fold_button.set_pressed_no_signal(is_expanded)
	fold_button.toggled.connect(_on_fold_button_toggled)
	_update_fold_button_text()

	main_container.add_child(fold_button)

	container = VBoxContainer.new()
	container.visible = is_expanded
	main_container.add_child(container)


## Expand/collapse toggle.
func _on_fold_button_toggled(pressed: bool) -> void:
	is_expanded = pressed
	container.visible = pressed
	_update_fold_button_text()


## Updates the fold button text with tag count.
func _update_fold_button_text() -> void:
	var label: String = "ManaCueList" if is_cue_tag else "ManaTagList"
	fold_button.text = "%s (%d)" % [label, tags.size()]


## Rebuilds tag UI and Add button.
func _refresh() -> void:
	if _refreshing:
		return
	_refreshing = true

	all_tags = tag_registry.get_all_cue_tags() if is_cue_tag else tag_registry.get_all_non_cue_tags()

	# Revalidate existing tags
	var rebuilt: Array[ManaTag] = []
	for tag in tags:
		for real in all_tags:
			if real.get_flat_name() == tag.get_flat_name():
				rebuilt.append(real)
				break
	tags = rebuilt

	# Clear old rows
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()

	for i in range(tags.size()):
		_build_row(i)

	var add_button: Button = Button.new()
	add_button.icon = ICON_ADD
	add_button.text = "Add Cue Tag" if is_cue_tag else "Add Tag"
	add_button.focus_mode = Control.FOCUS_NONE
	add_button.disabled = _get_unused_tags().is_empty()
	add_button.pressed.connect(_on_add_pressed)

	container.add_child(add_button)

	call_deferred("_update_property")
	_update_fold_button_text()
	_refreshing = false


## Builds a dropdown+remove row at index.
func _build_row(index: int) -> void:
	var row: HBoxContainer = HBoxContainer.new()

	var dropdown: OptionButton = OptionButton.new()
	dropdown.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var used: Array[String] = []
	for i in range(tags.size()):
		if i != index:
			used.append(tags[i].get_flat_name())

	for tag in all_tags:
		var name: String = tag.get_flat_name()
		var idx: int = dropdown.item_count
		dropdown.add_item(name)
		if used.has(name):
			dropdown.set_item_disabled(idx, true)

	var selected_index: int = all_tags.find(tags[index])
	if selected_index >= 0:
		dropdown.select(selected_index)

	dropdown.item_selected.connect(func(i: int) -> void:
		var selected: ManaTag = all_tags[i]
		if selected in tags and tags[index] != selected:
			dropdown.select(all_tags.find(tags[index]))
			return
		tags[index] = selected
		_emit_changed()
		call_deferred("_refresh")
	)

	var remove: Button = Button.new()
	remove.icon = ICON_REMOVE
	remove.tooltip_text = "Remove Cue Tag" if is_cue_tag else "Remove Tag"
	remove.focus_mode = Control.FOCUS_NONE
	remove.pressed.connect(func() -> void:
		tags.remove_at(index)
		_emit_changed()
		call_deferred("_refresh")
	)

	row.add_child(dropdown)
	row.add_child(remove)
	container.add_child(row)


## Emits the updated flat list.
func _emit_changed() -> void:
	var flat: Array[String] = []
	for tag in tags:
		flat.append(tag.get_flat_name())
	emit_changed(get_edited_property(), flat)


## Adds first unused tag.
func _on_add_pressed() -> void:
	var unused: Array[ManaTag] = _get_unused_tags()
	if not unused.is_empty():
		tags.append(unused[0])
		_emit_changed()
		call_deferred("_refresh")


## Finds unused tag objects.
func _get_unused_tags() -> Array[ManaTag]:
	var used: Array[String] = []
	for tag in tags:
		used.append(tag.get_flat_name())

	var result: Array[ManaTag] = []
	for tag in all_tags:
		if not used.has(tag.get_flat_name()):
			result.append(tag)
	return result


## Rebuilds if external data changed.
func _update_property() -> void:
	var raw = get_edited_object().get(get_edited_property())
	if raw == null or not raw is Array:
		return

	for item in raw:
		if typeof(item) != TYPE_STRING:
			return

	var rebuilt: Array[ManaTag] = []
	for flat in raw:
		for tag in all_tags:
			if tag.get_flat_name() == flat:
				rebuilt.append(tag)
				break

	var current: Array[String] = []
	for tag in tags:
		current.append(tag.get_flat_name())

	var new_val: Array[String] = []
	for tag in rebuilt:
		new_val.append(tag.get_flat_name())

	if current != new_val:
		tags = rebuilt
		call_deferred("_refresh")

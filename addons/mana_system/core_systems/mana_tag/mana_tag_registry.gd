## Mana System Plugin (Modular Ability & Networked Attributes)
## Created by Matthew Janes (IndieGameDad) - 2025
##
## System: Mana Tag System
## Centralized registry that stores all available ManaTags in the project.
## Supports tag lookup, validation, categorization, and tree-structure generation.


@tool class_name ManaTagRegistry extends Resource


@export var available_tags: Dictionary = {} # flat_name (String) -> ManaTag


## Description: Adds a tag to the registry if it doesn't already exist
## Usage: Used during plugin initialization or user creation of new tags
func add_tag(tag: ManaTag) -> void:
	var flat_name = tag.tag_name
	if available_tags.has(flat_name):
		push_warning("Tag '%s' already exists in registry." % flat_name)
		return
	available_tags[flat_name] = tag


## Description: Removes a tag from the registry using its flat name
## Usage: Used when deleting tags from the system or cleaning up unused data
func remove_tag_by_flat_name(flat_name: String) -> void:
	available_tags.erase(flat_name)


## Description: Returns all registered tags
## Usage: Used to populate dropdowns and search systems
func get_all_tags() -> Array[ManaTag]:
	return available_tags.values()


## Description: Returns the tag whose `tag_name` matches the flat name
## Usage: Used for fast lookups from string references
func get_tag_by_flat_name(flat_name: String) -> ManaTag:
	return available_tags.get(flat_name, null)


## Description: Returns an array of all flat tag names from registered tags
## Usage: Used for filtering, validation, and duplication checking
func get_all_flat_names() -> Array[String]:
	return available_tags.keys()


## Description: Returns true if a tag with the given flat name exists
## Usage: Used for editor validation and duplicate checks
func has_tag(flat_name: String) -> bool:
	return available_tags.has(flat_name)


## Description: Returns only the tags marked as `is_cue == true`
## Usage: Used to populate cue dropdowns
func get_all_cue_tags() -> Array[ManaTag]:
	var cue_tags: Array[ManaTag] = []
	for tag in available_tags.values():
		if tag.is_cue:
			cue_tags.append(tag)
	return cue_tags


## Description: Returns only the tags where `is_cue == false`
## Usage: Used by non-cue systems like Abilities, Effects, etc.
func get_all_non_cue_tags() -> Array[ManaTag]:
	var non_cue_tags: Array[ManaTag] = []
	for tag in available_tags.values():
		if not tag.is_cue:
			non_cue_tags.append(tag)
	return non_cue_tags


## Description: Returns a nested dictionary representing the tag hierarchy
## Usage: Used to build tree views or nested structures for editor use
func get_tag_tree_data() -> Dictionary:
	var tree: Dictionary = {}
	for tag in available_tags.values():
		var parts: Array[String] = tag.tag_name.split(".")
		var current: Dictionary = tree
		for i in parts.size():
			var part: String = parts[i]
			
			# Ensure sub-branch exists
			if not current.has(part):
				current[part] = {}
				
			current = current[part]
			
			# On the last part, store the actual tag resource
			if i == parts.size() - 1:
				current["__tag__"] = tag

	return tree

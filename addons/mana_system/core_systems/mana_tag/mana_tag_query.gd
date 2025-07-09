## Mana System Plugin (Modular Ability & Networked Attributes)
## Created by Matthew Janes (IndieGameDad) - 2025

## Defines a tag-based query for checking if a ManaTagContainer satisfies specific conditions.
## Supports required, optional (any), and blocked tag checks used across gameplay systems.
@tool class_name ManaTagQuery extends Resource

@export var required_tags: ManaTagContainer
@export var any_tags: ManaTagContainer
@export var blocked_tags: ManaTagContainer


## Description: Returns true if the given tag container satisfies the query
## Usage: Used to gate abilities, effects, or actions based on active tags
func matches(tag_container: ManaTagContainer) -> bool:
	var has_all_required: bool = has_required(tag_container)
	var passes_optional: bool = any_tags.get_flat_tag_names().is_empty() or has_any(tag_container)
	var not_blocked: bool = not is_blocked_by(tag_container)

	return has_all_required and passes_optional and not_blocked


## Description: Returns true if any required tag is missing
## Usage: Called internally by matches() to validate strict tag requirements
func has_required(tag_container: ManaTagContainer) -> bool:
	for flat_name in required_tags.get_flat_tag_names():
		if not tag_container.has(flat_name):
			return false
	return true


## Description: Returns true if none of the "any" tags are present
## Usage: Called internally by matches() to validate optional tag presence
func has_any(tag_container: ManaTagContainer) -> bool:
	for flat_name in any_tags.get_flat_tag_names():
		if tag_container.has(flat_name):
			return true
	return false


## Description: Returns true if any blocked tag is active
## Usage: Called internally by matches() to ensure conflicting tags are absent
func is_blocked_by(tag_container: ManaTagContainer) -> bool:
	for flat_name in blocked_tags.get_flat_tag_names():
		if tag_container.has(flat_name):
			return true
	return false

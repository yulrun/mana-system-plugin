## Mana System Plugin (Modular Ability & Networked Attributes)
## Created by Matthew Janes (IndieGameDad) - 2025
##
## System: Mana Tag System
## A flexible tag container that stores active ManaTags and their sources.
## Provides powerful query, merge, and modification helpers for tag-based systems.


@tool class_name ManaTagContainer extends Resource


signal tag_added(tag: ManaTag, source: Node)
signal tag_removed(tag: ManaTag, source: Node)

@export var tags_mana_taglist: Array[String] = []:
	set(value):
		push_warning("tags_mana_taglist is read-only. Use add_tag() and remove_tag() instead.")
	get():
		return get_flat_tag_names()

# key: flat_name {
#		"resource": ManaTag,
#		"sources": Array[Node]}
var tags: Dictionary = {}


## Description: Adds a tag from the given source
## Usage: Used by ManaTagComponent and other systems
func add_tag(tag: ManaTag, source: Node) -> void:
	var flat_name: String = tag.tag_name
	
	if not tags.has(flat_name):
		tags[flat_name] = {
			resource = tag,
			sources = [] as Array[Node]
		}
	
	if not tags[flat_name].sources.has(source):
		tags[flat_name].sources.append(source)
		tag_added.emit(tag, source)


## Description: Removes a source from a tag, and removes tag if last source
## Usage: Used when effects or abilities end
func remove_tag(tag: ManaTag, source: Node) -> void:
	var flat_name: String = tag.tag_name
	
	if not tags.has(flat_name) or not tags[flat_name].sources.has(source):
		return
	
	tags[flat_name].sources.erase(source)
	
	if tags[flat_name].sources.is_empty():
		tags.erase(flat_name)
	
	tag_removed.emit(tag, source)


## Description: Forcefully removes a Tag no matter the sources
## Usage: Used in an override state
func force_remove_tag(tag: ManaTag) -> void:
	var flat_name: String = tag.tag_name
	
	if not tags.has(flat_name):
		return
	
	tags.erase(flat_name)
	tag_removed.emit(tag, self)


## Description: Removes all tags granted by that source
## Usage: Used to clean up tags when a system ends
func remove_tags_by_source(source: Node) -> void:
	var tags_to_remove: Array[String] = []

	for flat_name in tags.keys():
		var tag_data: Dictionary = tags[flat_name]
		var sources: Array[Node] = tag_data.sources

		if sources.has(source):
			sources.erase(source)
			tag_removed.emit(tag_data.resource, source)

			if sources.is_empty():
				tags_to_remove.append(flat_name)

	for flat_name in tags_to_remove:
		tags.erase(flat_name)


## Description: Removes all tags from all sources
## Usage: Used on full reset
func remove_all_tags() -> void:
	for flat_name in tags.keys():
		tag_removed.emit(tags[flat_name].resource, self)
	tags.clear()


## Description: Returns an array of all active ManaTag resources in the container
## Usage: Used when iterating over all tracked tags or merging containers
func get_tags() -> Array[ManaTag]:
	var mana_tags: Array[ManaTag] = []
	for flat_name in tags.keys():
		mana_tags.append(tags[flat_name].resource)
	return mana_tags


## Description: Returns list of sources that applied the tag
## Usage: Used for cleanup or filtering
func get_sources_for_tag(flat_name: String) -> Array[Node]:
	if tags.has(flat_name):
		return tags[flat_name].sources
	return [] as Array[Node]


## Description: Returns the tag resource for a flat name
## Usage: Used for lookups from external systems
func get_tag_by_flat_name(flat_name: String) -> ManaTag:
	if tags.has(flat_name):
		return tags[flat_name].resource
	return null


## Description: Returns flat names of all active tags
## Usage: Used for filtering and debug tools
func get_flat_tag_names() -> Array[String]:
	return tags.keys()


## Description: Returns true if the container includes this tag
## Usage: Used in tag-based logic
func has(flat_name: String) -> bool:
	return tags.has(flat_name)


## Description: Returns true if all tags in the array exist in the container
## Usage: Used for validation checks and tag queries
func has_all(flat_names: Array[String]) -> bool:
	for flat_name in flat_names:
		if not has(flat_name):
			return false
	return true


## Description: Returns true if at least one tag in the array exists
## Usage: Used for branching behavior or query satisfaction
func has_any(flat_names: Array[String]) -> bool:
	for flat_name in flat_names:
		if has(flat_name):
			return true
	return false


## Description: Returns true if none of the given tags exist
## Usage: Used to block behavior if any listed tags are active
func has_none(flat_names: Array[String]) -> bool:
	for flat_name in flat_names:
		if has(flat_name):
			return false
	return true


## Description: Merges another container's tags into this one, preserving all sources
## Usage: Used when combining tag sets from different systems (e.g. abilities, effects)
func merge(container: ManaTagContainer) -> void:
	for tag in container.get_tags():
		var flat_name: String = tag.tag_name
		var sources: Array[Node] = container.get_sources_for_tag(flat_name)
		
		if not tags.has(flat_name):
			tags[flat_name] = {
				resource = tag,
				sources = [] as Array[Node]
			}
		
		var existing_sources: Array[Node] = tags[flat_name].sources
		for source in sources:
			if not existing_sources.has(source):
				existing_sources.append(source)
				tag_added.emit(tag, source)


## Description: Removes empty tag references from tags
## Usage: Only for manual debugging, never should be needed unless a bug happens
func prune_empties() -> void:
	var flat_names_to_remove: Array[String] = []
	
	for flat_name in tags.keys():
		var tag_data: Dictionary = tags[flat_name]
		if tag_data == null or not tag_data.has("sources") or tag_data.sources.is_empty():
			flat_names_to_remove.append(flat_name)
	
	for flat_name in flat_names_to_remove:
		tags.erase(flat_name)


## Description: Prints all active tags and their sources to the debug console
## Usage: Used during development to inspect the internal state of the container
func to_debug_string() -> void:
	for flat_name in tags.keys():
		print_debug("%s -> Sources: %s" % [flat_name, tags[flat_name].sources])

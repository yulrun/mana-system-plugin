## Mana System Plugin (Modular Ability & Networked Attributes)
## Created by Matthew Janes (IndieGameDad) - 2025
##
## System: Gameplay Tag System
## A container used to house GameplayTag's with a lot of useful helper functions

@tool class_name GameplayTagContainer extends Resource


signal tag_added(tag: GameplayTag, source: Node)
signal tag_removed(tag: GameplayTag, source: Node)

@export var tags_mana_taglist: Array[String] = []:
	set(value):
		push_warning("tags_mana_taglist is read-only. Use add_tag() and remove_tag() instead.")
	get():
		return get_flat_tag_names()

var tags: Dictionary = {} # keys are GameplayTags and its value are an Array[Node] (sources)
var _flat_tag_name_cache: Array[String] = []


## Description: Adds a tag from the given source
## Usage: Used by GameplayTagComponent and other systems
func add_tag(tag: GameplayTag, source: Node) -> void:
	if not tags.has(tag):
		if not _flat_tag_name_cache.has(tag.tag_name):
			_flat_tag_name_cache.append(tag.tag_name)
		tags[tag] = []
	if not tags[tag].has(source):
		tags[tag].append(source)
		tag_added.emit(tag, source)


## Description: Removes a source from a tag, and removes tag if last source
## Usage: Used when effects or abilities end
func remove_tag(tag: GameplayTag, source: Node) -> void:
	if not tags.has(tag) or not tags[tag].has(source):
		return
	
	tags[tag].erase(source)
	
	if tags[tag].is_empty():
		_flat_tag_name_cache.erase(tag.tag_name)
		tags.erase(tag)
	
	tag_removed.emit(tag, source)


## Description: Forcefully removes a Tag no matter the sources
## Usage: Used in an override state
func force_remove_tag(tag: GameplayTag) -> void:
	if not tags.has(tag):
		return
	_flat_tag_name_cache.erase(tag.tag_name)
	tags.erase(tag)
	tag_removed.emit(tag, self)


## Description: Removes all tags granted by that source
## Usage: Used to clean up tags when a system ends
func remove_tags_by_source(source: Node) -> void:
	var tags_to_remove := []
	for tag in tags.keys():
		var sources = tags[tag]
		if sources is Array[Node] and sources.has(source):
			sources.erase(source)
			tag_removed.emit(tag, source)
			if sources.is_empty():
				tags_to_remove.append(tag)
	for tag in tags_to_remove:
		_flat_tag_name_cache.erase(tag.tag_name)
		tags.erase(tag)


## Description: Removes all tags from all sources
## Usage: Used on full reset
func remove_all_tags() -> void:
	for tag in tags.keys():
		tag_removed.emit(tag, self)
	_flat_tag_name_cache.clear()
	tags.clear()


func get_tags() -> Array[GameplayTag]:
	return tags.keys()


## Description: Returns list of sources that applied the tag
## Usage: Used for cleanup or filtering
func get_sources_for_tag(flat_name: String) -> Array[Node]:
	for tag in tags.keys():
		if tag.tag_name == flat_name:
			return tags[tag]
	return [] as Array[Node]


## Description: Returns the tag resource for a flat name
## Usage: Used for lookups from external systems
func get_tag_by_flat_name(flat_name: String) -> GameplayTag:
	for tag in tags.keys():
		if tag.tag_name == flat_name:
			return tag
	return null


## Description: Returns flat names of all active tags
## Usage: Used for filtering and debug tools
func get_flat_tag_names() -> Array[String]:
	return _flat_tag_name_cache.duplicate()


## Description: Returns true if the container includes this tag
## Usage: Used in tag-based logic
func has(flat_name: String) -> bool:
	return _flat_tag_name_cache.has(flat_name)


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
func merge(container: GameplayTagContainer) -> void:
	for tag in container.get_tags():
		var flat_name: String = tag.tag_name
		var sources: Array[Node] = container.get_sources_for_tag(flat_name)
		# Add the tag name to our flat name cache if it's not already present
		if not _flat_tag_name_cache.has(flat_name):
			_flat_tag_name_cache.append(flat_name)
		# If we don't already have the tag, prepare its source list
		if not tags.has(tag):
			tags[tag] = []
		# Append any new sources and emit signal per source
		for source in sources:
			if not tags[tag].has(source):
				tags[tag].append(source)
				tag_added.emit(tag, source)


## Description: Removes empty tag references from tags
## Usage: Only for manual debugging, never should be needed unless a bug happens
func prune_empties() -> void:
	var tags_to_remove: Array[GameplayTag] = []
	for tag in tags.keys():
		if tags[tag] == null or tags[tag].is_empty():
			tags_to_remove.append(tag)
	for tag in tags_to_remove:
		tags.erase(tag)
		_flat_tag_name_cache.erase(tag.tag_name)


## Description: Prints all active tags and their sources to the debug console
## Usage: Used during development to inspect the internal state of the container
func to_debug_string() -> void:
	for tag in tags.keys():
		print_debug("%s -> Sources: %s" % [tag.tag_name, tags[tag]])

## Mana System Plugin (Modular Ability & Networked Attributes)
## Created by Matthew Janes (IndieGameDad) - 2025

## The core tag resource representing a single gameplay tag with metadata like category and cue status.
## Used across all MANA systems for tag-based logic, classification, filtering, and identification.
@tool class_name ManaTag extends Resource

@export var is_cue: bool = false
@export var tag_name: String:
	set(value):
		base_name = _strip_cue_from_name(value)
	get:
		return get_flat_name()

var base_name: String


## Internal function, used to get the full flat name of a GameplayTag this will
## prefix the base_name with "Cue." if it is_cue and doesn't already have a prefix
func get_flat_name() -> String:
	if is_cue and not base_name.to_lower().begins_with("cue."):
		return "%s%s" % ["Cue.", base_name]
	return base_name


## Internal function, used to strip "Cue." prefixes when assigning the tag_name
## this is dne to ensure "Cue." is only ever added once, when referencing the 
## tag_name variable in code
func _strip_cue_from_name(cue_name: String) -> String:
	if cue_name.to_lower().begins_with("cue."):
		return _strip_cue_from_name(cue_name.substr(4))
	return cue_name

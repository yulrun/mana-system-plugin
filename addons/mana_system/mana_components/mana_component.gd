## Mana System Plugin (Modular Ability & Networked Attributes)
## Created by Matthew Janes (IndieGameDad) - 2025

## The root container for all active MANA systems on an actor or entity.
## Manages global sync logic, component references, and future expansion hooks.
@tool class_name ManaComponent extends Node

@onready var tag_component: ManaTagComponent = %ManaTagComponent


## Returns a Dictionary containing sync data from all registered components.
## Called on the server before sending sync state to clients or saving.
func get_sync_data() -> Dictionary:
	var data: Dictionary = {}
	
	if is_instance_valid(tag_component):
		data[ManaTagComponent.SYNC_KEY] = tag_component.get_sync_data()
	
	return data


## Applies a sync state from the server to all child components.
## Called on clients when joining the game or receiving a state update.
func sync_data_from_server(data: Dictionary) -> void:
	if data.has(ManaTagComponent.SYNC_KEY) and is_instance_valid(tag_component):
		tag_component.sync_tags_from_server(data[ManaTagComponent.SYNC_KEY])

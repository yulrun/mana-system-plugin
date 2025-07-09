## Mana System Plugin (Modular Ability & Networked Attributes)
## Created by Matthew Janes (IndieGameDad) - 2025

## The runtime component that manages all active ManaTags for an actor or entity.
## Handles tag addition, removal, source tracking, and replication for tag-based systems.
@tool class_name ManaTagComponent extends Node

signal tag_added(tag: ManaTag, source: Node)
signal tag_removed(tag: ManaTag, source: Node)

const SYNC_KEY: String = "tags"

var tag_container: ManaTagContainer


## Description: Called when the node enters the scene tree.
## Usage: Initializes the tag container and connects internal signals to component signals.
func _ready() -> void:
	if tag_container == null:
		tag_container = ManaTagContainer.new()
		
	tag_container.tag_added.connect(_on_tag_added)
	tag_container.tag_removed.connect(_on_tag_removed)


## Description: Adds a tag to the container from a given source.
## Usage: Called by abilities, effects, or other systems to grant tags to this actor.
func add_tag(tag: ManaTag, source: Node) -> void:
	if multiplayer.is_server():
		tag_container.add_tag(tag, source)
		_sync_state_to_clients()


## Description: Removes a tag from a given source.
## Usage: Called by systems when the effect or tag source is no longer valid.
func remove_tag(tag: ManaTag, source: Node) -> void:
	if multiplayer.is_server():
		tag_container.remove_tag(tag, source)
		_sync_state_to_clients()


## Description: Returns true if the given tag exists in this component.
## Usage: Used by external systems to check for tag presence without querying the container directly.
func has_tag(flat_name: String) -> bool:
	return tag_container.has(flat_name)


## Description: Returns all active ManaTags tracked by this component.
## Usage: Used for debugging, UI display, or merge operations.
func get_tags() -> Array[ManaTag]:
	return tag_container.get_tags()


## Description: Checks whether this tag component satisfies a tag query.
## Usage: Used to validate tag requirements or conditional behaviors.
func matches_query(query: ManaTagQuery) -> bool:
	return query.matches(tag_container)


## Description: Removes all tags that originated from the given source.
## Usage: Called when a system ends and all of its tags should be cleared.
func remove_tags_from_source(source: Node) -> void:
	tag_container.remove_tags_from_source(source)


## Description: Clears all tags from all sources on this component.
## Usage: Used when resetting an actor’s state or removing all applied tags.
func remove_all_tags() -> void:
	tag_container.remove_all_tags()


## Description: Forwards internal tag_added signal from the container.
## Usage: Allows external systems to listen to tag events via the component.
func _on_tag_added(tag: ManaTag, source: Node) -> void:
	tag_added.emit(tag, source)


## Description: Forwards internal tag_removed signal from the container.
## Usage: Allows external systems to listen to tag events via the component.
func _on_tag_removed(tag: ManaTag, source: Node) -> void:
	tag_removed.emit(tag, source)


## Description: Synchronizes the full tag state from the server to this client.
## Usage: Called on clients when first connecting or when a resync is needed.
@rpc("authority", "call_local")
func sync_tags_from_server(sync_tags: Dictionary) -> void:
	tag_container.tags = sync_tags
	# Re-emit events to inform listeners
	for flat_name in sync_tags.keys():
		var data = sync_tags[flat_name]
		if typeof(data) == TYPE_DICTIONARY and data.has("resource") and data.has("sources"):
			var tag: ManaTag = data.resource
			for source in data.sources:
				tag_added.emit(tag, source)


## Description: Returns the current tag data as a Dictionary for saving or network sync.
## Usage: Called locally by the server-side [[ManaComponent]] to gather sync state for this component.
## Should only be called by server logic, never directly by clients.
func get_sync_data() -> Dictionary:
	return tag_container.tags


## Description: Sends the current tag state from the server to all connected clients.
## Usage: Called internally after any tag change to replicate the new tag state.
func _sync_state_to_clients() -> void:
	if multiplayer.is_server():
		sync_tags_from_server.rpc(tag_container.tags)

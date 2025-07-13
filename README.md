<!-- Title Image -->
<p align="center">
  <img src="./docs/mana-logo.svg" alt="MANA System Logo" height="200">
</p>
<p align="center">
  <a href="https://ko-fi.com/indiegamedad">☕ Buy me a Coffee!</a>
</p>

# MANA System (Modular Ability & Networked Attributes)

## Introduction

The **MANA System** is a modular, extensible gameplay ability system designed for the **Godot Engine**. Inspired by Unreal Engine's Gameplay Ability System (GAS), it brings the power and flexibility of tag-driven gameplay mechanics to Godot while following native Godot architecture and conventions.

This plugin enables developers to create highly customizable abilities, effects, and gameplay logic using **component-based systems**. Core features include gameplay tags, attributes with regeneration and dependencies, effect stacking and modifiers, gameplay cues for audiovisual feedback, and ability handling with asynchronous gameplay tasks. MANA is designed to support both singleplayer and multiplayer projects and is fully integrated with Godot’s editor tools, making it intuitive to configure and maintain.

Whether you need a lightweight tag manager or a full-featured ability system, MANA allows you to use only what you need—each system works independently or as part of a unified gameplay framework.

## Systems

All main systems are component-based and can be used individually or together under the unified `ManaComponent`. Each system includes in-editor management panels for intuitive creation, editing, and organization of gameplay data.

### Main Systems

- **ManaTag**  
  A hierarchical tag system used for categorization, filtering, activation conditions, blocking, and more. Tags are used throughout the entire plugin to drive logic.

- **ManaAttribute**  
  Defines character or object attributes (like Health, Stamina, Mana) with support for regeneration, minimum/maximum clamping, and inter-attribute dependencies.

- **ManaCue**  
  Handles visual/audio effects in response to gameplay events (e.g., spawning particles, playing sounds), based on tag activation and cue type (Instant, Duration, Looping, Custom).

- **ManaEffect**  
  Applies attribute modifiers, grants or blocks tags, and executes conditional logic over time. Effects can be instant, timed, or infinite, with full stacking and removal behavior.

- **ManaAbility**  
  Defines gameplay abilities (e.g., spells, dashes, interactions) with optional costs, cooldowns, tasks, and activation requirements. Integrated with attributes, tags, and cues.

### Sub Systems

- **ManaTargetType**  
  Defines how targets are selected for abilities or effects (e.g., self, hit target, area, trace). Fully extensible for custom targeting logic.

- **ManaTask**  
  Supports asynchronous gameplay tasks inside abilities (e.g., delays, waiting for input, animations). Based on the UGameplayTask concept from UE5.

- **ManaRequirement**  
  Reusable tag or attribute-based condition checks used by abilities and effects to control activation, continuation, or removal.

- **ManaCooldownComponent**  
  Handles cooldowns for abilities using tag-based or ability-specific lockouts. Emits signals for cooldown started and finished events.

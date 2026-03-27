# P1-T2 Validation Report

**Task:** P1-T2 — Define Toy Data Model And Spawn Pipeline
**Date:** 2026-03-28
**Verdict:** PARTIAL

## Deliverable Status

- [x] Shared toy catalog expanded to expose full definitions for Ball, Pillow, Brick, and Vase
- [x] Archetype defaults and scale presets added to the shared catalog contract
- [x] Reusable spawned-toy runtime scene and script added under `scenes/game/` and `scripts/game/`
- [x] Sandbox spawn flow instantiates toys from catalog data into a dedicated runtime container
- [x] Spawn input accepts both mouse button presses and `InputEventScreenTouch`
- [ ] Runtime scene loading and live spawn behavior verified inside Godot 4

## Validation Performed

1. Reviewed `scripts/autoload/ToyCatalog.gd` to confirm the catalog now exposes complete toy definitions instead of ID-only placeholders.
2. Reviewed `scripts/game/ToyInstance.gd` and `scenes/game/ToyInstance.tscn` to confirm spawned toys use a reusable runtime scene with placeholder visuals and collision.
3. Reviewed `scripts/game/Sandbox.gd` and `scenes/game/Sandbox.tscn` to confirm toys are spawned under `SpawnedToys` and that mouse and touch input share the same spawn path.
4. Checked for local Godot binaries:
   - `which godot` → not found
   - `which godot4` → not found
5. Ran configured Flow quality gates from `.flow/params.yaml`:
   - `verify.tests` → passed as configured placeholder: `No automated tests configured yet; scaffold the Godot project first.`
   - `verify.lint` → passed as configured placeholder: `No automated lint configured yet; add a GDScript lint command after scaffolding.`

## Evidence

- `ToyCatalog` now merges scale presets, archetype defaults, and toy-specific fields into one returned definition.
- The sandbox preloads `res://scenes/game/ToyInstance.tscn` and spawns it from `GameState.selected_toy_id`.
- `_unhandled_input()` normalizes `InputEventMouseButton` and `InputEventScreenTouch` into the same `_spawn_selected_toy()` path.
- Spawned instances are added under `SpawnedToys`, keeping runtime toy nodes separate from UI nodes.

## Gaps And Limitations

- Runtime validation is blocked in this environment because no Godot executable is installed.
- Flow quality gates remain placeholders, so this task can only claim source-level verification rather than editor/runtime verification.

## Recommended Next Checks

1. Open the project in Godot 4 and confirm the sandbox can spawn all four configured placeholder toys without parse errors.
2. Replace the placeholder `verify.tests` and `verify.lint` commands during `P1-T3` so later tasks have real validation coverage.

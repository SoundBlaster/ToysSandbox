# P4-T1 Validation Report

**Task:** P4-T1 - Add Onboarding, Settings, And Local Persistence  
**Date:** 2026-03-28  
**Verdict:** PASS

## Deliverable Status

- [x] Replaced `SaveService` stub with file-backed load/save state in `user://settings.cfg` and default recovery.
- [x] Boot flow now hydrates `GameState` and `AudioService` from persisted settings on startup.
- [x] Main menu now exposes a settings overlay with music/sound sliders and tutorial reset control.
- [x] Sandbox now shows a first-launch onboarding overlay and persists tutorial dismissal.
- [x] Selected toy changes are persisted via `GameState.set_selected_toy_id(...)`.
- [x] Flow quality gates pass for configured `tests` and `lint` commands.

## Implementation Evidence

1. `scripts/autoload/SaveService.gd`
   - Added full persisted state schema: `music_volume`, `sound_volume`, `selected_toy_id`, `tutorial_dismissed`.
   - Added `load_state()`, `save_state()`, `update_state()`, and validation/sanitization helpers.
   - Added default-file recreation path for missing/corrupt files.
2. `scripts/boot/Boot.gd`
   - Loads persisted state at launch and applies state to `GameState` + `AudioService`.
3. `scripts/autoload/GameState.gd`
   - Added persisted-state application and explicit setter methods that write to `SaveService`.
4. `scenes/menu/MainMenu.tscn` + `scripts/menu/MainMenu.gd`
   - Added `Settings` button and overlay panel.
   - Added music/sound sliders with live preview + persistence.
   - Added `Reset Tutorial` action.
5. `scenes/game/Sandbox.tscn` + `scripts/game/Sandbox.gd`
   - Added onboarding overlay (`Quick Start`) with manual dismiss button.
   - Added auto-dismiss on first successful spawn and persisted dismissal state.

## Validation Performed

1. Ran configured quality gates from `.flow/params.yaml`:
   - `bash scripts/ci/flow_validate.sh tests` -> **PASS**
   - `bash scripts/ci/flow_validate.sh lint` -> **PASS**
2. Confirmed persistence and onboarding flows are wired through runtime code paths:
   - Boot load -> state hydrate.
   - Main menu settings -> SaveService updates.
   - Sandbox toy selection and onboarding dismiss -> SaveService updates.

## Manual Verification Protocol

Use this quick smoke flow in Godot editor/runtime:

1. Delete `user://settings.cfg` and launch app; enter sandbox.
2. Verify onboarding overlay appears with spawn/drag/reset guidance.
3. Spawn a toy once; verify onboarding hides.
4. Return to menu -> Settings; change audio sliders and click `Reset` tutorial.
5. Enter sandbox again; verify onboarding returns.
6. Select non-default toy, restart app, enter sandbox, verify selection restored.
7. Re-open settings and verify audio slider values restored.

## Acceptance Criteria Mapping

- **First launch teaches spawn, drag, and reset without heavy text** -> Implemented via sandbox onboarding overlay with three short hints and dismiss CTA.
- **Settings include music volume, sound volume, and tutorial reset** -> Implemented in `MainMenu` settings overlay with two sliders and `Reset Tutorial` action.
- **Last selected toy and audio settings survive app restart** -> Implemented via `SaveService` persisted state loaded by boot and updated from menu/sandbox interactions.

## Notes

- The existing non-blocking warning from validation (`ObjectDB instances leaked at exit`) remains unchanged and predates this task.

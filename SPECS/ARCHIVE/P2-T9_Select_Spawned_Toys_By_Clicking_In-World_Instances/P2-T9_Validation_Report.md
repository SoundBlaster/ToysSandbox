# P2-T9 Validation Report

**Task:** P2-T9 — Select Spawned Toys By Clicking In-World Instances  
**Date:** 2026-03-28  
**Verdict:** PASS

## Deliverable Status

- [x] In-world toy activation now synchronizes the selected toy definition back into shelf state.
- [x] Programmatic shelf synchronization avoids emitting the `ItemList.item_selected` signal, so controller-driven status text is preserved.
- [x] `ToyInstance.gd` exposes the configured toy identifier directly for deterministic shelf sync.
- [x] Curated Flow validation now explicitly covers `scripts/game/SandboxInteractionController.gd`.
- [x] Flow quality gates passed in this sandbox with redirected Godot user directories.

## Validation Performed

1. Selection sync verification:
   - Confirmed `Sandbox._set_active_toy()` still owns selection visuals and now also calls `_sync_shelf_selection_from_active_toy()` for valid active toys.
   - Confirmed `_sync_shelf_selection_from_active_toy()` resolves the live toy identifier, updates `GameState.selected_toy_id`, refreshes the selected label, and aligns the shelf `ItemList` selection.
   - Confirmed `_select_shelf_index()` blocks `item_selected` signals during programmatic UI synchronization to avoid replacing controller status messages such as "Selected active toy. Drag to move it."
2. Data flow verification:
   - Added `ToyInstance.get_toy_id()` so sandbox UI sync can read the configured catalog id without duplicating definition parsing logic.
   - Confirmed empty-space spawning behavior remains unchanged because the interaction controller still distinguishes picked toys from empty play-area presses before calling `_spawn_selected_toy()`.
3. Quality gates (configured commands, executed with redirected Godot user dirs due sandbox restrictions on default macOS user paths):
   - `HOME=/tmp/codex-godot-home XDG_CONFIG_HOME=/tmp/codex-godot-xdg XDG_DATA_HOME=/tmp/codex-godot-data bash scripts/ci/flow_validate.sh tests` → **PASS**
   - `HOME=/tmp/codex-godot-home XDG_CONFIG_HOME=/tmp/codex-godot-xdg XDG_DATA_HOME=/tmp/codex-godot-data bash scripts/ci/flow_validate.sh lint` → **PASS**

## Acceptance Criteria Mapping

- **Clicking/tapping an existing spawned toy marks it as the active selection without spawning a new toy** → Achieved; the interaction controller continues to pick existing toys first and `Sandbox._set_active_toy()` now completes the shelf sync path for that selection.
- **The selected in-world toy is visually highlighted and receives tool actions immediately** → Achieved; active-toy highlight ownership remains in `Sandbox._set_active_toy()` and subsequent tool actions still operate on the controller’s active toy reference.
- **Shelf selection updates to the matching toy definition when an in-world instance is selected** → Achieved; the shelf `ItemList` and `GameState.selected_toy_id` are updated from the active toy’s configured id.
- **Selection behavior remains consistent for both mouse and touch input paths** → Achieved at source level; both paths still use the same controller pointer press logic and now converge on the same active-toy shelf sync behavior.

## Notes

- Running the raw configured gate commands without redirected environment variables caused Godot 4.6.1 headless to crash when writing editor settings/log files under blocked sandbox paths. Redirecting Godot’s user/config/data directories into `/tmp` removed the environment-specific failure and allowed the project validations to complete normally.
- Godot still reports the existing non-blocking `ObjectDB instances leaked at exit` warning after successful validation.

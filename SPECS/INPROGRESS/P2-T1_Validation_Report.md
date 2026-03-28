# P2-T1 Validation Report

**Task:** P2-T1 — Build Sandbox Scene, Camera, Bounds, And Shelf UI  
**Date:** 2026-03-28  
**Verdict:** PASS

## Deliverable Status

- [x] Main menu keeps a visible `Play` action that transitions to `scenes/game/Sandbox.tscn`.
- [x] Sandbox includes floor + side bounds and a fixed `Camera2D` framing node.
- [x] Shelf UI is present as a right-side panel and remains non-blocking for the left play area.
- [x] Shelf lists all 8 planned MVP toys from the shared `ToyCatalog` source.
- [x] Shelf selection updates `GameState.selected_toy_id`, and spawn uses that selected toy.
- [x] Configured Flow quality gates pass.

## Validation Performed

1. Expanded `scripts/autoload/ToyCatalog.gd` with full MVP roster (Ball, Pillow, Brick, Vase, Balloon, Jelly Cube, Pot, Sticky Block) and supporting archetype defaults.
2. Updated `scenes/game/Sandbox.tscn` to include:
   - fixed `Camera2D`
   - left-side gameplay bounds (floor + walls)
   - right-side shelf panel with `ItemList`
3. Updated `scripts/game/Sandbox.gd` to:
   - populate shelf options from `ToyCatalog.list_ids()`
   - synchronize shelf selection with `GameState.selected_toy_id`
   - preserve spawn behavior from selected shelf toy
   - clamp spawn points to a dedicated play area that avoids shelf overlap
4. Ran `bash scripts/ci/flow_validate.sh tests`.
5. Ran `bash scripts/ci/flow_validate.sh lint`.

## Evidence

- `tests` mode finished with `Flow validation passed for tests.`
- `lint` mode finished with `Flow validation passed for lint.`
- Static diagnostics reported no errors in changed files.

## Acceptance Criteria Mapping

- **Main menu has a visible Play action that opens the sandbox scene** → retained `PlayButton` flow in `MainMenu.gd`.
- **Sandbox includes floor, side bounds, and non-blocking shelf UI** → implemented in `Sandbox.tscn` with dedicated shelf panel + constrained play area.
- **Shelf exposes the full planned toy catalog** → `ToyCatalog.gd` now provides all 8 toys and shelf binds directly to catalog IDs.

## Notes

- Icon-first visual shelf treatment and art fallback behavior remain in scope for `P2-T2`.

# P2-T1 — Build Sandbox Scene, Camera, Bounds, And Shelf UI

**Task ID:** P2-T1  
**Phase:** Core Sandbox  
**Priority:** P0  
**Dependencies:** P1-T2  
**Status:** Planned

## Objective

Implement a playable sandbox baseline that is reachable from the main menu, framed by a stable in-game camera, bounded by floor/walls for physics objects, and equipped with a non-blocking toy shelf UI that lists the full planned MVP toy catalog.

## Deliverables

- Main menu play flow reliably opens the sandbox scene.
- Sandbox scene includes floor and side-wall boundaries sized for the play area.
- Sandbox scene uses an explicit camera node with deterministic framing for gameplay.
- A shelf UI exists in sandbox and does not block core spawn interactions.
- Shelf lists all 8 planned MVP toys (Ball, Pillow, Brick, Vase, Balloon, Jelly Cube, Pot, Sticky Block), even when assets are placeholders.
- Selected shelf toy is reflected in runtime state used by spawn logic.

## Success Criteria

- The player can enter sandbox from main menu with one visible `Play` action.
- Spawned toy physics remain constrained by floor and side bounds.
- Camera framing is stable and does not drift with spawned object motion.
- Shelf remains visible and usable while leaving enough play area to spawn and observe toys.
- Full toy roster is visible/selectable from one authoritative catalog source.

## Acceptance Tests

1. Open main menu and activate `Play`; confirm scene transitions to `Sandbox.tscn`.
2. Inspect sandbox scene tree for camera + floor + left/right wall nodes.
3. Spawn toys and verify wall/floor collisions keep objects inside intended bounds.
4. Verify shelf UI lists 8 toys and the selected state updates GameState selection.
5. Run configured Flow gates:
   - `bash scripts/ci/flow_validate.sh tests`
   - `bash scripts/ci/flow_validate.sh lint`
6. Record outcomes in `SPECS/INPROGRESS/P2-T1_Validation_Report.md`.

## Test-First Plan

- Define the expected shelf-to-selection contract first: selecting a shelf item must update `GameState.selected_toy_id`.
- Define the expected catalog contract first: catalog listing must return 8 ordered toy IDs.
- Add/adjust scene/script wiring after contracts are explicit to keep runtime changes small and verifiable.

## Execution Plan

### Phase 1 — Data + State Readiness

| Item | Input | Output | Verification |
|------|-------|--------|--------------|
| Expand catalog to full MVP set | Existing `ToyCatalog.gd`, PRD toy roster | 8 toy definitions in stable order | Inspect IDs and list output in code |
| Preserve selected toy invariants | `GameState.gd`, catalog IDs | Safe selected toy fallback when missing | Runtime selection guard in sandbox init |

### Phase 2 — Scene Framing And Bounds

| Item | Input | Output | Verification |
|------|-------|--------|--------------|
| Add deterministic camera | `Sandbox.tscn` | Fixed `Camera2D` framing | Scene inspection + manual spawn test |
| Validate play bounds | Existing floor/walls and spawn clamp | Consistent sandbox collision envelope | Spawn near edges and observe containment |

### Phase 3 — Shelf UI And Integration

| Item | Input | Output | Verification |
|------|-------|--------|--------------|
| Build non-blocking shelf container | `Sandbox.tscn` UI tree | Shelf panel anchored to side | UI remains visible while play area stays usable |
| Bind shelf options to GameState | `Sandbox.gd`, `ToyCatalog.gd` | Button list with selected state | Selecting button changes status + spawn toy |
| Keep menu return flow intact | Existing back action | Back button still returns to menu | Click back and verify scene transition |

## Constraints And Decisions

- Keep shelf implementation lightweight (standard Godot controls, no custom theme dependency).
- Use placeholder text/buttons for catalog items; icon rendering is handled in follow-up tasks.
- Do not introduce persistence changes here beyond runtime `GameState` selection update.
- Keep spawn interaction path unchanged outside necessary UI integration.

## Verification Notes

- If local Godot runtime is unavailable, rely on validation script and source-level checks, and document any environment limits in validation report.

## Notes

- `P2-T2` will refine icon-first presentation and visual fallback behavior.
- `P2-T3` will layer interaction verbs on top of this baseline shelf + spawn flow.

---
**Archived:** 2026-03-28
**Verdict:** PASS

# P2-T2 — Wire Toy Presentation, Selection, And Spawn Preview

**Task ID:** P2-T2  
**Phase:** Core Sandbox  
**Priority:** P0  
**Dependencies:** P1-T3, P2-T1  
**Status:** Planned

## Objective Summary

Connect the shared toy catalog to both shelf presentation and world spawning so one selected toy state drives the entire flow. The shelf should become icon-first, each toy should provide a world visual configuration, and missing art must gracefully fall back to procedural placeholder silhouettes. The implementation must preserve the existing click/touch spawn interaction and avoid introducing regressions in scene loading or autoload contracts.

The main design decision is to keep toy visual metadata in `ToyCatalog` (single source of truth), while `Sandbox.gd` remains responsible for UI binding and `ToyInstance.gd` applies the runtime visual. This keeps future persistence and onboarding tasks aligned with a stable selection contract (`GameState.selected_toy_id`) and avoids duplicating toy definitions across scripts.

## Success Criteria And Acceptance Tests

### Success Criteria
- Shelf renders all catalog toys with icon-first presentation and a readable selected state.
- Spawned toys use per-catalog visual configuration (texture when available, placeholder silhouette when missing).
- Missing icon/world textures never break selection or spawning.
- Selection state stays synchronized between shelf UI, `GameState`, and spawn logic.

### Acceptance Tests
1. Open sandbox and verify shelf displays all toy entries with icon + label.
2. Select each toy and confirm the selected state is visible and updates `GameState.selected_toy_id`.
3. Spawn each toy; verify world visual reflects catalog mapping (texture if available, fallback silhouette otherwise).
4. Temporarily use a toy with missing texture paths and verify no runtime errors and a visible placeholder render.
5. Run quality gates:
   - `bash scripts/ci/flow_validate.sh tests`
   - `bash scripts/ci/flow_validate.sh lint`
6. Record outcomes in `SPECS/INPROGRESS/P2-T2_Validation_Report.md`.

## Test-First Plan

- Define catalog-level visual contract first (`icon_texture`, `world_texture`, fallback metadata), then wire consumers.
- Add script guards that treat missing resources as expected input, not exceptional failures.
- Validate scene/script instantiation through Flow CI gates before and after UI/visual wiring changes.
- Ensure selection invariants before visual polish: if UI state and `GameState` diverge, fail fast by re-syncing from catalog order.

## Hierarchical TODO Plan

### Phase 1 — Catalog Visual Metadata Contract

| Item | Inputs | Outputs | Verification |
|------|--------|---------|--------------|
| Add icon/world texture fields to toy definitions | `ToyCatalog.gd`, current toy roster | Per-toy visual metadata + placeholder-friendly defaults | Inspect dictionary contract and retrieval helpers |
| Add safe texture loading helper | Resource paths from catalog | Null-safe helper returning `Texture2D` or `null` | Missing files do not throw and preserve flow |

### Phase 2 — Shelf Presentation And Selection Sync

| Item | Inputs | Outputs | Verification |
|------|--------|---------|--------------|
| Upgrade shelf list to icon-first entries | `Sandbox.tscn`, `Sandbox.gd`, toy metadata | ItemList entries with icon + readable labels | Sandbox UI renders all entries with clear selected state |
| Preserve one-way selection contract | `GameState.selected_toy_id`, shelf interactions | Deterministic selection sync at startup and on user selection | Selection in UI always matches state and spawn target |

### Phase 3 — Spawn Visual Application And Fallbacks

| Item | Inputs | Outputs | Verification |
|------|--------|---------|--------------|
| Apply world texture when present | `ToyInstance.gd`, catalog metadata | Sprite-backed world render for mapped toy entries | Spawned toy uses mapped texture |
| Render placeholder silhouette when texture missing | Catalog fallback metadata | Distinct visible placeholder shape/color | Missing art still yields readable gameplay object |
| Keep label and shape behavior intact | Existing toy shape logic | No regression in collision/configuration path | Spawn and physics behavior remain stable |

## Constraints And Toolchain Notes

- Keep compatibility with current Godot 4 project conventions and validation scripts.
- Do not introduce external dependencies or plugin requirements.
- Preserve existing scene node contracts where possible to reduce migration risk.
- Continue supporting both mouse and touch spawn inputs.

## Notes

- Update `docs/godot-validation.md` only if validation commands or prerequisites change.
- `P2-T3` should consume this stabilized selection/visual contract for interaction verbs.
- Archive should include this PRD, validation report, and review artifact when complete.

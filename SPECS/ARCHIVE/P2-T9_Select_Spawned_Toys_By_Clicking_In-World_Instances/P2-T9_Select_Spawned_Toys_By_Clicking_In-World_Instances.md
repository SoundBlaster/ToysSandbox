# P2-T9 — Select Spawned Toys By Clicking In-World Instances

**Task ID:** P2-T9  
**Phase:** Core Sandbox  
**Priority:** P1  
**Dependencies:** P2-T2, P2-T6  
**Status:** Planned

## Objective Summary

Make already spawned toys selectable directly from the sandbox play area for both mouse and touch input. Selecting an in-world toy must update the active toy highlight immediately and synchronize the shelf selection so duplicate, resize, fan, and smash actions target the matching toy definition without forcing the player back to the shelf first.

This task should build on the existing interaction-controller picking path instead of adding a second selection system. The sandbox scene should remain the owner of shelf state and UI synchronization, while the interaction controller continues to own pointer gesture handling and active-toy transitions.

## Success Criteria And Acceptance Tests

### Success Criteria
- Clicking or tapping an existing spawned toy marks that toy as the active selection without spawning a new one.
- The selected in-world toy is visually highlighted and is used by follow-up tool actions immediately.
- Shelf selection updates to match the selected toy definition without overwriting the in-world status messaging.
- Mouse and touch paths continue to share one interaction model.

### Acceptance Tests
1. Spawn at least two different toy types, then click an existing toy and verify the shelf selection moves to that toy’s catalog entry.
2. After selecting an in-world toy, trigger duplicate, resize, fan, and smash and verify each action applies to the selected body.
3. Verify clicking empty space still spawns the currently selected shelf toy.
4. Run quality gates:
   - `bash scripts/ci/flow_validate.sh tests`
   - `bash scripts/ci/flow_validate.sh lint`
5. Record outcomes in `SPECS/INPROGRESS/P2-T9_Validation_Report.md`.

## Test-First Plan

- Reuse the existing `_pick_toy_at()` and controller pointer-press flow as the selection entry point.
- Update sandbox-owned active-toy handling so choosing an in-world toy also updates `GameState.selected_toy_id` and the `ItemList` shelf selection without emitting the shelf selection signal.
- Expose the selected toy identifier from `ToyInstance.gd` directly to avoid reconstructing UI state indirectly.
- Extend the curated validation resource list so the interaction controller script is part of baseline validation coverage.

## Hierarchical TODO Plan

### Phase 1 — Wire Selection Sync
| Item | Inputs | Outputs | Verification |
|------|--------|---------|--------------|
| Expose toy identifier from live toy instances | `ToyInstance.gd` configured definition state | `get_toy_id()` helper | Active selection can resolve the catalog entry deterministically |
| Sync shelf state from active in-world selection | `Sandbox.gd` active toy setter, `GameState`, shelf `ItemList` | Shelf and selected label update when world toy becomes active | Shelf highlight matches clicked/tapped toy |

### Phase 2 — Preserve Interaction Behavior
| Item | Inputs | Outputs | Verification |
|------|--------|---------|--------------|
| Avoid status-label regressions from UI sync | Current `_on_toy_selected()` signal behavior | Programmatic shelf selection that does not emit `item_selected` | Controller status text remains selection/drag focused |
| Preserve spawn-on-empty-space flow | Existing controller press logic | No regression to empty-space spawn behavior | Clicking empty play area still spawns selected toy |

### Phase 3 — Validate And Document
| Item | Inputs | Outputs | Verification |
|------|--------|---------|--------------|
| Execute Flow quality gates | `flow_validate.sh` tests/lint | PASS/FAIL results | Commands exit successfully or failures are documented |
| Produce validation report | Code diff + command results + manual checks | `P2-T9_Validation_Report.md` | Acceptance criteria explicitly mapped |

## Constraints And Toolchain Notes

- Keep the interaction-controller ownership split introduced in P2-T6.
- Avoid UI layout changes; this task is limited to selection behavior and synchronization.
- Preserve current drag threshold and spawn behavior for both mouse and touch input.
- Maintain Godot 4 compatibility and current save-state behavior for `selected_toy_id`.

## Notes

- If validation reveals friction around pointer-release semantics after selection, track it separately unless it directly blocks this task’s acceptance criteria.
